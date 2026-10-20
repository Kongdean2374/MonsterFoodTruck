# 建置與產物

工程由 `python3 Scripts/generate_project.py` 決定性產生，產生的 `.xcodeproj` 和 shared scheme 一併提交；不依賴 XcodeGen、Homebrew 或第三方套件。新增 Swift 檔後重新產生並提交工程。

CI 候選設定為標準 `macos-15`、`/Applications/Xcode_16.4.app`；實際可用性與版本仍以 Actions `ENVIRONMENT.txt` 為準。每次記錄 runner image、Xcode、SDK、Swift 與 simulator runtimes，不把設定本身當成功證據。

在有該 Xcode 與 iPhone 16 Pro 模擬器的 Mac，執行：

```sh
bash Scripts/ci_environment.sh
bash Scripts/validate.sh
bash Scripts/package_ipa.sh
```

`validate.yml` 用低權限 push／PR／手動觸發。`unsigned-ipa.yml` 僅手動觸發可信 `main`，先測同 SHA，再以 iPhone 裝置 SDK Release archive，關閉簽名，檢查 Mach-O iOS device 平台後封裝 `Payload/MonsterFoodTruck.app`。

產物位於 Actions 執行頁的 artifacts，保留 14 天，下載可能需 GitHub 登入。裝置 artifact 內含 IPA、SHA-256、完整 source SHA 與工具版本 manifest；測試 artifact 含 xcresult 與實際截圖。只有成功執行後才有這些產物。

本輪不設定 Apple secrets、不登入 Apple、不簽名、不建立 Release、不上傳 TestFlight 或商店。未來發布須另行授權。

失敗時先讀環境紀錄及失敗步驟日誌；缺指定 Xcode／模擬器須記錄並驗證更新，不能靜默選 latest。沒有成功裝置 archive 時不提供 IPA，不以模擬器 `.app` 替代。

DOT-001 回歸：先 `build-for-testing`，直接讀取真正產出 `.app/Info.plist`，由 `Scripts/verify_app.py` 強制驗證必要識別欄位、展開後的值、平台、iPhone 直式設定、執行檔與離線資源，再 `test-without-building`。每次 artifacts 保存 `SIMULATOR_APP_INFO.plist`／`SIMULATOR_APP_IDENTITY.json`；裝置交付保存對應 `DEVICE_APP_*`。檢查器的 fixture 測試只驗證拒絕錯誤資料的行為，不代替真正模擬器安裝或裝置封裝。
