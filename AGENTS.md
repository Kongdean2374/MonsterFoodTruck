# 魔物餐車開發規則

完整且優先的產品、品質及交付規格為 [docs/PROJECT_SPEC.md](docs/PROJECT_SPEC.md)。Codex 與 Dot 必須先讀全文；本摘要不取代完整規格。

- 本倉庫為 `Kongdean2374/MonsterFoodTruck`，公開，預設分支 `main`。只讀寫本遊戲、其工作目錄與相關產物；不帶入其他私人資料。
- 原生 iPhone 直式、iOS 17 起、Swift／SpriteKit／SwiftUI、繁體中文、完整離線。固定一輛餐車、三魔物、三食譜、六關、兩備料／兩爐／兩成品與一餐蓋。
- 首頁、選關、教學、設定、存檔恢復、結算及完整正式美術／音訊均屬本次交付，不以占位素材或空殼當成完成。
- 先以實際 CI 驗證最小可啟動工程及無簽名裝置建置，再擴充；時間、資源、評分由可獨立測試的 Domain 模型控制。
- 單一產品寫入者；恢復工作先讀 git 狀態、`docs/WORK_STATUS.md` 及問題紀錄。不覆蓋未知工作、不 reset／force push／重寫歷史。
- 公開前檢查來源、資產散布依據與秘密；不擅自指定 MIT／GPL／CC0 等原創內容授權。
- 不購買素材、不升級或新增付費服務。不操作 Apple 帳號、簽名、TestFlight、App Store 或 Android。
- 結束遊玩需保存並提示系統離開方式，不呼叫 exit 或製造 crash。
- 實測、靜態檢查與未驗證分開記錄。Dot 必須獨立查驗實物；Codex 不能代宣告 Dot 通過。
- 交付須可追溯到同一完整 source SHA、成功 Actions、未簽名裝置 IPA、SHA-256 與真實測試／畫面證據。

