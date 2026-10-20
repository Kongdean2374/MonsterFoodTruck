# 固定候選的短片證據補拍

App 固定使用 `66c2929dd05c28af1b0c3ec8a79805446c6dc023`／build 25。原 41 項回歸、裝置 IPA、47 資源與 20 檔 checksum 已獨立核驗，可列工程候選；尚未完整驗收。

本目錄只存外部拍攝 harness，不改 App、角色素材、遊戲時鐘、關卡、數值或既有測試。Mac job 另 checkout 原 source，僅把 UI-test target 的 ArtReviewTests.swift 換成拍攝方法；App／project／資源／原模型測試／建置腳本都必須和原候選相同。實際 App SHA 與拍攝 harness SHA 在 SOURCE_PROVENANCE 分開記錄。

拍攝五個有限案例：

1. SE3 深底，三角色同母版既有動作連播三次：初始訂單／小鬼伸手、三位接餐、偷嚐反應與回待機。
2. SE3 淺底，相同三次完整動作。
3. 星火濃湯：第一關第一位鹿，真實點按備料／烹調／裝盤／餐蓋／香草／出餐。
4. 雲菇燉菜：第五關第一位鹿，正常時鐘等焦邊及一次偷嚐，再實際整理／餐蓋／香草／出餐。
5. 月角脆餅：第四關第一位鹿，真實點按相同料理流程。

料理拍攝只還原原候選已賺取解鎖的真實保存檔，原 bytes／hash 保留，再透過正常 UI 確認替換舊局。沒有改保存 JSON、注入訂單／分數或命令 driver；但這是有已保存進度的三段單客人流程，**不是新手自然解鎖、完整第五關或全部遊玩通過**。每段新 App save 另外匯出。

每段由 native simctl 原樣錄 MOV，包含完整相鄰影格；AVAssetReader 解碼每一實際 frame 並列 presentation timestamp CSV，任何索引只引用 actual_seconds。沒有用 image generator 製作 App 影片或把 sparse PNG 補成動畫。MOV 無音軌；XCTest 斷言只驗證拍攝操作，不替 7.7 評分。

原 ArtReview 的 reach／receive／return PNG 是離散取樣，檔名不保證實際階段。舊 MOV 第 01 張 actual=3.918333 秒、requested=28.332667 秒，兩者不可互換。新影片 PTS 直接由解碼影格取得，沒有 seek tolerance 的 requested 時刻替代。

只有 commit message 以 `[motion-evidence-66c2929]` 開始、且六個 product／test／build-script tree 都仍與候選相同時，才走此獨立短片路由，不重跑六關或重打 IPA；若任何 product tree 改動，正常完整 Validate 仍執行。路由成功不是新的 41 項回歸成功。失敗的拍攝 XCTest／日誌／原 MOV／摘要也上傳，不改寫原候選或原失敗。

已取得 [9a34d46 原生補拍](FAILED_9a34d46.md)：四項操作通過、脆餅啟動失敗，時間戳 JSON 匯出也失敗，整體 failure。四段有效原 MOV 保留後只補缺少的脆餅，並唯讀重新解析已有影片；不重拍成功案例、不重跑完整六關。操作通過不是接合／7.7 通過。

最新 [獨立分數](INDEPENDENT_REVIEW_20261021.md) 為 3／3／UNVERIFIED／3／2／3，不填總分；[原靜態與 actual 索引](EXISTING_EVIDENCE_INDEX.md)、[完整剩餘驗收清單](REMAINING_ACCEPTANCE.md)。
