---
# macos-file-summoner-a3ng
title: Replace panic() calls with graceful error handling
status: in-progress
type: bug
priority: high
created_at: 2026-01-21T12:16:59Z
updated_at: 2026-01-21T20:20:41Z
---

main.go uses panic() for recoverable errors at lines 28, 35, 67. This crashes the app with a stack trace instead of showing user-friendly error dialogs.

## Problem
- Line 28: Panic on Finder path retrieval failure
- Line 35: Panic on dialog error
- Line 67: Panic on file creation failure

## Solution
Replace panic() with mack.Alert() dialogs:
```go
if err != nil {
    mack.Alert("Error", "Failed to get Finder path: " + err.Error())
    os.Exit(1)
}
```

## Files
- main.go:28, 35, 67