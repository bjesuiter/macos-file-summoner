---
# macos-file-summoner-eg8h
title: Add set -euo pipefail to all shell scripts
status: todo
type: bug
priority: high
created_at: 2026-01-21T12:17:07Z
updated_at: 2026-01-21T12:17:07Z
---

Shell scripts lack proper error handling. Missing 'set -e' means scripts continue after errors.

## Problem
- 01-build.sh: No error handling, rm -rf without verification
- 02-sign.sh: Has some error handling but incomplete
- 03-notarize.sh: Uses dangerous eval()
- 04-check-app-signature.sh: No error handling
- 05-package-dmg.sh: No error handling

## Solution
Add to top of ALL scripts:
```bash
#!/usr/bin/env bash
set -euo pipefail
trap 'echo "Script failed at line $LINENO"; exit 1' ERR
```

## Files
- scripts/01-build.sh
- scripts/02-sign.sh
- scripts/03-notarize.sh
- scripts/04-check-app-signature.sh
- scripts/05-package-dmg.sh
- scripts/helpers/fix-execute-flag.sh