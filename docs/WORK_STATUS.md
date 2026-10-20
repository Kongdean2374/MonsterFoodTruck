# 工作狀態

2026-10-21（台北時間）。完整遊戲候選已取得同 SHA 的成功原生回歸與未簽名裝置 IPA，**尚未最終驗收**。實際 App source `66c2929dd05c28af1b0c3ec8a79805446c6dc023`／build 25；後續證據文件提交不改變此受測 SHA。MFT-007 龍局部 Alpha 仍開放，7.7／連續動態接合、音訊聽感與真機項仍待，不能代稱 Dot 通過。

## 恢復入口與唯一寫入者

- 公開倉庫 `Kongdean2374/MonsterFoodTruck`，單一工作樹 `/workspace/MonsterFoodTruck`、整合分支 `integration/full-game`，目前 Codex 對話為唯一產品寫入者。main 仍為 `b12837c80dfc9f44ae6035c8bf7334f0fff66fdb`，沒有為產包先合併 main。
- 恢復先讀 git status、本檔、[問題紀錄](QA/ISSUE_LOG.md) 及 [完整規格](PROJECT_SPEC.md)；不 reset／force push／覆蓋未知工作。自己的 pre-fast-forward 備份 stash 保留，不應 pop 回已整合內容。
- CI 正常等待約每 5–10 分鐘查詢，沒有新結果不固定刷屏。Validate 39497238513 的全部原 job 已自行結束，attempt 1，無取消／重開。另有固定同 App source 的五段短片外部 harness，原候選不變、不新增功能，不重跑完整六關；目前原生結果以 [短片索引](QA/MOTION_EVIDENCE_66c2929/) 為準。

## 同 SHA 實物與原生結果

[Validate 39497238513](https://github.com/Kongdean2374/MonsterFoodTruck/actions/runs/39497238513) 整體 success：基礎 31／0／0（26 單元＋5 UI）、延伸 4／0／0、SE3 與 15 Pro Max 各 3／0／0；共 41 次方法執行，包含尺寸重複方法，沒有 skipped XCTest。主 job 118885341280、小 118900546087、大 118900546280、裝置 118909103267 皆 success。export-existing-evidence skipped 是沒有要求的只讀匯出，不是略過測試。

- 裝置 artifact [12302352776](https://github.com/Kongdean2374/MonsterFoodTruck/actions/runs/39497238513/artifacts/12302352776)，`MonsterFoodTruck-unsigned-1.0.0-25.ipa`，26,053,576 bytes，SHA-256 `314ef428c7cad8ef754233940c91949c20dac0bfaa1aaed856bd15ce74094d4e`，至 2026-11-03。已下載核對全部 20 份交付檔及實際 IPA：bundle ID、iPhoneOS、最低 iOS 17、arm64、Mach-O platform=2、無 LC_CODE_SIGNATURE、原始資源逐位元組一致。
- 原始圖／摘要／真正 session／裝置識別／逐檔 hash／7.7 查驗入口見 [INTEGRATION_66c2929](QA/INTEGRATION_66c2929/)。review 12300107138、小 12302380889、大 12301693883 的 archive digest 均已下載核對；376 份 evidence／154 PNG 與裝置索引逐檔 hash 相符。
- 原重型 artifact 12300750859 為 1.55GB，超過連接器 512MiB 下載上限；Mac 裝置 job 已下載核對同 run／SHA／digest 並原樣收集。Codex 未本地下載完整 MOV 或宣稱親看全段。錄影 989.993 秒／1206×2622／音軌 0，正常收尾、36 個唯讀原尺寸取樣、0 解碼錯誤；不是音訊聽感通過。
- 原生環境 macos-15 Apple Silicon／Xcode 16.4／Swift 6.1.2／iOS 18.5。iOS 17 為部署下限，沒有實際 iOS 17 runtime／iPhone 17 Pro 測試。Linux 本機只有 Swift、無 Xcode／Simulator；不把語法解析冒充原生編譯。

## 已實作與本輪通過範圍

三角色／三菜／六關、兩備料／兩同功能爐／兩成品／一餐蓋；首頁、選關、簡介、教學、暫停、全部設定、存檔恢復、結算與六關完成均接入。正式同母版分層、五表情／動作、料理九狀態、工位與 25 個原創離線 WAV 已整合；美術 Alpha／獨立評分及音訊聽感未完成，不把素材存在當驗收。

- 基礎 Flow 完整真實第一關 3 成功／2 偏好／2 星、第二關解鎖；教學、暫停、保存／程序重開、全部設定值／音量、還原設定與清進度取消／確認均通過。首次教學 0／1／3 秒 PNG 相同，原鹿完整可見；不擴張為所有入場動畫通過。
- 六份正常前景時鐘 DEBUG 命令 driver session 全部服務 3／4／5／6／7／9、正常結算、重開保存解鎖、完成畫面 18／18 星。它們是工程重播，**不是六關全程真實 UI 點按或真人試玩**。
- 同一方法之後關閉 driver，真實第五關餐蓋蓋／取下／再蓋／直接服務／歸還重用、偷嚐後三秒整理、偏好仍失效、香草與兩位出餐通過。真正 UI 保存檔證實偷嚐 42.4306→整理 44.2299～47.2299→香草 49.3509～51.3509→服務 52.4308 秒；沒有改耐心／時鐘／評分或狀態注入。
- 練習隔離、不解鎖正式成績；背景不消耗耐心、無操作失敗、同關重試、取消及放棄完整延伸方法通過。
- 二十次真實第一位鹿進場／備料／暫停／放棄重進的根層入場／暫停／update 取樣最大值都是 1，完整 SpriteKit 後代都是 5，audio players 49 固定。排除 scene 本身／SwiftUI／UIKit／未掛樹物件；不宣稱全關卡節點、真機 FPS 或物件釋放 profiler 通過。
- 三尺寸 HomeLayouts／ArtReview／DEBUG 狀態都有原 PNG。Codex 實看所列首頁、教學、結果、後關實際圖、小大字／左手 busy 與深底五表情；側欄奶油標籤、數字及最後一列未見裁切。DEBUG 固定情境與實際操作、靜態與連續動態分列，不代稱 Dot 最終藝術通過。

## 本次獨立查驗與動態補件

Dot 已獨立核驗 66c2929 的 41 次原生執行、第五關實際保存事件、IPA 實際架構／平台／未簽名、47 資源及 20 檔 checksum，可列工程候選，仍未完整驗收。最新獨立 7.7 評分及限定範圍已記錄，沒有宣稱所有問題 ID 自動關閉。

原 36 個電影樣本改按 actual_seconds 索引（frame01=3.918333 秒，不是 requested 28.332667 秒），原始檔未改；三尺寸 24 張 ArtReview 的意圖名不當實際相位。深淺底各三次連續循環與三菜單客人真實點按，只補必要短片；還原候選已賺取的原保存進度，不注入訂單或分數，不當自然解鎖／完整六關人工通關。[剩餘驗收清單](QA/MOTION_EVIDENCE_66c2929/REMAINING_ACCEPTANCE.md)。

## 問題與獨立判定

- MFT-013／015／016／017 有本 SHA 原生回歸，READY_FOR_RETEST。原 d090 基礎 31／0／0＋延伸 3／1／0，28e 為 31／0／0＋2／2／0，2bb 為 31／0／0＋3／1／0；失敗與附件完整保留在各 QA 目錄。沒有把它們改寫成功，或僅重跑同一 SHA 消除紅燈。
- MFT-007 OPEN：龍頭頸及尾焰旁低 Alpha 紅黃殘點／毛邊。三次圖片工具修稿未解決，原稿／可退稿保留；沒有 Python／shader 清理特例授權，沒有繞過限制。方法問題整理在 [ALPHA_METHOD_PENDING](QA/ALPHA_METHOD_PENDING.md)，依既有指示待後續特定方法確認，不打斷其他不受影響工作。
- 7.7 最新獨立評分 3／3／UNVERIFIED／3／2／3，不計總分，未達每項至少 3 及總分至少 20 的門檻。靜態表情可 3 不充作動作分數；SE3 底字與奶油底已獨立實看修復，龍 Alpha 仍 2／4。資料入口 [ART_REVIEW](QA/INTEGRATION_66c2929/ART_REVIEW.md)。
- Dot 已獨立 VERIFIED_CLOSED 的 DOT-001 僅 f8707b553758ba86605d0b70b6f97be35b516b8e 的啟動工程：Validate 39424665706／IPA 39424665179、artifact 12265820706、2／0／0、原啟動圖及實際 IPA 識別／Mach-O／校驗；不是完整遊戲。
- Dot 對 b12837c80dfc9f44ae6035c8bf7334f0fff66fdb／Validate 39430419215／job 118653712104 的 14 單元＋1 啟動通過，僅核心／存檔等待問題 MFT-001 VERIFIED_CLOSED。
- Dot 的 7.3 是原 blob／母版及 0171012 SE3 風格與小尺寸辨識條件通過，可沿用擴作；不是 7.7 或完整遊戲通過。Dot 已獨立核對 2bb review archive digest／基礎 31／0／0＋延伸 3／1／0、工程六關及根層量測限制；原回報保留問題紀錄。

## 下一步與限制

本輪既有流程修正與同 SHA 回歸／IPA 已完成，沒有新功能待併入。將具體原物交獨立查驗；後續 MFT-007 若有允許的有效修法，改圖後需新 source SHA 及相應原生／深淺底／動態回歸，不能把新素材掛在舊 IPA 報告。

音訊監聽／系統靜音／真實觸覺、實體裝置效能、飛航完整遊玩、iOS 17 runtime 及完全非視覺通關 UNVERIFIED；使用者真機首次試玩清單在 PLAYTEST_GUIDE，不冒稱已驗。未簽名 IPA 需自行簽名，本輪不碰 Apple 帳號／簽署／TestFlight／App Store／Android，不新增付費服務。

CLI GitHub 憑證回傳 401，現有 GitHub 連接器可讀寫並已成功提交及下載；不需使用者重新登入才能保存成果。受測 App SHA 永遠以 manifest／CI 為準，文件提交不是另一個未測 App build。
