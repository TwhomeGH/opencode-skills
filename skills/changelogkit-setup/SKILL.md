---
name: changelogkit-setup
description: >-
  在任一 repo 接入 changelogkit（`.changelog.toml`、變更歷史 `Docs/ChangeHistory.md`、主 `TODO.md`、
  GitHub Pages 唯讀靜態站），或重新驗證既有接入時使用。會先確認本機是否已有 changelogkit 原始碼，
  再從該來源的 `--help`／`Docs/` 查當前指令與旗標，不依賴技能內寫死的版本資訊。
  Triggers: changelogkit, 接入變更歷史, ChangeHistory, Pages 靜態站, changelog 設定, 變更紀錄.
---

# 接入 changelogkit

把 changelogkit 裝進一個 repo：設定檔、變更歷史、主待辦、可選的 GitHub Pages 靜態站。
核心原則：**這份技能只放決策與地雷；旗標與行為一律在執行時向 changelogkit 本體查。**

## 為什麼是「薄技能」

changelogkit 持續改版，旗標與設定欄位會變。技能若抄一份旗標表，下次改版就會過期，還會與原始碼互相矛盾。

- 每次接入都先解析工具來源，執行 `--help`，必要時讀該來源的 `Docs/usage.md`／`Docs/pages.md`。
- 技能內只保留**跨版本穩定**的指令：`export`、`docs --check`、`--branch`、全域 `--locale` 的位置規則。
- 發現原始碼與技能描述不一致時，**以原始碼為準**，並在回報中指出落差。

## 步驟 0：確認目標 repo

- 以 `git -C <path> rev-parse --show-toplevel` 取得 repo 根；確認預設分支（`origin/HEAD`，否則問使用者）。
- 檢查既有檔案：`.changelog.toml`、`Docs/ChangeHistory.md`（或既有 `CHANGELOG.md`）、`TODO.md`、`.github/workflows/pages.yml`、`.gitignore`。
- 有既有設定時**預設合併、不覆寫**；先顯示差異再動手。

## 步驟 1：解析 changelogkit 來源

依序嘗試，找到就停：

1. 環境變數 `CHANGELOGKIT_SRC`（指向 changelogkit repo 根目錄）。
2. **詢問使用者是否已有本地原始碼、路徑在哪**（這是常態：接入時通常已持有）。
3. PATH 上的 `changelogkit` 指令。
4. 都沒有才安裝：解析最新 tag 後 `pip install "git+https://github.com/TwhomeGH/ChangeLogKit.git@<tag>"`
   （**不要** `pip install -e`，也不要釘死舊版）。

判定有效來源：`<root>/src/changelogkit/cli.py` 存在。使用本地原始碼時：

```powershell
$env:PYTHONPATH = "<changelogkit-root>\src"
$env:PYTHONUTF8 = "1"
python -m changelogkit --version
python -m changelogkit --help
```

同時讀取 `<root>/Docs/usage.md`、`Docs/pages.md`，確認當前欄位與靜態站行為。
Windows 的編碼與路徑細節見 `references/windows.md`。

## 步驟 2：建立或合併 `.changelog.toml`

最小可用設定見 `assets/changelog.toml.tpl`。決策順序：

- `history`：預設 `Docs/ChangeHistory.md`。若 repo 已有 `CHANGELOG.md` 且使用者要單一來源，才指向它；
  changelogkit 格式（問題／根因／修改）與 Keep a Changelog 不同，混用前先說明。
- `todo`：`TODO.md` 存在就指向它；不存在的處理見步驟 4。
- `exclude`：排除 vendor／建置產物，否則文件與符號索引會被第三方內容淹沒。判斷方法見 `references/vendor-noise.md`。
  排除後以文件數變化驗證（例如 180+ → 20 內）。
- `docs.groups`：repo 的文件分組有意義時才加；`paths` 不得重疊，加完跑 `docs --check` 到無 ERROR
  （沒命中的 pattern 只是 WARN，代表該路徑要嘛刪掉、要嘛修正）。
- 不寫死使用者本機絕對路徑；repo 內的設定必須可移植。

## 步驟 3：變更歷史檔

- 不存在才建立骨架（標題＋格式說明）。**不要捏造紀錄**。
- 要從 git log 回填，必須先取得明確同意；只寫能從 commit 證實的內容，日期用 commit 日期。
- 完成後用 `list`／`show` 確認解析得到條目；空檔案不算完成。

## 步驟 4：主 `TODO.md`

- 已存在就**不要改寫**內容，只確認設定指向它。
- 不存在才建立，內容從 repo 既有文件（例如「已知限制與待辦事項」）遷移，保留分類與未完成項；
  不要為了湊數發明工作。
- 解析格式是 `- [ ]`／`- [x]`；說明文字不要用這兩個前綴。

## 步驟 5：GitHub Pages（可選）

先問使用者是否要；沒有 GitHub remote 就不提。要的話：

- 複製 `assets/pages.yml.tpl`，把 `<BRANCH>` 換成實際分支。
- 安裝步驟**每次解析最新 tag**，不釘死版本；需要可重現時用 repo 變數 `CHANGELOGKIT_REF` 覆寫。
- `fetch-depth: 0` 必留（列 commits／diff 需要完整歷史）。
- `_site/` 加入 `.gitignore`。
- 本機先跑一次 `export` 驗證，再交給 CI。
- 提醒使用者手動設定：repo **Settings → Pages → Source = GitHub Actions**。

## 步驟 6：驗證門檻（沒過不得回報完成）

| 檢查 | 通過條件 |
| --- | --- |
| `docs --check` | exit 0、無 ERROR（WARN 需逐項說明） |
| `export <tmp>` | exit 0，`index.html` 的 `<title>` 與設定的 `title` 一致 |
| 文件索引 | 文件數合理（vendor 已排除），不是 0 |
| 待辦頁 | 有設定 `todo` 且 `TODO.md` 有項目時，`development/todo.html` 存在且解析到數量 |
| workflow YAML | 可被 YAML 解析器載入 |
| `git status` | 只有預期的新增／修改檔 |

回報要帶實際數字（文件數、頁數、tag），不要只說「已完成」。

## 明確不做

- 不代替使用者決定歷史內容、不改既有 TODO 條目、不把 `_site` 提交進 repo。
- 不自動產生 `Docs/community.md`（工具刻意維持唯讀，需明示 `community-init`）。
- 不在中文路徑做 `pip install -e`（會產生含非 ASCII 的 `.pth`，cp950 下 Python 直接起不來）。
- 不假設 repo 一定有 Pages，也不把 Pages 當成接入的必要條件。

## 官方參考

- [ChangeLogKit 原始碼](https://github.com/TwhomeGH/ChangeLogKit)
- [用法文件](https://github.com/TwhomeGH/ChangeLogKit/blob/main/Docs/usage.md)
- [Pages 靜態匯出](https://github.com/TwhomeGH/ChangeLogKit/blob/main/Docs/pages.md)
