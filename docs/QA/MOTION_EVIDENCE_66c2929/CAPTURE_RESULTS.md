# 同候選的五段短片與連續動態查驗

實際 App source 始終為 `66c2929dd05c28af1b0c3ec8a79805446c6dc023`／build 25；原 41 項回歸、裝置 IPA 及全部產品 tree 均未改。新建的兩份 Simulator App 各 47 份離線資源 hash，和原實際裝置 IPA 的資源識別完全一致。拍攝 harness SHA、匯出器 SHA 與 App SHA 分列。

## 操作結果與原始影片

五種短片案例已有成功操作紀錄。補拍總共執行 **6 次拍攝 XCTest：5 passed、1 failed、0 skipped**，不是「5／0」或新的完整回歸。原 fd05dc6 另在執行拍攝測試前因圖示 metadata gate 失敗。

| Run／harness | 實際結果 | 明確範圍 |
|---|---|---|
| [39509800845／fd05dc6](https://github.com/Kongdean2374/MonsterFoodTruck/actions/runs/39509800845) | failure，尚未跑拍攝 XCTest | 漏接既有資產準備，AppIcon metadata gate 攔下；[原失敗](FAILED_fd05dc6.md) |
| [39510391658／9a34d46](https://github.com/Kongdean2374/MonsterFoodTruck/actions/runs/39510391658) | failure；4 passed、1 failed、0 skipped | 深／淺底、濃湯、燉菜操作通過；脆餅被安裝狀態拒絕啟動。五份時間 JSON 匯出失敗，不能改寫整體成功；[原摘要與失敗](FAILED_9a34d46.md) |
| [39512444370／f8beae1](https://github.com/Kongdean2374/MonsterFoodTruck/actions/runs/39512444370) | success；1 passed、0 failed、0 skipped | 新 runner 只補缺少的脆餅；原斷言及識別／47 資源 gate 保留，沒有重拍其他四段或重跑六關 |

| 已下載核對的原 ZIP | bytes | SHA-256 |
|---|---:|---|
| [12305138449](https://github.com/Kongdean2374/MonsterFoodTruck/actions/runs/39510391658/artifacts/12305138449)，原五段／含脆餅失敗 | 147,353,842 | `6ec1acf0784a2f7c78b42641aa8533cfc411660f656231e6a7c4545459747573` |
| [12307030020](https://github.com/Kongdean2374/MonsterFoodTruck/actions/runs/39512444370/artifacts/12307030020)，成功脆餅補拍 | 31,656,982 | `b4688e4fd12514a9fe8a23e9ce1f664668859e2705b03bf6f5afadfcbc0ff1cc` |

GitHub 登入後下載 ZIP，影片位於各 `phase/phase.mov`；原 xcresult 另在相同 run 的 diagnostics artifact，沒有刪除。影片均為 SE3 的 750×1334 原生錄製；音軌 0。

| 原 MOV | 實際內容與限制 |
|---|---|
| `dark/dark.mov`、`light/light.mov` | 既有 DEBUG ArtReview 深／淺底，首列三個共用生產 Rig 連播三次。三角色初始訂單手勢、接餐、回位；小鬼另有伸手／偷嚐，龍的 warning 是既有 no-op。其餘四列為靜態表情。這不是三角色都由玩家真正出餐的流程 |
| `soup/soup.mov` | 第一關 L1-1，真實備料／下鍋／裝盤／蓋／取下／香草／出餐。保存事件證明 24.510420 秒達成偏好、status=served |
| `stew/stew.mov` | 第五關 L5-1，正常時鐘焦邊 31.591956→裝盤 34.541858→偷嚐 40.541858→整理 42.374292～45.374292→餐蓋→香草 51.258589～53.258589→出餐 55.153745 秒。其他客人有 left，不是第五關通關 |
| `crisp/crisp.mov`（補拍 ZIP） | 第四關 L4-1，同一套正常操作。真正 save 記烹調完成 15.667078、裝盤 16.213032、餐蓋、香草完成 23.129905、出餐達偏好 23.829912 秒 |

三菜都先還原候選原 bytes 的已賺取進度，再用正常 UI 操作單一客人；沒有改保存 JSON 或訂單／分數，也沒有工程命令 driver。這不是自然解鎖、整關成功或全遊戲點按通過。上述事件秒數是 **session 遊戲時鐘**，不能直接當電影定位時間。[逐片 SHA／操作／事件與完整測試歷史](CAPTURE_RESULTS.json)。

## 連續影格與時間定位

原 MOV 保留。時間戳初版匯出失敗已修正為 Encodable／JSONEncoder，脆餅原生成功輸出 [FRAME_PTS](NATIVE_f8beae1/crisp/FRAME_PTS.json) 與 CSV。對已有電影的本機 ffprobe 診斷另保留原始 frame PTS、重複／逆序紀錄及完整解碼結果；不把 ffmpeg 的 best_effort_timestamp 或 nominal FPS 當 actual，也不按牆鐘猜影片相位。這些都是影片診斷，不能證明畫面接合正確。

本機部分解碼影格出現文字／部件重影，因此另以 Apple AVAssetReader 對**已有**電影匯出相鄰原尺寸影格，保留讀出順序及每個 sample 的 actual PTS，不修改原 MOV，不重跑 App，不把 sort 後序號冒充原始 frame 序號。原生匯出結果待本頁後續補入。

7.7 仍為 **3／3／UNVERIFIED／3／2／3，不計總分**；操作綠燈、電影存在或能解碼不等於動態接合／美術通過。Alpha 第三次局部工具試稿未採用，原 PNG 未變。[完整剩餘驗收與最小本人動作](REMAINING_ACCEPTANCE.md) 保留音訊聽感、真機、具體方法授權與最終獨立判定缺口。
