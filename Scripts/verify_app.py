#!/usr/bin/env python3
"""Fail before install/package if the built .app has invalid identity or layout."""
import argparse
import hashlib
import json
import plistlib
import shutil
from pathlib import Path

def inspect(app, platform, resources=None):
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
    report={key: info[key] for key in required} | {'UIDeviceFamily': info['UIDeviceFamily'], 'app': app.name}
    if resources is not None:
        sources=[p for p in Path(resources).rglob('*') if p.is_file()]
        if len({p.name for p in sources})!=len(sources):raise ValueError('Duplicate flat resource names')
        hashes={}
        for source in sorted(sources):
            target=app/source.name
            if not target.is_file():raise ValueError(f'Built app is missing offline resource: {source.name}')
            digest=hashlib.sha256(target.read_bytes()).hexdigest()
            if digest!=hashlib.sha256(source.read_bytes()).hexdigest():raise ValueError(f'Built offline resource differs from source: {source.name}')
            hashes[source.name]=digest
        content=json.loads((app/'Content.json').read_text())
        if [len(content[k]) for k in ('recipes','monsters','levels')]!=[3,3,6]:raise ValueError('Built app has incomplete game content')
        if len(list(app.glob('*.wav')))!=25:raise ValueError('Built app has incomplete offline audio')
        if not (app/'Assets.car').is_file():raise ValueError('Compiled app icon catalog is missing')
        if info.get('CFBundleIcons',{}).get('CFBundlePrimaryIcon',{}).get('CFBundleIconName')!='AppIcon':raise ValueError('Built app icon metadata is missing')
        report['offline_resource_sha256']=hashes
        report['content_counts']={key:len(content[key]) for key in ('recipes','monsters','levels')}
    return report

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('app')
    parser.add_argument('--platform', required=True, choices=['iPhoneOS', 'iPhoneSimulator'])
    parser.add_argument('--output', required=True)
    parser.add_argument('--resources', help='Also verify every original offline resource against the built flat bundle')
    args = parser.parse_args()
    output = Path(args.output)
    output.parent.mkdir(parents=True, exist_ok=True)
    try:
        report = inspect(args.app, args.platform, args.resources)
    except Exception as error:
        failure=output.parent/'RESOURCE_FAILURE';failure.mkdir(exist_ok=True)
        (failure/'FAILURE.json').write_text(json.dumps(dict(error=str(error),platform=args.platform,app=str(args.app)),indent=2)+'\n')
        if args.resources:
            for source in Path(args.resources).rglob('*.png'):
                target=Path(args.app)/source.name
                if target.is_file():shutil.copyfile(target,failure/source.name)
        raise
    output.write_text(json.dumps(report, ensure_ascii=False, indent=2) + '\n')
    print(output.read_text())
