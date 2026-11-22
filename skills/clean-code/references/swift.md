# Swift — Swift-DocC

- 使用 `///`（每行一個）。類別、函式、屬性、型別皆可。
- 支援 Markdown。Xcode 會顯示於 Quick Help，並用於 DocC 文件。

## 格式

```swift
/// 回傳兩整數相加的結果，使用飽和運算避免溢位。
///
/// - Parameters:
///   - a: 左運算元。
///   - b: 右運算元。
/// - Returns: `a` 與 `b` 的和，已做飽和處理。
/// - Throws: `MathError.overflow` 當結果超出 `Int` 範圍。
/// - Note: 純函式，無副作用。
func add(_ a: Int, _ b: Int) throws -> Int
```

- 單一參數可寫 `- Parameter a: ...`。
- 常用標記：`- Parameter(s):`、`- Returns:`、`- Throws:`、`- Note:`、`- Warning:`、`- Important:`、`- Tip:`、`- SeeAlso:`、`- Complexity:`。
- 型別與其他符號用反引號：`` `Int` ``；跨符號連結用 `` ``Symbol`` `` 或 `- ``Name```。
- 型別 / 模組層級說明可用 `///` 或專屬 DocC 文章。

## 官方

- [Swift-DocC](https://www.swift.org/documentation/docc/)

## 單元測試的名稱與說明

先辨識 Swift Testing 或 XCTest，兩者的命名機制不同。共通規則見 [測試命名與報告](./testing.md)。

Swift Testing 的 `@Test` 第一個字串參數是顯示名稱，未指定時由函數名衍生；`///` 是原始碼說明，不會自動出現在測試清單。

```swift
// 片段：測試內容與 fixture 依專案補入。
@Test("來源 PTS 無效時保持未知 — invalidPTSRemainUnknown")
func invalidPTSRemainUnknown() throws {
    // 在此建立明確無效的 PTS，驗證仍為未知且沒有套用到達時間。
}
```

上例適用於 runner 只顯示標題、而專案要求「內容＋函數名」的情況。若 reporter 已另列函數 ID，標題僅保留「來源 PTS 無效時保持未知」即可；不要為同時顯示兩者而假設框架會自動附上函數名。

參數化測試使用既有 `@Test("描述", arguments: …)` 形式，摘要保留各案例參數，不能只列同一標題後去重。需要註釋時說明回歸原因或 fixture 前提，不重複標題。XCTest 維持 `test…` 方法命名與必要說明，不套用 `@Test`。

- [Swift Testing 定義測試與自訂名稱](https://docs.swift.org/latest/documentation/testing/definingtests/)
