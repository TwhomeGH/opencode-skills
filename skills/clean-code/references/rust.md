# Rust — rustdoc

- `///` 文件化項目；`//!` 文件化所在的模組 / crate（寫在檔案開頭）。
- 支援 Markdown。`# Examples` 內的程式碼區塊會**被當作測試執行**（doc test）。
- 用 `[`Foo`]` 做 intra-doc 連結。

```rust
/// 將兩個整數相加。
///
/// # Arguments
///
/// * `a` - 左運算元。
/// * `b` - 右運算元。
///
/// # Returns
///
/// `a` 與 `b` 的和。
///
/// # Panics
///
/// 若結果溢位且在 debug 模式。
///
/// # Examples
///
/// ```
/// assert_eq!(add(2, 3), 5);
/// ```
pub fn add(a: i32, b: i32) -> i32 {
    a + b
}
```

常用段落標題：`# Examples`、`# Panics`、`# Errors`、`# Safety`。

## 官方

- https://doc.rust-lang.org/rustdoc/how-to-write-documentation.html
