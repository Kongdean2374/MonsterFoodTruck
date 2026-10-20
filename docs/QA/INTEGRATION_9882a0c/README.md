# 9882a0c 原生測試建置失敗

Source **9882a0c3793ba1faccf240afb0b4deb9562acce9**／[Validate 39471446711](https://github.com/Kongdean2374/MonsterFoodTruck/actions/runs/39471446711)，主 job **118796263167 failure**。artifact **12286459099**／小型 review **12287916018**。

新增 `SceneLifecycleTests.swift:10` 測試 fixture 直接寫 `model.document.records`，但 document setter 是 private；Xcode 報 `cannot assign through subscript: 'document' setter is inaccessible`，test build exit 65。

**尚未執行 XCTest，沒有測試通過／失敗／略過數，也沒有此候選的 App PNG。** VALIDATION_STATUS 的 counts 保持 null、actual_png_count=0；沒有改用舊圖、生成圖或 Linux 結果充當本次實測。兩尺寸仍等待既有 job 結束，不重開同 SHA。

下一修正只改 fixture：先用真實 SaveStore 寫入星數，再載入 AppModel 執行設定→確認→取消；不放寬產品 setter，也不刪除原斷言。需新 SHA 原生重測。
