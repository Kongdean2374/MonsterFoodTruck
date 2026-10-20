#!/usr/bin/env python3
"""Always describe whether tests actually ran, including a pre-test build failure."""
import json,subprocess,sys
from pathlib import Path

out=Path('build');out.mkdir(exist_ok=True)
summary=out/'TEST_RESULT_SUMMARY.json'
native=json.loads(summary.read_text()) if summary.is_file() else None
report=dict(source_sha=subprocess.check_output(['git','rev-parse','HEAD'],text=True).strip(),exit_status=int(sys.argv[1]),last_stage=sys.argv[2],baseline_tests='executed; see native TEST_RESULT_SUMMARY.json' if native else 'not executed; no XCTest result summary available',passed=native.get('passedTests') if native else None,failed=native.get('failedTests') if native else None,skipped=native.get('skippedTests') if native else None,actual_png_count=len(list((out/'QA_EVIDENCE').rglob('*.png'))))
(out/'VALIDATION_STATUS.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
if not (out/'TEST_SUMMARY.md').exists():
 (out/'TEST_SUMMARY.md').write_text(f"Validation exited {report['exit_status']} during {report['last_stage']}. {report['baseline_tests']}. No test pass is claimed. Actual exported UI PNGs: {report['actual_png_count']}; if build or resource checks failed before launch, no UI picture can exist for this source. See compile.log / validate.log and VALIDATION_STATUS.json.\n")
