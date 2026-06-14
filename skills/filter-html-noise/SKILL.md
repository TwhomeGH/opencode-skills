---
name: filter-html-noise
description: 預設啟用。分析 HTML 時自動忽略無語義的 SVG 路徑座標、內聯 SVG 幾何資料、base64 圖片資料，保留廣告模組、追蹤代碼、UI 結構等業務邏輯相關內容。
---

# HTML 雜訊過濾技能（預設啟用）

## 核心原則

**自動忽略以下無分析價值的視覺雜訊：**

1. **SVG 路徑幾何座標** - `d="M...Z"`、`path` 元素的 Bézier 曲線點位資料
2. **內聯 SVG 完整結構** - `<svg>...</svg>` 內部的幾何繪製細節（保留 `<svg>` 標籤本身及 class/id 供定位）
3. **Base64 圖片資料** - `src="data:image/..."`、內聯編碼圖片
4. **內聯樣式視覺屬性** - `style="..."` 中的 `color`、`padding`、`blur`、`transform`、`background-image` 等純視覺屬性
5. **動態生成 ID 的內部結構** - `id="xxx:數字"` 格式元素的內部巢狀細節（保留元素本身）

**保留以下業務相關內容：**

- 廣告模組結構（`ytp-ad-`、`ad-` 類別的元素層級、按鈕文字、連結）
- 追蹤/分析代碼邏輯
- 播放器 UI 功能結構（按鈕、倒數、狀態文字）
- 所有語義文字內容、aria-label、連結 href、表單輸入

**例外：用戶明確要求分析 SVG 時**

- 當用戶說「分析 SVG」、「看 SVG 路徑」、「檢查圖標幾何」等明確指令時，才輸出/分析 SVG path、座標、viewBox 等細節
- 平常情況下 `<svg>` 視為黑盒，只保留標籤結構與 class/id

## 自動處理策略

- **讀取/搜尋 HTML 時**：預設心理過濾上述雜訊，不輸出、不分析 SVG path、base64、長 style 字串
- **grep 搜尋時**：自動排除 `d="M[^"]*"`、`data:image/`、`style="[^"]{100,}"` 模式
- **回覆總結時**：只描述功能性結構與文字，不包含座標、路徑、編碼字串

## 範例對比

**原始 HTML：**
```html
<button class="ytp-skip-ad-button" id="skip-button:21">
  <div class="ytp-skip-ad-button__text">略過</div>
  <span class="ytp-skip-ad-button__icon">
    <svg fill="none" height="24" viewBox="0 0 24 24" width="24">
      <path d="M20 20C20.26 20 20.51 19.89 20.70 19.70..." fill="white"></path>
    </svg>
  </span>
</button>
<div class="video-ads ytp-ad-module" data-layer="4">
  <div class="ytp-video-interstitial-buttoned-centered-layout">
    <div class="ytp-ad-badge__text--clean-player">贊助商廣告</div>
    <button class="ytp-ad-button" aria-label="我的廣告中心">...</button>
  </div>
</div>
```

**模型實際處理（自動過濾）：**
```html
<button class="ytp-skip-ad-button" id="skip-button:21">
  <div class="ytp-skip-ad-button__text">略過</div>
  <span class="ytp-skip-ad-button__icon"><svg>...</svg></span>
</button>
<div class="video-ads ytp-ad-module" data-layer="4">
  <div class="ytp-video-interstitial-buttoned-centered-layout">
    <div class="ytp-ad-badge__text--clean-player">贊助商廣告</div>
    <button class="ytp-ad-button" aria-label="我的廣告中心">...</button>
  </div>
</div>
```

**回覆用戶時總結：**
> 頁面包含跳過廣告按鈕（文字「略過」）、贊助商廣告標誌、廣告中心入口、插播式廣告佈局容器。SVG 圖標路徑、base64 背景圖、內聯樣式已自動忽略。

## 觸發方式

**預設自動啟用** - 遇到任何 HTML 內容分析任務時自動生效，無需額外指令。

關鍵字觸發（強化模式）：
- 「過濾 HTML」、「忽略 SVG」、「去除雜訊」、「專注語義」