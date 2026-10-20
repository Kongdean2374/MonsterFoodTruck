# 建置與產物

工程由 `python3 Scripts/generate_project.py` 決定性產生，產生的 `.xcodeproj` 和 shared scheme 一併提交；不依賴 XcodeGen、Homebrew 或第三方套件。新增 Swift 檔後重新產生並提交工程。

CI 候選設定為標準 `macos-15`、`/Applications/Xcode_16.4.app`；實際可用性與版本仍以 Actions `ENVIRONMENT.txt` 為準。每次記錄 runner image、Xcode、SDK、Swift 與 simulator runtimes，不把設定本身當成功證據。

在有該 Xcode 與 iPhone 16 Pro 模擬器的 Mac，執行：

```sh
export DEVELOPER_DIR=/Applications/Xcode_16.4.app/Contents/Developer
export MFT_FULL_QA=1
export MFT_LAYOUT_QA=1
bash Scripts/ci_environment.sh
bash Scripts/validate.sh
bash Scripts/package_ipa.sh
```

`validate.yml` 用低權限 push／PR／手動觸發。`unsigned-ipa.yml` 僅手動觸發可信 `main`，先測同 SHA，再以 iPhone 裝置 SDK Release archive，關閉簽名，檢查 Mach-O iOS device 平台後封裝 `Payload/MonsterFoodTruck.app`。

產物位於 Actions 執行頁的 artifacts，保留 14 天，下載可能需 GitHub 登入。裝置 archive／封裝成功後才有 IPA、SHA-256、完整 source SHA 與工具版本 manifest；測試失敗也保留 xcresult、原生摘要及實際 PNG。若失敗發生在啟動前，狀態會明寫未執行／沒有 App 圖，不虛構通過數。

本輪不設定 Apple secrets、不登入 Apple、不簽名、不建立 Release、不上傳 TestFlight 或商店。未來發布須另行授權。

失敗時先讀環境紀錄及失敗步驟日誌；缺指定 Xcode／模擬器須記錄並驗證更新，不能靜默選 latest。沒有成功裝置 archive 時不提供 IPA，不以模擬器 `.app` 替代。

DOT-001 回歸：先 `build-for-testing`，直接讀取真正產出 `.app/Info.plist`，由 `Scripts/verify_app.py` 強制驗證必要識別欄位、展開後的值、平台、iPhone 直式設定、執行檔與離線資源，再 `test-without-building`。每次 artifacts 保存 `SIMULATOR_APP_INFO.plist`／`SIMULATOR_APP_IDENTITY.json`；裝置交付保存對應 `DEVICE_APP_*`。檢查器的 fixture 測試只驗證拒絕錯誤資料的行為，不代替真正模擬器安裝或裝置封裝。

資源使用標準逐檔 PBXResourcesBuildPhase，避免在 `.app` 根目錄建立保留的 `Resources`／`Contents` 目錄而觸發錯誤包結構辨識。另以 Foundation Bundle API 檢查真正 App 的識別與執行檔；native 新舊布局 regression 保存於 `BUNDLE_LAYOUT_REGRESSION.txt`。

截圖直接由 UI 測試在 App 運行期間擷取，附在 xcresult，再用 `xcresulttool export attachments` 匯出至 `QA_EVIDENCE`；不在 XCTest 結束後向可能沒有 framebuffer 的模擬器索取截圖。沒有非空實際 PNG 時驗證仍失敗。

`validate.yml` 手動 `full_qa=true` 執行正常時鐘六關工程重播、實際點按取消／重試／背景路徑及延伸診斷；`layout_qa=true` 隨後執行 SE3 與 15 Pro Max 兩個獨立尺寸 job。主 job 失敗後尺寸仍會執行，三者各有自己的原生統計及 artifact。先執行主 job 是因 0171012 的主 job 曾未取得 hosted macOS runner 而被 GitHub 取消；不能把該取消當測試成功。

`MFT_PERFORMANCE=1` 僅在明確 DEBUG 診斷中取樣；PerformanceTests 以真實點按進入 20 次場景，保留節點、已分配音效實例、task_info 取樣記憶體及 SpriteKit 更新間隔。更新間隔不是實體螢幕 FPS，handler 到下次 scene update 不是 touch-to-photon，取樣最大值也不是連續 profiler 峰值。腳本匯出原始值與摘要，不依未測目標偽造 60fps／100ms 達標。
