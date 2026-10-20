# 資產清單與查驗狀態

日期：2026-10-20。圖片均為本次已授權 OpenAI 圖片工具依原創描述生成，無外部參考作品；Icon 參考的是本專案兩張母版。公開保存依據為 OpenAI Terms of Use 的 Content／Ownership of content：https://openai.com/policies/terms-of-use/ 。未替使用者另行指定再利用授權，不作排他性或法律保證。音訊與程式圖形由本專案原創，無第三方樣本。

| ID | 實際檔案與用途 | 格式／來源／修改 | 查驗者及狀態 |
|---|---|---|---|
| ember_dragon | `MonsterFoodTruck/Resources/Art/characters-and-dishes.png`，角色 atlas 第 1 欄 | 1536×1024 RGBA；原始母版 `ArtSource/Masters/characters-and-dishes.png`；runtime subtexture，未修改母版 | Codex 大圖及 alpha 數值已檢；實際小尺寸、動態、Dot 待驗 |
| star_soup | `MonsterFoodTruck/Resources/Art/characters-and-dishes.png`，料理 atlas 第 1 欄 | 1536×1024 RGBA；原始母版 `ArtSource/Masters/characters-and-dishes.png`；runtime subtexture，未修改母版 | Codex 大圖及 alpha 數值已檢；實際小尺寸、動態、Dot 待驗 |
| nibble_imp | `MonsterFoodTruck/Resources/Art/characters-and-dishes.png`，角色 atlas 第 2 欄 | 1536×1024 RGBA；原始母版 `ArtSource/Masters/characters-and-dishes.png`；runtime subtexture，未修改母版 | Codex 大圖及 alpha 數值已檢；實際小尺寸、動態、Dot 待驗 |
| moon_crisp | `MonsterFoodTruck/Resources/Art/characters-and-dishes.png`，料理 atlas 第 2 欄 | 1536×1024 RGBA；原始母版 `ArtSource/Masters/characters-and-dishes.png`；runtime subtexture，未修改母版 | Codex 大圖及 alpha 數值已檢；實際小尺寸、動態、Dot 待驗 |
| moss_deer | `MonsterFoodTruck/Resources/Art/characters-and-dishes.png`，角色 atlas 第 3 欄 | 1536×1024 RGBA；原始母版 `ArtSource/Masters/characters-and-dishes.png`；runtime subtexture，未修改母版 | Codex 大圖及 alpha 數值已檢；實際小尺寸、動態、Dot 待驗 |
| cloud_stew | `MonsterFoodTruck/Resources/Art/characters-and-dishes.png`，料理 atlas 第 3 欄 | 1536×1024 RGBA；原始母版 `ArtSource/Masters/characters-and-dishes.png`；runtime subtexture，未修改母版 | Codex 大圖及 alpha 數值已檢；實際小尺寸、動態、Dot 待驗 |
| forest_food_truck | `MonsterFoodTruck/Resources/Art/forest-food-truck.png`，首頁背景 | 1024×1536；母版 `ArtSource/Masters/forest-food-truck.png`，未改圖像 | Codex 大圖已檢；實際 App 待驗 |
| app_icon | `ArtSource/Masters/app-icon.png` → `Assets.xcassets/AppIcon.appiconset/Icon.png` | 1254×1254 RGB → macOS sips 尺寸正規化 1024×1024 RGB | Codex 大圖已檢；實際 icon 編譯／縮小待驗 |
| cloche | `Presentation/PlayScreen.swift` 的 ClocheView | 原創向量罩、輪廓與陰影；隨 UI 狀態蓋住料理 | 實際遊玩與風格一致性待驗 |
| audio_forest_evening | `MonsterFoodTruck/Resources/Audio/forest_evening.wav` | 原創 `Scripts/generate_audio.py`；單聲道 22050Hz PCM16，20.87秒；peak 0.1253、RMS 0.0284，未削波 | Codex 數值分析；**聽覺未驗證**，Dot 尚未監聽 |
| audio_select | `MonsterFoodTruck/Resources/Audio/select.wav` | 原創 `Scripts/generate_audio.py`；單聲道 22050Hz PCM16，0.33秒；peak 0.1018、RMS 0.0394，未削波 | Codex 數值分析；**聽覺未驗證**，Dot 尚未監聽 |
| audio_prepStart | `MonsterFoodTruck/Resources/Audio/prepStart.wav` | 原創 `Scripts/generate_audio.py`；單聲道 22050Hz PCM16，0.42秒；peak 0.1766、RMS 0.0494，未削波 | Codex 數值分析；**聽覺未驗證**，Dot 尚未監聽 |
| audio_prepDone | `MonsterFoodTruck/Resources/Audio/prepDone.wav` | 原創 `Scripts/generate_audio.py`；單聲道 22050Hz PCM16，0.42秒；peak 0.1765、RMS 0.0493，未削波 | Codex 數值分析；**聽覺未驗證**，Dot 尚未監聽 |
| audio_cookStart | `MonsterFoodTruck/Resources/Audio/cookStart.wav` | 原創 `Scripts/generate_audio.py`；單聲道 22050Hz PCM16，0.42秒；peak 0.1763、RMS 0.0494，未削波 | Codex 數值分析；**聽覺未驗證**，Dot 尚未監聽 |
| audio_cookDone | `MonsterFoodTruck/Resources/Audio/cookDone.wav` | 原創 `Scripts/generate_audio.py`；單聲道 22050Hz PCM16，0.51秒；peak 0.1995、RMS 0.0548，未削波 | Codex 數值分析；**聽覺未驗證**，Dot 尚未監聽 |
| audio_scorched | `MonsterFoodTruck/Resources/Audio/scorched.wav` | 原創 `Scripts/generate_audio.py`；單聲道 22050Hz PCM16，0.42秒；peak 0.1705、RMS 0.0494，未削波 | Codex 數值分析；**聽覺未驗證**，Dot 尚未監聽 |
| audio_plated | `MonsterFoodTruck/Resources/Audio/plated.wav` | 原創 `Scripts/generate_audio.py`；單聲道 22050Hz PCM16，0.42秒；peak 0.1767、RMS 0.0493，未削波 | Codex 數值分析；**聽覺未驗證**，Dot 尚未監聽 |
| audio_toppingStart | `MonsterFoodTruck/Resources/Audio/toppingStart.wav` | 原創 `Scripts/generate_audio.py`；單聲道 22050Hz PCM16，0.42秒；peak 0.1775、RMS 0.0494，未削波 | Codex 數值分析；**聽覺未驗證**，Dot 尚未監聽 |
| audio_toppingDone | `MonsterFoodTruck/Resources/Audio/toppingDone.wav` | 原創 `Scripts/generate_audio.py`；單聲道 22050Hz PCM16，0.42秒；peak 0.1767、RMS 0.0493，未削波 | Codex 數值分析；**聽覺未驗證**，Dot 尚未監聽 |
| audio_covered | `MonsterFoodTruck/Resources/Audio/covered.wav` | 原創 `Scripts/generate_audio.py`；單聲道 22050Hz PCM16，0.42秒；peak 0.1742、RMS 0.0493，未削波 | Codex 數值分析；**聽覺未驗證**，Dot 尚未監聽 |
| audio_uncovered | `MonsterFoodTruck/Resources/Audio/uncovered.wav` | 原創 `Scripts/generate_audio.py`；單聲道 22050Hz PCM16，0.42秒；peak 0.1653、RMS 0.0492，未削波 | Codex 數值分析；**聽覺未驗證**，Dot 尚未監聽 |
| audio_nibbleWarning | `MonsterFoodTruck/Resources/Audio/nibbleWarning.wav` | 原創 `Scripts/generate_audio.py`；單聲道 22050Hz PCM16，0.51秒；peak 0.256、RMS 0.0803，未削波 | Codex 數值分析；**聽覺未驗證**，Dot 尚未監聽 |
| audio_nibbled | `MonsterFoodTruck/Resources/Audio/nibbled.wav` | 原創 `Scripts/generate_audio.py`；單聲道 22050Hz PCM16，0.42秒；peak 0.1731、RMS 0.0493，未削波 | Codex 數值分析；**聽覺未驗證**，Dot 尚未監聽 |
| audio_tidyStart | `MonsterFoodTruck/Resources/Audio/tidyStart.wav` | 原創 `Scripts/generate_audio.py`；單聲道 22050Hz PCM16，0.42秒；peak 0.1745、RMS 0.0493，未削波 | Codex 數值分析；**聽覺未驗證**，Dot 尚未監聽 |
| audio_tidyDone | `MonsterFoodTruck/Resources/Audio/tidyDone.wav` | 原創 `Scripts/generate_audio.py`；單聲道 22050Hz PCM16，0.42秒；peak 0.1775、RMS 0.0493，未削波 | Codex 數值分析；**聽覺未驗證**，Dot 尚未監聽 |
| audio_served | `MonsterFoodTruck/Resources/Audio/served.wav` | 原創 `Scripts/generate_audio.py`；單聲道 22050Hz PCM16，0.42秒；peak 0.1739、RMS 0.0494，未削波 | Codex 數值分析；**聽覺未驗證**，Dot 尚未監聽 |
| audio_preferred | `MonsterFoodTruck/Resources/Audio/preferred.wav` | 原創 `Scripts/generate_audio.py`；單聲道 22050Hz PCM16，0.51秒；peak 0.1936、RMS 0.0548，未削波 | Codex 數值分析；**聽覺未驗證**，Dot 尚未監聽 |
| audio_left | `MonsterFoodTruck/Resources/Audio/left.wav` | 原創 `Scripts/generate_audio.py`；單聲道 22050Hz PCM16，0.42秒；peak 0.1771、RMS 0.0494，未削波 | Codex 數值分析；**聽覺未驗證**，Dot 尚未監聽 |
| audio_arrival | `MonsterFoodTruck/Resources/Audio/arrival.wav` | 原創 `Scripts/generate_audio.py`；單聲道 22050Hz PCM16，0.42秒；peak 0.1775、RMS 0.0493，未削波 | Codex 數值分析；**聽覺未驗證**，Dot 尚未監聽 |
| audio_win | `MonsterFoodTruck/Resources/Audio/win.wav` | 原創 `Scripts/generate_audio.py`；單聲道 22050Hz PCM16，0.6秒；peak 0.1955、RMS 0.0584，未削波 | Codex 數值分析；**聽覺未驗證**，Dot 尚未監聽 |
| audio_lose | `MonsterFoodTruck/Resources/Audio/lose.wav` | 原創 `Scripts/generate_audio.py`；單聲道 22050Hz PCM16，0.51秒；peak 0.1762、RMS 0.0548，未削波 | Codex 數值分析；**聽覺未驗證**，Dot 尚未監聽 |
| audio_dragonReaction | `MonsterFoodTruck/Resources/Audio/dragonReaction.wav` | 原創 `Scripts/generate_audio.py`；單聲道 22050Hz PCM16，0.51秒；peak 0.1756、RMS 0.0549，未削波 | Codex 數值分析；**聽覺未驗證**，Dot 尚未監聽 |
| audio_impReaction | `MonsterFoodTruck/Resources/Audio/impReaction.wav` | 原創 `Scripts/generate_audio.py`；單聲道 22050Hz PCM16，0.51秒；peak 0.1877、RMS 0.0549，未削波 | Codex 數值分析；**聽覺未驗證**，Dot 尚未監聽 |
| audio_deerReaction | `MonsterFoodTruck/Resources/Audio/deerReaction.wav` | 原創 `Scripts/generate_audio.py`；單聲道 22050Hz PCM16，0.51秒；peak 0.1784、RMS 0.0548，未削波 | Codex 數值分析；**聽覺未驗證**，Dot 尚未監聽 |

目前母版、Icon、圖集、音訊都不是完整品質驗收。角色分層、表情與動作及料理狀態仍需補足；不得把此清單視為 Dot 7.7 美術門檻已通過。

分層試作：`ArtSource/Prototypes/dragon-layer-rig.png` 與相應 JSON；以既有焰尾龍母版作參考生成／編修，887×1774 RGBA，五頭部＋軀幹／手臂／尾焰，原 PNG 未修改。資源副本在 `Resources/Art`；目前只接 DEBUG 單角色預覽，尚未以實際小尺寸確認接合、邊緣、五種表情或動畫，也沒有 Dot 視覺通過。詳原始檔旁 README；不作正式三角色動畫完成聲明。

餐車分層初稿：`ArtSource/Prototypes/kitchen-layers.png`、相應 JSON 及 `Resources/Art` 原檔副本；參考同一森林餐車與料理母版生成，1536×1024 RGBA，六部件，執行時裁切。只在 DEBUG 明確開啟試裝，爐具固定火焰尚須改為狀態分層，不作正式資產或 Dot 通過聲明。

啟動畫面：同一原創圖示母版透過 macOS sips 正規化成 LaunchMark 的 100／200／300px 圖集，保留來源，不新增圖像創作或外部素材。須由實際編譯的 Assets.car 讀取測試確認。
