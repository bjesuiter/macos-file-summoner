---
# macos-file-summoner-wgb6
title: 'Analysis: Re-enable notarization in CI workflow'
status: completed
type: task
priority: normal
created_at: 2026-01-21T12:18:23Z
updated_at: 2026-01-21T20:24:07Z
---

ANALYSIS NEEDED: Notarization is commented out in CI workflow. App may not work for all users.

## Current State
Lines 91-97 in go.yml are commented out:
```yaml
# - name: Notarize App with apples notarytool
#   run: ./scripts/03-notarize-app.sh
```

## Questions
1. Is Apple Developer subscription active?
2. Are the required secrets configured in GitHub?
3. Does the notarize script reference the correct script name?
4. Is notarization required for the current distribution method?

## If Re-enabling
1. Verify secrets are set: APPLE_DEVELOPER_ID_NAME, APPLE_ACCOUNT_APP_PASSWORD, APPLE_TEAM_ID
2. Fix script reference (03-notarize-app.sh → 03-notarize.sh)
3. Test notarization flow

## Files
- .github/workflows/go.yml:91-97