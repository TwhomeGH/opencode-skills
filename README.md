# opencode-skills

opencode 技能集，用於改善 Kotlin Multiplatform 開發體驗。

## 技能列表

| 技能 | 說明 |
| ------ | ------ |
| **kotlin-multiplatform-workspace** | 限制搜尋範圍到專案根目錄，避免全硬碟掃描導致 CPU 滿載 |
| **translate-to-chinese** | 繁體中文（zh-TW）回覆翻譯 |
| **filter-html-noise** | 預設啟用的 HTML 雜訊過濾技能。分析 HTML 時自動忽略無語義的視覺雜訊，保留業務邏輯相關內容 |
| **clean-code** | 撰寫 / 修改原始碼時的註釋、可讀性與模塊化準則。文件註釋依語言格式（Swift-DocC、JSDoc、docstring、PowerShell comment-based help…），並含未列入語言的查找流程 |
| **windows-script-pitfalls** | Windows 腳本與編碼地雷。UTF-8/ANSI（cp950）編碼、BOM 需求、chcp、PowerShell 執行原則、引號轉義，以及 Python locale/.pth 陷阱 |
| **safe-file-cleanup** | 準備刪除 / 清理本機檔案或資料夾時使用。依 Windows / macOS / Linux 送入系統回收站；無回收站時先確認永久刪除範圍 |
| **file-fix** | 寫入文件遇到問題時使用。退回指導使用者替換指定段落並說明前後差異，避免只為改檔而新建臨時腳本 |
| **swift-test** | Swift 測試。非 macOS 環境預設跳過；已安裝 Swift 編譯器時可編譯檢查與執行 `swift test` |

## 技能撰寫原則

技能彼此**獨立載入**，agent 也無法得知使用者裝了哪些同儕技能。因此：

1. **自足（self-contained）**：技能不得假設其他技能存在；跨技能引用只能是「額外參考」，絕不能是唯一資訊來源。
2. **需要同儕技能的知識時，把最關鍵的一兩條直接內聯**，而不是指向它——否則對方沒安裝時就懸空。
3. 引用外部資源用**官方 URL**，不要指向可能不存在的本地技能名。
4. 每個技能在 `description` 自述觸發條件（因為它們是各自獨立被載入的）。
5. 語言慣例等細節用 `references/<lang>.md` 拆分並**按需載入**，不要一次讀取全部。

## 安裝

```bash
git clone https://github.com/TwhomeGH/opencode-skills.git
```

在 `opencode.json`（**專案目錄**或 `~/.config/opencode/`）加入：

```json
{
  "skills": {
    "paths": ["/path/to/opencode-skills/skills"]
  }
}
```

詳細說明見 [docs/INSTALL.md](docs/INSTALL.md)，包含各平台路徑範例。

## 完整設定範例

搭配本技能集的 `~/.config/opencode/opencode.jsonc` 完整範例：

```jsonc
{
  "$schema": "https://opencode.ai/config.json",

  "skills": {
    "paths": ["F:/opencode-skills/skills"]
  },

  "plugin": ["opencode-lmstudio"],

  "provider": {
    "lmstudio": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "LM Studio",
      "options": {
        "baseURL": "http://192.168.0.102:1234/v1",
        "apiKey": "sk-lm-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
      }
    }
  },

  "references": {
    "playwright-mcp": {
      "repository": "microsoft/playwright-mcp",
      "description": "Use for Playwright MCP browser automation server configuration and usage"
    },
    "mcp-memory": {
      "repository": "modelcontextprotocol/servers",
      "description": "Use for MCP memory/knowledge graph server configuration"
    },
    "mcp-filesystem": {
      "repository": "modelcontextprotocol/servers",
      "description": "Use for MCP filesystem server for secure file operations"
    },
    "mcp-git": {
      "repository": "modelcontextprotocol/servers",
      "description": "Use for MCP git server for repository operations"
    },
    "mcp-github": {
      "repository": "github/github-mcp-server",
      "description": "Use for GitHub MCP server for PR, issue, and repo management"
    },
    "mcp-fetch": {
      "repository": "modelcontextprotocol/servers",
      "description": "Use for MCP fetch server for web content retrieval"
    },
    "mcp-sequential-thinking": {
      "repository": "modelcontextprotocol/servers",
      "description": "Use for MCP sequential thinking server for structured reasoning"
    }
  },

  "mcp": {
    "playwright": {
      "type": "local",
      "command": ["npx", "-y", "@playwright/mcp"],
      "enabled": true
    },
    "memory": {
      "type": "local",
      "command": ["npx", "-y", "@modelcontextprotocol/server-memory"],
      "enabled": true
    },
    "filesystem": {
      "type": "local",
      "command": ["npx", "-y", "@modelcontextprotocol/server-filesystem", "F:/opencode-skills"],
      "enabled": false
    },
    "git": {
      "type": "local",
      "command": ["npx", "-y", "mcp-server-git", "--repository", "."],
      "enabled": false
    },
    "github": {
      "type": "local",
      "command": ["npx", "-y", "@github/github-mcp-server"],
      "enabled": false,
      "env": {
        "GITHUB_TOKEN": "ghp_xxxxxxxxxxxxxxxxxxxx"
      }
    },
    "fetch": {
      "type": "local",
      "command": ["uvx", "mcp-server-fetch"],
      "enabled": false
    },
    "sequential-thinking": {
      "type": "local",
      "command": ["npx", "-y", "@modelcontextprotocol/server-sequential-thinking"],
      "enabled": false
    }
  }
}
```

> `model` 與 `small_model` 未指定，由 opencode 啟動時選擇或手動切換。

## License

[MIT](LICENSE)
