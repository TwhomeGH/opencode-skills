---
name: git-worktree-safety
description: >-
  建立、檢視與清理 Git worktree 時使用，尤其是教學文件、清理腳本或專案既有
  worktree 指南可能要求 `git worktree remove`、`--force`、`rm -rf`、`git clean`
  或 `reset --hard` 的情況。預設把整個 worktree 送系統回收站，再執行
  `git worktree prune`；先稽核既有文件與腳本是否會直接刪除未提交內容。
  Triggers: git worktree, worktree 清理, worktree remove, prune, 回收站, 清除 worktree, tutorial cleanup.
---

# Git worktree 安全生命週期

## 適用範圍

這個技能處理 **worktree 的建立、檢查、移除與分支收尾**，不是一般檔案清理的完整替代品。

- 清理單一檔案、快取或暫存目錄時，仍以系統回收站為預設。
- 若環境另有 `safe-file-cleanup` 技能，該技能是 OS 回收 API 的權威；本技能仍要能獨立運作，不依賴它存在。
- 不要假設專案已有 worktree 指南；先找、再判斷是否安全。

## 第一步：稽核既有 worktree 文件與腳本

在目標 repo 根目錄執行（用專案現有搜尋工具）：

```text
git worktree remove
worktree remove
--force
git clean
reset --hard
Remove-Item
rm -rf
Shift+Delete
```

同時檢查：

```powershell
git worktree list
git -C <worktree> status --short
git -C <worktree> log --oneline <base>..HEAD
```

把發現分成四類：

| 類型 | 例子 | 風險 |
| --- | --- | --- |
| 直接刪除 worktree | `git worktree remove`、`--force` | 不進回收站，可能丟未提交內容 |
| 直接刪檔案／目錄 | `Remove-Item -Recurse`、`rm -rf` | 不可還原 |
| 直接丟分支 | `git branch -D` | commit 參照消失（短時間可由 reflog 找回） |
| 沒有 prune | 手動刪目錄後未 `git worktree prune` | Git metadata 殘留 |

**先回報，不要自動大改既有教學。** 若是使用者要求修正，才逐段替換成回收站優先流程；不要把不同專案的慣例硬套進去。

## 第二步：判斷哪些要回收、哪些可直接清

| 目標 | 處理 |
| --- | --- |
| 整個 worktree 目錄 | **系統回收站** |
| source、未提交、untracked 變更 | **系統回收站** |
| 用途不確定的日誌／暫存檔 | **系統回收站** |
| 明確可重建的 build／runtime／cache／`node_modules` | 可直接清，但不要用整個 worktree 當目標 |
| Git 分支 | 不是檔案；合併後用 `git branch -d`，不進回收站 |

原則：**worktree 目錄一律回收；只有可重建產物才直接清。**

## 第三步：安全移除流程

1. 確認目標是已註冊的 worktree，不是主 worktree：

```powershell
git worktree list
```

2. 檢查未提交內容與未合併 commit：

```powershell
git -C <worktree> status --short
git -C <worktree> log --oneline <base>..HEAD
```

3. 停止會占用檔案的程式：dev server、SRS、Docker、VS Code 檔案監看、LSP。

4. 預設用**系統回收站**移動整個 worktree 目錄：

- Windows：檔案總管一般 Delete，或 Shell 回收站 API；不要 Shift+Delete。
- macOS：Finder「移到垃圾桶」或 Foundation `trashItem`。
- Linux：`gio trash <path>` 或桌面環境垃圾桶；不要 `rm -rf`。

5. 目錄消失後清 Git metadata：

```powershell
git worktree prune
git worktree list
```

6. 分支不會自動刪除。確認已合併後：

```powershell
git branch -d <branch>
```

若未合併但確定不要，才使用 `git branch -D`，並先確認 reflog 可救援：

```powershell
git reflog
git branch <branch> <sha>
```

## `git worktree remove` 的行為

| 行為 | 注意 |
| --- | --- |
| 直接刪除 | **不進回收站，沒有 undo** |
| dirty worktree | 有 modified／untracked 時拒絕 |
| `--force` | 連未提交內容一起刪，不可回收 |
| 分支 | 不會刪除，需另外處理 |
| 主 worktree | 不能刪目前 repo 的主目錄 |
| 目錄已不存在 | 用 `git worktree prune` 清 metadata |

只有在「內容已確認不需要、也不需要可還原」時才用 `git worktree remove --force`。教學與日常開發應使用回收站流程。

## 剛 checkout 也可能顯示 modified

Windows 的 CRLF／BOM 可能讓新 worktree 出現只差行尾的 modified：

```powershell
git -C <worktree> diff --ignore-space-at-eol --stat
git -C <worktree> diff --numstat
```

不要因為看到 `M` 就直接 `--force`。先確認不是自己的修改；若確定只是 line-ending，可用回收站 helper 或清理後的標準流程，而不是永久刪除。

## 建議專案文件結構

若專案還沒有 worktree 指南，建議新增 `Docs/development/git-worktree.md`，至少包含：

1. worktree 與 clone 的差別。
2. 建立與 `git worktree list`。
3. 清理前檢查（status、未合併 commit、執行中程序）。
4. 回收站 vs 可直接清的產物。
5. `git worktree remove`／`--force` 的破壞性。
6. prune、分支刪除、reflog。
7. Windows／macOS／Linux 的回收入口。
8. 一個完整的安全收尾範例。

教學文件若提到 worktree 清理，應連到這份指南，不要各自複製 `git worktree remove`。

## 安全 helper 的必備行為

若專案要提供清理腳本，至少做到：

- 只接受已註冊的 worktree，拒絕主 worktree。
- 列出 modified／untracked；沒有明確 `-DiscardChanges` 就拒絕。
- 拒絕有程序正在從該目錄執行。
- 使用系統回收 API；失敗就停止，**不得降級為永久刪除**。
- 回收後執行 `git worktree prune` 並驗證清單。
- 不自動刪分支；只提示後續指令。
- 提供 `-DryRun`，先印目標與檢查結果。

## 驗證清單

- [ ] `git worktree list` 已無目標
- [ ] 目錄已進回收站／垃圾桶，而不是直接消失
- [ ] `git worktree prune` 已執行
- [ ] 分支是否保留已明確決定
- [ ] 沒有執行中的 dev server／Docker／LSP
- [ ] 文件不再指示直接 `git worktree remove --force`

## 常見錯誤

| 錯誤 | 修正 |
| --- | --- |
| 用 `rm -rf` 刪 worktree | 改用系統回收站，再 prune |
| 看到 dirty 就 `--force` | 先檢查是否為 line-ending 或真有未提交工作 |
| 刪了目錄但沒 prune | `git worktree prune` |
| 直接 `git branch -D` | 先確認合併與 reflog；分支不是檔案 |
| 假設回收站一定支援網路磁碟 | 失敗就停止，改手動保留；不要永久刪除 |
