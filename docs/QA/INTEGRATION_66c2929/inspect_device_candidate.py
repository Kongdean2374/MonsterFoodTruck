#!/usr/bin/env python3
"""Read the downloaded unsigned candidate itself; never modify app or images."""
import hashlib
import importlib.util
import json
import plistlib
import struct
import subprocess
import sys
import tempfile
import zipfile
from pathlib import Path, PurePosixPath

delivery, expected_sha, expected_run, output = Path(sys.argv[1]), sys.argv[2], int(sys.argv[3]), Path(sys.argv[4])
repository = Path(subprocess.check_output(['git', 'rev-parse', '--show-toplevel'], text=True).strip())
checksums = {}
for line in (delivery / 'SHA256SUMS.txt').read_text().splitlines():
    digest, name = line.split('  ', 1)
    assert Path(name).name == name and name not in checksums
    actual = hashlib.sha256((delivery / name).read_bytes()).hexdigest()
    assert actual == digest, 'Delivery checksum mismatch: ' + name
    checksums[name] = actual
assert set(checksums) == {p.name for p in delivery.iterdir() if p.is_file() and p.name != 'SHA256SUMS.txt'}
manifest = json.loads((delivery / 'BUILD_MANIFEST.json').read_text())
assert manifest['source_sha'] == expected_sha and int(manifest['workflow_run_id']) == expected_run
assert manifest['signature'] == 'unsigned' and manifest['architectures'] == ['arm64']
ipa = delivery / manifest['ipa']
assert checksums[ipa.name] == manifest['ipa_sha256']
subprocess.run(['git', 'diff', '--exit-code', expected_sha, '--', 'MonsterFoodTruck/Resources'], cwd=repository, check=True, stdout=subprocess.PIPE)
spec = importlib.util.spec_from_file_location('verify_app', repository / 'Scripts/verify_app.py')
verifier = importlib.util.module_from_spec(spec)
spec.loader.exec_module(verifier)
with tempfile.TemporaryDirectory(prefix='mft-read-ipa-') as temporary:
    with zipfile.ZipFile(ipa) as archive:
        for name in archive.namelist():
            path = PurePosixPath(name)
            assert not path.is_absolute() and '..' not in path.parts
            assert path.parts[:2] == ('Payload', 'MonsterFoodTruck.app') or name == 'Payload/'
            assert not name.endswith(('.mobileprovision', '.p12', '.key')) and '_CodeSignature' not in path.parts
        assert archive.testzip() is None
        archive.extractall(temporary)
    app = Path(temporary) / 'Payload/MonsterFoodTruck.app'
    info = plistlib.loads((app / 'Info.plist').read_bytes())
    assert info == plistlib.loads((delivery / 'DEVICE_APP_INFO.plist').read_bytes())
    identity = verifier.inspect(app, 'iPhoneOS', repository / 'MonsterFoodTruck/Resources')
    assert info['CFBundleVersion'] == str(manifest['build']) and info['CFBundleShortVersionString'] == manifest['version']
    binary = (app / info['CFBundleExecutable']).read_bytes()
    magic, cpu, subtype, filetype, commands, command_bytes, flags, reserved = struct.unpack_from('<8I', binary)
    assert magic == 0xfeedfacf and cpu == 0x0100000c and filetype == 2
    assert 32 + command_bytes <= len(binary)
    offset, platforms, command_ids = 32, [], []
    for _ in range(commands):
        command, size = struct.unpack_from('<2I', binary, offset)
        assert size >= 8 and offset + size <= 32 + command_bytes
        command_ids.append(command)
        if command == 0x32:
            assert size >= 24
            platform, minimum, sdk, tools = struct.unpack_from('<4I', binary, offset + 8)
            platforms.append(dict(platform=platform, minimum_os=f'{minimum >> 16}.{minimum >> 8 & 255}.{minimum & 255}', sdk=f'{sdk >> 16}.{sdk >> 8 & 255}.{sdk & 255}'))
        offset += size
    assert offset == 32 + command_bytes and 0x1d not in command_ids
    assert len(platforms) == 1 and platforms[0]['platform'] == 2 and platforms[0]['minimum_os'] == '17.0.0'
    binary_sha256 = hashlib.sha256(binary).hexdigest()
scopes = {}
for name in ['TEST_RESULT_SUMMARY.json', 'JOURNEY_TEST_SUMMARY.json', 'LAYOUT_TEST_SUMMARY_small.json', 'LAYOUT_TEST_SUMMARY_large.json']:
    result = json.loads((delivery / name).read_text())
    assert result['passedTests'] > 0 and result['failedTests'] == result['skippedTests'] == 0
    scopes[name] = {k: result[k] for k in ['passedTests', 'failedTests', 'skippedTests']}
assembly = json.loads((delivery / 'VALIDATION_ASSEMBLY.json').read_text())
assert assembly['source_sha'] == expected_sha and int(assembly['workflow_run_id']) == expected_run
assert {s['scope'] for s in assembly['sources']} == {'validate', 'layout-small', 'layout-large'}
index = json.loads((delivery / 'QA_EVIDENCE_INDEX.json').read_text())
assert index['source_sha'] == expected_sha and any(f['path'].endswith('.png') and f['bytes'] > 0 for f in index['files'])
report = dict(source_sha=expected_sha, workflow_run_id=expected_run, method='Read-only inspection of downloaded candidate checksum files, actual IPA ZIP, actual App plist/resources and actual executable load commands on Linux. Not device installation, signature acceptance, human playtesting or Dot approval.', delivery_files_verified=len(checksums), ipa=ipa.name, ipa_bytes=ipa.stat().st_size, ipa_sha256=checksums[ipa.name], binary_sha256=binary_sha256, actual_app_identity=identity, macho_cpu='arm64', macho_platforms=platforms, signature_load_command='absent', native_scopes=scopes, original_evidence_files=len(index['files']))
output.write_text(json.dumps(report, ensure_ascii=False, indent=2) + '\n')
print(json.dumps({k: report[k] for k in ['source_sha', 'ipa', 'ipa_bytes', 'ipa_sha256', 'delivery_files_verified', 'macho_platforms', 'native_scopes']}, ensure_ascii=False, indent=2))
