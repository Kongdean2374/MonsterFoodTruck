# 魔物餐車 · MonsterFoodTruck

原生 iPhone 直式、完整離線的單人雙爐料理遊戲開發專案。目標包含三種魔物、三道料理、六個關卡，以及首頁、教學、選關、設定、存檔恢復與正式美術音訊。

`integration/full-game` 已有完整六關、三魔物／三菜、SwiftUI／SpriteKit 全流程、設定／存檔與正式素材音訊的整合候選。實際 source `66c2929dd05c28af1b0c3ec8a79805446c6dc023`／build 25 的 [Validate](https://github.com/Kongdean2374/MonsterFoodTruck/actions/runs/39497238513) 及同 SHA 未簽名裝置封裝均 success：基礎 31、延伸 4、小／大各 3，0 失敗／0 略過。**尚未完成完整遊戲驗收**：龍局部 Alpha、7.7 獨立美術評分、音訊聽感與真機項仍待，不能代稱 Dot 通過。

P1 啟動工程的安裝／測試／未簽名裝置封裝已由 Dot 對 `f8707b5` 獨立重測通過（DOT-001 已關閉），不代表本整合分支已通過。該候選只有最小啟動工程，請勿將其 IPA 當成完整遊戲試玩包。

- [完整開發與驗收規格](docs/PROJECT_SPEC.md)
- [目前工作狀態與工具缺口](docs/WORK_STATUS.md)
- [開發規則摘要](AGENTS.md)

最終交付為 GitHub Actions 實際建出的未簽名 iPhone IPA，需使用者自行簽名安裝。本輪不操作 Apple 帳號、不簽名、不上傳 TestFlight 或 App Store。

完整候選可下載 [unsigned-ipa-25-66c2929…](https://github.com/Kongdean2374/MonsterFoodTruck/actions/runs/39497238513/artifacts/12302352776)，內含 `MonsterFoodTruck-unsigned-1.0.0-25.ipa`（26,053,576 bytes）；SHA-256 `314ef428c7cad8ef754233940c91949c20dac0bfaa1aaed856bd15ce74094d4e`。已下載核對全部 20 份交付檔校驗及實際 IPA plist／arm64／iPhoneOS／最低 iOS 17／Mach-O platform=2／無簽名。可能需 GitHub 登入，artifact 保留至 2026-11-03。先核對 BUILD_MANIFEST 的完整 source SHA 與 [證據索引](docs/QA/INTEGRATION_66c2929/README.md)，再核對 SHA256SUMS；這份完整候選仍待 Dot 獨立驗收。

實際 App 畫面：[首頁](docs/QA/INTEGRATION_66c2929/QA_EVIDENCE/C4F9A7C7-7D30-4E1D-8527-0804794EDF80.png)、[SE3 忙碌／大字／左手](docs/QA/INTEGRATION_66c2929/QA_EVIDENCE/layout-small/86470BD0-0D5B-4A59-918B-0D3C84327A3D.png)、[第一關實際點按結算](docs/QA/INTEGRATION_66c2929/QA_EVIDENCE/B91B49C3-977E-439A-AFB7-D7CF4AA071AE.png)、[六關完成](docs/QA/INTEGRATION_66c2929/QA_EVIDENCE/journey/screenshots/98DF55D3-BFB8-44D3-B0F8-5B2F3BA289DA.png)。忙碌圖是明示 DEBUG 固定情境；六關完成圖來自正常時鐘工程命令重播，不宣稱六關全程手動點按。完整索引分列真實 UI、工程重播及靜態查驗。

本倉庫公開可見不代表原創內容已採用任何特定再利用授權；尚未指定開源授權。
