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
