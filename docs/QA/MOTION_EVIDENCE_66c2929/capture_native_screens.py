#!/usr/bin/env python3
"""Direct simulator screenshots, without a video encoder or pixel edits."""
import hashlib
import json
from pathlib import Path
import struct
import subprocess
import sys
import time

device,runner,phase,destination=sys.argv[1:]
out=Path(destination);out.mkdir(parents=True,exist_ok=True)
deadline=time.monotonic()+180
marker=None
while time.monotonic()<deadline:
    result=subprocess.run(['xcrun','simctl','get_app_container',device,runner,'data'],capture_output=True,text=True)
    if result.returncode==0:
        candidate=Path(result.stdout.strip())/'Documents'/f'MFT-dense-{phase}.json'
        if candidate.exists():marker=candidate;break
    time.sleep(0.2)
assert marker is not None,'UI-test runner did not publish the native capture marker'
ready=json.loads(marker.read_text());assert ready['background']==phase
assert 0<=time.time()-ready['ready_wall_seconds']<15,'Stale marker, not the current test'
rows=[];ack=marker.with_suffix('.ack');end=None
while end is None or time.monotonic()<end:
    file=out/f'actual-screen-{len(rows):04d}.png';start=time.time()
    result=subprocess.run(['xcrun','simctl','io',device,'screenshot',str(file)],capture_output=True,text=True)
    finish=time.time();assert result.returncode==0,result.stderr
    data=file.read_bytes();assert data[:8]==b'\x89PNG\r\n\x1a\n' and struct.unpack('>II',data[16:24])==(750,1334)
    rows.append(dict(file=file.name,capture_started_wall_seconds=start,capture_completed_wall_seconds=finish,bytes=len(data),sha256=hashlib.sha256(data).hexdigest()))
    if end is None:
        # A real baseline screenshot now exists; allow the UI test's first tap.
        ack.write_text(str(finish));end=time.monotonic()+6
assert len(rows)>=12,'Insufficient direct native screenshots'
gaps=[b['capture_started_wall_seconds']-a['capture_started_wall_seconds'] for a,b in zip(rows,rows[1:])]
report=dict(phase=phase,method='Direct xcrun simctl io screenshot, with no recordVideo encoder running. Original PNG bytes, original dimensions and each request start/completion wall time preserved. Baseline acknowledged before real UI tap; capture continues for six seconds. No image editing, alpha cleanup, rescaling, overlays, seek requests, generated frames or assumed nominal FPS.',ready_marker=ready,screenshots=rows,max_capture_start_gap_seconds=max(gaps),scope='Dense real screenshots of the fixed App existing DEBUG ArtReview first-row rigs. Capture timestamp is a bounded wall-time interval, not a movie PTS or an inferred animation phase. No art verdict or all-species gameplay assertion.')
(out/'DIRECT_SCREENS.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
print(json.dumps(dict(phase=phase,actual_direct_pngs=len(rows),max_capture_start_gap_seconds=max(gaps))))
