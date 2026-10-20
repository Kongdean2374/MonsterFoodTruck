# 錄影證據品質：與直接螢幕快照分開

[原生解碼 run 39513480323](https://github.com/Kongdean2374/MonsterFoodTruck/actions/runs/39513480323)／job 118939919113／匯出器 `c294f88aff77ab5b45032cc2f57df63f29a8f6eb` success。這是讀取原電影的工作，沒有 App build、模擬器或 XCTest。原 App 仍 `66c2929dd05c28af1b0c3ec8a79805446c6dc023`。

已下載 [artifact 12306483691](https://github.com/Kongdean2374/MonsterFoodTruck/actions/runs/39513480323/artifacts/12306483691)，370,083,573 bytes，SHA-256 `6ab0952818b80d4c4ae1dab19406c2c95279e9993848cbedd3130f9833f7a29f`。552 份原始匯出檔逐一 byte count／hash 相符，其中 542 張 PNG 均為 750×1334，沒有改像素。每段都有原生 reader 的實際 PTS／順序索引：

| 段落 | Apple decoder 原生影格數 | 保存的全部相鄰 PNG |
|---|---:|---|
| dark | 956 | reader frame 60～320，共 261 張；actual 48.020000～53.443333 秒 |
| light | 1040 | reader frame 140～420，共 281 張；actual 20.441667～26.798333 秒 |
| soup | 2141 | 原電影與完整 native PTS，未在此重做料理畫面 |
| stew | 3625 | 同上 |
| crisp | 2177 | 同上 |

Codex 已實看其中 dark 100／160／200／280、light 180／260／320／400：可見首列伸手、三位餐盤與滿足、回位，但部分讀出畫面也有靜態字重複或局部重影（例如 dark 200、light 400）。未稱 542 張每張都已人工驗過，也不能把原生解碼 success 當作接合成功。不同 decoder 的影格數及 PTS 有差異，不能用 ffmpeg frame 序號指代 Apple reader 序號；原始資料都保留。

因此下一個 `[rig-snapshots]` 請求只做兩個固定 App 的 ArtReview 案例，**不啟動 recordVideo encoder**。外部 `simctl io screenshot` 先完成一張基準 PNG、確認回寫到 UI-test runner 的 Documents，再由既有按鈕開始動作，連續六秒保存直接原尺寸快照及每次請求的實際開始／完成牆鐘時間。這些時間是擷取區間，不是假稱影片 PTS 或 nominal FPS。以直接快照對照是否是錄影路徑的影格問題，尚未在 App 寫入新修補或改素材。

原 4／1 拍攝 failure、補脆餅 1／0 success、原 MOV、原 native decoder PNG 與問題幀都保留；不刪掉瑕疵影格再宣稱全片乾淨。7.7 第 3 項維持 UNVERIFIED，第 5 項 2／4；不計總分。
