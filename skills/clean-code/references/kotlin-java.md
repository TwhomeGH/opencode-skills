# Kotlin / Java — KDoc / Javadoc

兩者都使用 `/** ... */`。IntelliJ / Android Studio 會顯示，並供 Dokka / javadoc 產生文件。

## Kotlin（KDoc）

KDoc 使用 **Markdown**（不是 HTML）。官方建議：**參數與回傳的說明盡量直接寫進正文並用連結提及，只有冗長描述才用 `@param` / `@return`。**

```kotlin
/**
 * 計算兩數相乘的結果。
 *
 * 使用 [BigDecimal] 避免浮點誤差。
 *
 * @param a 左運算元。
 * @param b 右運算元。
 * @return 乘積。
 * @throws ArithmeticException 若結果無法表示。
 * @see round
 */
fun multiply(a: BigDecimal, b: BigDecimal): BigDecimal
```

標籤：`@param`、`@return`、`@throws` / `@exception`、`@see`、`@sample`、`@author`、`@since`、`@suppress`。

## Java（Javadoc）

- 第一句是 **summary sentence**（以句點結尾），會被抽成摘要。
- 支援 HTML 與 `{@code ...}`、`{@link ...}`。

```java
/**
 * 計算兩數相乘的結果。
 *
 * @param a 左運算元，不可為 {@code null}。
 * @param b 右運算元，不可為 {@code null}。
 * @return 乘積。
 * @throws ArithmeticException 若結果無法表示。
 * @since 1.2
 */
public BigDecimal multiply(BigDecimal a, BigDecimal b)
```

## 官方

- [Kotlin KDoc](https://kotlinlang.org/docs/kotlin-doc.html)
- [Java Javadoc](https://www.oracle.com/technetwork/java/javase/documentation/index-137868.html)
