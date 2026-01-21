---
# macos-file-summoner-etrh
title: Add Go linting to CI pipeline
status: todo
type: feature
priority: normal
created_at: 2026-01-21T12:17:49Z
updated_at: 2026-01-21T12:17:49Z
---

No linting configured. Code quality issues can slip through undetected.

## Solution
1. Create .golangci.yml with enabled linters (gofmt, vet, errcheck, staticcheck, etc.)
2. Add lint command to bonnie.toml
3. Add golangci-lint-action to CI workflow

## Files to create/modify
- .golangci.yml (new)
- bonnie.toml
- .github/workflows/go.yml