---
# macos-file-summoner-exzh
title: Fix broken script reference in CI workflow
status: todo
type: bug
priority: critical
created_at: 2026-01-21T12:17:15Z
updated_at: 2026-01-21T12:17:15Z
---

GitHub Actions workflow references non-existent script, causing CI failures.

## Problem
- go.yml line 86: References ./scripts/02-sign-app.sh but file is ./scripts/02-sign.sh
- go.yml line 112: References ./scripts/fix-execute-flag.sh but file is at ./scripts/helpers/fix-execute-flag.sh

## Solution
Update references in .github/workflows/go.yml:
- Line 86: ./scripts/02-sign-app.sh → ./scripts/02-sign.sh
- Line 112: ./scripts/fix-execute-flag.sh → ./scripts/helpers/fix-execute-flag.sh

## Files
- .github/workflows/go.yml:86, 112