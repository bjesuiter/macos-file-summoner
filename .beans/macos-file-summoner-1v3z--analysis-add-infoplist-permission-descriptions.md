---
# macos-file-summoner-1v3z
title: 'Analysis: Add Info.plist permission descriptions'
status: todo
type: task
priority: low
created_at: 2026-01-21T12:18:17Z
updated_at: 2026-01-21T12:18:17Z
---

ANALYSIS NEEDED: Info.plist may be missing permission description keys that improve UX.

## Observations
- App uses AppleScript to control Finder (mack library)
- Currently no NSAppleEventsUsageDescription key
- macOS may show generic permission dialogs

## Questions
1. Does the app already request permissions correctly?
2. Would adding usage descriptions improve the experience?
3. What exact keys are needed for Finder access?

## Potential Keys to Add
- NSAppleEventsUsageDescription: Explain why app controls Finder
- NSSystemAdministrationUsageDescription: If needed for file creation

## Files
- mac-app-template/Contents/Info.plist