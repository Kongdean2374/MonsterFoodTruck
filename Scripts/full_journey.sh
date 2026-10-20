#!/bin/bash
set -euo pipefail
DEVICE=${1:?Simulator device ID is required}
mkdir -p build/QA_EVIDENCE/journey
STATE=$(xcrun simctl list devices --json | python3 -c 'import json,sys; d=sys.argv[1]; print(next(x["state"] for v in json.load(sys.stdin)["devices"].values() for x in v if x["udid"]==d))' "$DEVICE")
if [ "$STATE" != Booted ]; then xcrun simctl boot "$DEVICE"; fi
xcrun simctl bootstatus "$DEVICE" -b
open -a Simulator --args -CurrentDeviceUDID "$DEVICE"
xcrun simctl launch "$DEVICE" cc.chaihome.monsterfoodtruck > build/video-app-launch.txt
FRAME_READY=0
for ATTEMPT in {1..15}; do
  if xcrun simctl io "$DEVICE" screenshot build/QA_EVIDENCE/journey/recording-start.png > build/video-framebuffer.log 2>&1; then FRAME_READY=1; break; fi
  sleep 1
done
if [ "$FRAME_READY" != 1 ]; then echo 'No actual simulator framebuffer available for video' >&2; exit 1; fi
VIDEO_PID=
RECORDING_STOP_FAILED=0
stop_recording(){
  if [ -n "$VIDEO_PID" ]; then
    kill -INT "$VIDEO_PID" 2>/dev/null || true
    for ATTEMPT in {1..30}; do
      if ! kill -0 "$VIDEO_PID" 2>/dev/null; then break; fi
      sleep 1
    done
    if kill -0 "$VIDEO_PID" 2>/dev/null; then
      echo 'Recording did not finish after SIGINT; preserving test evidence and rejecting this recording' >&2
      RECORDING_STOP_FAILED=1
      kill -TERM "$VIDEO_PID" 2>/dev/null || true
      for ATTEMPT in {1..5}; do
        if ! kill -0 "$VIDEO_PID" 2>/dev/null; then break; fi
        sleep 1
      done
      if kill -0 "$VIDEO_PID" 2>/dev/null; then kill -KILL "$VIDEO_PID" 2>/dev/null || true; fi
    fi
    wait "$VIDEO_PID" || true
    VIDEO_PID=
  fi
}
trap stop_recording EXIT
python3 Scripts/start_recording.py "$DEVICE" build/QA_EVIDENCE/journey/normal-six-level-journey.mov > build/journey-recording.log 2>&1 &
VIDEO_PID=$!
STATUS=0
if xcodebuild test-without-building -project MonsterFoodTruck.xcodeproj -scheme MonsterFoodTruck -configuration Debug -destination "platform=iOS Simulator,id=$DEVICE" -parallel-testing-enabled NO -only-testing:MonsterFoodTruckUITests/FullJourneyTests -only-testing:MonsterFoodTruckUITests/ControlFlowTests -only-testing:MonsterFoodTruckUITests/PerformanceTests -resultBundlePath build/Journey.xcresult -derivedDataPath build/DerivedData CODE_SIGNING_ALLOWED=NO CURRENT_PROJECT_VERSION="${GITHUB_RUN_NUMBER:-1}" | tee build/journey.log; then
  STATUS=0
else
  STATUS=$?
fi
xcrun xcresulttool export attachments --path build/Journey.xcresult --output-path build/QA_EVIDENCE/journey/screenshots
xcrun xcresulttool get test-results summary --path build/Journey.xcresult > build/JOURNEY_TEST_SUMMARY.json
stop_recording
xcrun swift Scripts/probe_video.swift build/QA_EVIDENCE/journey/normal-six-level-journey.mov build/QA_EVIDENCE/journey/video-frames > build/QA_EVIDENCE/journey/VIDEO_METADATA.json
APP_DATA=$(xcrun simctl get_app_container "$DEVICE" cc.chaihome.monsterfoodtruck data)
REPLAY_DIR="$APP_DATA/Library/Application Support/MonsterFoodTruck/UIReplayEvidence/Journey"
if [ -d "$REPLAY_DIR" ]; then ditto "$REPLAY_DIR" build/QA_EVIDENCE/journey/actual-model-snapshots; fi
LATE_SAVE_DIR="$APP_DATA/Library/Application Support/MonsterFoodTruck/UIReplayEvidence"
mkdir -p build/QA_EVIDENCE/journey/actual-late-session
for SAVE_NAME in save-v1.json save-v1.backup.json; do
  if [ -f "$LATE_SAVE_DIR/$SAVE_NAME" ]; then cp "$LATE_SAVE_DIR/$SAVE_NAME" "build/QA_EVIDENCE/journey/actual-late-session/$SAVE_NAME"; fi
done
PERFORMANCE_REPORT="$APP_DATA/Library/Application Support/MonsterFoodTruck/Diagnostics/PERFORMANCE.json"
if [ -f "$PERFORMANCE_REPORT" ]; then
  cp "$PERFORMANCE_REPORT" build/QA_EVIDENCE/journey/PERFORMANCE.json
  python3 Scripts/summarize_performance.py build/QA_EVIDENCE/journey/PERFORMANCE.json build/QA_EVIDENCE/journey/PERFORMANCE_SUMMARY.json
fi
python3 - "$DEVICE" "$STATUS" "$RECORDING_STOP_FAILED" <<'PY'
import hashlib,json,os,subprocess,sys
from pathlib import Path
video=Path('build/QA_EVIDENCE/journey/normal-six-level-journey.mov')
report=dict(source_sha=subprocess.check_output(['git','rev-parse','HEAD'],text=True).strip(),simulator_id=sys.argv[1],test_exit=int(sys.argv[2]),method='FullJourneyTests: six levels through a DEBUG engineering command driver and normal foreground clock, followed in the same test by real late-level cloche taps with the driver disabled; unlocks restored from those actual saved settlements. Practice uses isolated storage. ControlFlowTests: real taps and deliberate no-input failure; no state injection. Neither is human playtesting.',audio='simctl video records picture only; does not verify sound or haptics',recording=video.name,recorded_bytes=video.stat().st_size if video.exists() else 0,workflow_run_id=os.getenv('GITHUB_RUN_ID'))
report['recording_required_forced_termination']=bool(int(sys.argv[3]))
if video.is_file():
 digest=hashlib.sha256()
 with video.open('rb') as stream:
  for chunk in iter(lambda:stream.read(1024*1024),b''):digest.update(chunk)
 report['recording_sha256']=digest.hexdigest()
Path('build/QA_EVIDENCE/journey/RECORDING_METHOD.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
saved=Path('build/QA_EVIDENCE/journey/actual-late-session/save-v1.json')
if saved.is_file():
 late=dict(source_sha=report['source_sha'],workflow_run_id=report['workflow_run_id'],method='Read-only export of the actual app save written by the driver-disabled late-level UI taps. Normal six-level engineering histories remain separately labelled.',path=saved.name,bytes=saved.stat().st_size,sha256=hashlib.sha256(saved.read_bytes()).hexdigest())
 (saved.parent/'PROVENANCE.json').write_text(json.dumps(late,ensure_ascii=False,indent=2)+'\n')
if int(sys.argv[2])==0:
 assert saved.is_file(),'Actual late-level UI save was not exported'
 session=json.loads(saved.read_text()).get('session')
 assert session and session['levelID']=='level_05' and not session['isPractice'],'Expected actual formal fifth-level UI session'
 assert all(next(o for o in session['orders'] if o['id']==order)['status']=='served' for order in ['L5-1','L5-2']),'Original two late-level customers were not both served'
 commands=[row['command'] for row in session['inputs']]
 assert sum('cover' in c for c in commands)>=3 and sum('uncover' in c for c in commands)>=2,'Actual cover/uncover/reuse commands missing from late UI save'
 assert any(c.get('garnish',{}).get('_0')=='L5-1' and c['garnish'].get('_1')=='香草芽' for c in commands),'Original actual herb command missing'
if report['recording_required_forced_termination']:raise SystemExit('Recording required forced termination; original XCTest summary and PNGs were preserved, but this is not a successful video validation')
if int(sys.argv[2])==0 and report['recorded_bytes']<1024:raise SystemExit('Normal-speed journey recording is missing or empty')
if int(sys.argv[2])==0 and len(list(Path('build/QA_EVIDENCE/journey/actual-model-snapshots').glob('actual-level_*.json')))!=6:raise SystemExit('Six actual runtime session histories were not exported')
if int(sys.argv[2])==0 and not Path('build/QA_EVIDENCE/journey/PERFORMANCE_SUMMARY.json').is_file():raise SystemExit('Actual twenty-entry performance measurements were not exported')
if int(sys.argv[2])==0:
 actual=sum(json.loads(p.read_text())['time'] for p in Path('build/QA_EVIDENCE/journey/actual-model-snapshots').glob('actual-level_*.json'))
 metadata=json.loads(Path('build/QA_EVIDENCE/journey/VIDEO_METADATA.json').read_text())
 if metadata['duration_seconds']<actual:raise SystemExit('Recording shorter than six actual runtime model histories')
PY
exit "$STATUS"
