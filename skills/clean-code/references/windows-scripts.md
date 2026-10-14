# Windows 腳本 — PowerShell / cmd·bat / VBScript

這三者的「文件註釋」成熟度差很多：**PowerShell 有正式的 comment-based help**（`Get-Help`、VS Code PSScriptAnalyzer 會提示），cmd/bat 與 VBScript 只有一般註釋。

> 腳本本身的**編碼／平台地雷**（BOM、codepage、執行原則…）不在本檔，但最基本的兩條先記著：文字檔存 **UTF-8**；含非 ASCII 的 `.ps1` 要存成 **UTF-8 with BOM**，否則 Windows PowerShell 會誤判為 ANSI。

## PowerShell — comment-based help

- 用 `#`（逐行）或 `<# … #>`（區塊）；關鍵字前置 `.`，不分大小寫，順序不拘。
- 位置：函式**開頭 / 結尾 / `function` 之前**；腳本檔**開頭 / 結尾**。放在腳本開頭時，前面只能有註釋與空行。
- `Get-Help <名稱> -Full` 會顯示；線上版用 `.LINK http(s)://…`。

```powershell
<#
.SYNOPSIS
    一句話說明。
.DESCRIPTION
    詳細說明。
.PARAMETER Path
    參數說明。
.EXAMPLE
    PS> Get-Thing -Path C:\data
#>
function Get-Thing {
    [CmdletBinding()]
    param([string]$Path)
}
```

主要關鍵字：`.SYNOPSIS`、`.DESCRIPTION`、`.PARAMETER <名稱>`、`.EXAMPLE`（**可重複**）、`.INPUTS`、`.OUTPUTS`、`.NOTES`、`.LINK`（可重複）、`.COMPONENT`、`.ROLE`、`.FUNCTIONALITY`、`.EXTERNALHELP`（改用 XML help）。

> 腳本開頭放 help、且緊接著是**函式宣告**時，中間需**空兩行**，否則 help 會被歸給那個函式而非腳本。

## cmd / batch — 一般註釋

- `REM <文字>`（官方；cmd.exe 內建）。`::` 是常見的非官方寫法（label trick），**在 `( )` 區塊內可能出錯**，正式場合用 `REM`。
- `REM` 後不可接重導 `<`、`>` 或管道 `|`。
- 多行註釋用 `Rem/||( … )`（`REM` 求值為成功，故區塊永不執行；結尾的 `)` 需轉義為 `^)`）。

```bat
@echo off
rem 建置並打包，需先設定 MSVC 環境。
rem
```

## VBScript（legacy）

- 註釋用 `'`（單引號）或 `Rem`。無文件註釋格式，WSH 也沒有 IDE help 整合。
- 非 ASCII 字面量在 WSH 下易受代碼頁影響；新腳本建議改用 PowerShell。

```vbscript
' 計算並輸出總和。
Rem 另一種寫法。
```

## 官方

- PowerShell comment-based help: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_comment_based_help
- cmd `rem`: https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/rem
