# 原有靜態與稀疏影片索引（範圍更正）

實際 App source `66c2929dd05c28af1b0c3ec8a79805446c6dc023`／[原 Validate 39497238513](https://github.com/Kongdean2374/MonsterFoodTruck/actions/runs/39497238513)。這些原物保留；短片另列，不將舊圖補成動畫。

## 原 ArtReview 的 24 張靜態圖

[完整 JSON](ORIGINAL_STATIC_ART_INDEX.json) 保存原檔、SHA-256、artifact／job、原生附件時間及尺寸。三尺寸各 8 張；SE3 的 8 張直接原樣複製如下。測試意圖名 reach／receive／return 不是實際動作階段證明，XCTest 點按及截圖開銷沒有固定相位。

| 原測試意圖名 | 原 PNG | 原生附件時間（台北） |
|---|---|---|
| ART-dark-five-poses-game-size | [8CFADC06](original-se3-static/8CFADC06-7E3B-49B1-9770-D36DD15F3D8D.png) | 2026-10-21T05:40:40.808000+08:00 |
| ART-dark-motion-reach | [1C0175BC](original-se3-static/1C0175BC-785D-4F0B-A1D3-EDA18D4F40FA.png) | 2026-10-21T05:40:46.052000+08:00 |
| ART-dark-motion-receive | [082E01F1](original-se3-static/082E01F1-4B49-47BC-83FF-4CCD5C50F505.png) | 2026-10-21T05:40:47.740000+08:00 |
| ART-dark-motion-return-to-anchor | [67CBC4DD](original-se3-static/67CBC4DD-0BA9-4DCD-B4DB-CD9D82FE8B96.png) | 2026-10-21T05:40:50.887000+08:00 |
| ART-light-five-poses-game-size | [33F2ED12](original-se3-static/33F2ED12-C5DF-47D8-A0E6-4DCAD24E8708.png) | 2026-10-21T05:41:11.427000+08:00 |
| ART-light-motion-reach | [60CBDD57](original-se3-static/60CBDD57-10F6-44FA-AF95-6ABD128DCBB7.png) | 2026-10-21T05:41:12.484000+08:00 |
| ART-light-motion-receive | [469B77DD](original-se3-static/469B77DD-486E-48AE-9DCF-EFD6023184A4.png) | 2026-10-21T05:41:13.604000+08:00 |
| ART-light-motion-return-to-anchor | [3A965CA3](original-se3-static/3A965CA3-E2CD-4F46-B12D-50C033481059.png) | 2026-10-21T05:41:15.542000+08:00 |

Codex 實看 SE3 六張離散動作圖：深底三張不足以辨明完整接餐階段；淺底接餐圖可見首列三位滿足與餐盤，但仍只是一個瞬間。不能因此宣告伸手、回位、動作原點或接合通過。

## 舊 989.993 秒影片：只按 actual 定位

[36 張原始取樣 JSON](ORIGINAL_SPARSE_VIDEO_INDEX.json) 保存每張原 PNG 的 hash 與 actual／requested。索引以 actual_seconds 排序，requested 僅留原始請求紀錄。第 01 張實際 **3.918333 秒**，不是請求的 **28.332667 秒**。實際相鄰間隔 3.918333～52.680000 秒（中位 28.281667），不能用約 28 秒取樣證明短動作。原音軌 0。

| 原 frame | actual_seconds（定位） | 原 requested_seconds（非定位） |
|---|---:|---:|
| actual-recording-frame-00.png | 0.000000 | 0.050000 |
| actual-recording-frame-01.png | 3.918333 | 28.332667 |
| actual-recording-frame-02.png | 56.598333 | 56.615333 |
| actual-recording-frame-03.png | 84.883333 | 84.898000 |
| actual-recording-frame-04.png | 113.146667 | 113.180667 |
| actual-recording-frame-05.png | 141.461667 | 141.463333 |
| actual-recording-frame-06.png | 169.731667 | 169.746000 |
| actual-recording-frame-07.png | 198.020000 | 198.028667 |
| actual-recording-frame-08.png | 226.296667 | 226.311333 |
| actual-recording-frame-09.png | 254.581667 | 254.594000 |
| actual-recording-frame-10.png | 282.836667 | 282.876667 |
| actual-recording-frame-11.png | 311.146667 | 311.159333 |
| actual-recording-frame-12.png | 339.433333 | 339.442000 |
| actual-recording-frame-13.png | 367.533333 | 367.724667 |
| actual-recording-frame-14.png | 395.968333 | 396.007333 |
| actual-recording-frame-15.png | 424.078333 | 424.290000 |
| actual-recording-frame-16.png | 452.566667 | 452.572667 |
| actual-recording-frame-17.png | 480.813333 | 480.855333 |
| actual-recording-frame-18.png | 506.955000 | 509.138000 |
| actual-recording-frame-19.png | 537.413333 | 537.420667 |
| actual-recording-frame-20.png | 565.603333 | 565.703333 |
| actual-recording-frame-21.png | 593.953333 | 593.986000 |
| actual-recording-frame-22.png | 622.268333 | 622.268667 |
| actual-recording-frame-23.png | 650.445000 | 650.551333 |
| actual-recording-frame-24.png | 678.260000 | 678.834000 |
| actual-recording-frame-25.png | 707.085000 | 707.116667 |
| actual-recording-frame-26.png | 735.391667 | 735.399333 |
| actual-recording-frame-27.png | 763.680000 | 763.682000 |
| actual-recording-frame-28.png | 791.961667 | 791.964667 |
| actual-recording-frame-29.png | 819.521667 | 820.247333 |
| actual-recording-frame-30.png | 848.521667 | 848.530000 |
| actual-recording-frame-31.png | 876.586667 | 876.812667 |
| actual-recording-frame-32.png | 903.785000 | 905.095333 |
| actual-recording-frame-33.png | 933.375000 | 933.378000 |
| actual-recording-frame-34.png | 961.435000 | 961.660667 |
| actual-recording-frame-35.png | 986.740000 | 989.943333 |

原 MOV SHA-256 `7612a829294299563b6e83df5ccecad90e0ed03e84ef7defa79d5e0ed91ad94f`，完整 MOV 在原重型 artifact 12300750859；本機只下載原 review 的 36 張樣本，未宣稱已看完整電影。
