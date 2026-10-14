# C# — XML documentation comments

使用 `///` 加上 XML 標籤；Visual Studio 與 Roslyn 會產生 IntelliSense 與 XML 文件檔。

```csharp
/// <summary>
/// 依識別碼取得使用者。
/// </summary>
/// <param name="id">使用者識別碼。</param>
/// <returns>找到的使用者；找不到時為 <c>null</c>。</returns>
/// <exception cref="HttpRequestException">API 回應失敗時擲回。</exception>
/// <example>
/// <code>
/// var user = await GetUserAsync("42");
/// </code>
/// </example>
public async Task<User?> GetUserAsync(string id)
{
    // ...
}
```

常用標籤：`<summary>`、`<param>`、`<returns>`、`<exception>`、`<remarks>`、`<example>`、`<code>`、`<seealso>`、`<see cref="..."/>`、`<inheritdoc/>`。

## 官方

- https://learn.microsoft.com/en-us/dotnet/csharp/language-reference/xmldoc/
