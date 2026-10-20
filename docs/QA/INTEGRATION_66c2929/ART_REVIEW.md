# 7.7 獨立查驗入口（未評分）

App source `66c2929dd05c28af1b0c3ec8a79805446c6dc023`／build 25；同 SHA 原生 scopes 與裝置 IPA 已成功，原物／逐檔 hash／直接圖連結見 [完整索引](README.md)。這是待獨立判定資料，沒有替 Dot 打分。

規格 7.7：六項各 0～4、每項至少 3、總分至少 20／24，且不能有重大缺陷。7.3 既有母版風格條件通過仍保留其原範圍，不升格為下表通過。

| 項目 | 實際證據入口 | 獨立分數／理由 |
|---|---|---|
| 角色與場景風格一致 | 同索引首頁、SE busy、三角色五表情；ASSET_MANIFEST 保留原母版來源 | UNVERIFIED |
| 小尺寸料理／魔物／計時可辨 | SE3 375×667pt 的 busy／高對比／左手，三菜與耐心／工序／爪子倒數 | UNVERIFIED |
| 表情與動作有個性 | SE3 深／淺底五表情；原 layout artifact 的 reach／receive／return-to-anchor 截圖；正常流程 MOV | UNVERIFIED，取樣不能代替連續動態接合查驗 |
| UI 完成度／對齊／可讀／操作 | 三尺寸 HomeLayouts、原基礎完整教學／實際第一關／全部設定與保存重開、真實後關點按 | UNVERIFIED；原生操作回歸成功不等於審美評分 |
| 透明／圖層／動畫原點／安全區 | ArtReview 深／淺底動作取樣與三尺寸原圖；MFT-007 原圖及 ALPHA_METHOD_PENDING | UNVERIFIED；龍低 Alpha 紅黃點／毛邊仍 OPEN，不能因縮圖不明顯關閉 |
| 忙碌場面目標／警告／空間 | 明確標示的 DEBUG busy 標準右手／大字高對比左手；正常後關真實偷嚐／整理／餐蓋 | UNVERIFIED；固定情境不等於全程點按 |

原 layout-small artifact 的 24 PNG 包含全部深淺底／動作取樣，SCREENSHOT_INDEX.json 記原檔名與 hash。Codex 已實看本索引列出的靜態畫面，未稱親看完整 MOV／所有接合；影片只有畫面，不能代音訊監聽。

MFT-007 沿用圖片工具處理並保留原稿；兩次工具修稿未解決，沒有使用 Python 或 shader 清理繞過限制。使用者睡眠期間的特定方法問題保留在 [ALPHA_METHOD_PENDING](../ALPHA_METHOD_PENDING.md)，本文件不提出新的逐階段授權要求。
