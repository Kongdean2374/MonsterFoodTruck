# 首次短片 harness 失敗（原候選未變）

[Run 39509800845](https://github.com/Kongdean2374/MonsterFoodTruck/actions/runs/39509800845)／job 118927710235／harness `fd05dc67aa3711548effb833aaf2cd44a4da47c8`，2026-10-21 06:43 台北時間結束 failure。實際 App source 固定 `66c2929dd05c28af1b0c3ec8a79805446c6dc023`。原生 build-for-testing 成功，但尚未執行任何拍攝 XCTest 或產生本輪短片，不能寫成 0 failed 的通過。

`actool` 明確警告 AppIcon 的 Icon.png 不存在；隨後既有 `verify_app.py` 以 `Built app icon metadata is missing` 拒絕產包。原因是新增外部 capture.sh 漏接原 ci_environment.sh 已使用的 `Scripts/prepare_assets.sh`。修復僅讓 capture.sh 執行同一既有資產準備步驟，保持既有識別／圖示／47 資源檢查，沒有放寬 gate、改產品或修飾失敗。

| 原始附件 | bytes | ZIP SHA-256 |
|---|---:|---|
| [12304489059](https://github.com/Kongdean2374/MonsterFoodTruck/actions/runs/39509800845/artifacts/12304489059) 環境／來源／失敗現場 | 21,258,035 | `95db6e977c2adda976fca91b7289ad526deca68590cc880ed085f8e9b5d0c32a` |
| [12304529165](https://github.com/Kongdean2374/MonsterFoodTruck/actions/runs/39509800845/artifacts/12304529165) 原 build.log | 10,999 | `79edc3a1bbe5696265d5281880bd8d7a328f7aa38c42e9e52ba33526789ba94f` |

第一份已實際下載並核對 ZIP digest。原失敗保留；修正後以新的 harness SHA 補拍同五段短片，不重跑完整六關或重新產 IPA。路由 run 39509800901 的 scope 成功僅確認六個產品 tree 與候選相同，不是新回歸結果。
