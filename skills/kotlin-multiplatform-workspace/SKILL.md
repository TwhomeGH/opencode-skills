---
name: kotlin-multiplatform-workspace
description: >-
  For Kotlin Multiplatform (KMP) workspaces such as animeko or mediamp: detect the
  project root from the session cwd or git root, then scope grep/glob/rg to it
  instead of the home directory. Triggers: animeko, mediamp, Kotlin, KMP, Gradle, Android.
---

# Kotlin Multiplatform Workspace

## 判定專案根目錄

不要假設固定路徑（也不要寫死任何人的家目錄）。依序判斷：

1. 目前 session 的專案根目錄：`git rev-parse --show-toplevel`，或 agent 提供的 cwd
2. cwd 不是 KMP 專案時，往上找含 `settings.gradle.kts` 或 `build.gradle.kts` 的目錄
3. 兩者都沒有 → 這個 skill 不適用，停止套用；不要改去掃描家目錄

KMP 判定：`settings.gradle.kts` 或模組的 `build.gradle.kts` 含 `kotlin("multiplatform")`
或 `org.jetbrains.kotlin.multiplatform`。

使用者提到 animeko／mediamp 但 cwd 不在專案內時，先問一次專案路徑，或請使用者切到該目錄；
不要用硬編碼的家目錄路徑去猜。

## 搜尋規則

- **grep/glob**：`path` 一律設為上面找到的專案根目錄
- **shell 的 rg**：先 cd 到專案根目錄，不要從家目錄開始
- 不要掃描 `%USERPROFILE%`／`~`；除非使用者明確指定
- Kotlin 符號查詢：`grep` 搭配 `include: "*.kt"` 與專案根目錄
- Gradle 依賴：看 `build.gradle.kts`／`settings.gradle.kts`
