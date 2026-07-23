# Send Pipeline 最佳化總結

## 修改檔案

| 檔案 | 變更內容 |
|------|----------|
| `RTMPHaishinKit/Sources/RTMP/RTMPChunk.swift` | `putMessage` 回傳型別從 `AnyIterator<Data>` 改為 `Data`；預先計算總大小，連續寫入所有 chunk，只做一次 `subdata` |
| `RTMPHaishinKit/Sources/RTMP/RTMPConnection.swift` | `doOutput` 直接 yield `Data` 而非 `[Data]`；`startOutputConsumer` AsyncStream 型別從 `[Data]` 改為 `Data` |
| `RTMPHaishinKit/Sources/RTMP/RTMPSocket.swift` | 移除不再使用的 `send(_ chunks:)` 與 `send(_ iterator:)` 方法 |
| `Docs/RTMP_FIXES.md` | 新增 7.3 節詳細記錄最佳化內容 |
| `Docs/CHANGELOG_RTMP_SOCKET.md` | 新增第 15 項 |

## 改善幅度

- 每次 send 減少 N 次 chunk Data 配置（原每 chunk 一次 `subdata`）
- 消除一次 `[Data]` 陣列配置
- 消除一次 socket 層 merge 配置
- 大型 keyframe（數十個 chunk）受益最顯著
