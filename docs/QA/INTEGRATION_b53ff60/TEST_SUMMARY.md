# Actual validation evidence

Source SHA: `b53ff6020f9f5227c6a636f66859d393277a41ca`
Exit status: 65; last stage: baseline-tests-failed

Baseline: executed; see native TEST_RESULT_SUMMARY.json

| Native result scope | Passed | Failed | Skipped |
|---|---:|---:|---:|
| TEST_RESULT_SUMMARY.json | 26 | 1 | 0 |

Actual exported App PNGs: 40. See native summaries, xcresult, logs and VALIDATION_STATUS.json.

FlowTests and ControlFlowTests use real UI taps; explicit DEBUG scenarios are fixed-state layout evidence. FullJourneyTests use real UI navigation with an engineering command driver, the normal foreground clock, shared validators and atomic saves; these are not human playtests. PerformanceTests use twenty real scene entries; SpriteKit update cadence and handler scheduling proxies are simulator diagnostics, not physical-device FPS or touch-to-photon latency. simctl recording has picture only and does not verify audio or haptics. A scope without its own native summary is not claimed as executed.
