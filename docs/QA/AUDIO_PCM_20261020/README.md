# 隨包 WAV 的唯讀 PCM 查驗

直接讀取目前 25 個正式 WAV 的真正 PCM bytes，記錄 SHA-256、sample rate／聲道／長度／peak／RMS／頭尾樣本。沒有重做或改動 WAV／PNG，也沒有把產生器的浮點報表當量化後音檔實測。

25 檔皆無滿刻度樣本；循環配樂尾樣本接首樣本的差為 0。預設音量下偷嚐預告相對配樂的整段 RMS 高約 11.74dB；這是數值比較，不能代表人耳辨識已通過。

按實作最多六個音效 voice、每個音效兩個已分配播放器，取個別 peak 的保守相加上界，原最大音量為 1.427、原預設值為 1.045。這個上界不代表 App 已發生削波。下一候選為音樂及音效共同加入 0.6 的混音餘量，保留兩 slider 比例及提示相對音量，使最大音量的保守上界降為 0.856。音檔、發聲數上限、優先序及事件合併皆不改。

詳見 EXACT_WAV_ANALYSIS.json。原生輸出混音、循環感受、裝置喇叭、靜音／中斷及真實觸覺仍需實際監聽／裝置查驗；未宣稱美術音效或整個遊戲驗收通過。

可直接下載原 WAV 作獨立監聽，不需先安裝 App；瀏覽器單檔播放不代表 App 混音：

| 原始音檔 | 監聽重點 |
|---|---|
| [配樂](../../../MonsterFoodTruck/Resources/Audio/forest_evening.wav) | 連續兩圈的接縫、輕柔程度 |
| [備料完成](../../../MonsterFoodTruck/Resources/Audio/prepDone.wav) | 與下列兩種關鍵提示是否可分辨 |
| [烹調完成](../../../MonsterFoodTruck/Resources/Audio/cookDone.wav) | 起鍋提醒是否清楚且不刺耳 |
| [偷嚐預告](../../../MonsterFoodTruck/Resources/Audio/nibbleWarning.wav) | 是否容易分辨、與配樂混合時是否仍清楚 |
| [龍](../../../MonsterFoodTruck/Resources/Audio/dragonReaction.wav)／[小鬼](../../../MonsterFoodTruck/Resources/Audio/impReaction.wav)／[鹿](../../../MonsterFoodTruck/Resources/Audio/deerReaction.wav) | 三個非語言反應的差異 |
