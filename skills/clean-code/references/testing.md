# 測試命名、註釋與執行報告

只在新增／修改測試或測試摘要時套用，依實際框架與版本確認能力。不要求為了命名新增測試、改寫所有舊測試或更換 runner。

## 三種資訊各自負責什麼

- **顯示描述**：以主要使用語言表達條件與預期行為，例如「來源 PTS 無效時保持未知，不以到達時間替代」。
- **測試識別**：保留 Suite／函數名或框架 test ID，供搜尋、篩選重跑與定位；採既有識別符慣例。
- **註釋**：說明為何需要這個案例、fixture 的重要前提、非直覺斷言與門檻依據。名稱足夠時不用重複註釋；框架註冊的測試不因 public／exported 就一律堆上 API 文件模板。

CI 期望呈現（不是所有框架原生輸出格式）：

```text
來源 PTS 無效時保持未知 — VideoFrameTraceTests.invalidPTSRemainUnknown [kind=invalid]
```

若 reporter 已提供完整 ID，不再在描述中重複函數名。若只呈現描述而難以定位，可以在標題加入穩定函數名；函數更名時同步更新。沒有具名函數的 test closure 使用 suite／檔案位置定位，不捏造函數名。

## 框架選擇

| 語言／框架 | 優先方式 | 注意事項 |
| --- | --- | --- |
| Swift Testing | `@Test("行為描述")`，保留具名函數；可用 `@Suite` 描述分組 | `///` 不等於顯示名稱；參數化測試還須保留參數／案例資訊。詳見 [Swift](./swift.md) |
| Swift XCTest | 具體的 `test…` 方法名，配合必要註釋與失敗訊息 | 不支援 Swift Testing 的 `@Test`；不要直接混用或為顯示名稱遷移框架 |
| Python pytest | 具體的 `test_…` 名稱；參數化使用 `ids`／`pytest.param(id=…)` | docstring 不保證成為標準輸出標題；用 `--collect-only`、詳細模式核對 node ID；中文案例是否跳脫依設定驗證，不貿然關閉跳脫 |
| Python unittest | `test_…` 方法＋必要 docstring；參數變體可用 `subTest` | docstring 顯示取決於 runner 的 descriptions／verbosity；不能據此保證所有 CI 都顯示說明 |
| JavaScript／TypeScript 測試框架 | 沿用框架 `test`／`it` 的描述字串、suite 分組及參數案例名稱 | 常見為匿名 closure；以 test ID／檔案位置補定位，不為格式額外包一個具名函數 |
| Java／Kotlin JUnit Jupiter | `@DisplayName`；參數化可配置 `@ParameterizedTest(name=…)` | 依版本確認 placeholders；描述與方法 ID 是否同時保留取決於 IDE／reporter，不套用至其他 JUnit 世代 |
| Go testing | `Test…` 函數＋`t.Run("條件與預期", …)` 子案例 | 詳細模式可辨識父測試／子案例；空白等字元可能經名稱正規化，保留實際重跑路徑 |
| Rust 標準測試 | 描述清楚的 `#[test]` 函數名＋必要註釋 | 不假造通用 display-name attribute；需要自然語言摘要時使用現有報告能力 |
| C# | 先辨識 xUnit／NUnit／MSTest，再查該版本的顯示名稱與案例命名 API | 三者的 attribute 不通用；註釋不一定出現在測試總管 |
| PowerShell Pester | `Describe`／`Context`／`It` 的描述與案例資料 | 依版本確認參數展開與輸出詳細程度，不把腳本函數 help 當測試名稱 |

未列框架：先看專案已有測試與官方文件，不憑語言名稱推定 runner 的行為。

## 註釋應補充的內容

- fixture 的有效性：若測「有效 PTS 傳遞」，資料必須真的帶有效 PTS；測無效值則明確驗證未知，而非比較 NaN 相等。
- 時間相關測試：門檻、容許誤差與等待上限的理由；避免把模擬器速度當成產品行為。
- 回歸測試：原來錯在哪個情境、斷言防止哪項退化；不只描述目前實作細節。
- 驗證邊界：單元測試不代表網路送達、實機穩定性或內容同步通過。

## 核對報告

使用框架支援的列出／收集模式或小範圍測試，確認中文、參數、多行 issue 及來源定位能保留。
只執行本次必要範圍；僅語法檢查不能宣稱 runner 顯示已驗證。

自製 CI 摘要優先讀結構化結果中的 display name、test ID、檔案／行號。不得把顯示名稱當唯一 key；參數案例和同名跨 suite 測試不能被合併。只能解析文字時，保留原始失敗區塊及未知欄位，不以簡單拆空白猜函數名，也不把整場結果重算成額外測試。

## 官方參考

- [Swift Testing 顯示名稱](https://docs.swift.org/latest/documentation/testing/definingtests/)
- [pytest 參數案例 ID](https://docs.pytest.org/en/stable/example/parametrize.html)
- [unittest TestCase.shortDescription](https://docs.python.org/3/library/unittest.html#unittest.TestCase.shortDescription)
- [JUnit Jupiter 使用指南](https://docs.junit.org/5.12.1/user-guide/index.html)
- [Go 子測試](https://go.dev/blog/subtests)

先確認專案版本；以上參考不是要求升級框架。
