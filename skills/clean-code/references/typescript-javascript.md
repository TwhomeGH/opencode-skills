# TypeScript / JavaScript — JSDoc / TSDoc

使用 `/** ... */`，VS Code 與大多數編輯器會在 hover 顯示。TypeScript 專案建議 **TSDoc**（**不收 `{type}`**，型別已在簽章中）。

```ts
/**
 * 依 id 取得使用者。
 *
 * @param id - 使用者識別碼。
 * @returns 找到的使用者，找不到時為 `undefined`。
 * @throws 當 API 回應非 2xx 時丟出 `HttpError`。
 * @example
 * const user = await getUser("42");
 */
async function getUser(id: string): Promise<User | undefined>
```

- JSDoc 舊式寫法含型別：`@param {string} id - ...`；TS 中省略型別，寫成 `@param id - ...`。
- 常用標籤：`@param`、`@returns`、`@throws`、`@example`、`@deprecated`、`@see`、`@typeParam`、`@template`。

## 官方

- [JSDoc](https://jsdoc.app/)
- [TSDoc](https://tsdoc.org/)
