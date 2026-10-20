# Content v2 排程診斷

2026-10-20，依規格 5.3、6.2、12.4 調整起始值，保持三角色／三菜／六關、訂單內容、耐心、備料／烹調／寬限／熱食時間與評分門檻。前兩關不變；後四關加密到達交錯，最多三客與至少四秒實際入場間隔仍由同一模型控制。暴露起始從七秒改三秒，明顯預告仍普通三秒／舒緩五秒。Content version=2，舊局依原存檔恢復流程拒絕不相容局，永久紀錄及設定保留。

舊版原生 3bc6d37／artifact 12279107638 的 72 筆資料全三星、0 預告／0 餐蓋，最長無合法工作等待 15.6 秒。先將該版本原始 Domain 在官方 Linux Swift 6.1.2 編譯，72 筆與原生數值逐項比對，誤差在 0.0001 內（BASELINE_PARITY.json）。後續候選均編譯實際 App 的 GameContent／GameSession／CommandReplayPlanner，沒有另一套簡化模擬器。Linux 結果仍不能代替新版本原生 XCTest 或 UI。

| 普通模式／動態排程 | 有保護 | 同輸入速度、禁用保護 |
|---|---|---|
| 第六關 1.8 秒命令＋0.4 秒選取 | 3 星、2 次餐蓋、0 偷嚐，133.8 秒 | 1 星、0 餐蓋、1 偷嚐，130.8 秒 |
| 第五關相同速度 | 1 星、1 餐蓋、1 偷嚐，108 秒 | 3 星；保護時機有代價，並非蓋上必勝 |
| 第五／六關 0.6 秒命令＋0.4 秒選取 | 均 3 星、各 2 次餐蓋 | 均 3 星；快速服務可代替保護 |

三種排程、0.6／1.2／1.8 秒間隔與雙模式共 72 筆保存在 candidate.json；相同條件禁保護對照在 candidate-no-protection.json。candidate-zero-selection.json 另用於既有無選單延遲快速參考解對照。所有輸入均走正式 validator，沒有注入分數／解鎖、預知尚未入場訂單或故意無操作展示餐蓋有用。新原生測試會保留每一策略完整 session，並檢查至少一個配對保護有實際成功／偏好收益。這些是工程診斷，未宣稱正常玩家體驗好玩、警告足夠易讀或 Dot 平衡通過。

重現（官方 Linux Swift 6.1.2，沒有 App 相依套件）：

```sh
swiftc -swift-version 5 -DDEBUG MonsterFoodTruck/Data/GameContent.swift MonsterFoodTruck/Domain/GameSession.swift MonsterFoodTruck/Domain/CommandReplayPlanner.swift Scripts/balance_diagnostics.swift -o /tmp/BalanceDiagnostics
/tmp/BalanceDiagnostics MonsterFoodTruck/Resources/Content.json /tmp/balance.json
MFT_DIAGNOSTIC_PROTECT=0 /tmp/BalanceDiagnostics MonsterFoodTruck/Resources/Content.json /tmp/no-protection.json
```

輸入環境變數只控制診斷命令頻率與保護策略，不會改正式遊戲時鐘。來源雜湊見 SOURCE_HASHES.json，實際候選 SHA 為包含本資料的提交。下一步需同 SHA 原生模型、正常時間六關錄影、真實後關餐蓋點按與真人覆核。
