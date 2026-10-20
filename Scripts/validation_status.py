#!/usr/bin/env python3
"""Always describe whether tests actually ran, including a pre-test build failure."""
import json,os,subprocess,sys
from pathlib import Path

out=Path('build');out.mkdir(exist_ok=True)
results={}
for file in [out/'TEST_RESULT_SUMMARY.json',out/'JOURNEY_TEST_SUMMARY.json',*sorted(out.glob('LAYOUT_TEST_SUMMARY_*.json'))]:
 if file.is_file():
  try:
   native=json.loads(file.read_text());results[file.name]={key:native.get(key) for key in ('passedTests','failedTests','skippedTests')}
  except Exception as error:results[file.name]={'read_error':str(error)}
baseline='executed; see native TEST_RESULT_SUMMARY.json' if 'TEST_RESULT_SUMMARY.json' in results else 'not scheduled in this layout-only job' if os.getenv('MFT_LAYOUT_ONLY')=='1' else 'not executed; no XCTest result summary available'
report=dict(source_sha=subprocess.check_output(['git','rev-parse','HEAD'],text=True).strip(),exit_status=int(sys.argv[1]),last_stage=sys.argv[2],baseline_tests=baseline,scoped_results=results,actual_png_count=len(list((out/'QA_EVIDENCE').rglob('*.png'))))
for target,key in [('passed','passedTests'),('failed','failedTests'),('skipped','skippedTests')]:
 values=[r[key] for r in results.values() if isinstance(r.get(key),int)]
 report[target]=sum(values) if values else None
(out/'VALIDATION_STATUS.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
if not (out/'TEST_SUMMARY.md').exists():
 (out/'TEST_SUMMARY.md').write_text(f"Validation exited {report['exit_status']} during {report['last_stage']}. Baseline: {report['baseline_tests']}. Recorded scoped results: {results or 'none; no test pass claimed'}. Actual exported UI PNGs: {report['actual_png_count']}. A pre-launch failure has no App screenshot; counts are never invented. See native summaries, logs and VALIDATION_STATUS.json.\n")
