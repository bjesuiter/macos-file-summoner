---
# macos-file-summoner-vw7r
title: Refactor complex switch statement in main.go
status: todo
type: task
priority: low
created_at: 2026-01-21T12:17:37Z
updated_at: 2026-01-21T12:17:37Z
---

17-line switch statement (lines 47-63) with repetitive cases violates DRY principle.

## Problem
Cases 1, 2, 3 all do similar things:
```go
case 1:
    log.Printf("Filename provided: %s", dialogResult[0])
    newFilename = strings.TrimSpace(dialogResult[0])
case 2:
    log.Printf("Filename provided: %s", dialogResult[1])
    newFilename = strings.TrimSpace(dialogResult[1])
case 3:
    log.Printf("Filename provided: %s", dialogResult[2])
    newFilename = strings.TrimSpace(dialogResult[2])
```

## Solution
```go
if len(dialogResult) >= 1 && len(dialogResult) <= 3 {
    idx := len(dialogResult) - 1
    newFilename = strings.TrimSpace(dialogResult[idx])
    log.Printf("Filename provided: %s", newFilename)
} else if len(dialogResult) == 0 {
    log.Printf("No filename provided")
    os.Exit(1)
} else {
    log.Printf("Unknown dialog result format")
    os.Exit(1)
}
```

## Files
- main.go:47-63