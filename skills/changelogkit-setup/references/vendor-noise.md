# 判斷要排除的 vendor 雜訊

changelogkit 預設索引版本控管內所有 Markdown 與原始碼。大型 repo 的 `3rdparty/`、`vendor/`、`node_modules/` 常有數百份說明文件，會把真正屬於專案的文件與符號搜尋淹沒。

## 量測，不要憑感覺

在 repo 根目錄先數各目錄追蹤中的 Markdown：

```powershell
git ls-files '*.md' |
  ForEach-Object { ($_ -split '/')[0] } |
  Group-Object |
  Sort-Object Count -Descending |
  Select-Object -First 10
```

再逐層看最大的目錄（例如 `trunk/3rdparty`）：若單一目錄占比超過全部文件的 30%，通常就該排除。

## 設定

```toml
[tool.changelog]
exclude = ["trunk/3rdparty/**", "**/node_modules/**", "**/dist/**"]
```

- glob 相對於 repo 根目錄；`**` 跨目錄、`*` 單層。
- `exclude` 同時影響文件索引與 API 符號掃描。
- 不要排除專案自己的 `Docs/` 或 `doc/`（即使名稱看起來像文件）。

## 驗證

排除前後各跑一次：

```powershell
python -m changelogkit docs --check
```

比較「共 N 份文件」。合理的結果通常是：保留專案文件與必要的 API 文件，總數落在數十份以內；若仍是數百份，表示還有大型 vendor 目錄沒排到。

## 取捨

- 排除第三方文件不會影響「近期改動」的 commit 列表（commit 頁仍可看到完整 diff）。
- 若之後需要查 vendor 文件的 API 符號，再把特定路徑加回 `include`，不要整包解除排除。
