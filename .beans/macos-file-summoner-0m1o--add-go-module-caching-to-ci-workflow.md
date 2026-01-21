---
# macos-file-summoner-0m1o
title: Add Go module caching to CI workflow
status: todo
type: task
priority: low
created_at: 2026-01-21T12:17:53Z
updated_at: 2026-01-21T12:17:53Z
---

CI builds don't cache Go modules, causing slower builds.

## Solution
Add caching step to .github/workflows/go.yml:
```yaml
- name: Cache Go modules
  uses: actions/cache@v4
  with:
    path: ~/go/pkg/mod
    key: ${{ runner.os }}-go-${{ hashFiles('**/go.sum') }}
    restore-keys: |
      ${{ runner.os }}-go-
```

## Files
- .github/workflows/go.yml