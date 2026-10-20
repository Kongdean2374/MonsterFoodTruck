#!/bin/bash
set -euo pipefail
mkdir -p build/delivery
test -z "$(git status --porcelain --untracked-files=no)"
xcodebuild archive -project MonsterFoodTruck.xcodeproj -scheme MonsterFoodTruck -configuration Release -destination 'generic/platform=iOS' -archivePath build/MonsterFoodTruck.xcarchive -derivedDataPath build/DeviceData CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY= DEVELOPMENT_TEAM= CURRENT_PROJECT_VERSION="${GITHUB_RUN_NUMBER:-1}" | tee build/archive.log
APP=build/MonsterFoodTruck.xcarchive/Products/Applications/MonsterFoodTruck.app
test -f "$APP/MonsterFoodTruck"
cp "$APP/Info.plist" build/delivery/DEVICE_APP_INFO.plist
python3 Scripts/verify_app.py "$APP" --platform iPhoneOS --output build/delivery/DEVICE_APP_IDENTITY.json
xcrun swift Scripts/probe_bundle.swift "$PWD/$APP" | tee build/delivery/DEVICE_BUNDLE_PROBE.txt
xcrun vtool -show-build "$APP/MonsterFoodTruck" | tee build/delivery/MACHO_PLATFORM.txt
grep -Eq 'platform[[:space:]]+IOS$' build/delivery/MACHO_PLATFORM.txt
if find "$APP" \( -name '*.mobileprovision' -o -name '*.p12' -o -name '*.key' \) | grep -q .; then
  echo 'Unexpected signing material' >&2; exit 1
fi
if codesign -d "$APP" 2> build/delivery/SIGNATURE.txt; then
  echo 'Unexpected signed app; inspect signature' >&2; exit 1
fi
mkdir -p build/package/Payload
ditto "$APP" build/package/Payload/MonsterFoodTruck.app
VERSION=$(/usr/libexec/PlistBuddy -c 'Print CFBundleShortVersionString' "$APP/Info.plist")
BUILD=$(/usr/libexec/PlistBuddy -c 'Print CFBundleVersion' "$APP/Info.plist")
IPA="MonsterFoodTruck-unsigned-$VERSION-$BUILD.ipa"
(cd build/package && zip -qry "../delivery/$IPA" Payload)
cp build/ENVIRONMENT.txt build/TEST_SUMMARY.md build/TEST_RESULT_SUMMARY.json build/delivery/
cp PLAYTEST_GUIDE.md build/delivery/
python3 - "$APP" "$IPA" <<'PY'
import datetime,hashlib,json,os,plistlib,subprocess,sys
from pathlib import Path
app,ipa=Path(sys.argv[1]),sys.argv[2]
p=plistlib.loads((app/'Info.plist').read_bytes())
assert p['CFBundleIdentifier']=='cc.chaihome.monsterfoodtruck'
assert p['CFBundleSupportedPlatforms']==['iPhoneOS']
assert p['MinimumOSVersion']=='17.0'
out=Path('build/delivery')
digest=hashlib.sha256((out/ipa).read_bytes()).hexdigest()
manifest=dict(source_sha=subprocess.check_output(['git','rev-parse','HEAD'],text=True).strip(),version=p['CFBundleShortVersionString'],build=p['CFBundleVersion'],bundle_id=p['CFBundleIdentifier'],platform='iOS device',signature='unsigned',runner_image=os.getenv('ImageVersion'),xcode=subprocess.check_output(['xcodebuild','-version'],text=True).strip(),sdk=subprocess.check_output(['xcrun','--sdk','iphoneos','--show-sdk-version'],text=True).strip(),workflow_run_id=os.getenv('GITHUB_RUN_ID'),ipa=ipa,ipa_sha256=digest,created_at=datetime.datetime.now(datetime.timezone.utc).isoformat(),validation='See TEST_SUMMARY.md; not a final acceptance')
(out/'BUILD_MANIFEST.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n')
(out/'SHA256SUMS.txt').write_text(''.join(hashlib.sha256(f.read_bytes()).hexdigest()+'  '+f.name+'\n' for f in sorted(out.iterdir()) if f.is_file() and f.name!='SHA256SUMS.txt'))
PY
