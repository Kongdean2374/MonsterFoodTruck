#!/bin/bash
set -euo pipefail
VALIDATION_STAGE=build
finish_validation(){
  STATUS=$?
  trap - EXIT
  python3 Scripts/validation_status.py "$STATUS" "$VALIDATION_STAGE"
  exit "$STATUS"
}
trap finish_validation EXIT
python3 Scripts/generate_project.py
mkdir -p build/QA_EVIDENCE
xcrun simctl list devices available --json > build/devices.json
SIM_ID=$(python3 - <<'PY'
import json
devices=json.load(open('build/devices.json'))['devices']
candidates=[d for runtime,ds in devices.items() if 'iOS' in runtime for d in ds if d.get('isAvailable') and d['name']=='iPhone 16 Pro']
if not candidates: raise SystemExit('Required iPhone 16 Pro simulator not available; inspect ENVIRONMENT.txt')
print(candidates[0]['udid'])
PY
)
echo "$SIM_ID" > build/simulator-id.txt
xcodebuild build-for-testing -project MonsterFoodTruck.xcodeproj -scheme MonsterFoodTruck -configuration Debug -destination "platform=iOS Simulator,id=$SIM_ID" -derivedDataPath build/DerivedData CODE_SIGNING_ALLOWED=NO | tee build/compile.log
SIM_APP=build/DerivedData/Build/Products/Debug-iphonesimulator/MonsterFoodTruck.app
VALIDATION_STAGE=built-bundle-identity
plutil -p "$SIM_APP/Info.plist"
cp "$SIM_APP/Info.plist" build/SIMULATOR_APP_INFO.plist
python3 Scripts/verify_app.py "$SIM_APP" --platform iPhoneSimulator --output build/SIMULATOR_APP_IDENTITY.json
xcrun swift Scripts/probe_bundle.swift "$PWD/$SIM_APP" | tee build/SIMULATOR_BUNDLE_PROBE.txt
if [ "${MFT_LAYOUT_ONLY:-0}" = 1 ]; then
  VALIDATION_STAGE=layout-tests
  LAYOUT_STATUS=0
  if bash Scripts/layout_smoke.sh; then LAYOUT_STATUS=0; else LAYOUT_STATUS=$?; fi
  VALIDATION_STAGE=built-resource-integrity
  ASSET_STATUS=0
  if python3 Scripts/verify_app.py "$SIM_APP" --platform iPhoneSimulator --resources MonsterFoodTruck/Resources --output build/SIMULATOR_APP_IDENTITY.json; then ASSET_STATUS=0; else ASSET_STATUS=$?; fi
  if [ "$LAYOUT_STATUS" != 0 ]; then VALIDATION_STAGE=layout-tests-failed; exit "$LAYOUT_STATUS"; fi
  if [ "$ASSET_STATUS" != 0 ]; then VALIDATION_STAGE=built-resource-integrity-failed; exit "$ASSET_STATUS"; fi
  VALIDATION_STAGE=complete
  exit 0
fi
TEST_STATUS=0
VALIDATION_STAGE=baseline-tests
if xcodebuild test-without-building -project MonsterFoodTruck.xcodeproj -scheme MonsterFoodTruck -configuration Debug -destination "platform=iOS Simulator,id=$SIM_ID" -parallel-testing-enabled NO -only-testing:MonsterFoodTruckTests -only-testing:MonsterFoodTruckUITests/FlowTests -resultBundlePath build/Validation.xcresult -derivedDataPath build/DerivedData CODE_SIGNING_ALLOWED=NO | tee build/validate.log; then
  TEST_STATUS=0
else
  TEST_STATUS=$?
fi
xcrun xcresulttool export attachments --path build/Validation.xcresult --output-path build/QA_EVIDENCE
xcrun xcresulttool get test-results summary --path build/Validation.xcresult > build/TEST_RESULT_SUMMARY.json
python3 - "$TEST_STATUS" <<'PY'
from pathlib import Path
import json,sys
screenshots=list(Path('build/QA_EVIDENCE').rglob('*.png'))
summary=json.loads(Path('build/TEST_RESULT_SUMMARY.json').read_text())
status=int(sys.argv[1])
Path('build/TEST_SUMMARY.md').write_text(f'xcodebuild test exit status: {status}. Actual counts: {summary.get("passedTests")} passed, {summary.get("failedTests")} failed, {summary.get("skippedTests")} skipped. See TEST_RESULT_SUMMARY.json and Validation.xcresult for cases and failures. QA_EVIDENCE contains actual XCTest screenshots and model replays, exported even when tests fail. Simulator validation is not device or full-game acceptance.\n')
if status==0 and (not screenshots or not all(p.stat().st_size>0 for p in screenshots)):
    raise SystemExit('Required actual XCTest screenshot attachments were not exported')
PY
VALIDATION_STAGE=built-resource-integrity
ASSET_STATUS=0
if python3 Scripts/verify_app.py "$SIM_APP" --platform iPhoneSimulator --resources MonsterFoodTruck/Resources --output build/SIMULATOR_APP_IDENTITY.json; then ASSET_STATUS=0; else ASSET_STATUS=$?; fi
if [ "$TEST_STATUS" != 0 ]; then VALIDATION_STAGE=baseline-tests-failed; exit "$TEST_STATUS"; fi
if [ "${MFT_FULL_QA:-0}" = 1 ]; then
  VALIDATION_STAGE=normal-six-level-journey
  bash Scripts/full_journey.sh "$SIM_ID"
  printf '\nExtended six-level normal-speed command replay ran separately; see JOURNEY_TEST_SUMMARY.json, Journey.xcresult and the actual simulator recording. Engineering replay is not human playtesting.\n' >> build/TEST_SUMMARY.md
fi
if [ "${MFT_LAYOUT_QA:-0}" = 1 ]; then
  VALIDATION_STAGE=small-and-large-layouts
  bash Scripts/layout_smoke.sh
  printf '\nAdditional small/large simulator UI layout tests ran; see LAYOUT_TEST_SUMMARY_*.json and QA_EVIDENCE/layout-*.\n' >> build/TEST_SUMMARY.md
fi
if [ "$ASSET_STATUS" != 0 ]; then VALIDATION_STAGE=built-resource-integrity-failed; exit "$ASSET_STATUS"; fi
VALIDATION_STAGE=complete
