# Actual validation evidence

Source SHA: `9882a0c3793ba1faccf240afb0b4deb9562acce9`
Exit status: 65; last stage: build

Baseline: not executed; no XCTest result summary available

| Native result scope | Passed | Failed | Skipped |
|---|---:|---:|---:|
| No native XCTest summary available | unreported | unreported | unreported |

Actual exported App PNGs: 0. See native summaries, xcresult, logs and VALIDATION_STATUS.json.

FlowTests and ControlFlowTests use real UI taps; explicit DEBUG scenarios are fixed-state layout evidence. FullJourneyTests use real UI navigation with an engineering command driver, the normal foreground clock, shared validators and atomic saves; these are not human playtests. PerformanceTests use twenty real scene entries; SpriteKit update cadence and handler scheduling proxies are simulator diagnostics, not physical-device FPS or touch-to-photon latency. simctl recording has picture only and does not verify audio or haptics. A scope without its own native summary is not claimed as executed.
