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
plutil -p build/DerivedData/Build/Products/Debug-iphonesimulator/MonsterFoodTruck.app/Info.plist
xcodebuild test-without-building -project MonsterFoodTruck.xcodeproj -scheme MonsterFoodTruck -configuration Debug -destination "platform=iOS Simulator,id=$SIM_ID" -parallel-testing-enabled NO -resultBundlePath build/Validation.xcresult -derivedDataPath build/DerivedData CODE_SIGNING_ALLOWED=NO | tee build/validate.log
xcrun simctl io "$SIM_ID" screenshot build/QA_EVIDENCE/after-tests.png
python3 - <<'PY'
from pathlib import Path
Path('build/TEST_SUMMARY.md').write_text('xcodebuild test completed successfully. See Validation.xcresult for test cases, attachments, failures and skipped tests. This is simulator validation, not device validation.\n')
PY
