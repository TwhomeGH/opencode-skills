---
name: kotlin-multiplatform-workspace
description: >-
  ONLY for KMP projects at C:\Users\Co\animeko or C:\Users\Co\mediamp.
  Scopes grep/glob/rg to the project root instead of home directory.
  Triggers: animeko, mediamp, Kotlin, KMP, Gradle, Android.
---

# Kotlin Multiplatform Workspace

## Project roots

| Project | Path |
|---------|------|
| animeko | `C:\Users\Co\animeko` |
| mediamp | `C:\Users\Co\mediamp` |

## Search guidelines

- **grep/glob**: always set `path` to the project root
- **rg in shell**: cd to project root first, NOT `C:\Users\Co`
- Never search under `C:\Users\Co` unless target is explicitly there
- For Kotlin symbol lookup: `grep` with `include: "*.kt"` and project root path
- For Gradle deps: check `build.gradle.kts` / `settings.gradle.kts`
