---
# macos-file-summoner-f1eo
title: Clean up duplicate entries in go.sum
status: todo
type: task
priority: low
created_at: 2026-01-21T12:18:25Z
updated_at: 2026-01-21T12:18:25Z
---

go.sum contains duplicate mack library versions.

## Problem
go.sum shows TWO versions of mack:
- v0.0.0-20200226161639 (old, unused)
- v0.0.0-20220307193339 (current)

## Solution
Run:
```bash
go mod tidy
```

This will remove unused dependency entries.

## Files
- go.sum