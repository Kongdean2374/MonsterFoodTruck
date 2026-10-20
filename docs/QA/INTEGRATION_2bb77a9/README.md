# 2bb77a9 原生實測與保留失敗

Source `2bb77a9af1064272f1d4ca50a0dc950fecf7f04a`，[Validate 39472144828](https://github.com/Kongdean2374/MonsterFoodTruck/actions/runs/39472144828)，主 job `118798719852` **failure**。18:56 UTC 使用者轉交 Dot 獨立核對：測試步驟已 failure、仍在上傳附件；已記錄，沒有把上傳當成仍測試或取消原 job。後續原附件完整上傳，Codex 下載 review artifact `12290551843`，archive SHA-256 與 GitHub digest 相符。

| 原生 scope | 通過 | 失敗 | 略過 |
|---|---:|---:|---:|
| 基礎：26 單元＋5 UI | 31 | 0 | 0 |
| 延伸：ControlFlow、FullJourney、Performance | 3 | 1 | 0 |

原 TEST_RESULT_SUMMARY、JOURNEY_TEST_SUMMARY、VALIDATION_STATUS 與日誌摘錄均保留。基礎完整 Flow 已通過首次教學、實際點按第一關、結算／解鎖、暫停保存／重開、全部設定重開值、還原設定及清除進度取消／確認；MFT-008 舊失敗沒有移除。Scene fixture 已由真實 SaveStore 載入，MFT-014 原編譯失敗已通過原生編譯及執行。這不是 Dot 獨立關閉或全遊戲通過。

唯一失敗在 `FullJourneyTests.swift:60`：第五關後段，餐蓋歸還重用後直接點香草芽，當時燉菜已焦邊、需要整理。原生 hierarchy 明列「焦邊・待整理」與「整理 3 秒」；失敗截圖稍後已再遭偷嚐，同樣需要整理。不是 Missing bundle ID、測試 timeout 或上傳／錄影停止 timeout。修正跟隨實際 UI 整理，再保留香草芽與兩次出餐斷言；不放寬 Domain、不注入修復狀態。

| 原始 App PNG | 實際範圍 |
|---|---|
| [失敗時畫面](QA_EVIDENCE/journey/screenshots/184628C0-A789-4255-A6E1-87DF504079D2.png) | 已服務 1／7，燉菜待整理，沒有香草芽按鈕 |
| [正常第五關蓋住龍餐](QA_EVIDENCE/journey/screenshots/801C48B8-AB34-4EBB-A272-64EBD555A142.png) | Driver 已停，真實點按；旁邊燉菜已焦邊 |
| [六關完成](QA_EVIDENCE/journey/screenshots/E257606E-8111-48F2-A0A6-8CC588F1E880.png) | 正常前景時鐘工程命令 driver，並非全程手動點按 |
| [第六關結算](QA_EVIDENCE/journey/screenshots/CD9A5CF4-C641-4D28-AFC0-E56CF3E971CE.png) | 9 服務／8 偏好，實際結算與保存；整個方法仍後續失敗 |
| [清除後重鎖](QA_EVIDENCE/57639D03-DFFD-46B7-8BF0-6F0D4B3F4BD5.png) | 基礎真實點按完整 Flow 的確認清除結果 |
| [首頁大字](QA_EVIDENCE/26CA896F-B283-4553-8198-EFF74E1234D0.png) | 設定已退出，實際首頁；其他尺寸另看各 job |
| [忙碌工位標籤](QA_EVIDENCE/44A003C2-D433-47DF-A9D2-E88DEAB8485F.png) | 明示 DEBUG 固定狀態；奶油淺底側標保留木紋，不是正常通關證據 |
| [深底五表情](QA_EVIDENCE/D0C063A7-5E35-436D-8A15-96F268B8DF10.png) | 實際 App 查驗頁；MFT-007 Alpha 仍開放，非動畫驗收 |

六份 `actual-model-snapshots` 是六次實際前景時鐘 session，服務／偏好分別 3／3、4／4、5／5、6／6、7／7、9／8；第五、六關各兩次餐蓋命令。結算、全部解鎖與程序重開斷言已走過，後續真實餐蓋點按失敗仍計入整個方法，不能將這些子步驟寫成完整 UI 通過。

練習隔離、真實背景五秒／失敗／同關重試／模式／取消／放棄，以及二十次實際場景進出，各自原生方法通過。PERFORMANCE_SUMMARY 的 SpriteKit update cadence 56.4–58.3 Hz、handler→next-update p95 8.48–20.42ms、取樣 footprint 135.2–140.1MB、resident 418.9–424.7MB；每次場景直接子節點（根下一層）1／預載音訊實例 49 固定。`PerformanceDiagnostics.enter` 只記錄 `scene.children.count`，不是遞迴計算角色部件與全部後代；不能由此宣稱整棵場景節點穩定。這不是物理 FPS、touch-to-photon、真機或連續 profiler 峰值。

原 MOV 在重型 artifact `12290916626`，1,065,126,399 bytes，原 metadata 1122.53 秒、1206×2622、音軌 0。整包 3,257,540,568 bytes 超過連接器 512MiB 上限，未下載／未宣稱實看整段。小型 review 內原 PNG／JSON 可直接下載；PROVENANCE 保存兩包 digest 與此處逐檔 hash，PNG_INDEX 保留 XCTest 名稱、裝置及時間。沒有重新建置、重跑、改圖或把 failure 換成 success。

SE3 small job `118823068652` 已完成：3 passed／0 failed／0 skipped；原 artifact `12291387951` 已下載並核對 digest。[375×667pt 首頁大字](QA_EVIDENCE/layout-small/A1DB82D6-FCF8-4AD1-8812-D6803B46444F.png) 確認已退出設定且沒有底部接縫；[小尺寸大字左手 busy](QA_EVIDENCE/layout-small/0C59948E-2226-47F6-844C-935446DB8277.png) 的固定奶油側標可辨、木紋保留，爪子與耐心數字未相壓。這兩張由 Codex 實看，未代稱 Dot 通過。

完整同 SHA IPA 尚未產生。large 原 job 保留執行，結果另補；不以本頁替代原生全 scopes 成功、7.7 或 Dot 驗收。

使用者另轉交 Dot 獨立下載同一 review artifact、核對 archive SHA-256、31／0／0 與 3／1／0、焦邊待整理／無香草芽、六份 session 服務完成、二十次模擬器診斷及無音軌；判定範圍完全保留。Dot 指出 nodes 計數風險後，Codex 已查源碼確認僅直接子節點，列 MFT-016，沒有把它當全部節點或真機效能通過。
