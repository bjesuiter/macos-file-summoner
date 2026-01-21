---
# macos-file-summoner-gpf2
title: Add filename input validation and sanitization
status: in-progress
type: bug
priority: high
created_at: 2026-01-21T12:17:03Z
updated_at: 2026-01-21T20:20:01Z
---

SECURITY: User input is passed directly to exec.Command() without validation. Could allow path traversal or command injection.

## Problem
- Lines 53, 56, 59: No validation on filename from dialog
- Could contain path separators (../), shell metacharacters, or null bytes

## Solution
1. Validate filename against allowed characters
2. Prevent path traversal with filepath.Base()
3. Check for empty filename after trimming

```go
if strings.Contains(newFilename, "/") || strings.Contains(newFilename, "..") {
    mack.Alert("Error", "Filename cannot contain path separators")
    os.Exit(1)
}
newFilename = filepath.Base(newFilename)
```

## Files
- main.go:53, 56, 59, 65