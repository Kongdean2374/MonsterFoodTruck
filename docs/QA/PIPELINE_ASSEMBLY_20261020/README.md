# 同次原生證據收集與裝置封裝門檻

準備讓完整 Validate 的主 job、small 與 large 都成功後，自動由同 SHA 建置 Release iPhoneOS IPA；保留既有獨立手動 unsigned workflow。裝置 job 不重跑已成功的 XCTest，而是下載同一 workflow run 的三份原始 artifact，核對 GitHub archive digest、run ID、head SHA、原始 VALIDATION_STATUS complete、四個原生摘要都大於零 passed／零 failed／零 skipped，保留原 PNG／影片／模型歷史。Release App 仍重新建置並讀實際 plist／Mach-O／資源 hash，與模擬器 version／build 比對。

封裝收集程式的四項 fixture 檢查已在 Linux 執行：原 bytes／counts 保留、另一 source 拒絕、原生 failure／skip 拒絕、archive digest 變動拒絕。Fixture 明確不是 App 圖片或原生結果。

另直接讀取已下載、未修改的真正原生 archive：b53ff60 small／large 各 3 passed／0 failed／0 skipped 可被收集，分別 42 個原始檔；9882a0c 的真實 test-build failure 被拒絕。來源／digest／實際摘要見 NATIVE_ARCHIVE_GATE_REPORT.json。**這不是重跑測試，也沒有讓失敗候選取得 IPA。** 完整收集與 Release archive 尚待新 SHA CI；不能把這項工具檢查當遊戲或封裝成功。
