---
name: changelogkit-setup
description: >-
  在任一 repo 接入 changelogkit（`.changelog.toml`、變更歷史 `Docs/ChangeHistory.md`、主 `TODO.md`、
  GitHub Pages 唯讀靜態站），或重新驗證既有接入時使用。會先確認 Python 環境是否已安裝 changelogkit，
  或是否指定本地原始碼，再從實際來源的 `--help`／`capabilities`／`Docs/` 查當前指令與旗標，
  不依賴技能內寫死的版本資訊。
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

1. 環境變數 `CHANGELOGKIT_SRC`（指向 changelogkit repo 根目錄；只有在明確要驗證本地原始碼時使用）。
2. **已安裝的 console script（先試這個）**：

   ```powershell
   changelogkit --version
   changelogkit capabilities --json
   ```

   可執行且版本符合需求就使用；這通常就是使用者已安裝在 Python 環境的版本。

3. **其他 Python 環境**：若 PATH 沒有 `changelogkit`，不要直接判定未安裝，依序檢查：

   ```powershell
   py -0p
   py -3.11 -m changelogkit --version
   python -m changelogkit --version
   pip show changelogkit
   where.exe changelogkit
   ```

   `python` 可能不是安裝套件的那個直譯器（例如 `python` 是 3.10、套件裝在 3.11）；
   `python -m changelogkit` 失敗不代表沒有安裝。用 `Get-Command changelogkit`／
   `where.exe changelogkit` 找到 console script 後，改用同一個 Python 環境；不要混用兩份安裝。
   Windows Store Python 的套件可能在
   `%LOCALAPPDATA%\Packages\PythonSoftwareFoundation.Python.*\LocalCache\local-packages`，
   不一定在 `%LOCALAPPDATA%\Programs\Python` 底下。
4. **詢問使用者是否已有本地原始碼、路徑在哪**；不要假設固定磁碟或路徑（例如某個磁碟上的
   `ChangeLogTools`）。可以從 `CHANGELOGKIT_SRC`、使用者指定路徑或 `git` 查詢取得；
   不要用 `D:\`／`F:\` 逐一搜尋猜測。
   若同時有安裝版與原始碼，選擇一個明確來源並在回報中寫出實際版本，不要靜默混用。
5. 都沒有才安裝：解析最新 tag 後 `pip install "git+https://github.com/TwhomeGH/ChangeLogKit.git@<tag>"`
   （**不要** `pip install -e`，也不要釘死舊版）。

使用本地原始碼時，判定有效來源：`<root>/src/changelogkit/cli.py` 存在，並用：

```powershell
$env:PYTHONPATH = "<changelogkit-root>\src"
$env:PYTHONUTF8 = "1"
python -m changelogkit --version
python -m changelogkit --help
python -m changelogkit capabilities --json
```

使用已安裝套件時不需要 `PYTHONPATH`，用 `changelogkit` 或「實際安裝該套件的 Python」
執行 `-m changelogkit`。**0.14.2 以後的 wheel 隨附** `changelogkit/docs/usage.md` 與
`changelogkit/docs/pages.md`，可用安裝該套件的 Python 找路徑：

```powershell
python -c "import changelogkit, pathlib; print(pathlib.Path(changelogkit.__file__).parent / 'docs' / 'usage.md')"
```

舊版 wheel 或找不到 `docs/` 時，不要因此判定安裝無效，改用 `--help` 與
`capabilities` 查；不要要求使用者先拉原 repo 才有文件。本地原始碼才讀
`<root>/Docs/usage.md`、`Docs/pages.md`。
Windows 的編碼與路徑細節見 `references/windows.md`。

### 能力探測（必做）

`capabilities --json` 是這個安裝版本的**已知功能索引**，不是完整規格：

- 先確認 `version`；`features` 內有 `since` 的項目，代表需要該版本以上。
- 技能要使用某功能（例如 LAN、API 文件、TODO 自動偵測）前，先確認對應 `id` 存在。
- 找不到對應 `id` 時，**不要假設支援、也不要自行發明設定**；依序檢查
  `--help`、`Docs/usage.md`、`Docs/pages.md` 與原始碼。
- `capabilities` 自 **0.13.3** 起提供。若 `--version` 小於 0.13.3，或指令回
  `unknown command`，表示這個安裝沒有這份清單：不要用其他版本的 `features` 推論，
  改用 `--help`、`Docs/usage.md`、`Docs/pages.md` 與原始碼判斷，並告知使用者實際版本與限制。
  必要時才安裝最新 tag。

清單是人工維護的；如果某個新功能不在清單中，應以目前原始碼與 `--help` 為準，並在回報中指出清單落差。

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
- 若使用 Workflow 健康檢查的 runtime 查詢，export step 要設 `GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}`；Actions 不會自動提供這個環境變數，**也不要放進 `.changelog.toml`**。
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
| 安裝狀態 | 先用 `changelogkit --version`／正確 Python 的 `-m changelogkit --version` 確認；原始碼資料夾不存在不等於未安裝 |
| 文件來源 | 0.14.2+ 的 wheel 有 `changelogkit/docs/`；舊版改用 `--help`／`capabilities`，不得要求先拉原 repo |
| `capabilities --json` | **0.13.3+** 才檢查：可解析 JSON；`version` 與 `--version` 一致；需要的功能 `id` 存在（不存在時已查 --help／Docs）。舊版沒有此指令時記為 fallback，不得假設能力 |
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
- 不把「`F:\ChangeLogTools` 或其他固定原始碼路徑不存在」當成「changelogkit 未安裝」；
  先查 Python 環境的 `python -m changelogkit`。
- 不因 repo 沒有 Pages workflow 就說「沒有站台產生流程」；本機 `export` 與 GitHub Pages
  是不同層次，前者不需要 workflow。

## 官方參考

- [ChangeLogKit 原始碼](https://github.com/TwhomeGH/ChangeLogKit)
- [用法文件](https://github.com/TwhomeGH/ChangeLogKit/blob/main/Docs/usage.md)
- [Pages 靜態匯出](https://github.com/TwhomeGH/ChangeLogKit/blob/main/Docs/pages.md)
