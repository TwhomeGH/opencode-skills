# Go — godoc

- 註釋直接寫在宣告上方，**以被宣告的名稱開頭**。
- 套件註釋 `// Package foo ...` 放在 `package foo` 上方（或獨立 `doc.go`）。
- 沒有 `@param` 標籤；參數與回傳寫在散文裡。連結用 `[Name]`。

```go
// Add returns the sum of a and b.
func Add(a, b int) int {
	return a + b
}
```

```go
// Package mathx provides small numeric helpers.
//
// It intentionally avoids external dependencies.
package mathx
```

- 空行分段；縮排代表程式碼區塊；支援清單與標題（Go 1.19+ 的 doc comment 格式）。

## 官方

- [Go Doc Comments](https://go.dev/doc/comment)
