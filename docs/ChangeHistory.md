# ChangeHistory

## 2026.11.13 16:10 新增 aft-bash-inspector 技能（唯讀任務檢視器）

**類型**: 新增 · **檔案**: `skills/aft-bash-inspector/`、`README.md`

### 問題 - 背景 bash 只有 taskId 才能查，沒有「列出全部」的介面

Agent 的 `bash_status`／`bash_watch`／`bash_kill` 都要先知道 taskId；工作一多或忘記 ID 時，只能猜或翻訊息。也看不到工作內部的程序樹（例如 cargo→rustc 誰在吃記憶體）。

### 根因 - AFT 沒有暴露 session-wide 的任務清單

`bash_owned_tasks` 是內部清理用；對外只提供單一 taskId 的查詢。任務狀態其實已寫在磁碟上的 `metadata.json`，但沒有工具去讀。

### 修改 - 以 AFT 的任務目錄實作唯讀檢視器

- `scripts/aft-bash.ps1`：`list`（執行中工作）、`show`（metadata＋程序樹＋輸出尾巴）、`watch`（輪詢跟隨輸出到結束）。
- 支援 `AFT_STORAGE_DIR` 與 `%LOCALAPPDATA%\cortexkit\aft\<harness>\bash-tasks`；taskId 可用唯一前綴。
- 唯讀、不提供 kill；ANSI 色碼在顯示時剝除，原始輸出保留。
- `SKILL.md` 說明資料來源、判讀技巧與邊界。

---

## 2026.11.13 15:20 以端到端測試修正 changelogkit-setup 的驗證判準

**類型**: 修正 · **檔案**: `skills/changelogkit-setup/SKILL.md`、`assets/ChangeHistory.md.tpl`、`references/windows.md`

### 問題 - 首版技能只驗證了模板，照文件實際執行會卡住

獨立 agent 依 SKILL.md 接入測試 repo 時發現 10 項問題；其中 `<title>` 驗證判準永遠不可能通過（`title` 只出現在 `<h1>`），歷史檔骨架也缺少解析規則。

### 根因 - 用「模板能跑」代替「流程能跑」

模板（`.changelog.toml`／Pages YAML）確實實測過，但技能本體的步驟、判準與分支處理沒有被執行；`<title>` 與 `title` 的關係憑印象寫入，未對照 `static_history.html`。

### 修改 - 以第二輪端到端測試逐項驗證

- 驗證判準改為首頁 `<h1>` 等於 `title`、`<title>` 以 `project` 開頭，並加「常見誤判」說明。
- 新增 `assets/ChangeHistory.md.tpl`；寫明「任何 `## ` 行都會被解析成條目」與 0 筆只能回報骨架。
- 分支判定補上「remote HEAD → 當前分支 → 詢問」三順位，並要求 `export --branch` 與 workflow 一致。
- Pages 門檻加註 N/A；`_site` 落點統一（repo 內先 gitignore，或輸出 repo 外）。
- 補上合併規則（保留既有值、要改先問）與 YAML 解析器說明。
- 第二輪測試：`docs --check`、`list`、`export`、`<h1>`／`<title>`、待辦頁、workflow YAML、`git status` 全數通過。

---

## 2026.11.13 14:45 新增 changelogkit-setup 技能（薄技能設計）

**類型**: 新增 · **檔案**: `skills/changelogkit-setup/`、`README.md`

### 問題 - 每次把 changelogkit 接入新專案都要重踩同一批坑

cp950 中文路徑不能 editable 安裝、`--locale` 必須放在子命令前、vendor 文件會淹沒索引、Pages 需要 `fetch-depth: 0`——這些只留在對話裡，換一個專案就要重新發現。

### 根因 - 接入流程沒有可重用的技能，而工具旗標會隨版本變動

把旗標抄進技能會立刻過期，還會與原始碼互相矛盾；需要把「流程與決策」和「工具本體」分離。

### 修改 - 新增薄技能，旗標一律向來源查

- `SKILL.md`：來源解析順序（`CHANGELOGKIT_SRC` → 詢問使用者 → PATH → 最新 tag）、7 步接入流程、自動偵測與必須詢問的分界、驗證門檻、明確不做清單。
- `references/windows.md`：PYTHONPATH 用法、禁止 editable 安裝的原因、UTF-8 主控台、`--locale` 位置規則。
- `references/vendor-noise.md`：以 `git ls-files '*.md'` 量測目錄占比，排除前後用 `docs --check` 驗證。
- `assets/`：`.changelog.toml` 與 Pages workflow 模板；Pages 每次解析最新 tag，不釘死版本，可用 `CHANGELOGKIT_REF` 覆寫。
- `README.md` 技能表補列。

---

## 2026.10.14 16:03 修正 clean-code references 的裸 URL（markdownlint MD034）

**類型**: 修正 · **檔案**: `skills/clean-code/references/*.md`

### 問題 - 官方參考用裸 URL，觸發 markdownlint MD034

`clean-code/references/` 各檔的「官方」清單直接貼上裸 URL（如 `- https://go.dev/doc/comment`），markdownlint 報 MD034/no-bare-urls；在非 GFM 的渲染器（如 changelogkit 的 markdown.js）可能不會自動變成可點連結。

### 根因 - 撰寫參考檔時直接貼 URL，未改成連結語法

### 修改 - 統一改成 `[文字](url)` 連結

- 8 個 references 檔（swift／kotlin-java／typescript-javascript／python／rust／go／csharp／windows-scripts）的「官方」清單改為 `[標題](url)`，與 repo 其他處（各 SKILL.md 的官方參考）一致。
- 同一修正已同步到 `~/.codex/skills/clean-code/references/`（該處為 repo 的複本）。

---

## 2026.10.14 15:40 校正 README 技能表與實際目錄一致

**類型**: 修正 · **檔案**: `README.md`

### 問題 - 技能列表與 skills/ 目錄不符

表格列了 repo 已移除的 `context-cleanup`，卻漏列實際存在的 `file-fix`、`safe-file-cleanup`、`swift-test`。

### 根因 - 移除／新增技能時未同步 README

先前「移除省 token 技能」只刪了技能目錄，未更新 README 的技能表，之後新增技能也未補列。

### 修改 - 以實際目錄為準重列

- 移除 `context-cleanup` 一列。
- 補上 `safe-file-cleanup`、`file-fix`、`swift-test` 三列；全表改以 `skills/` 目錄實際內容為準（8 個技能）。

---

## 2026.10.14 15:38 修正 clean-code 的懸空跨技能引用；README 新增技能撰寫原則

**類型**: 修正 · **檔案**: `skills/clean-code/references/windows-scripts.md`、`README.md`

### 問題 - 技能互相依賴，未安裝同儕技能時資訊懸空

`windows-scripts.md` 用「見 `windows-script-pitfalls` 技能」帶過腳本編碼地雷；但技能是獨立安裝的，agent 也無法得知使用者裝了哪些同儕技能——對方沒裝就等於沒有資訊。

### 根因 - 把跨技能引用當成資訊來源，而非額外參考

技能之間沒有依賴機制，卻在文件裡預設另一個技能存在。

### 修改 - 改為自足內容並明訂原則

- `windows-scripts.md` 的指標改為**自足**：直接內聯最關鍵兩條（文字檔存 UTF-8；含非 ASCII 的 `.ps1` 存 UTF-8 with BOM），不再指向技能名。
- `README.md` 新增「技能撰寫原則」：技能須自足、需要同儕知識時內聯、外部資源用官方 URL、`description` 自述觸發、細節用 `references/` 按需載入。
- 全 repo 檢查後，僅此一處交叉引用，其餘皆為自我指涉。

---

## 2026.10.14 15:33 新增 windows-script-pitfalls 技能；clean-code 補腳本註釋慣例

**類型**: 功能 · **檔案**: `skills/windows-script-pitfalls/SKILL.md`、`skills/clean-code/references/windows-scripts.md`、`skills/clean-code/SKILL.md`、`README.md`

### 問題 - 腳本語言與 Windows 編碼地雷沒有著落

`clean-code` 只涵蓋一般語言的 doc comment，未含腳本語言；而 PowerShell／cmd／VBScript 的編碼與平台地雷（cp950、BOM、chcp、執行原則）屬「正確性／環境」議題，放進註釋／可讀性技能會失焦。

### 修改 - 註釋慣例進 clean-code，編碼地雷另立技能

- `clean-code`：新增 `references/windows-scripts.md`（PowerShell comment-based help、cmd `REM`／`::`、VBScript `'`／`Rem`），語言分派表補兩列，官方參考補 PowerShell／cmd 連結。
- 新增 `windows-script-pitfalls` 技能：PowerShell 編碼（無 BOM 用 ANSI、5.1 輸出 UTF-16LE／ANSI 不一致）、BOM 的雙面刃、執行原則、引號轉義、cmd/bat 代碼頁與 BOM、VBScript legacy，以及 Python locale／`.pth` 陷阱（解法 `PYTHONUTF8=1` 或避免 `-e` 安裝）。
- 事實均對照官方文件：about_Character_Encoding、about_Execution_Policies、chcp、rem、PEP 540。
- `README.md` 技能表新增 windows-script-pitfalls 一列，並更新 clean-code 說明。

---

## 2026.10.14 15:29 接入 changelogkit 管理變更歷史

**類型**: 功能 · **檔案**: `.changelog.toml`、`docs/ChangeHistory.md`

### 問題 - 變更歷史散在 commit，無從瀏覽

專案沒有結構化的變更歷史（問題／根因／修改），想了解某項改動的來龍去脈只能翻 `git log`，也沒有可瀏覽的網頁或開發索引。

### 修改 - 以 changelogkit 建立變更歷史與開發索引

- 新增 `.changelog.toml`：`title = "opencode-skills 變更歷史"`、`history = "docs/ChangeHistory.md"`，開發索引來源為本 repo（`name = "opencode-skills"`、`path = "."`）。
- 新增 `docs/ChangeHistory.md` 作為變更歷史；之後以 `changelogkit add` 或網頁 GUI 維護。
- 執行方式：`py -3.11 -m changelogkit`（已全域安裝於 Python 3.11；注意 `python` 指向 3.10，勿混用）。

---

## 2026.10.14 15:27 新增 clean-code 技能：註釋、可讀性與模塊化準則

**類型**: 功能 · **檔案**: `skills/clean-code/SKILL.md`、`skills/clean-code/references/*.md`、`README.md`

### 問題 - 缺少統一的註釋與可讀性準則

技能集只涵蓋個別工具用法，沒有「寫程式時的習慣」：文件註釋（參數／回傳說明）、行內註釋、可讀性排版與模塊化判斷，全憑當下臨場決定、沒有一致準則。

### 修改 - 新增 clean-code 技能，語言格式以參考檔按需載入

- 新增 `skills/clean-code/SKILL.md`：把註釋拆成兩類分開講——「文件註釋（對外契約）」與「行內註釋（why not what）」；並含適用範圍與例外、可讀性規則、模塊化判斷、完成前自檢清單，且明寫「過度註釋＝噪音」的反例。
- 文件註釋格式**不寫死**：主檔只放「語言 → 慣例」分派表，細節拆到 `references/`（Swift-DocC、KDoc／Javadoc、JSDoc／TSDoc、PEP 257 docstring、rustdoc、godoc、C# XML），只載入當前語言那份。
- 未列入的語言訂出查找流程：專案既有風格優先 → 查該語言官方文件確認格式 → 用中性形式 → 提議補一份參考檔；不憑印象編造。
- `README.md` 技能表新增 clean-code 一列。

---
