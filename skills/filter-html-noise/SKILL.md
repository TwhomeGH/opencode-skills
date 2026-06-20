---
name: filter-html-noise
description: 預設啟用。分析 HTML 時自動忽略 SVG path 座標、base64 圖片、內聯視覺樣式，保留廣告模組、追蹤代碼、UI 結構等語義內容。
---

# HTML 雜訊過濾（預設啟用）

## 自動忽略

1. **SVG path 幾何座標** - `d="M...Z"`、Bézier 點位資料
2. **內聯 SVG 結構** - `<svg>...</svg>` 內部幾何（保留標籤及 class/id）
3. **Base64 圖片** - `src="data:image/..."`
4. **內聯視覺屬性** - `style` 中的 color、padding、transform 等
5. **動態 ID 內部細節** - `id="xxx:數字"` 的巢狀結構（保留元素本身）

## 保留

- 廣告模組（`ytp-ad-`、`ad-` 類別層級、按鈕文字、連結）
- 追蹤/分析代碼、播放器 UI（按鈕、倒數、狀態文字）
- 所有語義文字、aria-label、href、表單輸入

## 例外

用戶明確說「分析 SVG」、「看 SVG 路徑」等才輸出 SVG path/座標細節。

## 處理策略

- 讀取 HTML 時預設心理過濾上述雜訊，不輸出、不分析
- grep 自動排除 `d="M[^"]*"`、`data:image/`、`style="[^"]{100,}"`
- 回覆只描述功能性結構與文字

## 範例

**原始** → **過濾後**：
```
<button class="ytp-skip-ad-button" id="skip-button:21">
  <span class="ytp-skip-ad-button__icon"><svg>...</svg></span>
</button>
```
保留 ad 佈局容器、按鈕文字、aria-label；SVG path 與座標省略。

## 觸發

**預設自動啟用**。強化關鍵字：「過濾 HTML」、「忽略 SVG」、「去除雜訊」、「專注語義」
