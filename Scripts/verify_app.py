#!/usr/bin/env python3
"""Fail before install/package if the built .app has invalid identity or layout."""
import argparse
import hashlib
import json
import plistlib
import struct
import zlib
from pathlib import Path

def png_payload(data):
    """Keep every PNG chunk except text; Xcode copypng strips only text with compression off."""
    if data[:8]!=b'\x89PNG\r\n\x1a\n':raise ValueError('Invalid PNG signature')
    payload=data[:8];position=8
    while position+12<=len(data):
        size=struct.unpack('>I',data[position:position+4])[0]
        end=position+size+12
        if end>len(data):raise ValueError('Truncated PNG chunk')
        kind=data[position+4:position+8];body=data[position+8:position+8+size]
        if zlib.crc32(kind+body)!=struct.unpack('>I',data[end-4:end])[0]:raise ValueError('Invalid PNG CRC')
        if kind not in (b'tEXt',b'zTXt',b'iTXt'):payload+=data[position:end]
        position=end
        if kind==b'IEND':
            if position!=len(data):raise ValueError('Unexpected data after PNG end')
            return payload
    raise ValueError('PNG end chunk missing')

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
        hashes={};png_metadata={}
        for source in sorted(sources):
            target=app/source.name
            if not target.is_file():raise ValueError(f'Built app is missing offline resource: {source.name}')
            target_data=target.read_bytes();source_data=source.read_bytes()
            digest=hashlib.sha256(target_data).hexdigest();source_digest=hashlib.sha256(source_data).hexdigest()
            if digest!=source_digest:
                if source.suffix!='.png' or png_payload(target_data)!=png_payload(source_data):raise ValueError(f'Built offline resource differs from source: {source.name}')
                png_metadata[source.name]=dict(source_sha256=source_digest,built_sha256=digest,payload_sha256=hashlib.sha256(png_payload(target_data)).hexdigest(),allowed_difference='PNG text metadata only; every other chunk identical')
            hashes[source.name]=digest
        content=json.loads((app/'Content.json').read_text())
        if [len(content[k]) for k in ('recipes','monsters','levels')]!=[3,3,6]:raise ValueError('Built app has incomplete game content')
        if len(list(app.glob('*.wav')))!=25:raise ValueError('Built app has incomplete offline audio')
        if not (app/'Assets.car').is_file():raise ValueError('Compiled app icon catalog is missing')
        if info.get('CFBundleIcons',{}).get('CFBundlePrimaryIcon',{}).get('CFBundleIconName')!='AppIcon':raise ValueError('Built app icon metadata is missing')
        report['offline_resource_sha256']=hashes
        report['png_text_metadata_processing']=png_metadata
        report['content_counts']={key:len(content[key]) for key in ('recipes','monsters','levels')}
    return report

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('app')
    parser.add_argument('--platform', required=True, choices=['iPhoneOS', 'iPhoneSimulator'])
    parser.add_argument('--output', required=True)
    parser.add_argument('--resources', required=True, help='Verify every original offline resource against the built flat bundle')
    args = parser.parse_args()
    report = inspect(args.app, args.platform, args.resources)
    output = Path(args.output)
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(report, ensure_ascii=False, indent=2) + '\n')
    print(output.read_text())
