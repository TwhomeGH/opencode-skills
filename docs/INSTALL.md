# opencode-skills 安裝說明

## 下載

```bash
git clone https://github.com/TwhomeGH/opencode-skills.git
```

## 設定 opencode

在 `opencode.json` 或 `opencode.jsonc` 中加入 `skills.paths`：

```json
{
  "$schema": "https://opencode.ai/config.json",
  "skills": {
    "paths": [
      "/path/to/opencode-skills/skills"
    ]
  }
}
```

### Windows 範例

```json
{
  "$schema": "https://opencode.ai/config.json",
  "skills": {
    "paths": [
      "C:\\Users\\你的帳號\\opencode-skills\\skills"
    ]
  }
}
```

### macOS / Linux 範例

```json
{
  "skills": {
    "paths": [
      "/home/你的帳號/opencode-skills/skills"
    ]
  }
}
```

## 啟用

重新啟動 opencode，技能就會自動載入。

## 更新技能

```bash
cd /path/to/opencode-skills
git pull
```

重啟 opencode 即可套用最新版本。
