# 品質問題紀錄

## DOT-001

- 嚴重度：P1，阻擋模擬器安裝／驗證與 IPA 建置。
- 規格條款：1.2／11／12。
- 受測 source SHA：`1ba0a7458f13c0934ee1bb926c591a74d2cb879f`。
- 環境：GitHub-hosted macos-15、Xcode 16.4、iOS 18.5 Simulator、iPhone 16 Pro；非真機。
- 問題摘要：編譯後的 App 無法由模擬器安裝，`Missing bundle ID`，exit 65。
- 重現：該 SHA 執行 Validate iOS；未簽名 workflow 的相同測試也失敗。
- 預期：產出 App 的 plist 識別有效，可安裝並完成啟動與單元測試，之後能建立未簽名裝置 IPA。
- 實際：模擬器無法讀取 `MonsterFoodTruck.app` bundle identifier；裝置封裝步驟因測試失敗而略過，沒有宣稱產生 IPA。
- 證據：[validation run 39421655088](https://github.com/Kongdean2374/MonsterFoodTruck/actions/runs/39421655088)，job `118623827305`；[IPA run 39421658496](https://github.com/Kongdean2374/MonsterFoodTruck/actions/runs/39421658496)。原失敗紀錄保留。
- 要求修正：核對工程與 plist 處理、檢查實際輸出 plist、補必要識別檢查、重跑模擬器與裝置封裝，不略過測試。
- 修正：`e9f9fafd2400c2e2cfdc6b266036c976582865e8` 補 `CFBundleInfoDictionaryVersion=6.0`，拆分 build-for-testing／test-without-building 並輸出實際 plist；後續提交增加 `Scripts/verify_app.py` 對實際 simulator／device App 的必要識別、平台、執行檔與資源檢查，保留 plist／JSON 證據。
- 回歸：腳本缺欄位／未展開值／錯平台／缺執行檔拒絕測試；真正模擬器單元與 UI 測試；同 SHA Release 裝置 archive、Mach-O 平台與未簽名 IPA 檢查。
- Codex 狀態：IN_PROGRESS；等待新候選的實際 Actions 結果。
- Dot 重測：尚未取得；Codex 不代簽關閉。
- 歷史：OPEN（使用者轉交 Dot 問題）→ IN_PROGRESS。
