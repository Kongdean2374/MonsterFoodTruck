# 28e474d 原生結果（整體失敗，未產 IPA）

Source `28e474db37fdc8c9be40a490cd9c51a1070bd888`，[Validate 39481483503](https://github.com/Kongdean2374/MonsterFoodTruck/actions/runs/39481483503)。保留原 job／原斷言，沒有取消或重跑不變 SHA。review artifact `12293059125` 已下載，SHA-256 `ef1c15760f49de5c8edef6a4759c9604202542983233e198092fd1c84fdfb77b` 與 GitHub digest 相符。

| 原生 scope／job | 通過 | 失敗 | 略過 |
|---|---:|---:|---:|
| 基礎：26 單元＋5 UI／118832059204 | 31 | 0 | 0 |
| 延伸：ControlFlow、FullJourney、Performance／同主 job | 2 | 2 | 0 |
| SE3／118851764735 | 3 | 0 | 0 |
| 15 Pro Max／118851764708 | 3 | 0 | 0 |

大小尺寸原 archive 均已下載核對 digest 及原生摘要。主 job 整體 failure，package-device 按門檻 skipped，沒有完整遊戲 IPA。此 skipped 是未執行封裝 job，不是略過失敗 XCTest；原測試摘要 skippedTests 都是 0。

基礎完整教學、第一關實際點按、保存／重開、設定值、還原／清除確認流程仍全過。新增確認清除後保持非預設設定、清除 session／教學旗標的 SceneLifecycle 方法也通過。不是 Dot 獨立關閉或所有遊戲通過。

延伸的 ControlFlow 與練習隔離通過。六份正常時鐘工程 session 全部服務完成，服務／偏好分別 3／3、4／4、5／5、6／6、7／7、9／8；結算與重開解鎖已走過。它們使用 DEBUG 命令 driver，不是全程真實 UI 點按。其後 driver 已停，原第五關真實點按方法仍失敗，整個方法保留 failure。

原生操作時序：19:47:28 點第一輪整理；原「已整理・偏好失效」斷言通過；19:47:33 點香草芽；之後沒有出餐點按，等待至 19:48:14 的原 helper failure。見原日誌摘錄及 [整理前實圖](QA_EVIDENCE/journey/screenshots/D96DB399-43DF-44DF-8E58-EB7FBF3DE08E.png)、[出餐等待失敗實圖](QA_EVIDENCE/journey/screenshots/A223F638-4077-4570-8D35-9ED6C0614EF0.png)。失敗時第一位鹿已離場，不能只憑這張稍晚圖判定配料當下狀態。

`ENGINEERING_RECONSTRUCTION/` 用原生 synthesized-event 的近似相對時刻在同一純 Domain 重建：焦邊約 32.094 秒、整理 44.102→47.102、香草 49.572、偷嚐 49.919，配料被取消並再需整理；正常第二輪整理／配料可在耐心到期前送出，偏好仍失效。**這是工程診斷，不是新的 UI 通過證據。** 下一修正候選只依實際顯示的第二次受損做一次有界恢復，保留原配料／兩次出餐／餐蓋操作斷言、正常時鐘與全部原失敗。另記錄實際 UI 命令轉移並唯讀匯出原 App 後段保存檔，以便下次直接核對真正事件。

Performance 方法在第 13 行 `app.launch()` 自動終止前一個 App 時失敗：`Failed to terminate ...:58814 ...:0`，並未進入二十次迴圈。保留 [實際失敗畫面](QA_EVIDENCE/journey/screenshots/439E906D-3A59-42BF-934A-8056767A8DC6.png)，未把 2bb 的舊二十次取樣套用到此 SHA，也未先歸因 App deadlock 或 runner 容量。MFT-017 仍需新原生重測；失敗附件之後才經實際暫停 UI 保存現場，供下一候選排查。

原錄影 734,716,563 bytes，SHA-256 `2eb27f4e70f9193cadf49f092d76356f56e1ab7c704a4c28000262c0f50c7f87`；原 metadata 960.34 秒、1206×2622、音軌 0。錄影正常收尾，沒有強制終止，唯讀匯出 36 個原尺寸時間點、0 個解碼錯誤；完整影片與原尺寸取樣在原 Actions artifact，這裡只複製選定的原始 XCTest PNG／JSON。未宣稱實看全段、動畫 7.7 或音訊聽感通過。

PROVENANCE 保存原包 digest／逐檔 hash；重型 artifact `12294476623` 約 3.32GB 超過連接器 512MiB 上限，未下載，原物仍在 Actions。小型 review 可直接查閱所有原摘要、104 張 PNG（含 36 個解碼時間點）與六份 session。沒有改圖或補造缺失效能數字。
