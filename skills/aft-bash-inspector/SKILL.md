---
name: aft-bash-inspector
description: >-
  需要知道 AFT／OpenCode 的背景 bash 工作目前在做什麼時使用：列出執行中的工作、看單一工作的
  程序樹與輸出尾巴，或即時跟隨 stdout／stderr。工具是唯讀的，不會終止或修改任何工作。
  Triggers: background bash, 背景工作, bash_status, taskId, 查看進度, 即時輸出, AFT 任務.
---

# 檢視 AFT 背景 bash

Agent 端的 `bash_status`／`bash_watch`／`bash_kill` 都需要先有 `taskId`，而且沒有「列出全部背景工作」的介面。這份技能提供一個唯讀腳本，直接讀 AFT 寫在磁碟上的任務資料，補上這個缺口。

## 快速使用

載入 skill 時，harness 會提供這個 skill 的 base directory（「Base directory for this skill: …」）。**不要把它寫死**成某台機器的路徑。

```powershell
# 1) 填入 harness 在載入時提供的 base directory
$skillDir = '<harness 提供的 base directory>'

# 2) 沒有 base directory 時，才退回使用者設定的環境變數
if (-not (Test-Path -LiteralPath $skillDir) -and $env:OPENCODE_SKILLS_ROOT) {
    $skillDir = Join-Path $env:OPENCODE_SKILLS_ROOT 'skills\aft-bash-inspector'
}

$tool = Join-Path $skillDir 'scripts\aft-bash.ps1'
if (-not (Test-Path -LiteralPath $tool)) {
    Write-Error "找不到 $tool：skill 安裝不完整或路徑不明。請改用 bash_status（需要 taskId），或詢問使用者 skills 根目錄後再試一次。"
    return
}

& $tool list
& $tool show <taskId> -Tail 40
& $tool watch <taskId>
```

從 cmd.exe（不需要 PowerShell 語法）：

```bat
rem <skillDir> 同樣取 harness 提供的 base directory
"<skillDir>\scripts\aft-bash.cmd" list
```

路徑解析順序（不要用全碟搜尋）：

1. harness 提供的 base directory
2. `OPENCODE_SKILLS_ROOT` + `skills\aft-bash-inspector`
3. 都沒有 → 停用這個 skill 並回報缺少的路徑，改用 `bash_status`；必要時才問使用者 skills 根目錄

`<taskId>` 可用唯一前綴（例如 `bash-f16f`）；不確定就先跑 `list`。

### 常見語法錯誤

| 寫法 | 結果 | 正確寫法 |
| --- | --- | --- |
| `$tool list` | `ParserError`：`$tool` 後面不能直接接裸字 | `& $tool list` |
| `& tool list` | `tool` 不是命令（少了 `$`） | `& $tool list` |
| `tool list` | cmd 找不到 `tool` | `.cmd` 包裝或 `& $tool list` |
| 在 cmd 裡 `$tool = ...` | cmd 不認得 PowerShell 變數 | 直接用 `.cmd` 包裝 |

`& $tool list` 的意思是「把 `$tool` 這個字串當成程式路徑來執行，並傳 `list` 當第一個參數」。`$tool list` 會被 PowerShell 當成兩個相鄰的運算式，所以語法錯誤。

## 它從哪裡讀資料

AFT 會把每個工作寫在：

```
%LOCALAPPDATA%\cortexkit\aft\<harness>\bash-tasks\<project-hash>\<taskId>\
├─ control\metadata.json   # status、child_pid、command、session_id、started_at…
├─ io\stdout
├─ io\stderr
└─ io\exit                 # 完成後才有退出碼
```

所以它不是「連上那個 bash 程序」或開 socket，而是**讀 AFT 已經寫好的任務檔案**：`list` 掃 task 目錄、用 `io\exit` 快速跳過已完成者；`show` 讀 metadata 並用 `Win32_Process` 畫程序樹；`watch` 記住檔案目前長度，之後只讀新增的位元組。
若設定了 `AFT_STORAGE_DIR`，腳本也會掃該位置。目錄存在不代表還在跑，**以 `metadata.json` 的 `status` 為準**（`running`／`completed`／`killed`）。

## 模式

| 模式 | 內容 | 適用 |
| --- | --- | --- |
| `list` | 只列 `status=running` 的工作：taskId、PID、已執行時間、session、指令首行 | 「現在有什麼在跑？」 |
| `show` | metadata＋完整程序樹（含 CPU／記憶體）＋stdout／stderr 尾巴 | 「它卡在哪？跑到哪一步？」 |
| `watch` | 從目前位置開始跟隨新輸出，每 5 秒印一次狀態，結束時印 exit code | 「我想看它即時在做什麼」 |

`watch` 用輪詢（預設 1 秒），不是 AFT 的內部事件流；Ctrl+C 只停止觀看，**不會停止工作**。

## 判讀技巧

- 程序樹會顯示 wrapper：`cmd → pwsh → rustup → cargo → rustc`。真正的重活通常在 `rustc` 或 `node`，看它的 CPU／記憶體最有用。
- 記憶體突然很高（例如 `rustc` 10GB）時，先確認 commit charge 還有多少；Windows 上「實體記憶體還很多」不代表不會配置失敗。
- `show` 的輸出去除 ANSI 色碼，適合貼進回報；`io\stdout` 原始檔仍保留色碼。
- 完成後 `metadata.json` 的 `finished_at`／`exit_code` 才有值；`io\exit` 也是判斷依據。

## 安全與邊界

- 腳本**只讀**，不提供 kill；要停止工作請用 agent 的 `bash_kill`，或在明確知道目標時用 `taskkill /PID <child_pid> /T /F`。
- 不修改 AFT 的 registry／資料庫；不建立或刪除任務目錄。
- 任務輸出可能含敏感資訊；貼出前先確認內容。
- 這是本機除錯工具，不是正式 API；AFT 升級若改變目錄格式，先看 `metadata.json` 的 `schema_version` 再調整。

## Windows 注意

- 腳本以 UTF-8 設定主控台輸出；若你的視窗仍顯示亂碼，先 `chcp 65001`。
- 路徑含空白時一定用引號；PowerShell 執行原則若擋下 `.ps1`，用 `pwsh -File <path>` 或在當前使用者範圍設 `RemoteSigned`。
