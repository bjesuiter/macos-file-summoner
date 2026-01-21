---
# macos-file-summoner-4ggd
title: Fix version sync between ./version and Info.plist
status: in-progress
type: bug
priority: critical
created_at: 2026-01-21T12:16:56Z
updated_at: 2026-01-21T20:17:25Z
---

CRITICAL: ./version file contains 1.2.0 but Info.plist contains 1.2.2. These MUST stay in sync per AGENTS.md guidelines.

## Problem
Version mismatch breaks CI/CD automation and release integrity.

## Solution
1. Update ./version to 1.2.2 (or align both to correct version)
2. Consider adding a build-time sync mechanism to prevent future drift

## Files
- ./version
- ./mac-app-template/Contents/Info.plist