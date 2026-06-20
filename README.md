# opencode-skills

opencode 技能集，用於改善 Kotlin Multiplatform 開發體驗。

## 技能列表

| 技能 | 說明 |
|------|------|
| **kotlin-multiplatform-workspace** | 限制搜尋範圍到專案根目錄，避免全硬碟掃描導致 CPU 滿載 |
| **translate-to-chinese** | 繁體中文（zh-TW）回覆翻譯 |
| **filter-html-noise** | 預設啟用的 HTML 雜訊過濾技能。分析 HTML 時自動忽略無語義的視覺雜訊，保留業務邏輯相關內容 |
| **context-cleanup** | 預設啟用的 token 使用效率技能。控制 output tokens、避免重複敘述、減少不必要的工具呼叫 |

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
      "command": ["npx", "-y", "mcp-server-fetch"],
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
