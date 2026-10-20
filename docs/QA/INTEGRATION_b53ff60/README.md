# b53ff60 原生查驗索引

來源 **b53ff6020f9f5227c6a636f66859d393277a41ca**，不是後續證據匯出程式的 SHA。
[Validate 39466494713](https://github.com/Kongdean2374/MonsterFoodTruck/actions/runs/39466494713)，主 job **118779164125 failure**：**27 項，26 passed／1 failed／0 skipped**。22 項單元全過；5 項 UI 中 4 過、原完整點按案例 1 失敗。小 job **118784334535**／大 job **118784334216** 各 **3 passed／0 failed／0 skipped**，原始 JSON 與 artifact digest 見本目錄 LAYOUT_TEST_SUMMARY／LAYOUT_PROVENANCE。沒有重開同 SHA。

原 artifact **12286245660**，546,147,442 bytes，超過下載連接器的 512 MiB 上限。以 [只讀匯出 39468927250](https://github.com/Kongdean2374/MonsterFoodTruck/actions/runs/39468927250) 取出同一 artifact 的原始 PNG／摘要，沒有重建、重跑測試或修改圖片；小型 artifact **12286138427**。匯出成功僅代表讀取成功。原 archive SHA-256、原 source／run／失敗狀態及逐檔雜湊見 [EXPORT_PROVENANCE.json](EXPORT_PROVENANCE.json)；本目錄選圖及原摘要另附 [SHA256SUMS](SHA256SUMS)。

## 真實結果與失敗

- 原評分門檻方法及新增全偏好前提、減少動態清理離場節點方法均原生通過；僅此回歸範圍，未由 Codex 代稱 Dot 關閉 MFT-009／010。
- 原暫停 `.tap()` 現已走過，第一關真實點按結算與第二關解鎖仍走過；音量、觸覺、高對比、大字、左手及下一局舒緩模式的程序重開後斷言走過。
- 本次「還原設定 → 取消」及「還原設定 → 還原」走過，55%／75% 預設音量斷言通過。後續 **「清除遊戲進度 → 取消」仍未關閉確認窗**，`assertSecondLevel` 等待首頁可點的原斷言失敗，MFT-008 保持開放。不是整個清除／取消流程通過。
- 主基準失敗，六關延伸、完整影片及二十次進出效能測試未執行，沒有完整遊戲 IPA。

| 原始 App PNG | 證據範圍 |
|---|---|
| [取消後仍見清除確認窗](4231521C-978C-4A98-8C5E-FE1F217BC8D9.png) | 原失敗實物，保留 |
| [無遮罩出餐後空客位](82576EC6-4FCB-40F4-9B0F-008EEB0FB9F2.png) | 森林小徑文字已在淺色資訊區；工位側標籤仍弱，MFT-012 待下一候選 |
| [深底三角色五表情](5F8E846A-4A5C-42FE-995C-76B00B90828D.png) | Codex 實看最後一列標籤完整；龍 alpha MFT-007 仍開放，縮圖不能證明原圖清理 |
| [程序重開後設定](9659000E-8BAB-46C4-8B3F-8C790DDDA614.png) | 此時點實圖，其他設定值以原生斷言與日誌為準 |
| [首次教學三秒](3B145E19-CD31-4C7D-82ED-7E881AD40BE7.png) | 該時點角色圖；不代表整段入場動畫通過 |
| [SE 大字高對比左手首頁](25EF3C21-D213-4FFE-AA8F-6686F0B5A864.png) | Codex 實看完整首頁，不是先前 7c 的設定保存畫面 |
| [Pro Max 同名首頁附件](850C0A2E-C85F-4F51-A406-AF725C24AE53.png) | 實際仍在設定 sheet 關閉途中，不能當完整首頁證據；MFT-013 等待條件修正涵蓋大尺寸 |

[原生 JSON 摘要](TEST_RESULT_SUMMARY.json)、[狀態](VALIDATION_STATUS.json)、[實際環境](ENVIRONMENT.txt)、[選圖原附件對照](SELECTED_ATTACHMENTS.json)。這些是實際模擬器擷取；固定 DEBUG 美術頁不是正常點按全流程，也不是 7.7 評分。

下一候選保留原失敗斷言，改用單一 sheet 容器在設定保存後替換確認內容，避免兩個 sheet 關閉／重開交錯；此為待原生重測修正，不先宣稱根因已證明。
