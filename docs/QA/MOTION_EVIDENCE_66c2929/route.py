#!/usr/bin/env python3
"""Route only an explicit, unchanged-candidate capture request away from full QA."""
import json
import os
import subprocess
from pathlib import Path

CANDIDATE = '66c2929dd05c28af1b0c3ec8a79805446c6dc023'
MARKER = '[motion-evidence-66c2929]'
PRODUCT_ROOTS = ['MonsterFoodTruck', 'MonsterFoodTruck.xcodeproj', 'ArtSource', 'Tests', 'UITests', 'Scripts']

def classify(event, ref, message):
    explicit = event == 'push' and ref == 'refs/heads/integration/full-game' and message.startswith(MARKER)
    same = {}
    if explicit:
        for root in PRODUCT_ROOTS:
            candidate = subprocess.check_output(['git', 'rev-parse', CANDIDATE + ':' + root], text=True).strip()
            current = subprocess.check_output(['git', 'rev-parse', 'HEAD:' + root], text=True).strip()
            same[root] = dict(candidate=candidate, current=current, identical=candidate == current)
    return dict(capture_only=explicit and all(row['identical'] for row in same.values()),
                candidate_source_sha=CANDIDATE, explicit_request=explicit, product_trees=same,
                scope='Evidence capture only when every candidate product/test/build-script tree is identical. Any product change retains normal full validation.')

if __name__ == '__main__':
    report = classify(os.getenv('GITHUB_EVENT_NAME', ''), os.getenv('GITHUB_REF', ''), os.getenv('MFT_COMMIT_MESSAGE', ''))
    print(json.dumps(report, indent=2))
    if os.getenv('GITHUB_OUTPUT'):
        with open(os.environ['GITHUB_OUTPUT'], 'a') as stream:
            stream.write('capture_only=' + str(report['capture_only']).lower() + '\n')
    if os.getenv('MFT_REQUIRE_CAPTURE') == '1' and not report['capture_only']:
        raise SystemExit('Refusing capture: request or unchanged candidate product tree not verified')
