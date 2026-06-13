# opencode-skills 安裝說明

## 下載

```bash
git clone https://github.com/TwhomeGH/opencode-skills.git
```

## 設定 opencode

opencode 會從以下位置（由近到遠）載入設定並合併：

| 範圍 | 路徑 |
|------|------|
| **專案** | `./opencode.json` 或 `./opencode.jsonc`（與專案程式碼同目錄） |
| **全域** | `~/.config/opencode/opencode.json` 或 `~/.config/opencode/opencode.jsonc` |

一般建議放在**專案目錄**下，跟著 Git 走；若是個人偏好，則放全域。

在選定的位置加入 `skills.paths`：

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

**專案級**（與 `build.gradle.kts` 同層）：

```
C:\Users\你的帳號\animeko\
├── opencode.json          ← 放這裡
├── build.gradle.kts
├── settings.gradle.kts
└── ...
```

**全域級**：

```
C:\Users\你的帳號\.config\opencode\
├── opencode.jsonc          ← 或放這裡
└── skills\
```

內容：

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
  "$schema": "https://opencode.ai/config.json",
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
