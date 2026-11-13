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

```powershell
$tool = "F:\opencode-skills\skills\aft-bash-inspector\scripts\aft-bash.ps1"

& $tool list                        # 目前執行中的工作
& $tool show <taskId> -Tail 40      # 快照：metadata＋程序樹＋輸出尾巴
& $tool watch <taskId>              # 跟隨新的 stdout／stderr 直到工作結束
```

`<taskId>` 可用唯一前綴（例如 `bash-f16f`）；不確定就先跑 `list`。

## 它從哪裡讀資料

AFT 會把每個工作寫在：

```
%LOCALAPPDATA%\cortexkit\aft\<harness>\bash-tasks\<project-hash>\<taskId>\
├─ control\metadata.json   # status、child_pid、command、session_id、started_at…
├─ io\stdout
├─ io\stderr
└─ io\exit                 # 完成後才有退出碼
```

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
