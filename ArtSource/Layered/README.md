# 母版風格擴作的分層來源

使用者轉交 Dot 已對原母版與 0171012 的兩張 SE3 實圖給出 7.3 有條件沿用風格判定，允許繼續其他表情／部件／狀態／動畫。本目錄為參考本專案已保存母版、透過 OpenAI 圖片工具生成／編修後選取的原始 PNG；沒有加入外部作品。原母版、dragon 舊稿與 kitchen 初稿保留。不是 7.7 最終視覺或動態接合通過。

| Atlas | 圖片工具輸出 ID | 部件／用途 |
|---|---|---|
| imp-layer-rig | exec-415ed925-1d2d-42a7-9b68-68428237e713 | 1024×1536 RGBA，軀幹、五頭部、近手臂、尾巴；圖片工具調大間距，避免相鄰耳朵進入裁切區 |
| deer-layer-rig | exec-80e6e2c9-3e58-4a27-a153-5df2174a54ac | 1024×1536 RGBA，軀幹、五頭部、獨立近前腿、尾巴；圖片工具移除重複固定近腿與尾根 |
| soup-states | exec-fd40dcbf-2dea-401c-88d2-2e96ec4389c3 | 1254×1254 RGBA，原料、備妥、烹調、完成、焦邊、偷嚐、兩種整理後、蒸汽 |
| crisp-states | exec-e4deadd4-fb57-43e8-83f3-682a81c7d5a7 | 同上九狀態，固定木盤與月形脆餅 |
| stew-states | exec-242291ac-6dd1-44b6-a5fc-01fd5955a4c3 | 同上九狀態，固定綠色深盤；圖片工具將相碰的兩碗分離 |
| kitchen-props | exec-8a87cd33-d1b8-4304-aed8-36a7631a2ea1 | 1024×1536 RGBA，熄火／點火爐、香草、星脆片、餐蓋、掀起餐蓋 |

PNG 與圖片工具輸出逐位元組相同，Resources 副本也逐位元組相同。JSON 以唯讀 Alpha／尺寸分析記錄部件 bounds 與頭頸 anchor，App 執行時 CoreGraphics 裁成貼圖。沒有用 Python 或其他腳本編修圖片、清理 Alpha、重畫或合成成品。source_sha256 與每一 rect 由 CI 前置檢查，實際 App 包再逐檔比對來源。

三角色、料理狀態與餐車部件已接入同一遊玩畫面，SpriteKit 僅呈現模型狀態；時間、工序與得分仍由 Domain 決定。DEBUG ArtReviewTests 專供深／淺底、五表情、同遊戲 72×76pt 範圍與部件動作的原生證據，並非真實點按全遊戲或 Dot 藝術評分。

龍沿用 ArtSource/Prototypes 的原始八部件 PNG，MFT-007 紅黃 Alpha 殘點／毛邊仍未解。兩次圖片工具處理未消除同類問題，未推選新稿或用腳本清理；遵守使用者的方法限制，保留缺陷並繼續不受影響工作。所有新增部件仍須以實際 App 深淺底、小尺寸及動作覆核，不能由本 README 宣告完成。

來源與公開保存依據見 [資產清單](../../docs/ASSET_MANIFEST.md)；OpenAI Terms of Use Content／Ownership：https://openai.com/policies/terms-of-use/ 。不新增專案授權或作排他性保證。
