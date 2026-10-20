# 場景節點量測範圍與原生結果

後續 source d09011f／Validate 39489728099 已由 Apple SDK 編譯且原 Performance 方法通過。二十次入場／暫停直接子節點均 1、完整 SpriteKit 後代均 5，update 取樣最大值也分別 1／5；原始 JSON 和重新計算逐位元組相同的 summary 見 [INTEGRATION_d09011f](INTEGRATION_d09011f/)。整體另有真實後關點按失敗，沒有 IPA，也未代稱 Dot 或所有場景效能通過。以下保留準備時的歷史與範圍。

Dot 指出 2bb 的 `nodes=1` 後，已查明只取 `scene.children.count`。原 raw JSON／摘要保留，不能轉寫成全部部件穩定。

本地準備的 DEBUG 診斷遞迴計算完整 SpriteKit 後代，分別輸出入場／暫停直接子節點、完整後代，以及 scene update 取樣最大值。排除 scene 本身及 SwiftUI／UIKit 視圖；不是配置數、未掛樹物件的存活分析或連續 profiler 峰值。只更正驗收量測，沒有新增玩法或改時間／分數。

二十次原真實 UI 案例保留原根節點／音訊斷言，再檢查完整角色部件數大於根層、各次相同。原生摘要另要求入場與暫停的相同第一位客人流程子樹一致，原始與取樣最大值均保存；不把這項有限重進檢查擴成所有關卡／真機效能通過。

已完成 Swift 語法解析與 Python 語法檢查。以真正 2bb `PERFORMANCE.json` 呼叫新匯出器，正確拒絕把舊根層資料升格為全樹證據，沒有產生替代 summary 或修改原始檔。新遞迴數值尚未由 Apple SDK 編譯或原生執行。

這些改動納入下一修正候選，尚未有新原生數值；已完成但整體失敗的 28e474d／Validate 39481483503 不包含它們。原失敗已核對後才整合，不取消或重跑不變的 job。
