# Actual validation evidence

Source SHA: `28e474db37fdc8c9be40a490cd9c51a1070bd888`
Exit status: 65; last stage: normal-six-level-journey

Baseline: executed; see native TEST_RESULT_SUMMARY.json

| Native result scope | Passed | Failed | Skipped |
|---|---:|---:|---:|
| TEST_RESULT_SUMMARY.json | 31 | 0 | 0 |
| JOURNEY_TEST_SUMMARY.json | 2 | 2 | 0 |

Actual exported App PNGs: 104. See native summaries, xcresult, logs and VALIDATION_STATUS.json.

FlowTests and ControlFlowTests use real UI taps; explicit DEBUG scenarios are fixed-state layout evidence. FullJourneyTests use real UI navigation with an engineering command driver, the normal foreground clock, shared validators and atomic saves; these are not human playtests. PerformanceTests use twenty real scene entries; SpriteKit update cadence and handler scheduling proxies are simulator diagnostics, not physical-device FPS or touch-to-photon latency. simctl recording has picture only and does not verify audio or haptics. A scope without its own native summary is not claimed as executed.
