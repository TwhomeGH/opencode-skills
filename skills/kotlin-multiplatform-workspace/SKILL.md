---
name: kotlin-multiplatform-workspace
description: >-
  Use ONLY when working on the Kotlin Multiplatform projects at
  C:\Users\Co\animeko or C:\Users\Co\mediamp.
  Triggers: animeko, mediamp, Kotlin, Gradle, KMP, multiplatform,
  ani(me.ko)?, Android, WebVideoMatcher, MediaSource.
  When active, instructs the model to scope all ripgrep/glob/grep
  searches to the relevant project root instead of the home directory
  to avoid excessive CPU usage.
---

# Kotlin Multiplatform Workspace

## Project roots

| Project | Path |
|---------|------|
| animeko | `C:\Users\Co\animeko` |
| mediamp | `C:\Users\Co\mediamp` |

Search and file operations MUST use the full project-root path to
avoid scanning `C:\Users\Co\` (which contains 30+ top-level dirs).

## Search guidelines

- **grep** / **glob**: always set `path` to the project root, e.g.
  `C:\Users\Co\animeko` or `C:\Users\Co\mediamp`.
- **ripgrep (rg)**: when doing shell-based rg, `cd` to the project
  root first, NOT `C:\Users\Co`.
- Never search under the home directory `C:\Users\Co` unless the
  target is explicitly known to be there.

## Project structure: animeko

```
animeko/
├── app/                   # 主應用模組
│   ├── shared/            # 跨平台分享程式碼
│   │   ├── app-data/      # 資料層
│   │   ├── ui-settings/   # 設定 UI
│   │   └── ui-torrent/    # BT UI
│   └── desktop/           # Desktop 入口
├── datasource/            # 資料源
│   └── api/               # 資料源 API (contracts)
│       └── src/commonMain/kotlin/matcher/
│           └── WebVideoMatcher.kt   # SPI interface
├── client/                # 用戶端
├── danmaku/               # 彈幕
├── torrent/               # BT
└── utils/                 # 工具
```

## Project structure: mediamp

```
mediamp/
├── mediamp-api/           # API contracts
├── mediamp-exoplayer/     # Android ExoPlayer 實作
├── mediamp-ffmpeg/        # FFmpeg 實作
├── mediamp-vlc/           # VLC 實作
├── mediamp-mpv/           # mpv 實作
├── mediamp-compose/       # Compose Multiplatform UI
├── mediamp-web-preview/   # Web 預覽
├── mediamp-source-ktxio/  # KtxIO source
└── mediamp-test/          # 測試工具
```

## Java/Kotlin search tips

- Use IntelliJ IDEA's `.idea/` module indexes when possible instead
  of raw `rg`.
- For symbol lookup (class, interface, function), use `grep` with
  `include: "*.kt"` and `path` set to the project root.
- For Gradle dependencies, check `build.gradle.kts` and
  `settings.gradle.kts`.
