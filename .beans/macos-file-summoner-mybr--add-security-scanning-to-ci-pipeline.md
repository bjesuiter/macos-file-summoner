---
# macos-file-summoner-mybr
title: Add security scanning to CI pipeline
status: todo
type: feature
priority: low
created_at: 2026-01-21T12:18:40Z
updated_at: 2026-01-21T12:18:40Z
---

No security scanning configured. Vulnerabilities may go undetected.

## Solution
Add gosec to CI workflow:
```yaml
- name: Run Gosec Security Scanner
  uses: securego/gosec@master
  with:
    args: '-no-fail -fmt sarif -out gosec-results.sarif ./...'

- name: Upload Gosec Results
  uses: github/codeql-action/upload-sarif@v2
  with:
    sarif_file: gosec-results.sarif
```

## Files
- .github/workflows/go.yml