#!/usr/bin/env python3
"""Package-gate fixtures only; these are not App screenshots or XCTest results."""
import hashlib
import json
import tempfile
import unittest
import zipfile
from pathlib import Path
from assemble_validation import collect


class AssemblyGateTests(unittest.TestCase):
    def fixture(self, root, *, sha='a' * 40, failures=0, skipped=0):
        archive = root / 'fixture.zip'
        result = dict(passedTests=3, failedTests=failures, skippedTests=skipped)
        with zipfile.ZipFile(archive, 'w') as output:
            output.writestr('VALIDATION_STATUS.json', json.dumps(dict(source_sha=sha, exit_status=0, last_stage='complete')))
            output.writestr('LAYOUT_TEST_SUMMARY_small.json', json.dumps(result))
            output.writestr('LAYOUT_ENVIRONMENT.txt', 'fixture environment, not a simulator run')
            output.writestr('QA_EVIDENCE/layout-small/test-only.png', b'fixture bytes, not an App screenshot')
        metadata = dict(id=1, name='fixture', workflow_run=dict(id=7, head_sha='a' * 40), digest='sha256:' + hashlib.sha256(archive.read_bytes()).hexdigest())
        return archive, metadata

    def testOriginalBytesAndCountsStayUnchanged(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            archive, metadata = self.fixture(root)
            result = collect(archive, metadata, 'a' * 40, 7, 'layout-small', root / 'output')
            self.assertEqual((root / 'output/QA_EVIDENCE/layout-small/test-only.png').read_bytes(), b'fixture bytes, not an App screenshot')
            self.assertEqual(result['native_summaries']['LAYOUT_TEST_SUMMARY_small.json'], dict(passedTests=3, failedTests=0, skippedTests=0))

    def testAnotherSourceCannotSatisfyThisCandidate(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            archive, metadata = self.fixture(root, sha='b' * 40)
            with self.assertRaisesRegex(AssertionError, 'source SHA mismatch'):
                collect(archive, metadata, 'a' * 40, 7, 'layout-small', root / 'output')

    def testFailedOrSkippedNativeScopeCannotBePackaged(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            for failures, skipped in [(1, 0), (0, 1)]:
                with self.subTest(failures=failures, skipped=skipped):
                    archive, metadata = self.fixture(root, failures=failures, skipped=skipped)
                    with self.assertRaisesRegex(AssertionError, 'failures, skips or no passes'):
                        collect(archive, metadata, 'a' * 40, 7, 'layout-small', root / 'output')

    def testModifiedArchiveCannotUseOriginalDigest(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            archive, metadata = self.fixture(root)
            with archive.open('ab') as output:
                output.write(b'changed')
            with self.assertRaisesRegex(AssertionError, 'checksum differs'):
                collect(archive, metadata, 'a' * 40, 7, 'layout-small', root / 'output')


if __name__ == '__main__':
    unittest.main()
