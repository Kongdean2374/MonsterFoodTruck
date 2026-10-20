# Linux 核心與存檔回歸

官方 Linux Swift 6.1.2，在本工作樹編譯實際 App Data／Domain／SaveStore。來源逐檔 SHA-256 見 SOURCE_HASHES.json，adapter 與原始輸出保留；不是 iOS SDK build、UIKit／SpriteKit、點按或 Dot 驗收。

- GameModelTests：15 方法、0 failures，新增雙爐／雙成品滿位拒絕不移動料理、客人離場取消整理且只回收一次資源。其餘原門檻／六關／熱度／餐蓋／快照等斷言全部保留。
- SaveStoreTests：4 方法、0 failures，包含新增舊 contentVersion session 丟棄後保留星數／左右手／模式／音量且可繼續原子寫入。使用真實暫存檔案與主 queue 回呼，不模擬成功 callback。

adapter 僅將 Bundle 讀取改成本地同一 Content.json，移除 @testable import；GameModel 額外略去 Linux 不支援的 XCTest 附件匯出，所有測試方法及斷言不刪。SaveStore adapter 不修改 I/O／async 等待／斷言。原生測試仍使用原檔與原附件。

新增呈現狀態模型案例只完成語法解析，需 iOS 原生執行；單一 sheet 的實際取消操作仍必須由原完整 UI 案例重測。完整 validate_content 在 Linux 因未執行 Mac sips 生成 AppIcon 而無法完成，沒有以腳本圖片處理繞過限制；資產與實際包檢查以 Mac CI 為準。
