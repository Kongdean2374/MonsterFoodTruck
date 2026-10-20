# d59f212 整合失敗證據

[Validate 39433857551](https://github.com/Kongdean2374/MonsterFoodTruck/actions/runs/39433857551) 整體 failure。實際 log 為 14 單元通過，3 UI 中 2 通過、教學／暫停／保存流程在「裝盤」失敗；小／大尺寸未執行。Dot 亦獨立下載 artifact 12271815746 核對相同結果（使用者轉交）。

本目錄 PNG 為實際 xcresult 內原始附件的未修改內容，透過 zstandard 解壓取出，不是重畫、合成或測試後補拍。此候選的腳本因 set -e 提前結束，artifact 只有原始 xcresult/log，尚無原生匯出 PNG／summary；下一候選修正為成功或失敗均先匯出再回傳原失敗狀態。

- actual-home：實際 402×874pt 首頁，已檢視，底部接縫消失；尚待其他尺寸回歸。
- actual-DEBUG-busy：以真實模型命令建立後凍結的測試情境，非正常速度點按流程通過。
- actual-DEBUG-busy-large-left-contrast：同尺寸的大字／左手／高對比情境。角色腳部與菜名相疊，已列入後續修正；不能當成美術驗收通過。

UI 失敗時的 App accessibility 記錄顯示料理仍在備料槽，按鈕仍是「下鍋」。測試在 prepDone 教學覆蓋層出現的競態中，點按後直接假定命令已接受。修正保留完整原流程及斷言，隔離／隱藏模態背景操作，測試等待實際工序轉移；不得僅延長逾時或移除裝盤／出餐斷言。
