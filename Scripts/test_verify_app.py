#!/usr/bin/env python3
import plistlib
import tempfile
import unittest
from pathlib import Path
from verify_app import inspect

class VerifyAppTests(unittest.TestCase):
    def test_real_bundle_validation_rejects_missing_unexpanded_and_wrong_platform(self):
        with tempfile.TemporaryDirectory() as directory:
            app=Path(directory)/'MonsterFoodTruck.app'
            (app/'Resources').mkdir(parents=True)
            (app/'MonsterFoodTruck').write_bytes(b'fixture executable')
            (app/'Resources'/'ContentVersion.json').write_text('{}')
            info=dict(CFBundleIdentifier='cc.chaihome.monsterfoodtruck',CFBundleExecutable='MonsterFoodTruck',CFBundleName='MonsterFoodTruck',CFBundlePackageType='APPL',CFBundleInfoDictionaryVersion='6.0',CFBundleShortVersionString='1.0.0',CFBundleVersion='1',MinimumOSVersion='17.0',CFBundleSupportedPlatforms=['iPhoneSimulator'],UIDeviceFamily=[1],UISupportedInterfaceOrientations=['UIInterfaceOrientationPortrait'])
            def write(value): (app/'Info.plist').write_bytes(plistlib.dumps(value))
            write(info)
            self.assertEqual(inspect(app,'iPhoneSimulator')['CFBundleIdentifier'],info['CFBundleIdentifier'])
            for key in ['CFBundleIdentifier','CFBundleInfoDictionaryVersion','CFBundleExecutable']:
                invalid=info.copy();del invalid[key];write(invalid)
                with self.subTest(key=key),self.assertRaises(ValueError):inspect(app,'iPhoneSimulator')
            write(info|{'CFBundleIdentifier':'$(PRODUCT_BUNDLE_IDENTIFIER)'})
            with self.assertRaises(ValueError):inspect(app,'iPhoneSimulator')
            write(info)
            with self.assertRaises(ValueError):inspect(app,'iPhoneOS')
            (app/'MonsterFoodTruck').unlink()
            with self.assertRaises(ValueError):inspect(app,'iPhoneSimulator')

if __name__=='__main__':unittest.main()
