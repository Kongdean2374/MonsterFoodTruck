#!/usr/bin/env python3
"""Collect this run's successful native evidence before archiving the same SHA.

No tests, image processing, clock changes or result rewriting occur here.
The separate device job downloads the original archives, verifies their digest
and source, and preserves original summaries, PNGs, movies and session histories.
"""
import hashlib
import json
import os
import re
import subprocess
import zipfile
from pathlib import Path, PurePosixPath

REPO = 'Kongdean2374/MonsterFoodTruck'
SCOPES = {
    'validate': ['TEST_RESULT_SUMMARY.json', 'JOURNEY_TEST_SUMMARY.json'],
    'layout-small': ['LAYOUT_TEST_SUMMARY_small.json'],
    'layout-large': ['LAYOUT_TEST_SUMMARY_large.json'],
}
PRIMARY_FILES = {'ENVIRONMENT.txt', 'SIMULATOR_APP_INFO.plist', 'SIMULATOR_APP_IDENTITY.json', 'SIMULATOR_BUNDLE_PROBE.txt', 'TEST_SUMMARY.md'}


def sha256(path):
    digest = hashlib.sha256()
    with path.open('rb') as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b''):
            digest.update(chunk)
    return digest.hexdigest()


def collect(archive, metadata, source_sha, run_id, scope, output):
    assert metadata['workflow_run']['id'] == run_id, 'Artifact belongs to another workflow run'
    assert metadata['workflow_run']['head_sha'] == source_sha, 'Artifact belongs to another source SHA'
    digest = sha256(archive)
    assert metadata['digest'] == 'sha256:' + digest, 'Artifact archive checksum differs from GitHub metadata'
    files = []
    with zipfile.ZipFile(archive) as source:
        states = [name for name in source.namelist() if name.endswith('VALIDATION_STATUS.json') and '.xcresult/' not in name]
        assert len(states) == 1, 'Missing or ambiguous original validation status'
        state = json.loads(source.read(states[0]))
        assert state['source_sha'] == source_sha, 'Native evidence source SHA mismatch'
        assert state['exit_status'] == 0 and state['last_stage'] == 'complete', 'Native validation did not finish successfully'
        prefix = states[0][:-len('VALIDATION_STATUS.json')]
        summaries = {}
        for name in SCOPES[scope]:
            result = json.loads(source.read(prefix + name))
            assert result['passedTests'] > 0 and result['failedTests'] == 0 and result['skippedTests'] == 0, 'Required native scope has failures, skips or no passes: ' + name
            summaries[name] = {key: result[key] for key in ('passedTests', 'failedTests', 'skippedTests')}
        if scope == 'validate':
            for name in PRIMARY_FILES:
                assert prefix + name in source.namelist(), 'Missing primary evidence: ' + name
        for entry in source.infolist():
            if entry.is_dir() or not entry.filename.startswith(prefix):
                continue
            relative = PurePosixPath(entry.filename[len(prefix):])
            assert not relative.is_absolute() and '..' not in relative.parts, 'Unsafe artifact path'
            selected = (str(relative) in SCOPES[scope]
                        or (scope == 'validate' and str(relative) in PRIMARY_FILES)
                        or (relative.parts[0] == 'QA_EVIDENCE' and relative.suffix in {'.png', '.json', '.txt', '.mov', '.mp4'}))
            if not selected:
                continue
            target = output / str(relative)
            target.parent.mkdir(parents=True, exist_ok=True)
            with source.open(entry) as incoming, target.open('wb') as outgoing:
                for chunk in iter(lambda: incoming.read(1024 * 1024), b''):
                    outgoing.write(chunk)
            files.append({'path': str(relative), 'bytes': entry.file_size, 'sha256': sha256(target)})
        assert any(file['path'].endswith('.png') and file['bytes'] > 0 for file in files), 'No original App PNGs in required scope'
        layout_environment = source.read(prefix + 'LAYOUT_ENVIRONMENT.txt').decode() if scope != 'validate' else None
    return dict(scope=scope, artifact_id=metadata['id'], artifact_name=metadata['name'], archive_sha256=digest,
                original_status=state, native_summaries=summaries, files=files, layout_environment=layout_environment)


def api(endpoint):
    return json.loads(subprocess.check_output(['gh', 'api', 'repos/' + REPO + endpoint], text=True))


def main():
    assert os.environ['GITHUB_REPOSITORY'] == REPO
    run_id = int(os.environ['GITHUB_RUN_ID'])
    source_sha = os.environ['GITHUB_SHA']
    assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == source_sha
    run = api('/actions/runs/' + str(run_id))
    assert run['head_sha'] == source_sha and run['head_branch'] in {'main', 'integration/full-game'}
    jobs = api('/actions/runs/' + str(run_id) + '/jobs?per_page=100')['jobs']
    for scope in SCOPES:
        matches = [job for job in jobs if job['name'] == scope]
        assert len(matches) == 1 and matches[0]['status'] == 'completed' and matches[0]['conclusion'] == 'success', 'Required source job is not successful: ' + scope
    output = Path('build')
    downloads = output / 'validated-artifacts'
    downloads.mkdir(parents=True, exist_ok=True)
    available = api('/actions/runs/' + str(run_id) + '/artifacts?per_page=100')['artifacts']
    collected = []
    for scope in SCOPES:
        name = ('validation' if scope == 'validate' else scope) + '-' + str(run['run_number']) + '-' + source_sha
        matches = [artifact for artifact in available if artifact['name'] == name and not artifact['expired']]
        assert len(matches) == 1, 'Missing or ambiguous successful source artifact: ' + name
        metadata = matches[0]
        archive = downloads / (scope + '.zip')
        with archive.open('wb') as stream:
            download = subprocess.run(['gh', 'api', f'repos/{REPO}/actions/artifacts/{metadata["id"]}/zip'], stdout=stream, stderr=subprocess.PIPE)
        if download.returncode:
            raise SystemExit(re.sub(r'https?://\S+', '[download URL]', download.stderr.decode(errors='replace')))
        collected.append(collect(archive, metadata, source_sha, run_id, scope, output))
        archive.unlink()
    journey = output / 'QA_EVIDENCE/journey'
    assert (journey / 'normal-six-level-journey.mov').stat().st_size > 1024
    assert len(list((journey / 'actual-model-snapshots').glob('actual-level_*.json'))) == 6
    assert (journey / 'PERFORMANCE_SUMMARY.json').is_file()
    (output / 'LAYOUT_ENVIRONMENT.txt').write_text('\n'.join(item['scope'] + '\n' + item['layout_environment'] for item in collected if item['layout_environment']))
    report = dict(source_sha=source_sha, workflow_run_id=run_id,
                  method='Same-run native results and original App evidence assembled without rerunning tests; original archive digests and native summaries retained.', sources=collected)
    (output / 'VALIDATION_ASSEMBLY.json').write_text(json.dumps(report, ensure_ascii=False, indent=2) + '\n')
    subprocess.run(['python3', 'Scripts/validation_status.py', '0', 'complete'], check=True)
    print('Verified same-run native evidence for device archive: ' + source_sha)


if __name__ == '__main__':
    main()
