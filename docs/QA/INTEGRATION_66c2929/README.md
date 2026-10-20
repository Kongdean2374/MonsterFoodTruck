# 66c2929 完整候選：同 SHA 原生回歸與裝置 IPA

實際 App source **`66c2929dd05c28af1b0c3ec8a79805446c6dc023`**，版本 1.0.0／build 25。[Validate 39497238513](https://github.com/Kongdean2374/MonsterFoodTruck/actions/runs/39497238513) 原 attempt 1 整體 **success**，沒有取消、重開不變 SHA 或忽略失敗。此後的證據文件提交不會改變受測 App SHA。

這是完整六關候選的原生／封裝成功，**尚未最終驗收**。MFT-007 龍 Alpha 缺陷保留，7.7 六項獨立評分、完整動態接合與真機項仍未通過；Codex 不代稱 Dot 已通過。按規格 17 的完整完成定義仍須修正／查驗這些項目。

| 原生 scope／job | passed | failed | skipped |
|---|---:|---:|---:|
| 26 單元＋5 基礎 UI／118885341280 | 31 | 0 | 0 |
| 延伸 ControlFlow／FullJourney／Performance／同主 job | 4 | 0 | 0 |
| SE3，375×667pt／118900546087 | 3 | 0 | 0 |
| 15 Pro Max，430×932pt／118900546280 | 3 | 0 | 0 |

共 41 次方法執行（包含尺寸重複方法），0 失敗／0 略過。基礎完整教學、第一關真實點按、保存／恢復、全部設定重開、還原與清除取消／確認均通過；延伸練習隔離、背景／失敗／重試／取消／放棄與二十次真實進場也通過。裝置 job `118909103267` 只收集同次原始成功證據並 archive，沒有重跑成功 XCTest；唯一 skipped 的 export-existing-evidence 是未要求的只讀匯出 job，不是 skipped XCTest。

環境：macos-15 Apple Silicon、Xcode 16.4／Swift 6.1.2、SDK／Simulator iOS 18.5；主機型 iPhone 16 Pro 402×874pt。iOS 17 是裝置部署下限，未宣稱實際 iOS 17 runtime、iPhone 17 Pro 或實機效能已測。

## 可下載的同 SHA 裝置包

[unsigned-ipa-25-66c2929…／artifact 12302352776](https://github.com/Kongdean2374/MonsterFoodTruck/actions/runs/39497238513/artifacts/12302352776)，保留至 2026-11-03。下載後解壓：

- IPA：`MonsterFoodTruck-unsigned-1.0.0-25.ipa`，**26,053,576 bytes**。
- IPA SHA-256：`314ef428c7cad8ef754233940c91949c20dac0bfaa1aaed856bd15ce74094d4e`。
- 外層 artifact ZIP 為 26,119,376 bytes，SHA-256 `51e7f4ef0950edfafd53fce1a09e185573a942129949b6218e27f9b49d64747b`；它與內層 IPA 的 hash 不同。

Codex 已下載，核對 SHA256SUMS 的全部 20 份交付檔，再直接解析 IPA 中的實際 plist、原始離線資源與 Mach-O：bundle ID `cc.chaihome.monsterfoodtruck`、iPhoneOS、iPhone family、直式、arm64、最低 17.0、LC_BUILD_VERSION platform=2、沒有 LC_CODE_SIGNATURE 或簽名材料，三魔物／三菜／六關及 25 WAV／AppIcon 完整。每份原始資源與該 source 逐位元組相符。

[BUILD_MANIFEST](device/BUILD_MANIFEST.json)、[實際 App 識別](device/DEVICE_APP_IDENTITY.json)、[原始 SHA256SUMS](device/SHA256SUMS.txt)、[下載後直接查驗結果](DEVICE_CANDIDATE_INSPECTION.json) 均原樣保留。`device/` 不重複提交 IPA；執行原 SHA256SUMS 必須使用下載的完整交付目錄。本包未簽名，需自行簽名後安裝；本輪沒有操作 Apple 帳號、簽署、TestFlight 或 App Store。

可在本倉庫將 artifact 解壓至 `build/ipa-66` 後重現唯讀檢查：

```sh
python3 docs/QA/INTEGRATION_66c2929/inspect_device_candidate.py build/ipa-66 66c2929dd05c28af1b0c3ec8a79805446c6dc023 39497238513 build/inspection.json
```

## 真實點按、工程重播與圖片的範圍

六份 `actual-model-snapshots/actual-level_*.json` 是正常前景時鐘的 DEBUG 命令 driver；服務完成 3／4／5／6／7／9，經正常結算解鎖並重開保留，最終畫面 18／18 星。**它們不是六關全程真實 UI 點按或真人試玩。** 同一原方法之後關閉 driver，才執行真實第五關餐蓋／受損整理／配料／出餐點按；原第一關完整實際點按另在基礎 Flow。

MFT-015 真正 UI 保存檔現在直接證明：原鹿被偷嚐 42.4306 秒 → 整理 44.2299～47.2299 → 香草 49.3509～51.3509 → 出餐 52.4308；原龍與鹿皆 served，蓋三次、取下兩次、歸還重用，54.9030 秒暫停保存。偏好失效斷言保留，沒有調整耐心／時鐘／評分或注入狀態。見 [真實後段 save](QA_EVIDENCE/journey/actual-late-session/save-v1.json)；與工程六份歷史分列。

| 可直接檢視的原 App PNG | 證據種類 |
|---|---|
| [首頁](QA_EVIDENCE/C4F9A7C7-7D30-4E1D-8527-0804794EDF80.png) | 基礎真實 UI |
| [首次教學停留三秒](QA_EVIDENCE/B5CC83FD-8833-4924-BF92-6F0740B00C74.png) | 原鹿完整可見；原 0／1／3 秒 PNG hash 相同 |
| [第一關 3 成功／2 偏好／2 星](QA_EVIDENCE/B91B49C3-977E-439A-AFB7-D7CF4AA071AE.png) | 完整第一關真實 UI 點按 |
| [第五關偷嚐後待整理](QA_EVIDENCE/journey/screenshots/BED933EC-DF49-4A9F-90F6-B1CA4CD23E5C.png) | driver 關閉後真實點按 |
| [第五關兩位已服務](QA_EVIDENCE/journey/screenshots/B05D922F-B3F9-4BCC-B425-75A022A93CDC.png) | 同上，原方法 passed |
| [第六關結算](QA_EVIDENCE/journey/screenshots/C9828DC3-22C8-4A2D-AAE9-321959B66B01.png)／[六關完成](QA_EVIDENCE/journey/screenshots/98DF55D3-BFB8-44D3-B0F8-5B2F3BA289DA.png) | 正常時鐘工程 driver，非全程點按 |
| [SE3 首頁大字](QA_EVIDENCE/layout-small/6E458B60-E94A-495C-AD87-9B90BC137D11.png) | 設定值重開及關閉設定後真實畫面 |
| [SE3 busy／高對比／左手](QA_EVIDENCE/layout-small/86470BD0-0D5B-4A59-918B-0D3C84327A3D.png) | 明示 DEBUG 固定情境，非正式成績 |
| [SE3 三角色五表情／深底](QA_EVIDENCE/layout-small/8CFADC06-7E3B-49B1-9770-D36DD15F3D8D.png) | 實際 App 查驗頁，非遊玩通過 |
| [大尺寸首頁大字](QA_EVIDENCE/layout-large/DDBE33C6-BA91-4120-BDE2-5C61A4D140BE.png)／[busy 左手](QA_EVIDENCE/layout-large/DE51FA7C-C569-4B66-B0AF-40C0887080E5.png) | 兩類來源同上分別標示 |

Codex 實看以上尺寸／狀態：工位奶油標籤、耐心數字、空位與按鈕未見裁切；小尺寸五表情最後一列文字完整。此靜態查驗不關閉龍 Alpha 或代替 7.7／所有動畫接合。首次教學 0／1／3 秒原 hash 皆 `481454274c98bc0ffac67faa3756c571bcbf49110ef40ddd4b3e4e591d2273ae`。

[SCREENSHOT_INDEX](SCREENSHOT_INDEX.json) 索引 117 份原 XCTest PNG 的原名／路徑／hash；完整實際圖還包括鎖定／解鎖選關、簡介、暫停、設定、失敗、餐蓋及料理狀態。三個小型 archive 共 154 PNG（包含 36 個錄影時間點及一張錄影起點），已逐一對照同 SHA 裝置包的 QA_EVIDENCE_INDEX，376 份可下載 evidence 的 byte count／SHA-256 全相符。唯一沒有本地下載的是完整 MOV，見 [唯讀 evidence 查驗](EVIDENCE_INSPECTION.json)。

## 原始 archive 與錄影

| 原物 | artifact | ZIP SHA-256 |
|---|---|---|
| 原生摘要／106 PNG／session 小型 review | [12300107138](https://github.com/Kongdean2374/MonsterFoodTruck/actions/runs/39497238513/artifacts/12300107138) | `a27e1b5c45d25b9cd200ab124f577f72253d2a1f81d686b937bf1e6a002905a9` |
| SE3 原結果／24 PNG | [12302380889](https://github.com/Kongdean2374/MonsterFoodTruck/actions/runs/39497238513/artifacts/12302380889) | `4283e345a5f8b6e64d6ededabc73cd30550ef706a9ac02a2277df7f6a93eefa8` |
| 15 Pro Max 原結果／24 PNG | [12301693883](https://github.com/Kongdean2374/MonsterFoodTruck/actions/runs/39497238513/artifacts/12301693883) | `592ed18fd6b04da3bd77e9024a4152656f6eb2ddf9cbd4ec19bab57b455569e1` |
| 原 xcresult／完整錄影等重型原物 | [12300750859](https://github.com/Kongdean2374/MonsterFoodTruck/actions/runs/39497238513/artifacts/12300750859) | `51319c4482c7ec9f09b24a4608d7c95bf1add05bf1d7edba28cc88d523417ab1` |

前三份已下載核對 archive digest。重型 1,554,659,595 bytes 超過連接器 512MiB 上限，Codex 未下載；macOS 裝置 job 已下載核對原 digest 並原樣收集，見 [VALIDATION_ASSEMBLY](device/VALIDATION_ASSEMBLY.json)。本目錄所有選圖都是原 PNG 位元組複製，沒有生圖替代、改 Alpha 或合成畫面。

原 `normal-six-level-journey.mov` 為 989.993 秒、1206×2622、1,345,897,930 bytes、SHA-256 `7612a829294299563b6e83df5ccecad90e0ed03e84ef7defa79d5e0ed91ad94f`。含六關工程正常時鐘及其後真實後關點按；不是全程手動六關。正常停止、沒有強制終止，唯讀解碼 36 個原尺寸時間點、0 錯誤；取樣不代表已實看每一動畫。**音軌為 0，聽感及觸覺未驗證。**

## 完整子樹診斷與仍待驗收

二十次真實第一位鹿進場／備料／暫停／放棄重進，根層入場／暫停／update 取樣最大值均 1，完整 SpriteKit 後代均 5，audio players 49 固定。排除 scene 本身、SwiftUI／UIKit 及未掛樹物件；不是全關卡配置存活分析。update cadence 約 53.19–58.69 Hz、handler→next-update 樣本 p95 約 9.11–33.57ms、取樣 footprint 約 135.93–140.12MiB；不是實體 FPS／touch-to-photon／連續 profiler 峰值。原始與 summary 重新計算逐位元組一致。

MFT-013／015／016／017 有此 SHA 原生回歸，標 READY_FOR_RETEST；原失敗永久保留在 d09011f／28e474d／2bb77a9 目錄，未代稱 Dot 關閉。[7.7 獨立查驗入口](ART_REVIEW.md) 六項尚未評分。MFT-007 圖片工具兩次仍未解決，原稿／試稿保留，未獲 Python 圖片修改特例授權；後續方法待另行確認，不要求本輪逐階段批准。

真機簽名安裝、飛航全程、音訊監聽／系統靜音／觸覺、iOS 17 runtime、iPhone 17 Pro 效能及完全非視覺通關均未驗證。此候選提供具體實物供獨立查驗，沒有宣告完整遊戲最終通過。
