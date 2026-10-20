# 3bc6d37 首次教學穩定畫面

Source `3bc6d37b2804a7ed61c5d51b9cdd937da3713413`，[run 39450296133](https://github.com/Kongdean2374/MonsterFoodTruck/actions/runs/39450296133)，主 job 118723012974，artifact `12279107638`。本目錄保存主 job 證據；兩個尺寸 job 仍待結果。

主 job **failure**：23 項、22 passed／1 failed／0 skipped。19 單元全部通過，4 UI 中 3 通過／1 失敗。失敗為 FlowTests.testNavigationTutorialPauseAndPersistence 在可視中心 helper 讀取已移出可及性樹的音樂滑桿 frame 時，尚未捲動便無匹配；不是觸覺重開保存通過。本輪原教學到備料／下鍋／裝盤／出餐成功，設定三個切換即時值為 1，之後失敗。六關延伸未執行。

MFT-004 穩定證據（原始 PNG，未重畫）：

- [教學出現](4732829F-A66F-4A2F-9161-E766130E9DEB.png)
- [教學保持 1 秒](6EAAE1E0-A7F5-430C-9526-31220F3F074D.png)
- [教學保持 3 秒](7C4DB79C-2CE9-4296-8250-98F63D257FF4.png)

三圖位元組相同，SHA-256 `21f257d10322a86542220dd09331b27257685f780e44f8d6943e83db90bba398`。Codex 已實際檢視，角色、選框、耐心 65 一致；測試中沒有按繼續。節點單元亦實際通過，確認首次教學前建立 texture 與 alpha=1，時鐘暫停。此為 READY_FOR_RETEST，未代稱 Dot 已關閉本問題。

另外兩圖為明確 DEBUG 餐車分層初稿，一般／大字左手固定 busy 情境，不代表正常點按完整流程或正式美術。初稿有道具超出保留圖區／工作檯視覺過重等需修整之處；保留回退。所有原檔與案例／來源在 SCREENSHOT_PROVENANCE.json。

STRATEGY_DIAGNOSTICS.json：真正 Domain、三種排程、0.6／1.2／1.8 秒間隔與 0.4 秒選取延遲、後四關雙模式，共 72 筆。全部三星，0 偷嚐預告、0 餐蓋，最長無可操作等待 15.6 秒。這只代表可解，反而暴露策略差異與餐蓋價值不足，後續需依規格 5.3／12.4 調整交錯及暴露起始時間並比較，不以故意無操作場景冒充選擇有趣。
