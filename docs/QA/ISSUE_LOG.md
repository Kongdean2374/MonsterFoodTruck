# 品質問題紀錄

## MFT-001（Codex 自測發現）

- 嚴重度：P1；規格 9.2／12.1，存檔回歸不得宣稱通過。
- 受測 SHA：`b88566e00ebc063d702f7b6eb27ed83f751e0359`；[run 39426228219](https://github.com/Kongdean2374/MonsterFoodTruck/actions/runs/39426228219)。11 個模型測試與六關雙模式參考重播通過，但存檔測試的前兩個非同步完成回呼等待逾時，整體 failure。
- 重現：`testOrderedWritesBackupAndSettlementTransaction` 在同步 `wait(for:)` 等待由主佇列交付的完成回呼。
- 修正：改為 XCTest 的 async 測試與 `await fulfillment`，讓執行器在等待時可交付主佇列回呼；保留原來五秒限制與全部檔案／備份／舊寫入拒絕斷言，不略過或只增加逾時。
- 狀態：IN_PROGRESS，待新提交真實 CI 回歸，不從修改測試檔直接標通過。

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
- 狀態：VERIFIED_CLOSED。修復候選 `f8707b553758ba86605d0b70b6f97be35b516b8e` 已完成 Codex 回歸與下列 Dot 獨立重測；範圍僅限該啟動工程的安裝、驗證與裝置封裝。
- 中間回歸：`e9f9fafd2400c2e2cfdc6b266036c976582865e8` 的 [IPA run 39422475892](https://github.com/Kongdean2374/MonsterFoodTruck/actions/runs/39422475892) 再次失敗。日誌顯示實際 plist 已含正確 `CFBundleIdentifier`／`CFBundleInfoDictionaryVersion`，但模擬器仍回報 Missing bundle ID；補欄位本身並非完整修復，不宣稱已解決。
- 深入診斷：原工程將來源 Resources 作為藍色 folder reference，輸出 `.app/Resources/`。此保留目錄可能使 CFBundle 採舊式包結構查找 plist。改為標準逐檔 PBXResourcesBuildPhase、輸出扁平 iOS bundle，並加入 Foundation Bundle 識別 probe 及 native 新舊布局重現；必須等 CI 證明假設與實際安裝，不從靜態 plist 直接判定通過。
- Dot 重測：使用者於本開發對話轉交 Dot 的獨立查驗結果：親自核對兩筆 run 均 success，下載 artifact `12265820706`，確認 SHA256SUMS 全數吻合、實際 IPA 的 bundle ID／iPhoneOS／iOS 17／arm64／Mach-O platform=2 正確且無 LC_CODE_SIGNATURE；摘要 2 passed、0 failed、0 skipped；已檢視真實 P1-launch 截圖。Dot 明確授權本問題記為 VERIFIED_CLOSED。此為外部查驗者回報，不是 Codex 代簽。
- 歷史：OPEN（使用者轉交 Dot 問題）→ IN_PROGRESS。
- 包結構修復 `143e9fb2ba3db6a2ab4b7bcfcac52995fdb3ebac` 的 [Validate run 39423441754](https://github.com/Kongdean2374/MonsterFoodTruck/actions/runs/39423441754)／[IPA run 39423444228](https://github.com/Kongdean2374/MonsterFoodTruck/actions/runs/39423444228)：native 布局重現通過，真實 App 的 Foundation bundle identifier 正確；`testBundleIdentity` 與 `testLaunch` 都 passed，`TEST EXECUTE SUCCEEDED`，UI 測試成功保存 `P1-launch` 附件。安裝阻擋已在此候選消失，但兩筆整體 run 均為 failure：測試後多做的 `simctl screenshot` 回報 ScreenshotError code 2，導致 IPA archive 仍未執行。因此不把整體標成功。
- 後續修正：移除在 XCTest 結束後向無可用 framebuffer 擷取的額外截圖命令，改為從該次真實 xcresult 匯出 UI 測試附件與測試統計，強制確認非空 PNG。所有測試仍完整執行，不略過失敗項；待新 SHA 整體驗證及裝置封裝結果。
- 最終修復 SHA：`f8707b553758ba86605d0b70b6f97be35b516b8e`。
- 實際回歸：[Validate run 39424665706](https://github.com/Kongdean2374/MonsterFoodTruck/actions/runs/39424665706) SUCCESS；[IPA run 39424665179](https://github.com/Kongdean2374/MonsterFoodTruck/actions/runs/39424665179) SUCCESS。相同 source SHA，均執行真實 `testBundleIdentity`／`testLaunch`；2 passed、0 failed、0 skipped。
- 裝置 artifact：`unsigned-ipa-5-f8707b553758ba86605d0b70b6f97be35b516b8e`，artifact ID `12265820706`，到期 `2026-11-03T12:48:47Z`。內含 `MonsterFoodTruck-unsigned-1.0.0-5.ipa`（10,261 bytes），SHA-256 `4f43e4c8abd4d0a9eb39b09a26b7284cc0f535d6ee99e49aac86229c98192173`。
- Codex 產物查驗：下載 artifact 後逐項比對 SHA256SUMS 全部吻合；解析 IPA 的實際 plist 與 Mach-O，識別正確、arm64、LC_BUILD_VERSION platform=2（iOS device），沒有 LC_CODE_SIGNATURE；不是模擬器包。已實際檢視 UI 測試啟動截圖。
- 證據：[DOT-001 目錄](DOT-001/) 保存原始 BUILD_MANIFEST、測試統計、裝置識別、Foundation probe、vtool／codesign 輸出與真實截圖。截圖只證明 bootstrap 啟動，不是正式美術或完整遊戲驗收。
- 下載補充：本地 gh 的 blob redirect 下載曾遭 403，改用既有 GitHub 連接器的 artifact download 成功取得同一 artifact，沒有改連線政策或繞過限制。
- 歷史續：IN_PROGRESS → READY_FOR_RETEST → VERIFIED_CLOSED（Dot 對上述相同 SHA／artifact 獨立重測，經使用者轉交）。不代表後續提交、完整遊戲、正式美術或真機通過。
