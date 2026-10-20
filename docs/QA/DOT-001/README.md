# DOT-001 回歸證據

受測 source SHA：`f8707b553758ba86605d0b70b6f97be35b516b8e`。本目錄是後續文件提交，不能拿文件提交 SHA 冒充該 App 的 build SHA。

- [Validate 成功執行](https://github.com/Kongdean2374/MonsterFoodTruck/actions/runs/39424665706)
- [未簽名裝置 IPA 成功執行與 artifacts](https://github.com/Kongdean2374/MonsterFoodTruck/actions/runs/39424665179)
- BUILD_MANIFEST.json、TEST_RESULT_SUMMARY.json、DEVICE_APP_IDENTITY.json、DEVICE_BUNDLE_PROBE.txt、MACHO_PLATFORM.txt、SIGNATURE.txt：從實際 artifact 取出的原始證據。
- P1-bootstrap-launch.png：從實際 XCTest xcresult 匯出的 App 啟動截圖；未作合成或美術改造。

Codex 已下載 IPA 核對 checksum 並解析 Mach-O；使用者已轉交 Dot 對相同 SHA／artifact 的獨立重測，授權 DOT-001 記為 VERIFIED_CLOSED，詳問題紀錄。本候選只有最小工程，尚非完整遊戲、美術驗收或最終可試玩版本。IPA 不提交進 git，請由上述 Actions artifact 取得。真機與簽名安裝尚未測。
