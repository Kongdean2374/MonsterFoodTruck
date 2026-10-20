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

`validate.yml` 用低權限 push／PR／手動觸發。`unsigned-ipa.yml` 僅允許手動觸發本專案的 `main` 或指定整合分支 `integration/full-game`，其他 ref 不執行；沒有 fork／PR 觸發、secrets 或寫入權限。整合分支可提供同 SHA 完整試玩候選，避免為產包先將未獨立驗收內容推到 main。四個原生 scopes 仍須全部通過、沒有略過，再以 iPhone 裝置 SDK Release archive，關閉簽名，檢查實際 Mach-O 為 iOS device／arm64／minos 17.0 且無 LC_CODE_SIGNATURE，才封裝 `Payload/MonsterFoodTruck.app`。

產物位於 Actions 執行頁的 artifacts，保留 14 天，下載可能需 GitHub 登入。裝置 archive／封裝成功後才有 IPA、SHA-256、完整 source SHA 與工具版本 manifest；測試失敗也保留 xcresult、原生摘要及實際 PNG。若失敗發生在啟動前，狀態會明寫未執行／沒有 App 圖，不虛構通過數。

本輪不設定 Apple secrets、不登入 Apple、不簽名、不建立 Release、不上傳 TestFlight 或商店。未來發布須另行授權。

失敗時先讀環境紀錄及失敗步驟日誌；缺指定 Xcode／模擬器須記錄並驗證更新，不能靜默選 latest。沒有成功裝置 archive 時不提供 IPA，不以模擬器 `.app` 替代。

DOT-001 回歸：先 `build-for-testing`，直接讀取真正產出 `.app/Info.plist`，由 `Scripts/verify_app.py` 強制驗證必要識別欄位、展開後的值、平台、iPhone 直式設定、執行檔與離線資源，再 `test-without-building`。每次 artifacts 保存 `SIMULATOR_APP_INFO.plist`／`SIMULATOR_APP_IDENTITY.json`；裝置交付保存對應 `DEVICE_APP_*`。檢查器的 fixture 測試只驗證拒絕錯誤資料的行為，不代替真正模擬器安裝或裝置封裝。

資源使用標準逐檔 PBXResourcesBuildPhase，避免在 `.app` 根目錄建立保留的 `Resources`／`Contents` 目錄而觸發錯誤包結構辨識。另以 Foundation Bundle API 檢查真正 App 的識別與執行檔；native 新舊布局 regression 保存於 `BUNDLE_LAYOUT_REGRESSION.txt`。

截圖直接由 UI 測試在 App 運行期間擷取，附在 xcresult，再用 `xcresulttool export attachments` 匯出至 `QA_EVIDENCE`；不在 XCTest 結束後向可能沒有 framebuffer 的模擬器索取截圖。沒有非空實際 PNG 時驗證仍失敗。

延伸套件完成後先匯出原生摘要／PNG，再停止錄影與讀取影片 metadata。錄影 SIGINT 收尾最多等待 30 秒，必要清理最多再 5 秒；若需強制終止，保留原生測試證據但影片驗證仍失敗。測試 step 有獨立逾時，保留 job 的上傳時間，SIGINT／SIGTERM 也寫入實際終止狀態；沒有結果的 scope 明寫未執行／未回報，不推算通過數。

錄影 probe 另唯讀解碼 36 個原尺寸時間點，取樣 PNG 隨小型 review artifact 提供，VIDEO_METADATA 記錄要求／實際秒數與取樣錯誤；不縮放、合成或編修原母版。完整 MOV 與 SHA-256 仍保留在原始 QA 證據，取樣不代表已看完整段動畫，也不能關閉原 PNG 的 Alpha 缺陷。

`validate.yml` 手動 `full_qa=true` 執行正常時鐘六關工程重播、實際點按取消／重試／背景路徑及延伸診斷；`layout_qa=true` 隨後執行 SE3 與 15 Pro Max 兩個獨立尺寸 job。主 job 失敗後尺寸仍會執行，三者各有自己的原生統計及 artifact。先執行主 job 是因 0171012 的主 job 曾未取得 hosted macOS runner 而被 GitHub 取消；不能把該取消當測試成功。

指定整合分支的程式／工程／測試／腳本／workflow push 自動開啟相同的 full 與 layout scopes；純文件提交不觸發。手動觸發仍保留。CLI 憑證失效時可由已連接的 GitHub 倉庫工具提交修正並取得同 SHA 的 CI，不重跑原失敗候選，也不需要更改 main。

完整 Validate 的三個原生 job 全部 success 後，指定整合分支 push（或可信 ref 明確開 full／layout 的手動執行）才進入 `package-device`。它下載同次三份原始 artifact、核對 digest／run ID／source SHA／complete 狀態與四份原生摘要，保留原影片／PNG／session 歷史，不重跑已通過測試。Release archive 仍使用同 SHA、相同 build 號並重新檢查實際 iPhoneOS 包；產物也叫 `unsigned-ipa-<run>-<SHA>`，可從該 Validate 執行頁取得。VALIDATION_ASSEMBLY 記錄原證據來源；任何原生 failure／skip／缺摘要／錯 source 都阻止封裝。獨立 unsigned workflow 仍可手動從頭執行完整四 scopes。

大型 xcresult／影片另保留診斷 artifact；Validate 另有 `review-<run>-<SHA>` 小型 artifact，裝置包的 `unsigned-ipa-*` 只包含 delivery，圖片／摘要另放 `review-ipa-*`。小型檔保留原測試失敗數，不代表通過。若舊 artifact 超過下載工具大小上限，可手動提供 `evidence_artifact_id`：僅 Ubuntu 讀取既有 artifact、檢查原 archive digest 與 source SHA、原樣複製 PNG／JSON／TXT／摘要並附 EXPORT_PROVENANCE，沒有重建、重跑或產 IPA，且使用獨立 concurrency group，不影響既有 Mac CI。

`MFT_PERFORMANCE=1` 僅在明確 DEBUG 診斷中取樣；PerformanceTests 以真實點按進入 20 次場景，保留節點、已分配音效實例、task_info 取樣記憶體及 SpriteKit 更新間隔。更新間隔不是實體螢幕 FPS，handler 到下次 scene update 不是 touch-to-photon，取樣最大值也不是連續 profiler 峰值。腳本匯出原始值與摘要，不依未測目標偽造 60fps／100ms 達標。
