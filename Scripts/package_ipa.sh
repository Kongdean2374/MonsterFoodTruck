#!/bin/bash
set -euo pipefail
mkdir -p build/delivery
test -z "$(git status --porcelain --untracked-files=no)"
test "${MFT_FULL_QA:-0}" = 1
test "${MFT_LAYOUT_QA:-0}" = 1
python3 - <<'PY'
import json
from pathlib import Path
for name in ['TEST_RESULT_SUMMARY.json','JOURNEY_TEST_SUMMARY.json','LAYOUT_TEST_SUMMARY_small.json','LAYOUT_TEST_SUMMARY_large.json']:
 result=json.loads((Path('build')/name).read_text())
 assert result['passedTests']>0 and result['failedTests']==0 and result['skippedTests']==0,f'Incomplete required validation scope: {name}'
assert list(Path('build/QA_EVIDENCE').rglob('*.png')),'No actual App screenshots to accompany the device candidate'
PY
xcodebuild archive -project MonsterFoodTruck.xcodeproj -scheme MonsterFoodTruck -configuration Release -destination 'generic/platform=iOS' -archivePath build/MonsterFoodTruck.xcarchive -derivedDataPath build/DeviceData CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY= DEVELOPMENT_TEAM= CURRENT_PROJECT_VERSION="${GITHUB_RUN_NUMBER:-1}" | tee build/archive.log
APP=build/MonsterFoodTruck.xcarchive/Products/Applications/MonsterFoodTruck.app
test -f "$APP/MonsterFoodTruck"
cp "$APP/Info.plist" build/delivery/DEVICE_APP_INFO.plist
python3 Scripts/verify_app.py "$APP" --platform iPhoneOS --resources MonsterFoodTruck/Resources --output build/delivery/DEVICE_APP_IDENTITY.json
xcrun swift Scripts/probe_bundle.swift "$PWD/$APP" | tee build/delivery/DEVICE_BUNDLE_PROBE.txt
xcrun vtool -show-build "$APP/MonsterFoodTruck" | tee build/delivery/MACHO_PLATFORM.txt
grep -Eq 'platform[[:space:]]+IOS$' build/delivery/MACHO_PLATFORM.txt
xcrun lipo -archs "$APP/MonsterFoodTruck" > build/delivery/MACHO_ARCHITECTURES.txt
xcrun otool -l "$APP/MonsterFoodTruck" > build/delivery/MACHO_LOAD_COMMANDS.txt
python3 - <<'PY'
import re
from pathlib import Path
out=Path('build/delivery')
assert (out/'MACHO_ARCHITECTURES.txt').read_text().split()==['arm64'],'Device executable must be arm64'
assert 'LC_CODE_SIGNATURE' not in (out/'MACHO_LOAD_COMMANDS.txt').read_text(),'Unsigned executable must have no signature load command'
assert re.search(r'minos\s+17\.0(?:\s|$)',(out/'MACHO_PLATFORM.txt').read_text()),'Device binary minimum OS must be iOS 17.0'
PY
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
if [ "${MFT_FULL_QA:-0}" = 1 ]; then cp build/JOURNEY_TEST_SUMMARY.json build/delivery/; fi
if [ "${MFT_LAYOUT_QA:-0}" = 1 ]; then cp build/LAYOUT_TEST_SUMMARY_*.json build/LAYOUT_ENVIRONMENT.txt build/delivery/; fi
cp PLAYTEST_GUIDE.md build/delivery/
python3 - "$APP" "$IPA" <<'PY'
import datetime,hashlib,json,os,plistlib,subprocess,sys
from pathlib import Path
app,ipa=Path(sys.argv[1]),sys.argv[2]
p=plistlib.loads((app/'Info.plist').read_bytes())
sim=plistlib.loads(Path('build/SIMULATOR_APP_INFO.plist').read_bytes())
for key in ('CFBundleIdentifier','CFBundleShortVersionString','CFBundleVersion','MinimumOSVersion'):
 assert p[key]==sim[key],f'Device and validated simulator disagree on {key}'
assert p['CFBundleIdentifier']=='cc.chaihome.monsterfoodtruck'
assert p['CFBundleSupportedPlatforms']==['iPhoneOS']
assert p['MinimumOSVersion']=='17.0'
out=Path('build/delivery')
digest=hashlib.sha256((out/ipa).read_bytes()).hexdigest()
manifest=dict(source_sha=subprocess.check_output(['git','rev-parse','HEAD'],text=True).strip(),version=p['CFBundleShortVersionString'],build=p['CFBundleVersion'],bundle_id=p['CFBundleIdentifier'],platform='iOS device',signature='unsigned',runner_image=os.getenv('ImageVersion'),xcode=subprocess.check_output(['xcodebuild','-version'],text=True).strip(),sdk=subprocess.check_output(['xcrun','--sdk','iphoneos','--show-sdk-version'],text=True).strip(),workflow_run_id=os.getenv('GITHUB_RUN_ID'),ipa=ipa,ipa_sha256=digest,created_at=datetime.datetime.now(datetime.timezone.utc).isoformat(),validation='See TEST_SUMMARY.md; not a final acceptance')
manifest['architectures']=(out/'MACHO_ARCHITECTURES.txt').read_text().split()
manifest['signature_load_command']='absent; inspected actual Mach-O load commands'
(out/'BUILD_MANIFEST.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n')
evidence=[]
for file in sorted(Path('build/QA_EVIDENCE').rglob('*')):
 if file.is_file():
  checksum=hashlib.sha256()
  with file.open('rb') as stream:
   for chunk in iter(lambda:stream.read(1024*1024),b''):checksum.update(chunk)
  evidence.append(dict(path=str(file.relative_to('build')),bytes=file.stat().st_size,sha256=checksum.hexdigest()))
(out/'QA_EVIDENCE_INDEX.json').write_text(json.dumps(dict(source_sha=manifest['source_sha'],files=evidence),ensure_ascii=False,indent=2)+'\n')
(out/'SHA256SUMS.txt').write_text(''.join(hashlib.sha256(f.read_bytes()).hexdigest()+'  '+f.name+'\n' for f in sorted(out.iterdir()) if f.is_file() and f.name!='SHA256SUMS.txt'))
PY
