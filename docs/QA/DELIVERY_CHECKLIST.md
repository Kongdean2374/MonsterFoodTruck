# 完整候選交付查驗表

實際 App source `66c2929dd05c28af1b0c3ec8a79805446c6dc023`／build 25。Validate 39497238513 及同 SHA 裝置封裝 success，41 次原生方法執行／0 failed／0 skipped；詳細原物與能力邊界見 [INTEGRATION_66c2929](INTEGRATION_66c2929/)。尚未最終驗收，MFT-007 及獨立藝術／真機項不能被綠燈取代。

| 查驗內容 | 實際證據 | 狀態與邊界 |
|---|---|---|
| 工程／安裝／識別 | 三 scopes native identity／probe、實際 IPA plist／Mach-O | 本 SHA 通過；舊 DOT-001 仍只限原獨立啟動工程結論 |
| 三菜／三角色／六關與核心／存檔 | 26 原生單元、原 xcresult／JSON | 本 SHA 通過；先前 Linux 15 Domain／4 Save 另保留，不混算原生 |
| 完整首次教學、真實第一關、保存及全部設定 | 原完整 Flow／程序重開值／取消確認 | 本 SHA 通過，第一關真實 3／2／2 星 |
| 六關／結算／解鎖重開／完成畫面 | 六份正常時鐘 session、原方法 passed、MOV | 工程 driver，非六關全程真實 UI 或真人試玩 |
| 後關餐蓋／修整／香草／兩位出餐 | driver 關閉後實際點按、真正 UI save、PNG | 本 SHA 原方法通過；MFT-015 READY_FOR_RETEST |
| 練習隔離、背景、失敗／重試／確認取消 | FullJourney／ControlFlow 原生方法 | 本 SHA 通過 |
| 三尺寸／大字／高對比／左右手 | 主基礎及小大各 3 原方法／PNG | 本 SHA 通過有限操作斷言；不是所有視覺狀態評分 |
| 二十次進場／完整子樹／音訊池 | 原 PERFORMANCE v2／summary | 根層 1／完整 SpriteKit 後代 5、players 49 固定；不是全場景或真機 profiler |
| 正式美術／透明／動作 | 同母版擴作、深淺底五表情／動作取樣、正常 App | MFT-007 OPEN；7.7／連續動態接合 UNVERIFIED |
| 配樂／警告／音量／觸覺 | 25 原 WAV／PCM、實際設定回歸 | 聽感／真實觸覺未驗；影片音軌 0 |
| 本地資源／離線 | 實際 device App 全資源 byte hash | 本地資源檢查通過；實機飛航全流程未測 |
| 未簽名 iPhoneOS IPA／校驗 | artifact 12302352776、BUILD_MANIFEST、直接下載查驗 | 本 SHA 通過：20 檔校驗、arm64／最低 17／platform=2／無 LC_CODE_SIGNATURE |
| Dot 完整獨立驗收 | 7.7 六項與正確 source／artifact 明確判定 | 尚未取得，Codex 不代簽 |

最終完整完成定義仍未達成；已知必做藝術缺陷與獨立判定保留。候選實物可供具體重測，沒有把 P1 小包或不同 SHA 的成功拼成驗收。未操作 Apple 帳號／簽署／TestFlight／App Store；裝置簽名安裝與真機體驗由實際後續結果判定。
