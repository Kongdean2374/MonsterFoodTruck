#!/usr/bin/env python3
"""Fail before install/package if the built .app has invalid identity or layout."""
import argparse
import json
import plistlib
from pathlib import Path

def inspect(app, platform):
    app = Path(app)
    info = plistlib.loads((app / 'Info.plist').read_bytes())
    required = ['CFBundleIdentifier', 'CFBundleExecutable', 'CFBundleName',
                'CFBundlePackageType', 'CFBundleInfoDictionaryVersion',
                'CFBundleShortVersionString', 'CFBundleVersion', 'MinimumOSVersion',
                'CFBundleSupportedPlatforms']
    for key in required:
        if key not in info or info[key] in ('', None, []):
            raise ValueError(f'Built app is missing required field: {key}')
        if '$(' in str(info[key]):
            raise ValueError(f'Built app contains unexpanded build setting: {key}')
    if info['CFBundleIdentifier'] != 'cc.chaihome.monsterfoodtruck':
        raise ValueError('Unexpected built app bundle identifier')
    if info['CFBundleInfoDictionaryVersion'] != '6.0' or info['CFBundlePackageType'] != 'APPL':
        raise ValueError('Invalid app bundle dictionary version or package type')
    if info['CFBundleExecutable'] != 'MonsterFoodTruck' or not (app / info['CFBundleExecutable']).is_file():
        raise ValueError('App executable is missing or incorrectly named')
    if info['CFBundleSupportedPlatforms'] != [platform]:
        raise ValueError(f'Expected {platform}; got {info["CFBundleSupportedPlatforms"]}')
    if info['MinimumOSVersion'] != '17.0' or info.get('UIDeviceFamily') != [1]:
        raise ValueError('Unexpected deployment target or device family')
    if info.get('UISupportedInterfaceOrientations') != ['UIInterfaceOrientationPortrait']:
        raise ValueError('Expected iPhone portrait-only app')
    if not str(info['CFBundleVersion']).isdigit() or int(info['CFBundleVersion']) < 1:
        raise ValueError('Invalid build number')
    if (app / 'Resources').exists() or (app / 'Contents').exists():
        raise ValueError('Reserved Resources/Contents folder changes CFBundle layout detection')
    if not (app / 'ContentVersion.json').is_file():
        raise ValueError('Offline resource was not copied into built app root')
    for suffix in ('*.mobileprovision', '*.p12', '*.key'):
        if any(app.rglob(suffix)):
            raise ValueError('Unexpected signing material in app')
    return {key: info[key] for key in required} | {'UIDeviceFamily': info['UIDeviceFamily'], 'app': app.name}

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('app')
    parser.add_argument('--platform', required=True, choices=['iPhoneOS', 'iPhoneSimulator'])
    parser.add_argument('--output', required=True)
    args = parser.parse_args()
    report = inspect(args.app, args.platform)
    output = Path(args.output)
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(report, ensure_ascii=False, indent=2) + '\n')
    print(output.read_text())
