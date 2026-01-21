---
# macos-file-summoner-s403
title: Add build-time version sync mechanism
status: todo
type: feature
priority: normal
created_at: 2026-01-21T12:18:37Z
updated_at: 2026-01-21T12:18:37Z
---

Version must be manually maintained in two places (./version and Info.plist). Should be automated.

## Problem
Human error can cause version mismatch between files (as seen with 1.2.0 vs 1.2.2).

## Solution Options
1. Build script that copies version to Info.plist:
```bash
VERSION=$(cat ./version)
sed -i '' "s/<string>1\.[0-9]\.[0-9]<\/string>/<string>$VERSION<\/string>/g" mac-app-template/Contents/Info.plist
```

2. Use Go ldflags to embed version at build time

3. Generate Info.plist from template during build

## Files
- scripts/01-build.sh (or new sync script)
- bonnie.toml