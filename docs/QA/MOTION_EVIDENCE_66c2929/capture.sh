#!/bin/bash
set -euo pipefail
MFT_APP_ROOT=${1:?Source checkout required}
MFT_QA_ROOT=${2:?Evidence checkout required}
MFT_HARNESS="$MFT_QA_ROOT/docs/QA/MOTION_EVIDENCE_66c2929"
MFT_OUTPUT="$MFT_QA_ROOT/build/motion-evidence"
MFT_REVIEW="$MFT_OUTPUT/review"
mkdir -p "$MFT_REVIEW"
cd "$MFT_APP_ROOT"
test "$(git rev-parse HEAD)" = 66c2929dd05c28af1b0c3ec8a79805446c6dc023
test -z "$(git status --porcelain --untracked-files=no)"
{
  echo "candidate_source_sha=$(git rev-parse HEAD)"
  echo "harness_sha=${MFT_HARNESS_SHA:?}"
  xcodebuild -version
  xcrun swift --version
  xcrun simctl list runtimes
} > "$MFT_REVIEW/ENVIRONMENT.txt"
bash Scripts/prepare_assets.sh
cp build/icon-normalization.txt "$MFT_REVIEW/icon-normalization.txt"
python3 Scripts/generate_project.py
git diff --exit-code -- MonsterFoodTruck.xcodeproj
cp "$MFT_HARNESS/ArtReviewTests.swift" UITests/ArtReviewTests.swift
python3 - "$MFT_QA_ROOT" "$MFT_REVIEW" <<'PY'
import hashlib,json,os,subprocess,sys
from pathlib import Path
qa,out=map(Path,sys.argv[1:]);candidate='66c2929dd05c28af1b0c3ec8a79805446c6dc023'
seed=qa/'docs/QA/INTEGRATION_66c2929/QA_EVIDENCE/journey/actual-late-session'
receipt=json.loads((seed/'PROVENANCE.json').read_text())
assert receipt['source_sha']==candidate
assert hashlib.sha256((seed/'save-v1.json').read_bytes()).hexdigest()==receipt['sha256']
report=dict(candidate_source_sha=candidate,candidate_build=25,harness_sha=os.environ['MFT_HARNESS_SHA'],capture_cases=os.environ.get('MFT_CAPTURE_CASES','all'),workflow_run_id=os.environ['GITHUB_RUN_ID'],method='Only a separate UI-test harness is overlaid on the fixed candidate checkout. App source, project, resources and game clocks unchanged. Explicit capture_cases records all five bounded cases or only the missing crisp case; no six-level replay, new IPA or full-game acceptance.',harness_file='UITests/ArtReviewTests.swift',harness_sha256=hashlib.sha256(Path('UITests/ArtReviewTests.swift').read_bytes()).hexdigest(),original_harness_git_blob=subprocess.check_output(['git','rev-parse',candidate+':UITests/ArtReviewTests.swift'],text=True).strip(),seed_save=receipt,seed_method='Unmodified actual save earned in source 66c2929, copied to the isolated simulator before each recipe. Unlocks are restored progress, not a fresh-user unlock walkthrough or injected order/score state.',audio='Native simctl picture only; hearing and haptics unverified.')
(out/'SOURCE_PROVENANCE.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
PY
xcrun simctl list devices available --json > "$MFT_REVIEW/DEVICES.json"
MFT_DEVICE=$(python3 - "$MFT_REVIEW/DEVICES.json" <<'PY'
import json,sys
d=json.load(open(sys.argv[1]))['devices']
c=[x for runtime,items in d.items() if runtime=='com.apple.CoreSimulator.SimRuntime.iOS-18-5' for x in items if x.get('isAvailable') and x['name']=='iPhone SE (3rd generation)']
assert len(c)==1,'Expected the original small iOS 18.5 simulator'
print(c[0]['udid'])
PY
)
xcodebuild build-for-testing -project MonsterFoodTruck.xcodeproj -scheme MonsterFoodTruck -configuration Debug -destination "platform=iOS Simulator,id=$MFT_DEVICE" -derivedDataPath "$MFT_OUTPUT/DerivedData" CODE_SIGNING_ALLOWED=NO CURRENT_PROJECT_VERSION=25 | tee "$MFT_OUTPUT/build.log"
MFT_APP="$MFT_OUTPUT/DerivedData/Build/Products/Debug-iphonesimulator/MonsterFoodTruck.app"
cp "$MFT_APP/Info.plist" "$MFT_REVIEW/SIMULATOR_APP_INFO.plist"
python3 Scripts/verify_app.py "$MFT_APP" --platform iPhoneSimulator --resources MonsterFoodTruck/Resources --output "$MFT_REVIEW/SIMULATOR_APP_IDENTITY.json"
MFT_DEVICE_STATE=$(xcrun simctl list devices --json | python3 -c 'import json,sys; print(next(d["state"] for a in json.load(sys.stdin)["devices"].values() for d in a if d["udid"]==sys.argv[1]))' "$MFT_DEVICE")
if [ "$MFT_DEVICE_STATE" != Booted ]; then xcrun simctl boot "$MFT_DEVICE"; fi
xcrun simctl bootstatus "$MFT_DEVICE" -b
open -a Simulator --args -CurrentDeviceUDID "$MFT_DEVICE"
xcrun simctl install "$MFT_DEVICE" "$MFT_APP"
MFT_APP_DATA=$(xcrun simctl get_app_container "$MFT_DEVICE" cc.chaihome.monsterfoodtruck data)
MFT_SEED="$MFT_QA_ROOT/docs/QA/INTEGRATION_66c2929/QA_EVIDENCE/journey/actual-late-session"
MFT_VIDEO_PID=
MFT_FORCED_STOP=0
stop_recording(){
  if [ -n "$MFT_VIDEO_PID" ]; then
    kill -INT "$MFT_VIDEO_PID" 2>/dev/null || true
    for MFT_WAIT in {1..30}; do if ! kill -0 "$MFT_VIDEO_PID" 2>/dev/null; then break; fi; sleep 1; done
    if kill -0 "$MFT_VIDEO_PID" 2>/dev/null; then MFT_FORCED_STOP=1; kill -TERM "$MFT_VIDEO_PID" 2>/dev/null || true; fi
    for MFT_WAIT in {1..5}; do if ! kill -0 "$MFT_VIDEO_PID" 2>/dev/null; then break; fi; sleep 1; done
    if kill -0 "$MFT_VIDEO_PID" 2>/dev/null; then MFT_FORCED_STOP=1; kill -KILL "$MFT_VIDEO_PID" 2>/dev/null || true; fi
    wait "$MFT_VIDEO_PID" || true;MFT_VIDEO_PID=
  fi
}
trap stop_recording EXIT
MFT_ANY_FAILED=0
case "${MFT_CAPTURE_CASES:-all}" in
  all) MFT_SPECS="dark:testDarkContinuousMotion light:testLightContinuousMotion soup:testSoupTransitions stew:testStewRecoveryTransitions crisp:testCrispTransitions";;
  crisp) MFT_SPECS="crisp:testCrispTransitions";;
  *) echo "Unrecognized explicit capture scope" >&2;exit 1;;
esac
for MFT_SPEC in $MFT_SPECS; do
  MFT_PHASE=${MFT_SPEC%%:*};MFT_METHOD=${MFT_SPEC#*:};MFT_PHASE_OUT="$MFT_REVIEW/$MFT_PHASE"
  mkdir -p "$MFT_PHASE_OUT"
  xcrun simctl terminate "$MFT_DEVICE" cc.chaihome.monsterfoodtruck 2>/dev/null || true
  MFT_APP_DATA=$(xcrun simctl get_app_container "$MFT_DEVICE" cc.chaihome.monsterfoodtruck data)
  if [ "$MFT_PHASE" != dark ] && [ "$MFT_PHASE" != light ]; then
    MFT_SAVE="$MFT_APP_DATA/Library/Application Support/MonsterFoodTruck/UIReplayEvidence"
    mkdir -p "$MFT_SAVE"
    cp "$MFT_SEED/save-v1.json" "$MFT_SAVE/save-v1.json"
    cp "$MFT_SEED/save-v1.backup.json" "$MFT_SAVE/save-v1.backup.json"
  fi
  xcrun simctl launch "$MFT_DEVICE" cc.chaihome.monsterfoodtruck > "$MFT_PHASE_OUT/pre-record-launch.txt"
  xcrun simctl io "$MFT_DEVICE" screenshot "$MFT_PHASE_OUT/recording-ready.png"
  MFT_FORCED_STOP=0
  python3 Scripts/start_recording.py "$MFT_DEVICE" "$MFT_PHASE_OUT/$MFT_PHASE.mov" > "$MFT_PHASE_OUT/recording.log" 2>&1 &
  MFT_VIDEO_PID=$!
  sleep 1
  MFT_TEST_STATUS=0
  if xcodebuild test-without-building -project MonsterFoodTruck.xcodeproj -scheme MonsterFoodTruck -configuration Debug -destination "platform=iOS Simulator,id=$MFT_DEVICE" -parallel-testing-enabled NO -only-testing:"MonsterFoodTruckUITests/ArtReviewTests/$MFT_METHOD" -resultBundlePath "$MFT_OUTPUT/$MFT_PHASE.xcresult" -derivedDataPath "$MFT_OUTPUT/DerivedData" CODE_SIGNING_ALLOWED=NO CURRENT_PROJECT_VERSION=25 | tee "$MFT_PHASE_OUT/test.log"; then MFT_TEST_STATUS=0; else MFT_TEST_STATUS=$?; fi
  MFT_EXPORT_STATUS=0
  if ! xcrun xcresulttool export attachments --path "$MFT_OUTPUT/$MFT_PHASE.xcresult" --output-path "$MFT_PHASE_OUT/screenshots"; then MFT_EXPORT_STATUS=1; fi
  if ! xcrun xcresulttool get test-results summary --path "$MFT_OUTPUT/$MFT_PHASE.xcresult" > "$MFT_PHASE_OUT/TEST_SUMMARY.json"; then MFT_EXPORT_STATUS=1; fi
  stop_recording
  MFT_PROBE_STATUS=0
  if ! xcrun swift "$MFT_HARNESS/probe_continuous_video.swift" "$MFT_PHASE_OUT/$MFT_PHASE.mov" "$MFT_PHASE_OUT/FRAME_PTS" > "$MFT_PHASE_OUT/VIDEO_PROBE.log" 2>&1; then MFT_PROBE_STATUS=1; fi
  if [ "$MFT_PHASE" != dark ] && [ "$MFT_PHASE" != light ]; then
    MFT_APP_DATA=$(xcrun simctl get_app_container "$MFT_DEVICE" cc.chaihome.monsterfoodtruck data)
    MFT_SAVE="$MFT_APP_DATA/Library/Application Support/MonsterFoodTruck/UIReplayEvidence"
    cp "$MFT_SAVE/save-v1.json" "$MFT_PHASE_OUT/actual-save-v1.json"
  fi
  python3 - "$MFT_PHASE_OUT" "$MFT_TEST_STATUS" "$MFT_EXPORT_STATUS" "$MFT_PROBE_STATUS" "$MFT_FORCED_STOP" <<'PY'
import hashlib,json,sys
from pathlib import Path
out=Path(sys.argv[1]);statuses=list(map(int,sys.argv[2:]));files=[]
for file in sorted(out.rglob('*')):
 if file.is_file():
  h=hashlib.sha256()
  with file.open('rb') as stream:
   for chunk in iter(lambda:stream.read(1024*1024),b''):h.update(chunk)
  files.append(dict(path=str(file.relative_to(out)),bytes=file.stat().st_size,sha256=h.hexdigest()))
(out/'CAPTURE_STATUS.json').write_text(json.dumps(dict(phase=out.name,test_exit=statuses[0],export_exit=statuses[1],video_probe_exit=statuses[2],recording_forced_termination=bool(statuses[3]),files=files,scope='Original native short capture. Passed assertions check capture operations only, not final art scores or all-level human play.'),ensure_ascii=False,indent=2)+'\n')
PY
  if [ "$MFT_TEST_STATUS" != 0 ] || [ "$MFT_EXPORT_STATUS" != 0 ] || [ "$MFT_PROBE_STATUS" != 0 ] || [ "$MFT_FORCED_STOP" != 0 ]; then MFT_ANY_FAILED=1; fi
done
git diff --exit-code -- MonsterFoodTruck MonsterFoodTruck.xcodeproj ArtSource Tests Scripts
python3 - "$MFT_REVIEW" <<'PY'
import hashlib,json,os
from pathlib import Path
import sys
r=Path(sys.argv[1]);rows=[]
expected=[('soup','L1-1','star_soup'),('stew','L5-1','cloud_stew'),('crisp','L4-1','moon_crisp')]
if os.environ.get('MFT_CAPTURE_CASES')=='crisp':expected=[expected[-1]]
for phase,order,recipe in expected:
 f=r/phase/'actual-save-v1.json'
 if not f.is_file():continue
 s=json.loads(f.read_text())['session'];o=next(x for x in s['orders'] if x['id']==order)
 assert o['recipe']==recipe and o['status']=='served' and not s['isPractice'],phase
 commands=[x['command'] for x in s['inputs']]
 for action in ['prepare','cook','plate','cover','uncover','garnish','serve']:assert any(action in c for c in commands),(phase,action)
 if phase=='stew':
  events=[e for e in s['events'] if e.get('orderID')==order]
  for kind in ['scorched','nibbled','tidyStart','tidyDone','toppingDone','served']:assert any(e['kind']==kind for e in events),kind
 rows.append(dict(phase=phase,order=order,recipe=recipe,sha256=hashlib.sha256(f.read_bytes()).hexdigest(),method='Restored actual candidate-earned progress, then one customer served by real UI taps at normal clock; not a completed-level walkthrough.'))
(r/'ACTUAL_RECIPE_SESSIONS.json').write_text(json.dumps(rows,ensure_ascii=False,indent=2)+'\n')
assert len(rows)==len(expected),'Missing actual recipe session evidence in explicit capture scope'
total=sum(p.stat().st_size for p in r.rglob('*') if p.is_file());assert total<400*1024*1024,'Short review evidence exceeds explicit download budget'
PY
exit "$MFT_ANY_FAILED"
