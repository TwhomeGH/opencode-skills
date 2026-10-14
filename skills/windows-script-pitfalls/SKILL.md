---
name: windows-script-pitfalls
description: >-
  Use when writing or debugging PowerShell (.ps1), batch (.bat/.cmd), or VBScript (.vbs) on Windows,
  or when garbled text / mojibake / non-ASCII paths / codepage / BOM / CRLF issues break scripts or tools.
  Covers UTF-8 vs ANSI (cp950/cp936) script encoding, when a BOM is required, chcp, PowerShell execution
  policy, quoting and escaping, and the Python locale/.pth trap. Triggers: 編碼, 亂碼, BOM, chcp, cp950,
  codepage, UTF-8, .ps1, bat, vbs, PowerShell.
---

# Windows 腳本與編碼地雷

在 Windows 寫／除錯腳本，或遇到「中文變亂碼、非 ASCII 路徑讓工具掛掉」時適用。核心一句話：**別讓地區設定（locale）決定編碼**——能明確指定 UTF-8 就指定。

## 核心原則

- 文字檔一律 **UTF-8**；檔案內含非 ASCII 時，先問「誰用什麼編碼讀它」。
- **UTF-8 BOM 是雙面刃**：Windows PowerShell 5.1 需要 BOM 才正確讀非 ASCII 的 `.ps1`；但 BOM 會讓多數 Unix 工具（`cat`、`sed`、`awk`）出錯。要跨平台就避開 BOM，或避免非 ASCII。
- 最安全：腳本與路徑**只用 ASCII**；要非 ASCII 就用相容編碼並**明確指定**。
- 遇到亂碼先問三件事：**檔案存成什麼編碼？讀它的程式用什麼編碼？主控台用什麼代碼頁？**

## PowerShell

### 編碼（about_Character_Encoding）

- **讀原始碼**：無 BOM 時，PowerShell 引擎以 **ANSI（作用中的系統代碼頁）** 解讀；因此含非 ASCII 的 `.ps1` 要存成 **UTF-8 with BOM**，否則 Windows PowerShell 會誤判為 ANSI。
- **輸出預設不一致**：PowerShell 6+ 一律 `utf8NoBOM`；Windows PowerShell 5.1 的 `>`／`Out-File` 是 **UTF-16LE**，而 `Set-Content`／`Add-Content` 在空檔時用 **ANSI**。不要假設一致。
- 明確指定：`-Encoding utf8`／`utf8BOM`／`utf8NoBOM`；或設 `$PSDefaultParameterValues['*:Encoding']='utf8'`。
- `Get-Content`／`Import-PowerShellDataFile` 無 BOM 時用 ANSI；`Import-Csv`／`Select-String` 假設 UTF-8。
- `$OutputEncoding` 只管**與外部程式溝通**，**不影響寫檔**（寫檔用 `$PSDefaultParameterValues['Out-File:Encoding']`）。
- 主控台顯示亂碼：`chcp 65001`（該視窗）或 `[Console]::OutputEncoding=[Text.Encoding]::UTF8`。

### 執行原則（Execution Policy）

- Windows 用戶端預設 **Restricted**（不能跑 `.ps1`）；伺服器預設 **RemoteSigned**；全部未設定時的有效值同此。
- **不是安全邊界**，只是 defense in depth，很容易繞過。
- 從網路下載的 `.ps1` 會被標記「來自網際網路」→ RemoteSigned 下不能跑；用 `Unblock-File` 解除。
- 別把 `-ExecutionPolicy Bypass` 當萬用解法；要改優先 `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser`。

### 引號與轉義

- 單引號 `'...'` 不展開變數；雙引號 `"..."` 會展開（`$var`、`$(...)`）。
- 反引號 `` ` `` 是轉義字元（`` `n ``、`` `t ``、`` `" ``）。路徑含空白務必加引號。

## cmd / batch

- 執行受**作用中的主控台代碼頁**影響；UTF-8 內容需搭配 `chcp 65001`（且 `chcp` 之前的行仍用舊代碼頁）。
- 重導輸出 `>` 的編碼跟隨代碼頁 → 內容易亂碼。
- **含 UTF-8 BOM 的 `.bat` 會讓第一行出錯**（BOM 被當成指令開頭）。
- 建議：`.bat` 只用 ASCII；需要非 ASCII 就改寫成 PowerShell。

## VBScript（legacy）

- 由 WSH（`cscript`／`wscript`）執行，編碼行為依系統 ANSI 代碼頁，非 ASCII 字面量易亂碼。
- 具體讀檔編碼以**實測**為準；新專案不建議用 VBScript，改用 PowerShell。

## 跨工具：locale 與讀檔編碼

- 許多工具在未明確指定編碼時用 **locale 編碼**（繁中 Windows 常為 **cp950 / Big5**；簡中為 cp936）。
- **實例（Python）**：editable 安裝（`pip install -e`）到含非 ASCII 的路徑（如 `…\桌面\…`）會寫出含中文路徑的 `.pth`；在 cp950 的 Windows 上 Python 以 locale 讀 `.pth` → `UnicodeDecodeError` → `Fatal Python error: init_import_site`，**連 `python`／`pip` 都啟動不了**。
  - 解法：**別用 `-e`**（改用一般安裝 `pip install <dir>`，或 pipx）；或設 **`PYTHONUTF8=1`**（等同 `-X utf8`，啟用 UTF-8 模式）。
- Python 讀寫檔案一律明確 `open(..., encoding="utf-8")`；不要依賴預設編碼。

## 完成前自檢

- [ ] 檔案編碼與「讀它的程式」相符？（`.ps1` 含非 ASCII → UTF-8 with BOM）
- [ ] 沒有讓 locale／代碼頁決定編碼？（工具輸出入明確 UTF-8）
- [ ] 非 ASCII 路徑是否會踩到工具／函式庫的地雷？
- [ ] 需要時有設定 `chcp`／`PYTHONUTF8`／`-Encoding`？

## 官方參考

- PowerShell 編碼：[about_Character_Encoding](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_character_encoding)
- PowerShell 執行原則：[about_Execution_Policies](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_execution_policies)
- cmd 代碼頁：[chcp](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/chcp)
- Python UTF-8 模式：[PEP 540](https://peps.python.org/pep-0540/)、[`PYTHONUTF8` / `-X utf8`](https://docs.python.org/3/using/cmdline.html#envvar-PYTHONUTF8)
