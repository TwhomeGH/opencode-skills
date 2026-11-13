# Windows：編碼與本地原始碼

在 Windows（繁中系統常見 cp950）使用 changelogkit 時的地雷與正確指令。這些問題與 changelogkit 版本無關，屬環境層。

## 不要對含非 ASCII 的路徑做 editable 安裝

`pip install -e <含中文的路徑>` 會把該路徑寫進 `site-packages` 的 `.pth`。Python 在 **cp950** 下以 locale 讀 `.pth`，遇到中文就 `UnicodeDecodeError`，直接 `Fatal Python error: init_import_site`——**任何 `python`／`pip` 指令都啟動不了**，比工具本身壞掉更難救。

正確做法（擇一）：

- 本地原始碼：用 `PYTHONPATH` 指向 `src/`，不安装。
- 要全域指令：用非 editable 安裝（`pip install <路徑>`，複製進 site-packages，不產生 `.pth`）。
- 臨時救援：`set PYTHONUTF8=1` 後再處理；或先刪掉出問題的 `.pth`。

## 主控台輸出

`--help` 與錯誤訊息含中文時，cp950 視窗會顯示亂碼。執行前設：

```powershell
$env:PYTHONUTF8 = "1"
[Console]::OutputEncoding = [Text.Encoding]::UTF8
```

或該視窗先 `chcp 65001`。這只影響顯示，不改檔案內容。

## PowerShell 指令範本

```powershell
# 本地原始碼
$env:PYTHONPATH = "C:\path\to\ChangeLogTools\src"
$env:PYTHONUTF8 = "1"
cd C:\path\to\target-repo

python -m changelogkit --version
python -m changelogkit --help
python -m changelogkit --locale zh-TW export _site --branch main
```

注意：

- 路徑含空白時一定要引號。
- `--locale` 是**全域旗標，必須放在子命令前**；放在 `export` 之後會被 argparse 拒絕。
- 驗證實際使用的是哪個版本：比較 `--version` 與 `CHANGELOGKIT_SRC` 的 `pyproject.toml`，不要假設 PATH 上的版本等於原始碼版本。

## 靜態站輸出位置

`export` 預設在目標 repo 產生 `_site/`。**先把 `_site/` 加進 `.gitignore` 再匯出**，避免誤提交；若不想在 repo 留下產物，可輸出到 repo 外的暫存目錄（例如 `%TEMP%\changelog-site`），兩者都算通過，但回報要寫清楚落點。
