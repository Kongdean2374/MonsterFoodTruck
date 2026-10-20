# 第二次補拍：四項操作通過、一項啟動失敗，時間匯出失敗

[Run 39510391658](https://github.com/Kongdean2374/MonsterFoodTruck/actions/runs/39510391658)／job 118929662697／harness `9a34d468b074799329dee99f80bb4ae44fe21231` 整體 **failure**。實際 App 一直是 `66c2929dd05c28af1b0c3ec8a79805446c6dc023`／build 25，原生編譯及 bundle／AppIcon／47 資源檢查成功。此輪不改寫成全部通過，也不和原 41 項回歸混算。

| 拍攝方法 | passed／failed／skipped | 原生結果 |
|---|---|---|
| 深底三角色三次連續循環 | 1／0／0 | 原 MOV 保留 |
| 淺底三角色三次連續循環 | 1／0／0 | 原 MOV 保留 |
| 濃湯真實單客人 | 1／0／0 | 真正 save：L1-1 served，備料／下鍋／裝盤／蓋／取下／香草／出餐輸入齊全 |
| 燉菜真實受損／整理單客人 | 1／0／0 | 真正 save：L5-1 served；焦邊、偷嚐、整理與香草齊全。其他客人有 left，不是完整第五關成功 |
| 脆餅單客人 | 0／1／0 | app.launch 階段失敗，尚未開始料理；FBSOpenApplicationErrorDomain Code=6，App 正在 installing or uninstalling，拒絕 launch |

全部五段原 MOV 都正常停止、沒有強制終止。時間解碼程式在 JSONSerialization 寫出時均發生 `Invalid type in JSON write (__SwiftValue)`；原 `VIDEO_PROBE.log`、CAPTURE_STATUS 的 probe_exit=1 及 failure 保留，不能把它稱為已成功匯出時間索引。修復以型別明確的 Encodable／JSONEncoder 寫出，避免 Any 語境下 Optional 被包入 JSON。已有原 MOV 可直接用唯讀 ffprobe／ffmpeg 重新解碼實際 PTS，不需再拍四個成功案例。

| 原始附件 | bytes | ZIP SHA-256 |
|---|---:|---|
| [12305138449](https://github.com/Kongdean2374/MonsterFoodTruck/actions/runs/39510391658/artifacts/12305138449) 五段原 MOV／摘要／save／失敗現場 | 147,353,842 | `6ec1acf0784a2f7c78b42641aa8533cfc411660f656231e6a7c4545459747573` |
| [12305053561](https://github.com/Kongdean2374/MonsterFoodTruck/actions/runs/39510391658/artifacts/12305053561) 原 xcresult／build.log | 58,583,333 | `d0c2535eb170e2be848dd22d1adbb1c1f4ff73109be52383e7107300246960df` |

第一份已實際下載核對 digest。原摘要／五份狀態／probe log／兩份真正料理 save 原樣保存於 [NATIVE_9a34d46](NATIVE_9a34d46/)。下一個短片請求明確標 `[crisp-only]`，只在新 runner／同候選 App 補脆餅；保留原失敗，不加 retry、不刪斷言或降低來源／識別／資源 gate。啟動狀態的唯一根因尚未推定。
