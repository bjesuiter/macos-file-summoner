# AGENTS.md - AI Agent Guidelines for macOS File Summoner

Guidelines for AI coding agents working in this repository.

## Project Overview

**Type**: macOS native app written in Go  
**Purpose**: Create new files directly from Finder toolbar  
**Architecture**: Single Go binary packaged as `.app` bundle

## Directory Structure

```
├── main.go                 # Main application code (single file)
├── go.mod / go.sum         # Go module (Go 1.23)
├── version                 # App version (sync with Info.plist!)
├── bonnie.toml             # Task runner config (bx)
├── scripts/                # Build, sign, notarize scripts
├── mac-app-template/       # macOS .app bundle template
│   └── Contents/
│       ├── Info.plist      # App metadata (version here too!)
│       ├── MacOS/          # Binary location
│       └── Resources/      # icon.icns
└── .github/workflows/      # CI/CD pipelines
```

## Build Commands

### Prerequisites
- Go 1.23+
- Task runner: `bx` (install via `cargo install --locked bx`)
- For signing: Apple Developer ID certificate in keychain

### Building

```bash
# Build the app (recommended)
bx build

# Direct Go build (binary only, no .app bundle)
GOOS=darwin GOARCH=arm64 go build -o build/macos-file-summoner .

# Full pipeline with signing (requires .env)
bx build && bx sign
```

### Other Commands

```bash
bx sign              # Sign the app
bx notarize          # Notarize with Apple
bx check-signature   # Verify code signature
bx package-dmg       # Create DMG for distribution
```

### Testing

**No test files exist currently.** If adding tests:

```bash
go test ./...                        # Run all tests
go test -run TestFunctionName ./...  # Run single test
go test -v ./...                     # Verbose output
```

## Code Style Guidelines

### Go Formatting
- Use `gofmt` or `goimports`
- Standard Go formatting conventions

### Imports
Group imports: stdlib first, then external packages with blank line between:
```go
import (
    "log"
    "os"
    "os/exec"
    "strings"

    "github.com/andybrewer/mack"
)
```

### Naming Conventions
- **Functions**: camelCase (`touchFile`, `main`)
- **Variables**: Short, contextual (`path`, `err`, `cmd`)
- **Constants**: UPPER_SNAKE_CASE if needed
- **Package**: Match directory name

### Error Handling
Check errors immediately, use `panic()` for unrecoverable errors:
```go
if err != nil {
    panic(err)
}
```

### Logging
Use `log.Printf()` with context:
```go
log.Printf("Topmost finder path: %s\n", path)
```

### Shell Scripts
- Shebang: `#!/usr/bin/env bash`
- Define helper functions at top (e.g., `log()`)
- Use defaults: `${VAR:-default}`
- Check required env vars early
- Quote paths with spaces: `"${DIST_DIR}/${MACOS_APP_ARTIFACT}"`

### Prettier (non-Go files)
```json
{
  "printWidth": 120,
  "tabWidth": 2,
  "singleQuote": true,
  "semi": true,
  "trailingComma": "es5"
}
```

## Dependencies

**Single external dependency:**
- `github.com/andybrewer/mack` - AppleScript communication

```bash
go get <package-path>
go mod tidy
```

## Version Management

**CRITICAL**: Update version in TWO places:
1. `./version` file (CI/CD)
2. `./mac-app-template/Contents/Info.plist` (CFBundleVersion + CFBundleShortVersionString)

## Environment Variables

See `.env.example` for detailed instructions on obtaining each credential.

### Local Development (`.env` file)
- `APPLE_DEVELOPER_ID_CODE` - Code signing identity
- `APPLE_DEVELOPER_ID_NAME` - Apple ID email
- `APPLE_ACCOUNT_APP_PASSWORD` - App-specific password
- `APPLE_TEAM_ID` - Developer Team ID
- `APPLE_DEVELOPER_ID_LABEL` - Same as APPLE_DEVELOPER_ID_CODE (for create-dmg)

### GitHub Actions Secrets (required for CI/CD releases)

All secrets must be configured in: Repository Settings → Secrets and variables → Actions

| Secret | Description |
|--------|-------------|
| `APPLE_DEVELOPER_ID_CERT_P12` | Base64-encoded .p12 certificate (`base64 -i cert.p12`) |
| `APPLE_DEVELOPER_ID_CERT_PASSWD` | Password for the .p12 certificate |
| `APPLE_DEVELOPER_ID_CODE` | Signing identity (e.g., `Developer ID Application: Name (TEAMID)`) |
| `APPLE_DEVELOPER_ID_NAME` | Apple ID email for notarization |
| `APPLE_ACCOUNT_APP_PASSWORD` | App-specific password for notarization |
| `APPLE_TEAM_ID` | 10-character Team ID |
| `APPLE_DEVELOPER_ID_LABEL` | Same as `APPLE_DEVELOPER_ID_CODE` |

**Find your signing identity and Team ID:**
```bash
security find-identity -v -p codesigning
```

## Common Tasks

### Adding a New Feature
1. Modify `main.go`
2. Build: `bx build`
3. Test: Run `dist/File Summoner.app`

### Releasing a New Version
1. Update version in `./version` AND `Info.plist`
2. Update CHANGELOG in `README.md`
3. Commit as "Release vX.X.X"
4. Tag: `git tag vX.X.X && git push --tags`

### Debugging AppleScript Issues
- Uses `mack` library to communicate with Finder
- macOS Sequoia (15.0) introduced garbage text in dialog output
- Current fix: Split filename at "Legacy" string (see `main.go:42`)

## Files to NEVER Modify Without Request
- `.env` - Contains secrets (never commit)
- `*.p12` certificates
- Signed artifacts in `dist/`
