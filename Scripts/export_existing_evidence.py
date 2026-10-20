#!/usr/bin/env python3
"""Read an existing artifact; export its original small review files, never tests."""
import hashlib
import json
import os
import re
import subprocess
import zipfile
from pathlib import Path, PurePosixPath

REPO='Kongdean2374/MonsterFoodTruck'
artifact_id=os.environ.get('MFT_SOURCE_ARTIFACT','')
if not re.fullmatch(r'[1-9][0-9]*',artifact_id):raise SystemExit('A numeric original artifact ID is required')
root=Path('build/existing-evidence');root.mkdir(parents=True,exist_ok=True)
out=root/'review';out.mkdir(exist_ok=True)
metadata=json.loads(subprocess.check_output(['gh','api',f'repos/{REPO}/actions/artifacts/{artifact_id}'],text=True))
run_id=metadata['workflow_run']['id']
run=json.loads(subprocess.check_output(['gh','api',f'repos/{REPO}/actions/runs/{run_id}'],text=True))
archive=root/'original.zip'
with archive.open('wb') as stream:
    download=subprocess.run(['gh','api',f'repos/{REPO}/actions/artifacts/{artifact_id}/zip'],stdout=stream,stderr=subprocess.PIPE)
if download.returncode:
    raise SystemExit(re.sub(r'https?://\S+','[download URL]',download.stderr.decode(errors='replace')))
digest=hashlib.sha256()
with archive.open('rb') as stream:
    for chunk in iter(lambda:stream.read(1024*1024),b''):digest.update(chunk)
if metadata.get('digest'):assert metadata['digest']=='sha256:'+digest.hexdigest(),'Original artifact archive checksum differs from GitHub metadata'
top_names={'ENVIRONMENT.txt','TEST_RESULT_SUMMARY.json','JOURNEY_TEST_SUMMARY.json','VALIDATION_STATUS.json','TEST_SUMMARY.md','SIMULATOR_APP_IDENTITY.json','SIMULATOR_APP_INFO.plist','SIMULATOR_BUNDLE_PROBE.txt','LAYOUT_TEST_SUMMARY_small.json','LAYOUT_TEST_SUMMARY_large.json','LAYOUT_ENVIRONMENT.txt'}
files=[];total=0
with zipfile.ZipFile(archive) as source:
    status_names=[n for n in source.namelist() if n.endswith('VALIDATION_STATUS.json') and '.xcresult/' not in n]
    assert len(status_names)==1,'Original source status is missing or ambiguous'
    status=json.loads(source.read(status_names[0]));assert status['source_sha']==run['head_sha'],'Original evidence source differs from its workflow run'
    prefix=status_names[0][:-len('VALIDATION_STATUS.json')]
    for entry in source.infolist():
        if entry.is_dir() or not entry.filename.startswith(prefix):continue
        relative=PurePosixPath(entry.filename[len(prefix):])
        assert not relative.is_absolute() and '..' not in relative.parts,'Unsafe artifact path'
        selected=(str(relative) in top_names or (relative.parts[0]=='QA_EVIDENCE' and relative.suffix in {'.png','.json','.txt'}))
        if not selected:continue
        total+=entry.file_size;assert total<400*1024*1024,'Original review files exceed the explicit review budget; nothing is silently omitted'
        data=source.read(entry);target=out/str(relative);target.parent.mkdir(parents=True,exist_ok=True);target.write_bytes(data)
        files.append({'path':str(relative),'bytes':len(data),'sha256':hashlib.sha256(data).hexdigest()})
assert any(f['path'].endswith('.png') for f in files),'No original App PNGs available'
provenance={'method':'Read-only export of an existing GitHub artifact. No build, test rerun, image editing or IPA packaging. Original test failures and counts are preserved.','repository':REPO,'original_artifact_id':int(artifact_id),'original_artifact_name':metadata['name'],'original_archive_sha256':digest.hexdigest(),'original_workflow_run_id':run_id,'original_run_status':run['status'],'original_run_conclusion':run['conclusion'],'original_source_sha':run['head_sha'],'original_validation_status':status,'files':files}
(out/'EXPORT_PROVENANCE.json').write_text(json.dumps(provenance,ensure_ascii=False,indent=2)+'\n')
print(json.dumps({k:provenance[k] for k in ['method','original_artifact_id','original_workflow_run_id','original_source_sha','original_validation_status']},ensure_ascii=False,indent=2))
if os.environ.get('GITHUB_STEP_SUMMARY'):
    with open(os.environ['GITHUB_STEP_SUMMARY'],'a') as stream:
        stream.write(f"Existing evidence export only; no tests or IPA produced. Original run: https://github.com/{REPO}/actions/runs/{run_id}\n\nOriginal source: `{run['head_sha']}`; original run: **{run['conclusion'] or run['status']}**. See unchanged native summaries and EXPORT_PROVENANCE.json.\n")
