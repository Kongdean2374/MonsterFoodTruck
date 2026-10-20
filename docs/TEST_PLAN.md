# 測試與證據

測試檔不等於已通過。每次以實際完整 source SHA、Actions run 與 xcresult／JSON 摘要為準；任何 failure 都不視為完整驗收。

目前實際結果：DOT-001 的 f8707b5 已有 2 passed／0 failed／0 skipped、同 SHA 裝置 IPA 及 Dot 獨立重測。b88566e 的 11 個 GameModelTests 實際通過，包含六關普通／舒緩三星參考解、重播、0.6 秒主要操作間隔、資源／命令／熱度／偷嚐／修整／截止點／背景時間等；SaveStore 回呼等待失敗，整體 failure。修復 `b12837c80dfc9f44ae6035c8bf7334f0fff66fdb` 的 run `39430419215`／job `118653712104` SUCCESS，14 項單元與 1 項啟動 UI 測試通過；使用者已轉交 Dot 對此相同候選的獨立查核。範圍僅核心／存檔與啟動，整合 UI／音畫尚待驗證。

核心回歸由 `Tests/GameModelTests.swift`、`SaveStoreTests.swift` 直接使用 App 的 Domain／Data／SaveStore，沒有另寫評分計算器或直接注入成功狀態。參考序列改以 XCTest JSON 附件保存，供後續候選匯出核對；真實 UI 截圖也由 XCTest 在運行時擷取。

整合後必測：

1. 首頁全部入口、鎖定／解鎖六關、關卡簡介、教學事件推進與重看不更新正式成績。
2. 正常備料／下鍋／裝盤／配料／整理／餐蓋／出餐、錯誤和滿站回饋、背景與音訊中斷暫停。
3. 設定音量／觸覺／下一局模式／高對比／大字／左右手／減少動態、設定重設與進度清除的獨立確認及取消路徑。
4. 保存回首頁、終止／重開恢復、壞主檔／備份、不相容 session 保留永久進度、結算原子性與失敗重試。
5. 全六關正常命令流程、成功／失敗／重試、六關完成與三星紀錄。比較短菜優先、長菜先下鍋與動態調整，記錄等待／無效操作／餐蓋實際用途；尚未完成平衡診斷。
6. 小中大模擬器、標準／大字／高對比／左右手布局、VoiceOver 基本導航；至少一般與第五／六關完整實際玩法影片。未取得的畫面與音訊不虛稱已檢視。
7. 同候選 Release 裝置包檢查、資產／六關完整性、checksum、無簽名及平台檢查，與最後獨立驗收對應。

目前整合已擴作三角色分層／五表情、三菜九狀態與餐車道具，會在三尺寸 ArtReviewTests 匯出實際深淺底／動作 PNG；不是美術評分或正常點按全流程。龍 MFT-007 Alpha 殘點仍開放，原圖保留且未使用 Python 圖片編修。真機啟動／安裝、觸覺、飛航與實機效能尚未測，模擬器不能代替。音訊已有離線播放器與 25 WAV 靜態分析，聽覺未驗證。

最新原生候選 b53ff60／Validate 39466494713：主 scope 26 passed／1 failed／0 skipped（22 單元全過），原完整 UI 案例仍於清除進度取消後確認窗未關閉而失敗；兩尺寸原 job 各 3 passed／0 failed／0 skipped。原始 PNG／摘要及大型 artifact 只讀匯出 provenance 見 QA/INTEGRATION_b53ff60。沒有六關延伸、影片或效能實測。下一候選保留全部斷言，修正單一 sheet 呈現與工位標籤淺底，首頁截圖須等設定確實消失後才拍。

新增滿爐／滿成品與客人離場整理回收回歸；同一 Domain 15 方法／全部斷言在 Linux 官方 Swift 通過，iOS 仍待。另新增舊資料版本 session 丟棄後保留永久資料可繼續寫入的真實 I/O 案例，與設定→確認單一呈現／取消保留資料的模型案例。

Content v2 的三排程／兩模式／三間隔及配對禁保護對照，使用同一 App Domain。Linux 官方 Swift 6.1.2 先重現舊原生 72 筆，再作候選數值診斷；其 XCTest adapter 保留 13 個 GameModel 原方法與全部斷言，只改本地 Content 載入並略去 Linux 不支援的附件匯出。MFT-009 原失敗與修正測試前提後的重測都保存，iOS XCTest 仍完整執行及匯出附件。這些不是 iOS build／UI 或真人試玩通過。

FullJourneyTests 依正常前景時鐘走六關及真實結算，取得實際解鎖存檔後關閉命令 driver，以真實點按確認第五關餐蓋開合、蓋著出餐與回收重用。練習使用隔離保存，不能覆寫六個正式 session 證據。PerformanceTests 二十次真實進出場景，記錄 SpriteKit update cadence／handler 到下一次 update／task_info 取樣最大值；這些不是物理 FPS／touch-to-photon／連續 profiler 峰值。最終同 SHA 每個 scope 與包檢查須對照 QA/DELIVERY_CHECKLIST.md。
