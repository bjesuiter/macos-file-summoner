---
# macos-file-summoner-jwj3
title: Update deprecated GitHub Actions
status: completed
type: task
priority: normal
created_at: 2026-01-21T12:17:48Z
updated_at: 2026-01-21T20:22:48Z
---

GitHub Actions workflow uses deprecated actions that will eventually break.

## Problem
- Line 236: actions/create-release@v1.1.4 is deprecated
- Line 250: actions/upload-release-asset@v1 is deprecated

## Solution
Replace with softprops/action-gh-release@v1:
```yaml
- name: Create and Upload Release
  uses: softprops/action-gh-release@v1
  with:
    files: ${{ env.MACOS_DMG_ARTIFACT_ID }}/${{ env.MACOS_DMG_ARTIFACT_NAME }}
    draft: true
    body: |
      ### Changes
      See CHANGELOG.md for details
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

## Files
- .github/workflows/go.yml:234-259