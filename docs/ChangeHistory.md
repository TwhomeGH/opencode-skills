# ChangeHistory

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
