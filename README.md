# 魔物餐車 · MonsterFoodTruck

原生 iPhone 直式、完整離線的單人雙爐料理遊戲開發專案。目標包含三種魔物、三道料理、六個關卡，以及首頁、教學、選關、設定、存檔恢復與正式美術音訊。

目前核心模型與六關資料已提交，完整 SwiftUI／SpriteKit 介面與母版素材正在 `integration/full-game` 整合。**尚未完成完整遊戲驗收**；未測項與缺少的動畫／畫面證據列於工作狀態及資產清單。

P1 啟動工程的安裝／測試／未簽名裝置封裝已由 Dot 對 `f8707b5` 獨立重測通過（DOT-001 已關閉），不代表本整合分支已通過。該候選只有最小啟動工程，請勿將其 IPA 當成完整遊戲試玩包。

- [完整開發與驗收規格](docs/PROJECT_SPEC.md)
- [目前工作狀態與工具缺口](docs/WORK_STATUS.md)
- [開發規則摘要](AGENTS.md)

最終交付為 GitHub Actions 實際建出的未簽名 iPhone IPA，需使用者自行簽名安裝。本輪不操作 Apple 帳號、不簽名、不上傳 TestFlight 或 App Store。

從倉庫 Actions 選擇完整成功且有 `package-device` 的「Validate」，或手動成功的「Unsigned iPhone IPA」，下載 `unsigned-ipa-<build>-<SHA>` artifact；可能需要 GitHub 登入，保留 14 天。先核對 BUILD_MANIFEST 的完整 source SHA 與驗收報告，再用 SHA256SUMS 核對檔案。現在唯一已獨立查驗的產物仍是上述 P1 工程包；完整遊戲候選尚未產出。

本倉庫公開可見不代表原創內容已採用任何特定再利用授權；尚未指定開源授權。
