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
- 原始碼文件若與本技能衝突（例如工具自身 repo 用 editable 安裝），**以本技能的模板為準**：
  `Docs/pages.md` 描述的是 changelogkit 自己 repo 的流程，不是任意目標 repo 的建議做法。
- 發現原始碼行為與技能描述不一致時，以原始碼為準，並在回報中指出落差。

## 步驟 0：確認目標 repo

- 以 `git -C <path> rev-parse --show-toplevel` 取得 repo 根。
- 判定分支，順序如下：
  1. `git symbolic-ref --short refs/remotes/origin/HEAD`（有 remote 時）
  2. 否則 `git branch --show-current`
  3. detached HEAD 或結果為空才問使用者
- **記下分支名**：`export --branch` 要用它，否則靜態站的 GitHub 連結會指向錯誤分支。
- 檢查既有檔案：`.changelog.toml`、`Docs/ChangeHistory.md`（或既有 `CHANGELOG.md`）、`TODO.md`、`.github/workflows/pages.yml`、`.gitignore`。
- 有既有設定時**預設合併、不覆寫**：只補缺少的欄位，既有值（尤其 `title`）一律保留並在回報中列出。
  要改既有值（例如舊標題已不適用）時先停下、顯示 diff 並詢問，不要自行決定。
  `project` 未設定可留白（工具預設用 repo 目錄名），不必為了湊欄位而推論改寫。
  合併完成後用 `git diff`（或等效的檔案差異）呈現變更內容。

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
- `todo`：可省略（工具會自動找根目錄 `TODO.md`）。明確寫出只是讓意圖清楚；`TODO.md` 不存在時見步驟 4。
- `exclude`：排除 vendor／建置產物，否則文件與符號索引會被第三方內容淹沒。判斷方法見 `references/vendor-noise.md`。
  排除後以文件數變化驗證（例如 180+ → 20 內）。
- `docs.groups`：repo 的文件分組有意義時才加；`paths` 不得重疊，加完跑 `docs --check` 到無 ERROR
  （沒命中的 pattern 只是 WARN，代表該路徑要嘛刪掉、要嘛修正）。
- 歷史檔本身也會進文件索引（通常落在「其他」）。這是預期行為；不想顯示就用 `docs.entries` 或接受它。
- 不寫死使用者本機絕對路徑；repo 內的設定必須可移植。

## 步驟 3：變更歷史檔

- 不存在才用 `assets/ChangeHistory.md.tpl` 建立骨架。**不要捏造紀錄**。
- 解析規則（原始碼 `history.py`，跨版本大致穩定）：
  - 標題格式是 `## YYYY.MM.DD [HH:MM] 標題`。**有日期標題時，只有這種行是條目邊界**；內文的 `## ` 會留在同一筆，不應再被當成新紀錄。
  - 內文子標題請用 `###`；完全沒有日期標題的舊檔才會 fallback 把所有 `## ` 當成條目，供 `backfill-dates` 補日期。
  - HTML 註解會被移除，但別在註解裡放 `## `。
- 完成判準：檔案存在、`list` 能執行、筆數如實回報。**0 筆只能說「已建立骨架（0 筆）」**，不能說歷史已建立完成。
- 要從 git log 回填，必須先取得明確同意；只寫能從 commit 證實的內容，日期用 commit 日期。
- 有條目後用 `list`／`show <編號>` 確認解析內容與顯示一致。

## 步驟 4：主 `TODO.md`

- 已存在就**不要改寫**內容，只確認設定指向它。
- 不存在才建立，內容從 repo 既有文件（例如「已知限制與待辦事項」）遷移，保留分類與未完成項；
  不要為了湊數發明工作。
- 解析格式是 `- [ ]`／`- [x]`；說明文字不要用這兩個前綴。

## 步驟 5：GitHub Pages（可選）

先問使用者是否要；沒有 GitHub remote 就不提。要的話：

- 複製 `assets/pages.yml.tpl`，把 `<BRANCH>` 換成步驟 0 記下的實際分支。
- 安裝步驟**每次解析最新 tag**，不釘死版本；需要可重現時用 repo 變數 `CHANGELOGKIT_REF` 覆寫。
- `fetch-depth: 0` 必留（列 commits／diff 需要完整歷史）。
- `export --branch` 必須等於 workflow 觸發分支。
- 本機先跑一次 `export` 驗證，再交給 CI。
- 提醒使用者手動設定：repo **Settings → Pages → Source = GitHub Actions**。

### 選配：外部 API 文件站

repo 已有 Doxygen、Sphinx、Go doc、pdoc 等產生的 HTML 或外部 API 站時，可選擇接入；沒有設定就完全維持現狀。

- 使用 `[[tool.changelog.api]]`，可同時設定多個站點；`html` 指向本機 HTML 目錄，`url` 指向外部站（二選一）。
- `embed` 預設 `false`；靜態站預設只外連，要複製本機產物才設 `true`。多個站點會收成「API 文件」下拉。
- `kind` 是選填的 adapter 提示，純掛載不需要；目前只有掛載，tagfile／`objects.inv` 的符號深連結尚未內建，實際欄位以來源 `Docs/usage.md` 為準。
- **Doxygen 產物不可放在 export 輸出目錄內**（例如 `_site/api`），否則匯出前清理會刪掉它；請輸出到獨立目錄（例如 `build/doxygen/html`）。
- 若 Pages 要 `embed`：先產生 API，再跑 `export`；CI 先 `mkdir -p` 輸出父目錄（舊版 Doxygen 不會自動建立巢狀目錄），最後確認 `_site/api-docs/<mount>/index.html`。

## 步驟 6：驗證門檻（沒過不得回報完成）

| 檢查 | 通過條件 |
| --- | --- |
| `docs --check` | exit 0、無 ERROR；WARN 逐條說明（輸出格式為 `WARN  <訊息>`） |
| 歷史檔 | 檔案存在；`list` 可執行；筆數如實回報（0 筆＝骨架） |
| `export` | exit 0；首頁 `<h1>` 等於設定的 `title`；`<title>` 以 `project` 開頭 |
| 文件索引 | 文件頁數與 `docs --check` 的文件數一致；vendor 已排除，不是 0 |
| 待辦頁 | 有 `TODO.md` 項目時，`development/todo.html` 存在且解析到數量 |
| API 文件站 | 有設定時，動態／靜態的 `/api-docs/<mount>/index.html` 可取得且導覽有入口；`url` 外部站只需確認連結；Doxygen 產物不得位於 export 輸出目錄內 |
| workflow YAML | **有 Pages 才檢查**：用 YAML 解析器（例如 PyYAML）載入無語法錯誤；YAML 1.1 會把 `on:` 讀成 `True`，不影響判定；沒有 Pages 記為 N/A |
| `git status` | 只有預期的新增／修改檔；`_site/` 不得出現（已 gitignore 或輸出到 repo 外） |

**常見誤判**：`<title>` 是「`project` · 頁面名稱」，不是 `title` 欄位；`title` 只出現在 `<h1>`。
拿 `<title>` 比對 `title` 會永遠失敗。

`export` 預設寫 repo 內 `_site/`：先把它加進 `.gitignore`。不想留產物就輸出到 repo 外的暫存目錄，
兩種都算通過，但回報要說明實際落點。

回報要帶實際數字（文件數、頁數、歷史筆數、tag），不要只說「已完成」。

## 明確不做

- 不代替使用者決定歷史內容、不改既有 TODO 條目、不把 `_site` 提交進 repo。
- 不自動產生 `Docs/community.md`（工具刻意維持唯讀，需明示 `community-init`）。
- 不在中文路徑做 `pip install -e`（會產生含非 ASCII 的 `.pth`，cp950 下 Python 直接起不來）。
- 不假設 repo 一定有 Pages，也不把 Pages 當成接入的必要條件。

## 官方參考

- [ChangeLogKit 原始碼](https://github.com/TwhomeGH/ChangeLogKit)
- [用法文件](https://github.com/TwhomeGH/ChangeLogKit/blob/main/Docs/usage.md)
- [Pages 靜態匯出](https://github.com/TwhomeGH/ChangeLogKit/blob/main/Docs/pages.md)
