# 69c3933：原操作前進，設定回歸仍失敗

Source `69c3933a7833429a32b537ac2ba7e1ff93739f4b`，[Validate 39441785452](https://github.com/Kongdean2374/MonsterFoodTruck/actions/runs/39441785452)，job 118693237157，artifact 12275303224。**整體 failure**，原生摘要為 18 passed／1 failed／0 skipped：15 單元全部通過，4 UI 中 3 通過，教學／暫停／保存長流程在新增的觸覺開關保存斷言失敗。沒有小／大裝置結果。

這次成功匯出 26 張原始 PNG、原生 summary 與完整 xcresult／log；此目錄僅保存可直接檢視的選圖及必要統計。檔案直接複製，沒有重畫、裁切或合成；對應原始 UUID 見 EVIDENCE_INDEX。

- 原來「裝盤」阻擋沒有重現；真實點按走完備料／下鍋／裝盤／出餐、暫停／設定、保存回首頁、終止／重開／繼續，之後完成第一關（三筆服務、兩筆偏好、二星），實際保存並解鎖第二關。這是同一個後段仍 failure 的測試案例之子流程證據，不能把整個案例標為 passed。
- `actual-settings-before-restart-switches-unchanged` 清楚顯示點選文字區後的高對比／大字仍為關閉；當時 artifact 的 `settings-large-contrast-left` 等檔名是預期情境名，不是已確認旗標生效。重開後觸覺仍開啟，FlowTests.swift:68 失敗。後續保留原斷言，加上點按後即刻查驗並修正文字區觸控；設定關閉也等待存檔完成。
- `actual-DEBUG-large-left-contrast` 是明確以 DEBUG 測試情境開啟旗標的真實 App 畫面，非上述文字區點按成功證明。
- 單角色 rig 試裝已在真實 402×874pt App 渲染，未見原腳部壓菜名的重疊；尚未確認小尺寸、深色邊緣、五表情及動作，也沒有 Dot 量表判定。其餘兩角色仍是原母版。
- `actual-DEBUG-warning` 顯示舊警告線終點被成品按鈕遮住；後續改到 SwiftUI 控制上方、增加目標外框與爪子提示，需重拍。
- 此候選 teardown 使用 `hasSucceeded` 過早判定，讓已通過案例亦留下名稱為 FAILED 的附件；真正失敗數以原生 summary 為準（只有一項）。後續改用 failureCount，保留原 artifact 名稱以利稽核。
- 實際包內所有離線資源逐檔 SHA-256 與來源一致，包含圖像、25 音訊及三食譜／三魔物／六關。這不代表聽覺、美術、完整 UI 或裝置 IPA 通過。

尚無對此候選的 Dot 獨立通過回報，MFT-002／MFT-003 不代簽關閉。
