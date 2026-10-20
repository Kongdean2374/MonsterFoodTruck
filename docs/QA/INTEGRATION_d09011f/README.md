# d09011f 原生結果（整體失敗，未產 IPA）

Source `d09011f5c55c8ab29632e6d7ffbf4cc15f16743e`，[Validate 39489728099](https://github.com/Kongdean2374/MonsterFoodTruck/actions/runs/39489728099)，主 job `118859372658`。原 job 自行結束；沒有取消或重跑不變 SHA。已下載原 review artifact `12297477079`，141,804,776 bytes，SHA-256 `a9e5266d9e79170525a0ddf6b4dd8b20467ec561381eab6fdc5918e11cfe4ee2` 與 GitHub digest 相符。

| 原生 scope | 通過 | 失敗 | 略過 |
|---|---:|---:|---:|
| 基礎：26 單元＋5 UI | 31 | 0 | 0 |
| 延伸：ControlFlow、FullJourney、Performance | 3 | 1 | 0 |
| SE3／118880036118 | 3 | 0 | 0 |
| 15 Pro Max／118880035916 | 3 | 0 | 0 |

small／large 原 job 均自行 success，各 3／0／0；原 archive 已下載核對 digest，原生摘要在本目錄。package-device 118882342403 因主 job failure 按門檻 skipped，沒有完整 IPA；不把上傳成功當測試成功，也不把封裝 skipped 當成略過 XCTest。

Codex 實看兩尺寸大字／高對比首頁（small `2B4FED1C`、large `1ADE2730`）及 busy／左手固定情境（small `FD6FEC05`、large `35916752`）：首頁已關閉設定，工位奶油標籤清楚、數字與按鈕未見裁切。busy 圖是 DEBUG 靜態查驗，不是正式六關實際點按或動畫通過；原圖都在兩個 layout artifact，MFT-007 不因縮圖可辨就關閉。

原基礎教學／第一關真實點按、全部設定重開、保存恢復、還原及清除取消／確認均通過。延伸 ControlFlow、練習隔離、二十次真實進場通過；六份正常時鐘 DEBUG 工程 session 及重開解鎖走過，之後 driver 關閉的第五關真實點按仍失敗。六份工程歷史和真正後段 UI 存檔分開保存，不當成人工遊玩。

## MFT-015：原存檔確定偷嚐發生在香草可點性查詢期間

`FullJourneyTests.swift:80`：`Failed to determine hittability of "香草芽" Button: Activation point invalid and no suggested hit points based on element frame`。當時 `waitForExistence` 已看到香草，但下一個 hittability 查詢時它被合法移除；新增的配料後恢復 helper 尚未執行。

真正 App 保存檔 `QA_EVIDENCE/journey/actual-late-session/save-v1.json`（SHA-256 `fb98a9c1288b188a87ae3491f469e247ba7647e6807130270146c44cd345aa66`）提供直接事件證據：第一次整理 42.6657→45.6657 秒，既有偷嚐預告 41.8769 秒開始、整理期間暫停，47.8769 秒偷嚐；沒有香草輸入。失敗後才透過正常暫停 UI 保存，session 51.3012 秒、原鹿仍在、龍已服務。不是先前以日誌時刻推估的 Domain 重建。

[原失敗截圖](QA_EVIDENCE/journey/screenshots/EB111C5C-08DC-411A-90BE-4719DB6D0CC4.png)／[原 hierarchy](QA_EVIDENCE/journey/screenshots/E437FFA6-2354-4BB1-AFDF-0FB256B6C75C.txt) 一致顯示「被偷嚐・待整理」，主要動作為「整理 3 秒」，香草已不存在。[較早焦邊實圖](QA_EVIDENCE/journey/screenshots/BE9E28FF-D797-4607-B5B9-571FED7AD929.png) 保留。完整方法仍 failed，不將前半成功拼成整例成功。

下一修正只改真實 UI 案例的合法操作順序：餐蓋歸還重用及取下後，等這次一餐限一次的實際偷嚐完成，再整理、確認偏好資格沒有恢復、點原香草與出餐。保留原餐蓋開合／直接服務／重用、損壞時不能配料、香草 hittable、兩位服務及保存首頁斷言；新增實際偷嚐狀態與存檔事件先後檢查。正常時鐘／耐心／玩法不變，不注入狀態、強制點座標或自動重試整例。尚待新 SHA 原生。

## MFT-016／017：原生完整子樹與二十次進場

原 Performance 方法 passed，沒有重現 28e474d 的啟動終止失敗。原 `PERFORMANCE.json` 與 `PERFORMANCE_SUMMARY.json` 均匯出，庫內同一匯出器重新計算與原 summary 逐位元組一致。

- 二十次入場／暫停均為直接子節點 1、完整 SpriteKit 後代 5；update 取樣最大值也分別 1／5。包含當次第一位鹿的部件，排除 scene 本身及 SwiftUI／UIKit，不是所有關卡或游離物件存活分析。
- 預載音訊 player 49 固定；不代表 49 路同時播放。
- update cadence 約 53.45–59.12 Hz；每次 handler→next-update 樣本的 p95 約 9.41–46.57 ms；最大 frame gap 169.16 ms。這不是物理螢幕 FPS 或 touch-to-photon。
- 取樣 footprint 約 135.80–140.24 MiB，resident 約 376.33–424.38 MiB；不是連續 profiler 峰值或真機數據。

這是此有限流程的原生回歸與量測，未代稱 Dot 關閉 MFT-016／017、真機效能或完整遊戲通過。

原錄影 metadata 為 1116.85 秒／1206×2622／音軌 0，正常收尾、36 個唯讀原尺寸取樣、0 解碼錯誤。原 MOV 1,354,970,032 bytes，SHA-256 `26d718ebd4549ac09a32c0ec13f110fdaee8e960486f1047930cceff82f01def`；完整 MOV 仍在原重型 artifact，未下載或宣稱全段動畫／音訊聽感通過。

PROVENANCE 保存原包 digest 與所選原檔逐項 hash；重型 artifact `12296993325` 約 3.65GB 超過連接器 512MiB 上限，未下載。圖片原樣複製，沒有 Alpha 編修。MFT-007、7.7、真機音訊／觸覺與完整遊戲驗收仍待。
