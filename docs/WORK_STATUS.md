# 工作狀態

- 目標倉庫：https://github.com/Kongdean2374/MonsterFoodTruck
- 開發分支：`integration/full-game`（同一工作樹、單一寫入者）；最終目標分支 `main`。`main` 上的 b12837c 正在獨立跑核心回歸。
- 階段：P1 工程建置已打通；DOT-001 經 Dot 獨立重測 VERIFIED_CLOSED。核心模型與介面／資產整合中，完整成品尚未完成。
- 最近交付審核 source SHA：`f8707b553758ba86605d0b70b6f97be35b516b8e`（DOT-001 工程修復，非完整遊戲候選）。
- 活動任務識別：未另建外部任務。
- 產品檔案寫入者：目前 Codex 對話，單一寫入者。
- Dot 狀態：使用者已轉交 DOT-001 對 f8707b5 的獨立重測與 VERIFIED_CLOSED 判定；範圍僅該啟動工程，不代表完整遊戲或美術通過。

## 已完成檢查

- GitHub CLI 與連接器均確認擁有者為 `Kongdean2374`、倉庫可見性 `public`、預設分支 `main`、未封存且未停用。
- 兩種工具均回報 `pull: true`、`push: true`。
- 遠端初始為空倉庫，沒有既有分支或產品檔案可被覆蓋；已成功 clone。
- 將使用者提供的完整規格原文保存為 `docs/PROJECT_SPEC.md`，建立本規則摘要及狀態紀錄。
- 實際首次 push 成功：`d957fdfd0ce4fd87e5495b791c4e92055068162a`；`main` 的 GitHub API 回覆與 `git ls-remote` 均指向該提交。
- 經 GitHub Contents API 讀回 `docs/PROJECT_SPEC.md`，逐位元組比對本地原始附件，完全一致；工作樹乾淨。

## 工具與未驗證項

- Git／GitHub CLI／GitHub 連接器可用。
- 已提供圖片生成與圖片檢視工具；尚未生成或驗收正式素材。
- 本地 Linux 沒有 Xcode、iOS SDK 或 iOS 模擬器；已實際使用 macos-15／Xcode 16.4／iOS 18.5 SDK 與 iPhone 16 Pro Simulator 完成最小工程的單元／UI 測試及無簽名裝置 archive。
- 音訊製作、播放與聽覺驗證尚未執行。
- 已建立最小 SwiftUI／SpriteKit 工程、決定性工程產生器、單元與啟動 UI 測試、兩條 Actions；DOT-001 對應的 Validate run `39424665706` 與 IPA run `39424665179` 同 SHA 均 SUCCESS，2 passed、0 failed、0 skipped。已下載實際 IPA 比對校驗碼與裝置 Mach-O，已檢視真實截圖；詳 `docs/QA/ISSUE_LOG.md`。
- 本地保留尚未整合／編譯的核心模型、六關資料、模型與存檔測試、存檔／音訊服務、後續介面程式、兩張原創美術母版與音訊生成輸出。這些不在上述修復 App 中，不能把該 App 的測試成功套用到它們。
- 尚無完整遊戲、正式美術音訊、效能、真機或 Dot 驗收結果。

## 阻礙與下一步

- 先前自動建庫因 integration 缺少建立倉庫權限失敗；目前使用者已提供可存取的倉庫，已實際驗證既有倉庫可 clone、push 及讀回。建庫阻礙已解除。
- 下一個實際動作：推送整合分支並手動跑既有 Validate 工作流程，處理真實編譯／模型／介面失敗，取得首頁、教學及遊玩實際畫面；不以生圖當 App 截圖。核心／存檔已有測試及來源可審核，MFT-001 待 async 回歸。
- 查詢 Actions 管理設定 API 回傳 403，這不等於 workflow 無法執行；以實際推送及工作流程結果確認，不修改帳號安全設定。
- 問題 ID：DOT-001 VERIFIED_CLOSED；完整產品、美術、流程及最終候選仍須查驗，未達最終交付條件。

