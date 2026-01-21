---
# macos-file-summoner-c629
title: Extract CHANGELOG.md from README.md
status: todo
type: task
priority: low
created_at: 2026-01-21T12:18:30Z
updated_at: 2026-01-21T12:18:30Z
---

Changelog is embedded in README.md (lines ~80-120). Should be a separate file for better organization.

## Solution
1. Create CHANGELOG.md with content from README
2. Update README to link to CHANGELOG.md
3. Consider using Keep a Changelog format (https://keepachangelog.com)

## Files
- CHANGELOG.md (new)
- README.md