#!/usr/bin/env python3
import plistlib
import json
import struct
import zlib
import tempfile
import unittest
from pathlib import Path
from verify_app import inspect

class VerifyAppTests(unittest.TestCase):
    def test_real_bundle_validation_rejects_missing_unexpanded_and_wrong_platform(self):
        with tempfile.TemporaryDirectory() as directory:
            app=Path(directory)/'MonsterFoodTruck.app'
            app.mkdir(parents=True)
            (app/'MonsterFoodTruck').write_bytes(b'fixture executable')
            (app/'ContentVersion.json').write_text('{}')
            info=dict(CFBundleIdentifier='cc.chaihome.monsterfoodtruck',CFBundleExecutable='MonsterFoodTruck',CFBundleName='MonsterFoodTruck',CFBundlePackageType='APPL',CFBundleInfoDictionaryVersion='6.0',CFBundleShortVersionString='1.0.0',CFBundleVersion='1',MinimumOSVersion='17.0',CFBundleSupportedPlatforms=['iPhoneSimulator'],UIDeviceFamily=[1],UISupportedInterfaceOrientations=['UIInterfaceOrientationPortrait'])
            def write(value): (app/'Info.plist').write_bytes(plistlib.dumps(value))
            write(info)
            self.assertEqual(inspect(app,'iPhoneSimulator')['CFBundleIdentifier'],info['CFBundleIdentifier'])
            resources=Path(directory)/'offline';resources.mkdir()
            (resources/'Content.json').write_text(json.dumps(dict(recipes=[{}]*3,monsters=[{}]*3,levels=[{}]*6)))
            def chunk(kind,body):return struct.pack('>I',len(body))+kind+body+struct.pack('>I',zlib.crc32(kind+body))
            pixels=chunk(b'IHDR',struct.pack('>IIBBBBB',1,1,8,6,0,0,0))+chunk(b'IDAT',zlib.compress(b'\0\x20\x40\x60\xff'))+chunk(b'IEND',b'')
            png=b'\x89PNG\r\n\x1a\n'+chunk(b'tEXt',b'Title\0fixture')+pixels
            (resources/'art.png').write_bytes(png)
            for index in range(25):(resources/f'event-{index}.wav').write_bytes(b'fixture PCM')
            for source in resources.iterdir():(app/source.name).write_bytes(source.read_bytes())
            (app/'Assets.car').write_bytes(b'fixture compiled catalog')
            info['CFBundleIcons']={'CFBundlePrimaryIcon':{'CFBundleIconName':'AppIcon'}};write(info)
            self.assertEqual(inspect(app,'iPhoneSimulator',resources)['content_counts']['levels'],6)
            (app/'art.png').write_bytes(b'\x89PNG\r\n\x1a\n'+pixels)
            with self.assertRaisesRegex(ValueError,'differs from source'):inspect(app,'iPhoneSimulator',resources)
            (app/'art.png').write_bytes(png)
            (app/'event-0.wav').unlink()
            with self.assertRaisesRegex(ValueError,'missing offline resource'):inspect(app,'iPhoneSimulator',resources)
            (app/'event-0.wav').write_bytes(b'corrupt audio')
            with self.assertRaisesRegex(ValueError,'differs from source'):inspect(app,'iPhoneSimulator',resources)
            for key in ['CFBundleIdentifier','CFBundleInfoDictionaryVersion','CFBundleExecutable']:
                invalid=info.copy();del invalid[key];write(invalid)
                with self.subTest(key=key),self.assertRaises(ValueError):inspect(app,'iPhoneSimulator')
            write(info|{'CFBundleIdentifier':'$(PRODUCT_BUNDLE_IDENTIFIER)'})
            with self.assertRaises(ValueError):inspect(app,'iPhoneSimulator')
            write(info)
            with self.assertRaises(ValueError):inspect(app,'iPhoneOS')
            (app/'Resources').mkdir()
            with self.assertRaises(ValueError):inspect(app,'iPhoneSimulator')
            (app/'Resources').rmdir()
            (app/'MonsterFoodTruck').unlink()
            with self.assertRaises(ValueError):inspect(app,'iPhoneSimulator')

if __name__=='__main__':unittest.main()
