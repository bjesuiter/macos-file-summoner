---
# macos-file-summoner-tcg9
title: 'Analysis: Document or remove Legacy string workaround'
status: in-progress
type: task
priority: normal
created_at: 2026-01-21T12:18:13Z
updated_at: 2026-01-21T20:23:01Z
---

ANALYSIS NEEDED: The 'Legacy' string split workaround for macOS Sequoia is fragile.

## Current Code (line 42)
```go
dialogResult := strings.Split(response.Text, "Legacy")
```

## Concerns
1. Hardcoded string may break on future macOS versions
2. No version detection - applies to all macOS versions
3. No documentation explaining the workaround
4. What if a user's filename contains 'Legacy'?

## Options to Evaluate
1. Add macOS version detection and only apply if needed
2. Make the workaround string configurable via env var
3. Check if mack library has been updated to fix this
4. At minimum: add detailed code comment

## Files
- main.go:42