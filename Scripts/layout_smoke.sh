#!/bin/bash
set -euo pipefail
xcrun simctl list runtimes --json > build/layout-runtimes.json
RUNTIME=$(python3 - <<'PY'
import json
items=json.load(open('build/layout-runtimes.json'))['runtimes']
matches=[r['identifier'] for r in items if r.get('isAvailable') and r.get('version')=='18.5' and 'iOS' in r['name']]
if len(matches)!=1:raise SystemExit('Expected the recorded iOS 18.5 runtime for layout evidence')
print(matches[0])
PY
)
SIZES=(small large)
if [ -n "${MFT_LAYOUT_SIZE:-}" ]; then
  case "$MFT_LAYOUT_SIZE" in small|large) SIZES=("$MFT_LAYOUT_SIZE");; *) echo 'Unknown layout size' >&2; exit 1;; esac
fi
for SIZE in "${SIZES[@]}"; do
  if [ "$SIZE" = small ]; then TYPE=com.apple.CoreSimulator.SimDeviceType.iPhone-SE-3rd-generation; else TYPE=com.apple.CoreSimulator.SimDeviceType.iPhone-15-Pro-Max; fi
  DEVICE=$(xcrun simctl create "MonsterFoodTruck-$SIZE" "$TYPE" "$RUNTIME")
  echo "$SIZE $TYPE $DEVICE $RUNTIME" >> build/LAYOUT_ENVIRONMENT.txt
  STATUS=0
  if xcodebuild test-without-building -project MonsterFoodTruck.xcodeproj -scheme MonsterFoodTruck -configuration Debug -destination "platform=iOS Simulator,id=$DEVICE" -parallel-testing-enabled NO -only-testing:MonsterFoodTruckUITests/FlowTests/testDebugScenarioScreenshots -only-testing:MonsterFoodTruckUITests/FlowTests/testHomeLayouts -resultBundlePath "build/Layout-$SIZE.xcresult" -derivedDataPath build/DerivedData CODE_SIGNING_ALLOWED=NO | tee "build/layout-$SIZE.log"; then STATUS=0; else STATUS=$?; fi
  xcrun xcresulttool export attachments --path "build/Layout-$SIZE.xcresult" --output-path "build/QA_EVIDENCE/layout-$SIZE"
  xcrun xcresulttool get test-results summary --path "build/Layout-$SIZE.xcresult" > "build/LAYOUT_TEST_SUMMARY_$SIZE.json"
  if [ "$STATUS" != 0 ]; then exit "$STATUS"; fi
  xcrun simctl list devices --json > build/layout-devices-after.json
  STATE=$(python3 - "$DEVICE" <<'PY'
import json,sys
print(next(d['state'] for ds in json.load(open('build/layout-devices-after.json'))['devices'].values() for d in ds if d['udid']==sys.argv[1]))
PY
)
  if [ "$STATE" = Booted ]; then xcrun simctl shutdown "$DEVICE"; fi
done
