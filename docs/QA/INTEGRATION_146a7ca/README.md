# 146a7ca 實測紀錄

Source `146a7caffbbc8b88489eb4be112dbfd04a7e4031`，[Validate 39455229683](https://github.com/Kongdean2374/MonsterFoodTruck/actions/runs/39455229683)，整體 **failure**，沒有重新執行相同提交。

| 原生範圍 | Job | Artifact | 實際結果 |
|---|---|---|---|
| iPhone 16 Pro／iOS 18.5 | 118740237075 | 12280577079 | 25 項，24 passed／1 failed／0 skipped；21 單元全通過、4 UI 中 3 通過／1 失敗 |
| SE3 小尺寸 | 118743990402 | 12281068198 | 2 項，1 passed／1 failed／0 skipped |
| 15 Pro Max 大尺寸 | 118743990605 | 12281082785 | 2 項，2 passed／0 failed／0 skipped |

原觸覺即時值與程序重開後的 0 斷言、兩音量為 0、減少動態為 0 都實際通過；[重開後實圖](E654E3A1-1E0F-482C-9708-42128307CF92.png)。整個 Flow 案例仍失敗：按「還原設定」後，背景首頁的關卡選擇存在但無法點按，[失敗當刻確認窗仍在](623D2BD5-DA7C-4BBF-B826-D417B7BD427F.png)。視窗亦繼承首頁深色背景、文字對比不足；MFT-008 保留實際證據，下一候選明確 dismiss、固定淺色及完整按鈕命中區，並等待首頁真正 hittable。尚未確認此次按鈕點按是否有進入 action，不先斷定只是 binding 問題。

SE3 的 debugScenario 通過，HomeLayouts 在 FlowTests.swift:133 找不到「高對比資訊」而失敗。[失敗實圖](73D9EFA0-AD7B-49CB-A644-E5DF45E0943C.png) 顯示 Form 回到頂部。原始 log 顯示大幅上／下捲反覆跨越同一目標；146 的 exists guard 避免了直接讀不存在 frame，仍不足以讓 SE 完成。下一候選使用短距離捲動、實際導覽列邊界並保留每一步位置，所有設定與重開後斷言保留。

六關正常時鐘工程重播、延伸真實點按、場景二十次進出與錄影未執行，沒有本 SHA 的完整遊戲 IPA。圖片均直接複製原生附件，未重畫；來源及雜湊見 SCREENSHOT_PROVENANCE.json。不是 Dot 對新候選的通過判定。
