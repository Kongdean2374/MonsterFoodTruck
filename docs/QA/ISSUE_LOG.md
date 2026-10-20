# 品質問題紀錄

## 最新同 SHA 候選：66c2929（原生／封裝成功，待獨立驗收）

- Source `66c2929dd05c28af1b0c3ec8a79805446c6dc023`／Validate 39497238513，原 attempt 1 整體 success；基礎 31／0／0、延伸 4／0／0、small／large 各 3／0／0，package-device 118909103267 success。沒有取消或重開舊 job；41 是含尺寸重複方法的執行次數，未略過 XCTest。
- MFT-015 修復回歸：原第五關 driver 關閉後，實際等偷嚐完成再整理／原香草／出餐，原餐蓋開合、直接服務、歸還重用、失效偏好、兩次服務及保存斷言全部保留且通過。真正 App save 記偷嚐 42.4306→整理 44.2299～47.2299→香草 49.3509～51.3509→服務 52.4308 秒；不改時鐘／耐心／玩法或注入狀態。狀態 READY_FOR_RETEST，原 d090／28e／2bb 失敗保留。
- MFT-013 三尺寸 HomeLayouts 的設定保存階段、關閉後首頁與程序重開值均通過。MFT-016 二十次完整 SpriteKit 後代入場／暫停／update 取樣最大值皆 5，直接子節點皆 1、audio players 49。MFT-017 二十次 Performance 完整方法本次及 d090 均通過，沒有推定原啟動失敗唯一根因。以上 READY_FOR_RETEST，非 Dot 關閉。
- 完整裝置 artifact 12302352776 已下載，20 份交付檔校驗全符，實際 IPA 26,053,576 bytes，SHA-256 `314ef428c7cad8ef754233940c91949c20dac0bfaa1aaed856bd15ce74094d4e`；plist／iPhoneOS／iOS 17／arm64／platform=2／無 LC_CODE_SIGNATURE 直接查驗正確。見 [同 SHA 原圖、session、原生摘要與實際 IPA 查驗](INTEGRATION_66c2929/)。
- MFT-007 仍 OPEN；7.7／連續動態接合、音訊監聽與真機項 UNVERIFIED，沒有將本成功拼成完整遊戲 Dot 通過。以下各節保留前輪歷史，不改寫原失敗。

## 最新原生回歸：d09011f（未通過完整候選）

- Validate 39489728099／主 job 118859372658：基礎 31／0／0，延伸 3／1／0；原 review artifact 12297477079 已下載核對 digest。見 [原生摘要、失敗圖與實際存檔](INTEGRATION_d09011f/)。沒有略過失敗方法；兩尺寸各 3／0／0，封裝依門檻 skipped，無完整 IPA。
- MFT-015 仍 IN_PROGRESS：原鹿料理在第一次整理完成後，香草 hittability 查詢期間被偷嚐；實際 session 確定整理完成 45.6657、偷嚐 47.8769 秒、沒有香草輸入。下一候選等待這次真正偷嚐後才整理／加香草／服務，保留原斷言與正常時鐘；不是把消失控制項強制點擊或忽略失敗。
- MFT-016 原 Performance 方法通過，完整 SpriteKit 後代首次有真正量測：二十次入場／暫停及 update 取樣最大值都是根層 1、後代 5，audio players 49。只限當次第一位鹿流程，非所有場景、游離配置或真機效能。狀態 READY_FOR_RETEST（量測範圍更正），未代稱 Dot 關閉。
- MFT-017 在同一 d090 原 Performance 方法未重現；二十次確實執行並有新原始 JSON。狀態 READY_FOR_RETEST，原 28e 啟動失敗保留，沒有據此推定唯一根因。
- MFT-013 主及小大 HomeLayouts 的原設定保存／關閉與重開值斷言均通過，兩尺寸各 3／0／0；只確認此回歸，不代稱完整候選或 Dot 通過。

## MFT-017（延伸效能案例啟動時終止前一 App 失敗）

- Source 28e474d／Validate 39481483503／job 118832059204，PerformanceTests.swift:13 在 `app.launch()` 自動終止前一程序時回報 `Failed to terminate ...:58814 ...:0`。該方法 failed，沒有開始二十次進場；本 SHA 沒有二十次新效能取樣，不能套用 2bb 舊資料。
- 原失敗截圖及摘要見 INTEGRATION_28e474d，保留 failure，不擅自歸因 App deadlock 或 runner 容量。下一候選原完整方法照跑；FullJourney 如失敗先保存原截圖／hierarchy，再經真實暫停 UI 留住現場，減少下一獨立案例與前一活躍遊戲互相干擾，不強殺 App 或把失敗轉綠。
- 狀態 OPEN，待同 SHA 原生回歸與實物。

## MFT-016（場景節點診斷只計直接子節點）

- 使用者轉交 Dot 獨立核對 2bb 的二十次進場診斷，要求確認 nodes=1 範圍。Codex 檢查 `PerformanceDiagnostics.enter` 使用 `scene.children.count`，UI diagnostic 同樣只取 `model.kitchen.children.count`；確實未遞迴計算 ForestRig／DragonRig 後代，也不是節點連續峰值。
- 原 raw JSON／summary 完整保留，解讀只限直接子節點沒有增加、預載音訊實例 49 固定，不宣稱全部場景節點穩定。舊 20 次原生方法仍通過其實際斷言，不能擴張斷言含義。
- 狀態 OPEN：文件已更正範圍；依使用者要求先完成既有 MFT-015 流程及同 SHA 回歸，再補原規格需要的完整後代／生命週期證據，不為此新增產品功能。

## MFT-015（後關實際餐蓋點按未先整理受損料理）

- 後續 28e474d 基礎 31／0／0；延伸 2／2／0，原第一輪整理／偏好失效／香草點按已走過，但之後出餐等待失敗。依原生操作時刻的 Domain 診斷，原偷嚐預告在整理時暫停、完成後接續，約在配料開始後 0.35 秒偷嚐並取消配料；不是再次缺原香草按鈕。重建是診斷，不代稱 UI 成功，見 INTEGRATION_28e474d/ENGINEERING_RECONSTRUCTION。
- 下一候選保留所有原斷言，在顯示第二次受損時只做一次真實三秒整理、重新香草與出餐；不重置偷嚐／延長耐心／注入狀態。原 helper 減少重複 accessibility 查詢，命令只點一次，附實際轉移紀錄；另匯出真正 App 保存的後段 session，和六關 DEBUG 工程歷史分列，仍待原生。

- P1，規格 4.6／12.2／12.3，source `2bb77a9af1064272f1d4ca50a0dc950fecf7f04a`／Validate 39472144828／主 job 118798719852。基礎 31 passed／0 failed／0 skipped；延伸 3 passed／1 failed／0 skipped，整體 failure。
- `FullJourneyTests.swift:60` 在真實第五關關閉 driver、餐蓋重用後直接點香草芽，原生 hierarchy 明列燉菜「焦邊・待整理」、主要命令「整理 3 秒」。原 PNG 蓋住龍餐時就已顯示旁邊燉菜焦邊，失敗圖稍後再遭偷嚐；配料被合法禁用，不是單純不存在等待或 timeout。前面六次工程 session／結算／重開解鎖已走過，但不能把後續失敗的整個方法標成功。
- 使用者轉交 Dot 18:56 UTC 獨立查核測試已失敗／附件仍上傳；已保留原 job，待上傳完成才下載核對具體失敗。原 PNG／摘要／SHA-256 見 [INTEGRATION_2bb77a9](INTEGRATION_2bb77a9/)。上傳成功不等於測試成功。
- 下一候選依畫面可用命令執行正常三秒整理，確認不恢復偏好後保留原香草芽、出餐兩次、餐蓋取下／直接服務／歸還重用斷言；取消與這個檢查無關的小鬼備料，仍等待真實小鬼入場，不改訂單或時鐘。工位的輔助使用 value 同步提供畫面已有的「已整理・偏好失效」，不只向看得到字幕的人揭示後果。
- 狀態 IN_PROGRESS，修正待新 SHA 原生，原失敗保留。

## MFT-014（新增呈現狀態回歸案例無法編譯）

- 後續 `2bb77a9` 原生已編譯並執行通過全部 26 單元（含 5 項 SceneLifecycle）；測試 fixture 使用 SaveStore 真實寫入，沒有擴大 private(set) setter。基礎 31／0／0，延伸另因 MFT-015 失敗。狀態 READY_FOR_RETEST，未代稱 Dot 獨立關閉。

- P1，規格 12.2。9882a0c／Validate 39471446711／主 job 118796263167，新增 SceneLifecycleTests.swift:10 直接修改 private(set) document，test build exit 65。沒有執行 XCTest，counts 未回報、沒有本候選 App PNG；不是 0 failed 的成功驗證。
- 修 fixture 先經 SaveStore 真實寫入永久紀錄，再載入 AppModel；不改產品 setter 可見性，保留原斷言。原錯誤／狀態在 INTEGRATION_9882a0c。狀態 IN_PROGRESS，待新 SHA 原生重測。

## MFT-013（首頁截圖在設定保存中過早擷取）

- P2，規格 12.3。Codex 實看 7c79fe0 small 的 0ACAF0A3：原附件名 layout-home-large-contrast-left，但畫面仍在設定 sheet 且完成鈕因保存而停用。原生 small 3 項方法確實通過，不改寫其結果，也不將該檔名當首頁證明。b53ff60 的 small 25EF3C21 已是完整首頁；large 850C0A2E 則仍在 sheet 關閉途中，修正等待條件同時涵蓋三尺寸。
- 修正既有 HomeLayouts：保留設定值與全部導航斷言，新增等設定導覽列消失及首頁關卡選擇真的可點，再拍首頁；不是加任意 sleep 或用生成圖替代。原始圖／檔名／來源保留，查驗索引更正描述。
- 狀態 IN_PROGRESS，併入下一候選，b53ff60 既有 CI 不重開。

## MFT-012（工位側標籤對比）

- P2，規格 7.4／7.7。使用者轉交 Dot 對 7c79fe0 的 EEA95D22 busy 實圖獨立覆核：三菜、時間、偷嚐目標、空位可辨，虛線未壓耐心數字；左側「成品／爐台／備料」深色字在深木紋上對比不足，要求局部固定淺底並保留餐車材質。
- 下一候選將三標籤置於固定奶油淺底小圓角標籤，保留整體木紋；新增 4pt 標籤寬度與工位背景相應對齊。尚未有新實圖，b53ff60 既有 CI 不取消／重開。
- 同次空客位「森林小徑」需無遮罩圖確認：Codex 已實看 7c79fe0 的 22FE236D／81037746 無遮罩出餐後畫面，文字確實在森林深色區；b53ff60 的無遮罩 82576EC6 已實看，文字已在固定奶油資訊區可辨。側標籤新淺底仍待下一候選，見 INTEGRATION_b53ff60。
- 狀態 IN_PROGRESS。不是動畫、點按命中或 7.7 通過。

## MFT-011（裝飾森林跨越暫停鈕命中區）

- P1，規格 3.7／7.5／12.2。7c79fe0／run 39462050918 主 job 118763757859，原真實流程第一道出餐後在 FlowTests.swift:39 點暫停失敗；按鈕可見但 XCTest 無 hit point。實際階層顯示森林 Image 的 bounds 跨到標題區（y0.7–315.7），clip 的 80pt 視覺框沒有約束命中。
- 新修正禁止森林／車體／工作檯裝飾命中，工作區使用明確矩形命中形狀；原按鈕 .tap 保留，不用座標跳過。另修 ArtReview 最後一列表情文字被場景框截斷。
- b53ff60 主基準原 `.tap()` 已成功，原長案例繼續到第一關結算／設定重開，後因 MFT-008 仍整例失敗。原生深底五表情圖最後一列文字亦完整，見 INTEGRATION_b53ff60；不是全部動作／美術通過。狀態 READY_FOR_RETEST，未代稱 Dot 關閉。

## MFT-010（減少動態切換後的待離場節點）

- Codex 靜態查驗，P2，規格 7.5／9／12.2。角色已服務後會短暫保留接餐／離場動作，且從 active dictionary 移除；若此時開啟減少動態，整個場景暫停，舊節點可能停在畫面。不是 Dot 實際回報或已通過驗證。
- 新修正為待離場與出餐粒子標記短暫節點，啟用減少動態時先清理，再暫停場景。新增原生回歸以真實料理／出餐命令建立離場狀態，確認開啟減少動態後沒有殘留，原服務分數不變。
- b53ff60 的新增原生減少動態離場清理方法已通過，見 INTEGRATION_b53ff60。狀態 READY_FOR_RETEST，未擴張為整段動畫或 Dot 通過。

## MFT-009（評分邊界測試的參考軌跡前提）

- 7c79fe0 新動態排程會為騰出成品位而跳過一次選配料，仍能三星，但原邊界測試假設參考軌跡的每一單都達成偏好。Linux Swift 6.1.2 以原 13 個 GameModel 方法與全部斷言執行（只改 Bundle 載入、略去 Linux 不支援的附件匯出），12 方法通過／1 邊界方法失敗，共 4 個斷言失敗：第六關目標偏好 7，實際 6／2 星。原生 7c79fe0 仍等待 CI，不以 Linux 替代其結果。
- 修復測試前提：邊界案例使用同一 validator 的短菜優先全偏好軌跡，新增先證明每單偏好皆達成的斷言，再保留全部原服務數／偏好數／0–3 星門檻斷言；原動態策略與六關雙模式三星回歸不變。Linux 13 方法重測 13 passed／0 failed；不是 iOS UI 或 Dot 通過。原失敗與重測記錄保留於 BALANCE_V2。
- 7c79fe0 的原生方法已重現相同 4 個斷言失敗；主 scope 24 passed／2 failed／0 skipped，另一失敗為 MFT-011。b53ff60 原生評分方法及全部舊門檻斷言、新前提均通過，見 INTEGRATION_b53ff60；整體仍因 UI 失敗而 failure。
- 狀態 READY_FOR_RETEST（評分回歸範圍），未代稱 Dot 關閉。

## MFT-008（設定還原確認窗未關閉）

- 後續 `2bb77a9` 的原完整 Flow 方法已通過，包含原清除取消／雙確認／設定值重開斷言；新增單一呈現取消模型也通過。基礎 31／0／0，原生 PNG／摘要見 INTEGRATION_2bb77a9。狀態 READY_FOR_RETEST，僅這項回歸已有 Codex 原生證據，沒有代稱 Dot 關閉或全 run 成功。

- P2，規格 3.4／12.2。146a7ca 的 run 39455229683 主 job 118740237075，25 項中 24 passed／1 failed／0 skipped。原設定重開保存已通過，之後按「還原設定」仍見確認窗，首頁關卡選擇存在但無法點按。深色繼承亦使文字對比不足；見 INTEGRATION_146a7ca。
- 下一候選明確 dismiss、固定確認窗淺色、完整按鈕命中區，測試等首頁真正 hittable。原清除雙確認、取消與保留進度斷言不移除。尚未證明單一根因，狀態 IN_PROGRESS。
- b53ff60／Validate 39466494713／主 job 118779164125：27 項，26 passed／1 failed／0 skipped，22 單元全部通過。原流程的還原設定取消／確認及 55%／75% 預設值均走過；失敗往後移至「清除進度 → 取消」仍見確認窗，原首頁可點斷言失敗。原圖與摘要見 INTEGRATION_b53ff60，不把進展當整例通過。
- 下一候選改為單一 sheet 容器，設定寫入成功後直接替換為確認內容，避免兩個 sheet 的關閉／重開交錯；保留全部原取消、雙確認、值保存及程序重開斷言，新增保存後同一呈現狀態與取消保留永久資料的模型回歸。尚待原生 UIKit／點按驗證。

## MFT-007（龍部件透明邊緣）

- 使用者轉交 Dot 獨立查驗原 blob：已實看三角色三菜母版、餐車母版與 dragon-layer-rig.png，維持 7.3 風格沿用；但黑底下頭部下沿／頸部與尾焰旁有紅黃零散殘點及毛邊，要求局部 Alpha 清理、深淺底實際尺寸覆核，再驗證原點與接合。不是撤回母版方向。
- Codex 實際分析原 PNG：遠離實心輪廓的紅點主要 Alpha 1–3／255；圖片工具一次局部編修仍有同類殘留，不把工具輸出當清理成功。已提出改用可重現 Alpha 清理副本的方法；原母版／舊試稿與回退來源保留。
- 使用者最新明確限制：先沿用圖片工具、保留原檔；一般品質監督不是 Python 圖片編修授權。不使用 Python 編修圖片；若圖片工具仍不能解決，保留本缺陷並繼續不受影響工作，由對方另行確認特定方法。
- 第二次圖片工具以同母版重做邊緣仍有同類紅色低 Alpha 點，沒有推選／覆蓋原稿，也沒有改用腳本清理。下一候選會產生實際遊戲尺寸的深淺底與部件動作截圖；這不等於已消除原檔缺陷。
- 狀態 IN_PROGRESS。未清理完成、未取得深淺底實圖或動態接合通過。

## MFT-006（後四關策略差異與餐蓋價值）

- Codex 工程診斷，規格 5.3／12.4：3bc6d37 的實際 Domain 72 筆觀察（雙模式、三排程、三輸入間隔，含選取延遲），全為三星、0 偷嚐預告／0 餐蓋，最長無可操作等待 15.6 秒；少量過熟也未改變星數。原始資料見 INTEGRATION_3bc6d37/STRATEGY_DIAGNOSTICS.json。
- 這證明可解但未形成足夠排程取捨，不以故意站著不動展示機制有用。下一步比較較緊密訂單交錯與暴露起始時間，保留至少 3 秒預告、原耐心及六關內容範圍；同時更新資料版本／規格／測試與前後證據。
- 已實作 Content v2 時序與 3 秒暴露起始候選，雙模式至少 3／5 秒預告不變。Linux 同一 App Domain 的 72 筆及配對保護對照，呈現第六關慢速輸入保護 3 星／不保護 1 星，也保留第五關保護反而有代價的結果。前後資料、基準原生數值重現與來源雜湊見 BALANCE_V2；新原生／真實時間錄影及真人判定尚待。
- 狀態 IN_PROGRESS，尚未宣稱好玩、完成平衡或 Dot 通過。

## MFT-005（教學練習入口與重開隔離）

- Codex 代碼查驗，規格 3.3／3.8／12.2：原先由說明設定一個延後消耗的練習旗標；進入練習簡介後返回，再開始正式局，可能仍被當成練習。反之重開練習局可能丟失標記而更新正式成績。
- 修改中：練習簡介採明確路由，開局／替換確認明確攜帶 practice，重開保留目前局標記；正式開始不繼承先前的練習意圖。新增導航取消／重開模型回歸，完整練習工程重播仍檢查結算不解鎖第二關。尚未有此修復的實測結果。
- 146a7ca 的 21 項單元全部通過，含練習取消／重開隔離及設定 I/O 實際失敗／重試回歸；完整練習結算工程重播因前序 UI 失敗尚未執行。
- 狀態 READY_FOR_RETEST（模型與導航範圍），完整練習流程仍待。

## MFT-004（首次教學角色空白）

- 嚴重度：P2，規格 3.3／7／12.3。Source `69c3933a7833429a32b537ac2ba7e1ff93739f4b`；validation-14 的 `928A2329-FDF4-4A27-9E2E-C7CEDB9577DC.png`（tutorial-first）。
- Dot 獨立查核：使用者轉交，看到苔角鹿訂單、耐心 65 與選中框，但角色圖空白；單張可能是入場瞬間，尚未判為持續故障，要求穩定畫面。Dot 同次確認原生 19 項、18 通過／1 觸覺失敗／0 略過，以及第一關 3 成功／2 偏好／2 星與第二關解鎖；所列首頁、介紹、busy 標準／大字左手、結果實圖未見明確裁切。這些觀察不代表整個 UI 或美術通過。
- Codex 代碼定位：`begin` 建立訂單並顯示教學，沒有在教學前呼叫 `syncKitchen`；角色節點原本要到 dismissLesson → resume 才建立。現有角色沒有 alpha 入場漸變，因此缺少初始同步可直接解釋該畫面；仍需新候選實圖驗證。
- 修改中：在顯示首次教學前同步場景；隔離存檔的 SceneLifecycle 回歸確認節點／texture 已存在、alpha=1、教學與時鐘維持暫停且 resize 不重複建立角色；真實 UI 保留原教學斷言，新增 0／1／3 秒穩定截圖。使用者要求保留的 run 39446499495 不取消、不重開；待後續修復候選實測。
- 修復 SHA `3bc6d37b2804a7ed61c5d51b9cdd937da3713413`，run 39450296133 主 job 118723012974，artifact 12279107638。節點回歸實際 passed；原生教學 0／1／3 秒 PNG 都清楚顯示苔角鹿、耐心 65 與教學暫停，三檔 SHA-256 皆為 `21f257d10322a86542220dd09331b27257685f780e44f8d6943e83db90bba398`。見 [INTEGRATION_3bc6d37](INTEGRATION_3bc6d37/)。
- 使用者另轉交 Dot 獨立實看 7c79fe0 的 F0FE16B3 首次教學 3 秒圖：苔角鹿完整可見，僅此時點已確認，不能擴稱所有入場／動畫通過。
- 狀態 READY_FOR_RETEST（僅角色同步修復）；主驗證仍 22 通過／1 滑桿查詢失敗／0 略過，不代稱 Dot 已通過或整個流程成功。

## MFT-003（設定文字區點按與保存回歸）

- 嚴重度：P2，規格 4／12.2；Source `69c3933a7833429a32b537ac2ba7e1ff93739f4b`，[run 39441785452](https://github.com/Kongdean2374/MonsterFoodTruck/actions/runs/39441785452)，artifact `12275303224`。
- 原生結果：18 passed／1 failed／0 skipped（15 單元；3 UI 通過、1 UI 失敗）。原教學操作已到達真實第一關結算及第二關解鎖，但同一長案例之後於 FlowTests.swift:68 讀取重開後觸覺開關，預期 0、實際 1，整體 failure。
- 畫面：重開前即能看到高對比／大字等仍為關閉，原 Toggle 的文字區點按未切換開關；不能將原預期檔名當成旗標已生效。尚未證明是檔案寫入失敗，不作該歸因。
- 修改中：文字區提供至少 44pt 的操作區，維持原生開關與明確 accessibility label；每次點按立即檢查實際值，再檢查重開保存，不刪除觸覺斷言。完成設定等最新原子寫入完成才關閉，失敗保留畫面及重試；雙壞檔則保護原檔並允許返回／明確清除流程。
- 同次修正：以 failureCount 判斷失敗附件，避免 passed 案例被過早 hasSucceeded 值命名為 FAILED；原 artifact 及原生統計保留。
- `0171012` 的 run 39446499495：小尺寸 2 UI 通過；大尺寸 1 通過／1 失敗，左手配置預期 1 實際 0。實圖前兩個開關已開、左手配置仍在可視區下方；增加點按中心在可視範圍的捲動條件，保留所有數值與重開保存斷言。主驗證因 runner 容量被 GitHub 取消，沒有執行，不套用 layout 成果為主驗證通過。詳 [INTEGRATION_0171012](INTEGRATION_0171012/)。
- `3bc6d37` 主驗證 23 項中 22 通過／1 失敗／0 略過：三個切換立即斷言通過，但 helper 直接取 frame 時，上方音樂滑桿已不在 Form 的可及性樹，捲動前即被 XCTest 判無匹配而失敗。新增先檢查 exists 再捲動／取 frame 的條件，保留全部原斷言；觸覺重開保存本輪未執行，仍待回歸。
- 146a7ca 的主案例實際通過觸覺即時／程序重開後 0、音量保存及減少動態保存；整例仍因之後確認窗 MFT-008 失敗。SE 小尺寸仍被捲動跨越目標阻擋（1 通過／1 失敗），大尺寸 2 通過。下一候選短距離捲動並在失敗時保留逐步位置；新增高對比／大字／左手程序重開後值仍為 1 的明確斷言，保留全部舊斷言。
- 使用者轉交 Dot 對 3bc6d37 的獨立結果：large 成功，small debugScenario 成功、HomeLayouts 於 FlowTests.swift:127 缺高對比 snapshot（job 118730361469）。沒有重開重複 job；等 146 完成後如實記錄 SE 仍失敗。
- 7c79fe0 的 small 實際 3 passed／0 failed／0 skipped；large 2 passed／1 failed／0 skipped。使用者轉交 Dot 獨立核對同一 run／兩個 job。已實看 large 附件：十二次 x0.5 短拖後左手列位置完全不變，起點落在模式分段選擇器，改在 Form 留白 x0.03 拖曳，保留原斷言及位置匯出。這仍不是三尺寸通過。
- 證據：[INTEGRATION_146a7ca](INTEGRATION_146a7ca/)、[INTEGRATION_69c3933](INTEGRATION_69c3933/)。狀態 READY_FOR_RETEST 僅觸覺保存子項；SE 可視捲動仍 IN_PROGRESS，未有 Dot 通過判定。

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

### MFT-013 後續：2bb 大尺寸儲存與關閉同步

- 原大尺寸 job 118823068619 已自行 failure，2／1／0；artifact 12290254187 已下載核對 SHA-256。FlowTests.swift:167 在「完成」後等導覽列消失失敗，失敗截圖已是完整首頁；保持原失敗，不稱三尺寸通過。
- 原 XCTest 32.64 秒錄影末段仍見停用的完成按鈕，之後才關閉。原條件把非同步 ordered save 與 sheet 轉場合併計五秒，沒有先等寫入階段；來源與未改圖片見 INTEGRATION_2bb77a9。尚未斷言單一 UIKit 根因或已修好。
- 本地待測修正只讓既有 isClosingSettings 顯示「儲存中…」，UI 先等該真實狀態結束，再保留原導覽列不存在／首頁 hittable 五秒斷言及原三個設定重開值。28e474d 原生 job 已在執行，保留，不為本地修正取消它或重跑不變 SHA。

### MFT-012 後續：三尺寸局部標籤實圖

- Codex 已實看 2bb 主／SE3／15 Pro Max 原 busy 圖，成品／爐台／備料固定奶油淺底可讀、保留木紋；原字壓深木紋的局部改動已有實物，未代稱 Dot 通過。原生三尺寸整體仍有 large 儲存關閉等待失敗，兩者範圍分開，見 INTEGRATION_2bb77a9。

### MFT-016 本地必要驗收準備

- 原主流程 28e474d 正在回歸期間，本地準備完整 SpriteKit 後代入場／暫停計數與 update 取樣最大值、原二十次 UI 方法的部件不增加斷言，原根層／音訊斷言仍保留。根與後代、取樣與 profiler、SpriteKit 與 SwiftUI 範圍明列，不新增玩法。
- Swift／Python 語法檢查完成；真正 2bb 根層 JSON 被新匯出器拒絕升格成全樹結果。新 Apple SDK 編譯與原生數值仍待，狀態 IN_PROGRESS，不修改原 job 或宣稱已通過。見 NODE_INVENTORY_PENDING.md。
