# opencode-skills

opencode 技能集，用於改善 Kotlin Multiplatform 開發體驗。

## 技能列表

| 技能 | 說明 |
|------|------|
| **kotlin-multiplatform-workspace** | 限制搜尋範圍到專案根目錄，避免全硬碟掃描導致 CPU 滿載 |
| **translate-to-chinese** | 繁體中文（zh-TW）回覆翻譯 |

## 安裝

```bash
git clone https://github.com/TwhomeGH/opencode-skills.git
```

在 `opencode.json` 加入：

```json
{
  "skills": {
    "paths": ["/path/to/opencode-skills/skills"]
  }
}
```

詳細說明見 [docs/INSTALL.md](docs/INSTALL.md)。

## License

[MIT](LICENSE)
