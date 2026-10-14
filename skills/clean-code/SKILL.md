---
name: clean-code
description: >-
  Use when writing, editing, reviewing, or refactoring source code in any language.
  Enforces doc comments for public APIs (Swift-DocC, JSDoc/TSDoc, Python docstrings,
  rustdoc, godoc, KDoc, Javadoc, C# XML), inline comments that explain why,
  parameter/return documentation, and readable formatting (logical grouping, blank
  lines, no monolithic blocks). Also covers when to extract or split code into shared
  modules. Triggers: 註釋, 可讀性, 參數說明, doc comment, JSDoc, Swift-DocC, docstring, modularize.
---

# Clean Code：註釋、可讀性與模塊化

撰寫、修改、審查或重構任何語言的原始碼時適用。目標是維持可讀性與可維護性——**不是**追求註釋數量。

## 適用範圍與例外

- **套用**：專案的原始碼（`.swift`、`.kt`、`.ts`、`.py`、`.rs`、`.go`、`.cs` 等）。
- **不套用**（除非使用者明確要求）：自動生成的程式碼、`vendor/`、`node_modules/`、minified 或 build 產物、一次性拋棄式腳本。
- **既有風格優先**：先看鄰近檔案的慣例（註釋語言、縮排、doc 格式），沿用專案既有形式，不要用本技能的預設去覆蓋它。
- **註釋語言**：沿用檔案既有語言；新檔案預設與專案主要註釋語言一致。

## 兩種註釋，規則不同

### 1. 文件註釋（doc comment）— 對外契約

描述「這個 API 是什麼、怎麼用」，供 IDE 提示與文件生成。

- **必須有**：public / exported API、套件或模組入口、複雜演算法、有非顯而易見副作用或錯誤條件的函式、公開類別與屬性。
- **不需要**：trivial 的私有 one-liner（如 `getName`、單純 getter / setter）。
- **必含**：參數、回傳、會拋出的錯誤（若語言慣例如此），以及必要的使用範例。格式依語言 → 見下方分派表。

### 2. 行內註釋（inline comment）— 解釋「為什麼」

- 寫 **why，不寫 what**。程式碼本身已說明做什麼；註釋補充「為何這樣做」——取捨、限制、外部規範、暫時性 workaround、非直覺的邊界條件。
- 標記待辦：`TODO:`、`FIXME:`、`HACK:`、`NOTE:`，並寫明原因與解除條件。
- **不要**：逐行翻譯程式碼、把已清楚的程式碼再講一遍、與程式碼脫節（改了程式卻沒改註釋）。
- **反例警告**：過度註釋與缺乏註釋一樣傷害可讀性。每行都註釋＝噪音。

## 語言分派表（doc comment 格式）

| 語言 | 慣例 | 參考檔 |
|------|------|--------|
| Swift | Swift-DocC（`///`） | [references/swift.md](references/swift.md) |
| Kotlin / Java | KDoc / Javadoc（`/** */`） | [references/kotlin-java.md](references/kotlin-java.md) |
| TypeScript / JavaScript | JSDoc / TSDoc（`/** */`） | [references/typescript-javascript.md](references/typescript-javascript.md) |
| Python | docstring（PEP 257；Google / NumPy / reST） | [references/python.md](references/python.md) |
| Rust | rustdoc（`///`、`//!`） | [references/rust.md](references/rust.md) |
| Go | godoc（`//`，以名稱開頭） | [references/go.md](references/go.md) |
| C# | XML doc comments（`/// <summary>`） | [references/csharp.md](references/csharp.md) |
| PowerShell | comment-based help（`<# .SYNOPSIS … #>`） | [references/windows-scripts.md](references/windows-scripts.md) |
| cmd / bat / VBScript | `REM`、`::`、`'`、`Rem`（無 doc 格式） | [references/windows-scripts.md](references/windows-scripts.md) |

> 只載入當前語言那一份參考檔，不要一次讀取全部。

### 未列入的語言

上表只涵蓋常用語言。遇到其他語言時，依序：

1. **專案既有風格優先**——先看同專案怎麼寫。
2. **查權威來源**——查找該語言的官方文件或標準（官方 style guide / 語言規格），確認其 doc comment 格式與被 IDE 辨識的寫法後再動手；**不要憑印象編造格式**。
3. **仍不確定**——用該語言最中性的註釋形式（通常就是一般區塊 / 行註釋），不要發明不存在的標籤。
4. 若這是會常用的語言，可提議補一份 `references/<lang>.md`，讓技能累積可重用的知識。

## 可讀性規則

- **邏輯分段**：不同邏輯區塊之間空一行；一段只做一件事。
- **一 statement 一行**：不要把多個運算擠在同一行（避免 `a=1;b=2` 這類寫法）。
- **拒絕巨型函式**：函式過長或同時做多件事時，抽成具名的小函式（見下節）。
- **早回傳 / guard clause**：先處理例外與邊界，減少深層巢狀。
- **命名**：名稱要表達意圖；避免 `data`、`tmp`、`x1` 這類無意義名稱。
- **控制行長**：過長的行依語言慣例換行。
- **一致性**：欄位、imports、括號風格等沿用專案既有形式（能交給 formatter / linter 更好）。

## 模塊化判斷

**何時抽出**：

- 同一段邏輯出現 **2 次以上**（DRY；但不為只用到一次的東西硬抽）。
- 一個函式 / 檔案同時承擔多個職責（單一職責）。
- 需要獨立測試，或被多處引用。
- 概念需要「統一管理」（例如：設定、常數、錯誤型別、API client）。

**抽到哪裡**：

- 先就近放進同一模組；被 2 個以上模組共用時，才提升到共用層（`shared/`、`common/`、`utils/`）。
- 統一管理的東西集中一處，不要散落各檔重複定義。
- 抽出後**不留死碼**：移除被取代的舊實作。

## 完成前自檢

- [ ] 新增 / 修改的 public API 有 doc comment，且含參數與回傳說明？
- [ ] 註釋解釋意圖（why），且與程式碼一致？
- [ ] 邏輯區塊之間有分段、沒有擠成一坨？
- [ ] 沒有可抽出的重複邏輯？抽出後舊碼已刪除？
- [ ] 沿用專案既有風格與註釋語言？
- [ ] 沒有對 trivial 程式碼過度註釋？

## 官方參考

- Swift：[Swift-DocC](https://www.swift.org/documentation/docc/)
- Kotlin：[KDoc](https://kotlinlang.org/docs/kotlin-doc.html)
- Java：[How to Write Doc Comments (Javadoc)](https://www.oracle.com/technetwork/java/javase/documentation/index-137868.html)
- TypeScript / JS：[JSDoc](https://jsdoc.app/)、[TSDoc](https://tsdoc.org/)
- Python：[PEP 257](https://peps.python.org/pep-0257/)、[Google Python Style Guide](https://google.github.io/styleguide/pyguide.html#38-comments-and-docstrings)
- Rust：[How to write documentation (rustdoc)](https://doc.rust-lang.org/rustdoc/how-to-write-documentation.html)
- Go：[Go Doc Comments](https://go.dev/doc/comment)
- C#：[XML documentation comments](https://learn.microsoft.com/en-us/dotnet/csharp/language-reference/xmldoc/)
- PowerShell：[about_Comment_Based_Help](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_comment_based_help)
- cmd：[rem](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/rem)
