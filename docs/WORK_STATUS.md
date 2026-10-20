# 工作狀態

2026-10-20。完整遊戲仍在回歸，沒有最終驗收或完整遊戲 IPA。最新 source `d09011f5c55c8ab29632e6d7ffbf4cc15f16743e`，[Validate 39489728099](https://github.com/Kongdean2374/MonsterFoodTruck/actions/runs/39489728099) 主 job 自行 failure：基礎 31／0／0、延伸 3／1／0；small／large 各 3／0／0，封裝依門檻 skipped。實際後段保存檔已確定香草可點性查詢期間遭偷嚐；下一候選只修此真實 UI 操作順序，原斷言／時鐘及失敗證據均保留。二十次完整 SpriteKit 子樹已有新原生量測，見 [實物與範圍](QA/INTEGRATION_d09011f/)。查詢節奏約 5–10 分鐘，無結果不固定回報。

## 恢復入口與單一寫入者

- 倉庫 `Kongdean2374/MonsterFoodTruck`，公開，預設分支 main。單一工作樹 `/workspace/MonsterFoodTruck`、整合分支 `integration/full-game`，目前 Codex 對話為唯一產品寫入者。不 reset／force push／覆蓋未知工作。
- 先讀 `git status`、本檔及 [問題紀錄](QA/ISSUE_LOG.md)；完整規格 [PROJECT_SPEC](PROJECT_SPEC.md)。歷史失敗及 Dot 的獨立判定保存在問題紀錄與各 QA 目錄，不以新成功改寫。
- 最新完成原生候選 `28e474db37fdc8c9be40a490cd9c51a1070bd888`／Validate 39481483503：基礎 31／0／0，延伸 2／2／0，small／large 各 3／0／0，全部原 job 已自行結束；主失敗，無 IPA。失敗是配料遭接續偷嚐後未再整理，以及後續 Performance 啟動終止前 App 失敗，未略過任何失敗測試。
- main 仍為 `b12837c80dfc9f44ae6035c8bf7334f0fff66fdb` 的核心候選。完整候選可在指定整合分支手動產出同 SHA 的完整驗證與未簽名裝置包；仍須全部原生 scopes 通過，不為產包先改 main。

## 已有獨立判定（範圍不可擴張）

- DOT-001：Dot 親自下載 f8707b553758ba86605d0b70b6f97be35b516b8e 的 artifact 12265820706，確認 Validate 39424665706／IPA 39424665179 成功、2 passed／0 failed／0 skipped、真實 P1-launch、SHA256SUMS／iPhoneOS／iOS 17／arm64／Mach-O platform=2／無 LC_CODE_SIGNATURE。VERIFIED_CLOSED 僅啟動工程的安裝與封裝，該小 IPA 不是完整遊戲。
- MFT-001：b12837c 的 Validate 39430419215／job 118653712104，14 單元＋1 啟動 UI 通過，Dot 獨立確認存檔回呼逾時消失。僅核心／存檔等待問題 VERIFIED_CLOSED。
- 7.3：Dot 查看原 blob、三角色三菜／餐車母版與 0171012 兩張 SE3 實圖，經使用者轉交有條件通過沿用同一母版風格及小尺寸辨識，可繼續表情／部件／狀態／動畫，不需額外使用者逐階段同意。不是 7.7 六項評分、動態接合或全遊戲通過。
- Dot 對 69c3933 確認實際第一關 3 成功／2 偏好／2 星、第二關解鎖，且所列畫面未見明確裁切；該整體仍 18 passed／1 觸覺斷言 failed／0 skipped。首次教學角色空白另列 MFT-004。
- Dot 對 3bc6d37 的尺寸查核：large 成功；small debugScenario 通過、HomeLayouts 於 FlowTests.swift:127 缺高對比 snapshot（job 118730361469）。146 已等原 run 完成再記錄結果，沒有另重跑同 SHA。

## 最新已完成原生結果與修正

- 2bb77a9：26 單元與 5 基礎 UI 全部通過，完整 Flow 的教學／實際第一關／保存／全部設定重開／還原與清除取消及確認均過；MFT-008／014 有新原生回歸，不代稱 Dot 關閉。延伸練習隔離、背景／失敗／重試／取消／放棄、二十次真實場景進出各自通過；六次正常時鐘工程 session 與結算／重開解鎖走過，但同一方法之後第五關實際餐蓋點按未先整理焦邊料理，點香草芽失敗。原生摘要 31／0／0＋3／1／0，整體 failure，見 [實物與保留失敗](QA/INTEGRATION_2bb77a9/)。

- b53ff60 主基準 22 單元全過、UI 4 過／1 失敗。原暫停點按、第一關實際點按結算／第二關解鎖、觸覺／音量／減少動態／高對比／大字／左手／模式重開保存均走過；還原設定取消／確認及 55%／75% 預設值走過。原整例後續在「清除進度 → 取消」仍見確認窗而失敗，全部原斷言保留，MFT-008 開放。六關延伸／影片／效能未執行。見 [原生實物](QA/INTEGRATION_b53ff60/)。
- 該 artifact 12286245660 為 546MB，超過連接器下載上限；只讀匯出 run 39468927250／小型 artifact 12286138427 原樣取出 PNG／摘要，附 archive digest／原 source／失敗狀態及逐檔 hash。匯出 success 不是測試 success，沒有重建或重跑。後續原生與 IPA workflow 已分開小型 review 與重型診斷產物。
- 7c79fe0／Validate 39462050918：主 24 passed／2 failed／0 skipped，small 3 過、large 2 過／1 失敗。large 原十二次手勢被分段選擇器消耗，左手列完全不動；b53 改用 Form 邊緣留白，原重測兩尺寸各 3 項通過。原評分邊界前提及裝飾森林命中問題已由 b53 原生分別通過；整個遊戲仍未通過。歷史原始圖／日誌在 [INTEGRATION_7c79fe0](QA/INTEGRATION_7c79fe0/)。
- Dot 已獨立靜態覆核 7c 四張圖：三秒鹿完整可見（僅該時點）、深淺底五表情可區分、busy 資訊可辨且虛線未壓耐心。底字裁切／龍 Alpha 仍開放，新增側標籤對比 MFT-012，不是動畫／命中／7.7 通過。b53 深底實圖底列文字完整，無遮罩空客位已移至奶油資訊區；Codex 已實看，未代稱 Dot 關閉。
- 146a7ca／Validate 39455229683 主 24 過／1 失敗（21 單元過）、small 1 過／1 失敗、large 2 過；此前失敗、PNG 處理阻擋、保存逾時與首次教學角色空白全部保存在問題紀錄，不以新結果覆蓋。

## 下一候選待原生驗證

- MFT-015：保留原餐蓋與香草芽／兩次出餐斷言，真實點按依可用命令先整理受損料理，輔助使用值亦顯示偏好失效。沒有調整耐心、菜時間、注入狀態或忽略舊失敗。待新 SHA 原生。

- 9882a0c 新增 SceneLifecycle 案例直接寫入 private(set) document，原生編譯拒絕；主／small／large 均 test build failure，未執行任何 XCTest／沒有新 App 圖，不能將 Linux 通過數套用。2bb77a9 修正 fixture 先經 SaveStore 真實原子寫入再載入 AppModel，保留產品封裝與原斷言；見 QA/INTEGRATION_9882a0c。

- MFT-008：設定與確認改用單一 sheet 容器，保存成功後替換內容，避免兩張 sheet 關閉／重開交錯。保留取消、雙確認、程序重開及值保留全部原斷言，新增呈現狀態／取消不清資料模型回歸。2bb 原完整 UI Flow 與呈現取消模型均已通過；新擴充確認清除斷言尚待原生，未代稱 Dot 關閉。
- MFT-012：成品／爐台／備料置於固定奶油淺底小標籤，保留木紋與工位材質，增加 4pt 寬度相應對齊；2bb 主實圖已看到固定淺底清楚可讀；small／large 原附件待下載覆核，不先稱三尺寸通過。
- MFT-013：原 small 附件 0ACAF0A3 名為首頁但實際仍在設定保存。已更正索引並保留原檔／實際 pass 數；HomeLayouts 等設定導覽列消失及首頁可點後才拍，沒有任意 sleep 或生成替代圖。
- 核心新增滿爐／滿成品拒絕不移動料理、客人離場取消整理且只回收一次資源；Linux 官方 Swift 6.1.2 同一 Domain 15 個原方法／全部斷言通過。另加舊 contentVersion session 丟棄後仍保存永久紀錄／設定的真實檔案 I/O 回歸；Linux 同一 SaveStore 的 4 個原方法全部通過，2bb 原生新增案例已通過。
- Content v2：後四關訂單交錯、暴露起始 7→3 秒，預告普通 3／舒緩 5 秒及原耐心／菜時間不變。原生 72 筆候選與 Linux 配對診斷相符，保護有收益也有代價，見 BALANCE_V2 及 7c 證據；不是真人好玩或平衡通過。
- 同母版三角色八部件／五表情、三菜九狀態與工位道具均已接入正常遊玩；PNG 與圖片工具輸出逐位元組相同，JSON 僅 runtime 裁切／anchor。正式流程／動態接合及最終藝術評分尚待。
- MFT-007：龍低 Alpha 殘點與毛邊仍開放。兩次圖片工具修稿未解決，未推選／覆蓋原稿，未使用 Python／其他程式繞過圖片編修限制；方法與待查資料見 ALPHA_METHOD_PENDING。必要個人方法授權先整理，不打斷其他工作。
- CLI GitHub 憑證目前回傳 401，連接器仍可讀 CI；先透過可用倉庫工具提交修正，整合分支產品 push 自動執行相同 full／layout scopes。沒有 Apple 帳號或簽名操作。
- 本次修正（待新 SHA 原生）：完整 Validate 三個原生 job 都成功後，自動收集同次原始 artifact／digest／run／source／四份摘要再 archive 同 SHA 裝置包，不重跑成功 XCTest。四項封裝門檻 fixture 通過，真正 b53 small／large archive 可原樣收集，真正 988 失敗 artifact 被拒絕；actionlint 1.7.12 檢查兩份 workflow 通過。這不是原生遊戲或 IPA 成功，待下一候選實際執行；現有 2bb job 不重開。
- 本次修正（待新 SHA 原生）：真正 25 WAV bytes 的唯讀 PCM／SHA-256 查驗無單檔滿刻度樣本、循環邊界差為 0；共同 0.6 混音餘量保留 slider 比例，六音效＋配樂保守 peak 上界 0.856，原生聽覺仍未驗。新增確認清除後重新讀存檔仍保留非預設設定／清除教學與 session 的斷言；主模擬器選取也明確固定 18.5，不依 runtime 列表順序。這些與封裝銜接一併留待下一候選，不冒用目前 2bb 的執行結果。
- 本次修正（待新 SHA 原生）：延伸原生摘要／PNG 先於錄影停止匯出；SIGINT 收尾 30 秒、必要清理 5 秒，強制終止仍判影片驗證失敗。獨立 step 逾時保留 artifact 上傳時間，終止訊號寫實際狀態。原 MOV 保留並 hash，另唯讀解碼 36 個原尺寸時間點供小型 review，明列取樣錯誤，不改任何美術 PNG 或以取樣宣稱整段動畫通過。Swift 僅語法解析，Mac API／實際錄影收尾仍待新候選。

## 下一步與能力邊界

- 既有 b53ff60 已全部結束且兩尺寸原圖／摘要已下載；2bb 基礎完整流程已通過，修其延伸 MFT-015 實際失敗，整合上述待測改動後用新 SHA 重測，不重開不變的舊候選。
- 完整延伸測試：正常前景時鐘六關命令重播及真實錄影；關卡解鎖由實際六次結算取得，再關閉命令 driver，真實點按第五關餐蓋／取下／直接出餐／歸還重用；練習隔離保存、背景五秒不消耗耐心、故意無操作失敗、重試／取消／放棄。工程重播不是人工遊玩。
- 二十次真實進出場景目前只記錄直接子節點（非全部後代）、音效實例、task_info 取樣記憶體、SpriteKit update cadence 及 handler→next-update。它們不是實體 FPS、touch-to-photon 或連續 profiler 峰值。
- Linux 無 Xcode／iOS Simulator。真實原生使用 GitHub macos-15 Apple Silicon、Xcode 16.4／Swift 6.1.2／iOS 18.5 runtime。iOS 17 是部署下限，沒有宣稱實際 iOS 17 runtime 或 iPhone 17 Pro 真機通過。
- 25 個原創離線 WAV 及播放器已整合、靜態無削波；聽覺、真實觸覺、真機效能與飛航模式實測仍待。原始母版／舊稿保留；7.7 與完整遊戲 Dot 驗收未取得。
- 最終只交付同一完整 source SHA、成功原生 scopes、可追溯實際 PNG／影片、無簽名 iPhoneOS IPA、必要識別欄位／Mach-O／逐檔校驗／SHA256SUMS。不得以 bootstrap IPA、固定情境或純 Domain 結果代替。

- Dot 已獨立核對 2bb review artifact SHA-256／基礎 31／0／0／延伸 3／1／0、六份工程 session 與模擬器診斷；未稱全遊戲或聽感通過。Codex 依提醒查到 nodes=1 實際是 `scene.children.count`，僅根下一層，不能宣稱全部角色部件穩定，列 MFT-016。先完成 MFT-015 原主流程同 SHA 回歸，不新增產品功能；後續補足原規格必要證據。

- 目前整合 HEAD `28e474db37fdc8c9be40a490cd9c51a1070bd888`／Validate 39481483503／主 job 118832059204 已開始原生，含 MFT-015 既有修正、四 scopes 成功後同 SHA 自動裝置 archive；不新增產品功能。2bb large 原失敗已下載核對，本地保留 MFT-013 儲存階段同步修正待目前回歸完成，不取消或另開重複 job。

- 依最新查詢節奏約 5–10 分鐘看一次 CI，沒有新結果不固定刷屏。獨立必要驗收僅本地準備：MFT-016 改為根層／完整 SpriteKit 後代分列入場、暫停及 update 取樣最大值，延伸原二十次實際進場斷言；原根層 JSON 被新全樹匯出門檻明確拒絕，不補造數值。僅語法與真實舊資料拒絕檢查，未有原生新數字，未套用正在跑的 28e474d，見 NODE_INVENTORY_PENDING。

- 28e474d 所有原 job 已自行結束：基礎 31／0／0，延伸 2／2／0，小大各 3／0／0，package-device 因主失敗 skipped；沒有 IPA。原 review／layout archive 已下載核對 digest，原失敗與實圖見 INTEGRATION_28e474d。第一輪整理與香草點按走過；依實際時序的 Domain 診斷是偷嚐接續並取消配料，下一修正候選有界處理第二次受損、保留原斷言並匯出真實後段 session。Performance 在啟動終止前 App 失敗，沒有新 20 次數據，MFT-017 開放。

- 下一修正候選僅修既有驗證：真實 UI 對第二次受損有界整理／重加原香草／出餐，原斷言及正常時鐘保留；失敗先留原圖／hierarchy 再透過正常暫停 UI 保存現場。真正後段保存檔另匯出並檢查原兩位客人、餐蓋取下／重用與香草輸入。MFT-013 先等實際儲存階段再執行原關閉斷言；MFT-016 加全 SpriteKit 子樹量測，不改玩法。新數值與新修正尚待同 SHA 原生，不借用舊成功。
