#!/bin/bash
set -euo pipefail
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
plutil -p "$SIM_APP/Info.plist"
cp "$SIM_APP/Info.plist" build/SIMULATOR_APP_INFO.plist
python3 Scripts/verify_app.py "$SIM_APP" --platform iPhoneSimulator --output build/SIMULATOR_APP_IDENTITY.json
xcrun swift Scripts/probe_bundle.swift "$PWD/$SIM_APP" | tee build/SIMULATOR_BUNDLE_PROBE.txt
xcodebuild test-without-building -project MonsterFoodTruck.xcodeproj -scheme MonsterFoodTruck -configuration Debug -destination "platform=iOS Simulator,id=$SIM_ID" -parallel-testing-enabled NO -resultBundlePath build/Validation.xcresult -derivedDataPath build/DerivedData CODE_SIGNING_ALLOWED=NO | tee build/validate.log
xcrun xcresulttool export attachments --path build/Validation.xcresult --output-path build/QA_EVIDENCE
xcrun xcresulttool get test-results summary --path build/Validation.xcresult > build/TEST_RESULT_SUMMARY.json
python3 - <<'PY'
from pathlib import Path
screenshots=list(Path('build/QA_EVIDENCE').rglob('*.png'))
if not screenshots or not all(p.stat().st_size>0 for p in screenshots):
    raise SystemExit('Required actual XCTest screenshot attachments were not exported')
Path('build/TEST_SUMMARY.md').write_text('xcodebuild build-for-testing and test-without-building completed successfully. See TEST_RESULT_SUMMARY.json and Validation.xcresult for executed, failed and skipped test counts. QA_EVIDENCE contains actual screenshots captured inside the running app by XCTest, exported from that result bundle. This is simulator validation, not device or full-game acceptance.\n')
PY
if [ "${MFT_LAYOUT_QA:-0}" = 1 ]; then
  bash Scripts/layout_smoke.sh
  printf '\nAdditional small/large simulator UI layout tests ran; see LAYOUT_TEST_SUMMARY_*.json and QA_EVIDENCE/layout-*.\n' >> build/TEST_SUMMARY.md
fi
