# 0171012 三尺寸分離驗證

完整 source SHA：`0171012506fd63161b0d3911de0de6f294ff8f43`。 [Validate run 39446499495](https://github.com/Kongdean2374/MonsterFoodTruck/actions/runs/39446499495) 整體 failure，未重開／取消其工作。

| job | 實際結果 | artifact |
|---|---|---|
| layout-small 118709710147 | 2 UI passed／0 failed／0 skipped；11 PNG | 12277238759 |
| layout-large 118709710190 | 1 UI passed／1 failed／0 skipped；9 PNG | 12276374054 |
| validate 118709710697 | 未取得 runner，GitHub 取消；沒有執行單元、主尺寸 UI 或六關延伸 | 無 |

主 job 的 GitHub check annotation 原文：`The job was not acquired by Runner of type hosted even after multiple attempts`，以及 macOS arm64 capacity constraints。不是編譯成功或測試成功；不能從兩個 layout job 推算未執行的項目。

大尺寸失敗於 FlowTests.testHomeLayouts 的左手配置數值斷言，預期 1、實際 0。實圖高對比與大字為開，但左手配置在畫面底部之外；原 `isHittable` 沒有保證點按中心在可視區。後續會在點按前要求中心避開 toolbar／底部安全區並捲動，不移除原斷言。小尺寸該案例通過不取代大尺寸失敗。

已下載兩份 artifact；本目錄 PNG 為原生 xcresulttool 匯出的原檔直接複製，未拼接／重畫，來源檔名、案例與 SHA-256 在 SCREENSHOT_PROVENANCE.json。兩個 debug 情境案例只是固定模型狀態截圖，不是正常點按或真人操作。龍分層初稿在 SE3 的實圖可見，目前未獲 Dot 視覺通過，不據此擴稱正式三角色動畫完成。

Codex 實圖觀察：SE3 一般／大字左手的資訊與控制沒有明確裁切，腳部未壓上文字。大尺寸 warning 虛線貼右側耐心數字，需要將線移到保留邊距。首次教學角色同步修正不在此 SHA，不能用此候選代表修復。
