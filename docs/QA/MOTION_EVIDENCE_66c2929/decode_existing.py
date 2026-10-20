#!/usr/bin/env python3
"""Download fixed original captures, hash-check them and decode on macOS."""
import hashlib
import json
import os
from pathlib import Path,PurePosixPath
import subprocess
import zipfile

REPO='Kongdean2374/MonsterFoodTruck'
assert os.environ['GITHUB_REPOSITORY']==REPO
root=Path('build/native-motion-decode');out=root/'review';out.mkdir(parents=True,exist_ok=True)
sources=[(12305138449,39510391658,'9a34d468b074799329dee99f80bb4ae44fe21231','6ec1acf0784a2f7c78b42641aa8533cfc411660f656231e6a7c4545459747573',['dark','light','soup','stew']),(12307030020,39512444370,'f8beae134e58094082500827726bc2ea538fd1a3','b4688e4fd12514a9fe8a23e9ce1f664668859e2705b03bf6f5afadfcbc0ff1cc',['crisp'])]
def sha(p):
    h=hashlib.sha256()
    with p.open('rb') as stream:
        for data in iter(lambda:stream.read(1024*1024),b''):h.update(data)
    return h.hexdigest()
receipts=[]
for artifact,run,harness,digest,phases in sources:
    meta=json.loads(subprocess.check_output(['gh','api',f'repos/{REPO}/actions/artifacts/{artifact}'],text=True))
    assert meta['workflow_run']['id']==run and meta['workflow_run']['head_sha']==harness
    assert meta['digest']=='sha256:'+digest
    archive=root/(str(artifact)+'.zip')
    with archive.open('wb') as stream:subprocess.run(['gh','api',f'repos/{REPO}/actions/artifacts/{artifact}/zip'],stdout=stream,check=True)
    assert sha(archive)==digest
    base=root/str(artifact);base.mkdir(exist_ok=True)
    with zipfile.ZipFile(archive) as z:
        for name in z.namelist():
            p=PurePosixPath(name);assert not p.is_absolute() and '..' not in p.parts
        z.extractall(base)
    provenance=json.loads((base/'SOURCE_PROVENANCE.json').read_text())
    assert provenance['candidate_source_sha']=='66c2929dd05c28af1b0c3ec8a79805446c6dc023'
    assert provenance['harness_sha']==harness
    for phase in phases:
        native=json.loads((base/phase/'TEST_SUMMARY.json').read_text())
        assert native['passedTests']==1 and native['failedTests']==0 and native['skippedTests']==0
        movie=base/phase/(phase+'.mov');dest=out/phase
        first,last=(60,320) if phase=='dark' else (140,420) if phase=='light' else (-1,-1)
        subprocess.run(['xcrun','swift','docs/QA/MOTION_EVIDENCE_66c2929/decode_original_frames.swift',str(movie),str(dest),str(first),str(last)],check=True)
        receipts.append(dict(phase=phase,original_artifact_id=artifact,original_run_id=run,original_harness_sha=harness,original_archive_sha256=digest,original_movie_sha256=sha(movie),original_movie_bytes=movie.stat().st_size,selected_contiguous_reader_frames=[first,last] if first>=0 else None,native_test_summary=native))
files=[dict(path=str(p.relative_to(out)),bytes=p.stat().st_size,sha256=sha(p)) for p in sorted(out.rglob('*')) if p.is_file()]
(out/'PROVENANCE.json').write_text(json.dumps(dict(candidate_source_sha='66c2929dd05c28af1b0c3ec8a79805446c6dc023',exporter_sha=os.environ['GITHUB_SHA'],exporter_run_id=os.environ['GITHUB_RUN_ID'],method='Read-only Apple decoder export of already-recorded native movies; no App build, simulator run, test retry, image editing or IPA packaging. Original failed run remains failed. No replacement or regenerated frames.',sources=receipts,files=files),ensure_ascii=False,indent=2)+'\n')
assert sum(p.stat().st_size for p in out.rglob('*') if p.is_file())<400*1024*1024
