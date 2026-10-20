# 首次整合啟動與核心重播證據

source SHA：`3b7dce8ab0871d09e6b794c5b0da8d9055faaa74`；[Validate run 39432461903](https://github.com/Kongdean2374/MonsterFoodTruck/actions/runs/39432461903)，artifact `12268383631`。實際摘要為 15 passed、0 failed、0 skipped：14 單元及 1 啟動 UI 測試。

`actual-home.png` 從該 run 的真實 XCTest 附件取得，已由 Codex 檢視；它證明首頁母版與真實按鈕已整合，不代表所有按鈕流程、遊玩、美術／音訊或全部布局已驗收。檢視發現的底部背景接縫於後續提交修正，不能拿這張舊圖當修正後結果。

`ReferenceReplays` 保存該次模型測試的十二份原始 JSON 附件，六關普通／舒緩均由同一 GameSession 與 UI 共用的合法命令產生及重新播放。EVIDENCE_INDEX 記錄來源、操作數與間隔。這些是設計診斷，不是假裝真人試玩，也不代替正常玩法影片或關卡樂趣驗證。

此目錄是後續證據提交；受測 App source SHA 以首行為準，不能改用本文件提交的 SHA。
