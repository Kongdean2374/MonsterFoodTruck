# 品質問題紀錄

## MFT-005（教學練習入口與重開隔離）

- Codex 代碼查驗，規格 3.3／3.8／12.2：原先由說明設定一個延後消耗的練習旗標；進入練習簡介後返回，再開始正式局，可能仍被當成練習。反之重開練習局可能丟失標記而更新正式成績。
- 修改中：練習簡介採明確路由，開局／替換確認明確攜帶 practice，重開保留目前局標記；正式開始不繼承先前的練習意圖。新增導航取消／重開模型回歸，完整練習工程重播仍檢查結算不解鎖第二關。尚未有此修復的實測結果。
- 狀態 IN_PROGRESS；不把代碼檢查或新增測試當通過。

## MFT-004（首次教學角色空白）

- 嚴重度：P2，規格 3.3／7／12.3。Source `69c3933a7833429a32b537ac2ba7e1ff93739f4b`；validation-14 的 `928A2329-FDF4-4A27-9E2E-C7CEDB9577DC.png`（tutorial-first）。
- Dot 獨立查核：使用者轉交，看到苔角鹿訂單、耐心 65 與選中框，但角色圖空白；單張可能是入場瞬間，尚未判為持續故障，要求穩定畫面。Dot 同次確認原生 19 項、18 通過／1 觸覺失敗／0 略過，以及第一關 3 成功／2 偏好／2 星與第二關解鎖；所列首頁、介紹、busy 標準／大字左手、結果實圖未見明確裁切。這些觀察不代表整個 UI 或美術通過。
- Codex 代碼定位：`begin` 建立訂單並顯示教學，沒有在教學前呼叫 `syncKitchen`；角色節點原本要到 dismissLesson → resume 才建立。現有角色沒有 alpha 入場漸變，因此缺少初始同步可直接解釋該畫面；仍需新候選實圖驗證。
- 修改中：在顯示首次教學前同步場景；隔離存檔的 SceneLifecycle 回歸確認節點／texture 已存在、alpha=1、教學與時鐘維持暫停且 resize 不重複建立角色；真實 UI 保留原教學斷言，新增 0／1／3 秒穩定截圖。使用者要求保留的 run 39446499495 不取消、不重開；待後續修復候選實測。
- 狀態 IN_PROGRESS，未代稱 Dot 已通過或將舊單張當穩定證據。

## MFT-003（設定文字區點按與保存回歸）

- 嚴重度：P2，規格 4／12.2；Source `69c3933a7833429a32b537ac2ba7e1ff93739f4b`，[run 39441785452](https://github.com/Kongdean2374/MonsterFoodTruck/actions/runs/39441785452)，artifact `12275303224`。
- 原生結果：18 passed／1 failed／0 skipped（15 單元；3 UI 通過、1 UI 失敗）。原教學操作已到達真實第一關結算及第二關解鎖，但同一長案例之後於 FlowTests.swift:68 讀取重開後觸覺開關，預期 0、實際 1，整體 failure。
- 畫面：重開前即能看到高對比／大字等仍為關閉，原 Toggle 的文字區點按未切換開關；不能將原預期檔名當成旗標已生效。尚未證明是檔案寫入失敗，不作該歸因。
- 修改中：文字區提供至少 44pt 的操作區，維持原生開關與明確 accessibility label；每次點按立即檢查實際值，再檢查重開保存，不刪除觸覺斷言。完成設定等最新原子寫入完成才關閉，失敗保留畫面及重試；雙壞檔則保護原檔並允許返回／明確清除流程。
- 同次修正：以 failureCount 判斷失敗附件，避免 passed 案例被過早 hasSucceeded 值命名為 FAILED；原 artifact 及原生統計保留。
- `0171012` 的 run 39446499495：小尺寸 2 UI 通過；大尺寸 1 通過／1 失敗，左手配置預期 1 實際 0。實圖前兩個開關已開、左手配置仍在可視區下方；增加點按中心在可視範圍的捲動條件，保留所有數值與重開保存斷言。主驗證因 runner 容量被 GitHub 取消，沒有執行，不套用 layout 成果為主驗證通過。詳 [INTEGRATION_0171012](INTEGRATION_0171012/)。
- 證據：[INTEGRATION_69c3933](INTEGRATION_69c3933/)。狀態 IN_PROGRESS，未有 Dot 通過判定。

## MFT-002（整合教學操作與失敗證據）

- 嚴重度：P1（操作驗證未通過），規格 3／12。受測 SHA `d59f2123188156043a46dd10e7f8bc1d0a97d4f1`；[Validate 39433857551](https://github.com/Kongdean2374/MonsterFoodTruck/actions/runs/39433857551)，job `118665612505`，artifact `12271815746`。
- 實際結果：14 項單元通過；3 項 UI 中截圖與啟動 2 項通過，教學／暫停／保存流程於 FlowTests.swift:50 等待「裝盤」失敗。整體 failure；後續小／大尺寸沒有執行。
- Dot 獨立查驗：使用者轉交 Dot 親自下載上述 artifact 並核對 validate.log 的同一失敗；指出 artifact 僅 xcresult／log，缺少可直接檢視的匯出 PNG 及 summary。未代稱 Dot 通過。
- 診斷：App 的實際 accessibility 日誌顯示料理仍在備料槽且主要按鈕仍為「下鍋」。教學提示出現時，原測試可能點到被覆蓋的背景按鈕後直接視為命令成功。背景操作亦應從模態提示的輔助使用順序隔離。
- 修改中：教學／暫停時停用並隱藏背景操作；命令 catch-up 如觸發教學先停下；保留原「備料→下鍋→裝盤→出餐→設定→保存→重開」斷言並等待實際轉移。失敗時先匯出附件／摘要再回傳原 xcodebuild 失敗碼，新增操作失敗截圖與 hierarchy。
- 真實畫面：[INTEGRATION_d59f212](INTEGRATION_d59f212/) 保存首頁、測試情境及大字／左手／高對比原始 PNG 與來源。首頁接縫在此畫面消失；同尺寸角色腳部仍與文字相疊，修正後需重拍。debug 情境與工程重播不代表完整真實點按 UI 通過。
- 狀態：IN_PROGRESS，等待新候選原失敗及尺寸回歸。
- `69c3933a7833429a32b537ac2ba7e1ff93739f4b` 的原教學／保存子流程已執行到第一關結算與解鎖第二關，但整個長案例因新增 MFT-003 設定斷言仍 failure。失敗附件匯出已實測成功：26 PNG＋原生 summary；資源逐檔一致。未把該案例或三尺寸標成通過，仍等待完整重測與 Dot 查驗。
- 中間候選 `1b90898e19032ce55883d9723f15ba1533f045f0` 的 [run 39437388402](https://github.com/Kongdean2374/MonsterFoodTruck/actions/runs/39437388402) 在編譯成功後、啟動測試前被新增資源完整性檢查攔下：Xcode CopyPNGFile 的預設轉換使輸出 PNG 位元組與來源 SHA-256 不同。此 run 沒有執行單元／UI，不宣稱原失敗消失。下一候選關閉原始資源 PNG 的建置重壓縮，保留逐檔校驗；另外增加所有退出階段的狀態摘要，建置前失敗不虛構截圖或測試數。
- `e4865ea38af8e6c728463e4a7dcefd25bfc45d56` 的 [run 39437916409](https://github.com/Kongdean2374/MonsterFoodTruck/actions/runs/39437916409) 同樣在資源檢查失敗、沒有執行 XCTest。log 確認關閉壓縮後仍執行 `copypng -strip-PNG-text`，因此原檔雜湊仍不同。後續校驗僅允許 tEXt／zTXt／iTXt 文字中繼資料差異，驗證每個 PNG chunk 的 CRC，要求像素、色彩及全部非文字區塊完全一致；產出與來源 SHA-256 及共同 payload 雜湊均記錄。其他資源仍要求逐位元組一致，不以刪除資源檢查取得成功。
- 上述中間方案 `e76f4a79c910be07a11eb043fe7215806e3d259b` 的 [run 39440235520](https://github.com/Kongdean2374/MonsterFoodTruck/actions/runs/39440235520) 仍被 PNG 區塊差異攔下，未執行 XCTest。Codex 新增的檢查未先配合 Xcode 資源處理，拖住了原 UI 回歸。後續改成明確以 opaque file 複製原始 PNG，關閉 PNG 文字移除，恢復逐位元組嚴格校驗；如仍失敗會連同實際輸出 PNG 保存以便查對，避免只依指令推測。必要 bundle 識別／native probe 仍在安裝前執行，完整資源檢查放到測試附件匯出之後獨立執行，任何失敗保留非零結果，不再阻止取得原教學及尺寸的實測證據。

## MFT-001（Codex 自測發現）

- 嚴重度：P1；規格 9.2／12.1，存檔回歸不得宣稱通過。
- 受測 SHA：`b88566e00ebc063d702f7b6eb27ed83f751e0359`；[run 39426228219](https://github.com/Kongdean2374/MonsterFoodTruck/actions/runs/39426228219)。11 個模型測試與六關雙模式參考重播通過，但存檔測試的前兩個非同步完成回呼等待逾時，整體 failure。
- 重現：`testOrderedWritesBackupAndSettlementTransaction` 在同步 `wait(for:)` 等待由主佇列交付的完成回呼。
- 修正：改為 XCTest 的 async 測試與 `await fulfillment`，讓執行器在等待時可交付主佇列回呼；保留原來五秒限制與全部檔案／備份／舊寫入拒絕斷言，不略過或只增加逾時。
- 修復 SHA：`b12837c80dfc9f44ae6035c8bf7334f0fff66fdb`；[Validate run 39430419215](https://github.com/Kongdean2374/MonsterFoodTruck/actions/runs/39430419215)，job `118653712104` 整體 SUCCESS。14 項單元測試與 1 項啟動 UI 測試通過，原來兩處存檔寫入／結算回呼逾時消失。
- 獨立查驗：使用者轉交 Dot 親自核對上述 SHA／run／job 的結果，確認目前核心與存檔回歸通過。這不代表完整 UI、美術、音效或整合分支的新提交通過。
- 狀態：VERIFIED_CLOSED（僅此等待問題及該核心候選）。保留原失敗 run，不以後續成功改寫原紀錄。

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
