# 工作狀態

2026-10-20。完整遊戲仍在製作與回歸，沒有最終驗收或完整遊戲 IPA。

## 恢復入口與單一寫入者

- 倉庫 `Kongdean2374/MonsterFoodTruck`，公開，預設分支 main。單一工作樹 `/workspace/MonsterFoodTruck`、整合分支 `integration/full-game`，目前 Codex 對話為唯一產品寫入者。不 reset／force push／覆蓋未知工作。
- 先讀 `git status`、本檔及 [問題紀錄](QA/ISSUE_LOG.md)；完整規格 [PROJECT_SPEC](PROJECT_SPEC.md)。歷史失敗及 Dot 的獨立判定保存在問題紀錄與各 QA 目錄，不以新成功改寫。
- 目前正在驗證候選 `7c79fe0e0111f9d44212fc8e36866ab9a80a9a29`；[Validate 39462050918](https://github.com/Kongdean2374/MonsterFoodTruck/actions/runs/39462050918) 正在執行，主 job 118763757859。full_qa／layout_qa 均開啟；主流程失敗仍會跑兩尺寸。沒有取消／重開重複 job。
- main 仍為 `b12837c80dfc9f44ae6035c8bf7334f0fff66fdb` 的核心候選。最終需將完整候選整合到 main，再產出同 SHA 的真實測試與未簽名裝置包。

## 已有獨立判定（範圍不可擴張）

- DOT-001：Dot 親自下載 f8707b553758ba86605d0b70b6f97be35b516b8e 的 artifact 12265820706，確認 Validate 39424665706／IPA 39424665179 成功、2 passed／0 failed／0 skipped、真實 P1-launch、SHA256SUMS／iPhoneOS／iOS 17／arm64／Mach-O platform=2／無 LC_CODE_SIGNATURE。VERIFIED_CLOSED 僅啟動工程的安裝與封裝，該小 IPA 不是完整遊戲。
- MFT-001：b12837c 的 Validate 39430419215／job 118653712104，14 單元＋1 啟動 UI 通過，Dot 獨立確認存檔回呼逾時消失。僅核心／存檔等待問題 VERIFIED_CLOSED。
- 7.3：Dot 查看原 blob、三角色三菜／餐車母版與 0171012 兩張 SE3 實圖，經使用者轉交有條件通過沿用同一母版風格及小尺寸辨識，可繼續表情／部件／狀態／動畫，不需額外使用者逐階段同意。不是 7.7 六項評分、動態接合或全遊戲通過。
- Dot 對 69c3933 確認實際第一關 3 成功／2 偏好／2 星、第二關解鎖，且所列畫面未見明確裁切；該整體仍 18 passed／1 觸覺斷言 failed／0 skipped。首次教學角色空白另列 MFT-004。
- Dot 對 3bc6d37 的尺寸查核：large 成功；small debugScenario 通過、HomeLayouts 於 FlowTests.swift:127 缺高對比 snapshot（job 118730361469）。146 已等原 run 完成再記錄結果，沒有另重跑同 SHA。

## 最新已完成原生結果

- `146a7caffbbc8b88489eb4be112dbfd04a7e4031`／Validate 39455229683，整體 failure。主 job 25 項、24 passed／1 failed／0 skipped（21 單元全過、UI 3 過／1 失敗）；small 1 過／1 失敗；large 2 過。觸覺即時與程序重開後 0、音量與減少動態保存通過，後續「還原設定」確認窗未關閉 MFT-008 失敗；SE 的大幅捲動反覆跨越高對比目標。原始 PNG／summary／來源見 [INTEGRATION_146a7ca](QA/INTEGRATION_146a7ca/)。六關延伸、影片、效能未執行。
- `3bc6d37`／Validate 39450296133 主 job 23 項、22 passed／1 failed／0 skipped（19 單元全過），失敗為先讀取移出 Form 可及性樹的音樂 slider frame。首次教學節點回歸通過，0／1／3 秒實際 PNG 相同、角色與耐心 65 穩定；MFT-004 READY_FOR_RETEST，未代稱 Dot 關閉。見 [INTEGRATION_3bc6d37](QA/INTEGRATION_3bc6d37/)。
- 較早整合與原失敗都在 [問題紀錄](QA/ISSUE_LOG.md)，包括 d59f212 的裝盤失敗與三次測試前 PNG 處理檢查失敗；均未略過或冒稱執行成功。

## 目前候選與待驗證修正

- 7c79fe0：先 exists 再 frame，改短距離捲動、以實際導覽列判可視中心；保留舊設定／觸覺／重開斷言，新增高對比／大字／左手重開仍為 1。確認窗明確 dismiss、完整按鈕命中區、固定淺色。原教學／暫停／保存／第一關／設定／清除仍完整執行。
- 同母版擴作：鹿／小鬼各八部件與五表情、三菜各九狀態、六工位道具，三角色及餐車分層接入一般遊玩；PNG 與圖片工具輸出逐位元組相同，JSON 只作執行期裁切及 anchor。ArtReviewTests 在三尺寸提供真實深淺底／五表情／動作 PNG。尚待實物查驗。
- MFT-007：龍的紅黃低 Alpha 殘點與毛邊仍開放。兩次圖片工具處理未消除同類缺陷，未推選／覆蓋原稿，**未使用 Python 圖片編修**。使用者明確限制先沿用圖片工具；無法解決時保留缺陷繼續其他工作，不重問一般授權。
- Content v2：原生舊版 72 筆策略診斷全三星、0 預告／餐蓋，已調整後四關到達與暴露起始 7→3 秒，預告仍普通 3／舒緩 5 秒、耐心與菜時間不變。Linux 官方 Swift 6.1.2 編譯同一 App Domain，先重現舊原生 72 筆，再比較保護收益與代價；見 [BALANCE_V2](QA/BALANCE_V2/)。不是 iOS UI、真人或 Dot 平衡通過。
- 待新候選原生驗證：料理完成亮點、脆餅滋滋與少量出餐粒子；減少動態清理待離場節點，避免暫停動畫留下鬼影，新增原生節點回歸。同步 ContentVersion 的實際資料／資產集識別與包檢查。
- 待新候選原生驗證 MFT-009：新動態參考解有意省略選配料，原評分邊界案例卻假設每單偏好全達成。Linux 13 個原方法與全部斷言，12 方法過／1 失敗（4 斷言）；改以同 validator 的全偏好短菜軌跡建立門檻案例，新增全偏好前提斷言，13 方法重測全過。原失敗／重測均保存；原生結果獨立等待，沒有刪除失敗斷言或放寬星數門檻。

## 下一步與能力邊界

- 等既有 7c79fe0，下載原生摘要／實圖，修實際失敗；整合上述待測改動後用新 SHA 重測，不重開不變的舊候選。
- 完整延伸測試：正常前景時鐘六關命令重播及真實錄影；關卡解鎖由實際六次結算取得，再關閉命令 driver，真實點按第五關餐蓋／取下／直接出餐／歸還重用；練習隔離保存、背景五秒不消耗耐心、故意無操作失敗、重試／取消／放棄。工程重播不是人工遊玩。
- 二十次真實進出場景記錄節點、音效實例、task_info 取樣記憶體、SpriteKit update cadence 及 handler→next-update。它們不是實體 FPS、touch-to-photon 或連續 profiler 峰值。
- Linux 無 Xcode／iOS Simulator。真實原生使用 GitHub macos-15 Apple Silicon、Xcode 16.4／Swift 6.1.2／iOS 18.5 runtime。iOS 17 是部署下限，沒有宣稱實際 iOS 17 runtime 或 iPhone 17 Pro 真機通過。
- 25 個原創離線 WAV 及播放器已整合、靜態無削波；聽覺、真實觸覺、真機效能與飛航模式實測仍待。原始母版／舊稿保留；7.7 與完整遊戲 Dot 驗收未取得。
- 最終只交付同一完整 source SHA、成功原生 scopes、可追溯實際 PNG／影片、無簽名 iPhoneOS IPA、必要識別欄位／Mach-O／逐檔校驗／SHA256SUMS。不得以 bootstrap IPA、固定情境或純 Domain 結果代替。
