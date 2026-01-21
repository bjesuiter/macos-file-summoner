# SwiftUI Migration Plan: macOS File Summoner

**Document Version**: 1.0  
**Created**: January 2026  
**Status**: Planning Phase

---

## Executive Summary

This document outlines a comprehensive plan to migrate **macOS File Summoner** from Go to native Swift/SwiftUI. The migration will eliminate AppleScript workarounds (e.g., the macOS Sequoia "Legacy" bug), provide a modern codebase, and enable future enhancements like custom file templates and improved UI.

### Current State (Go)

| Component | Technology | Issues |
|-----------|------------|--------|
| Core Logic | Go 1.23 | Works, but non-native |
| Finder Communication | `mack` library (AppleScript bridge) | Sequoia bug workaround needed |
| User Dialog | `mack.Dialog` (AppleScript) | Limited customization |
| File Creation | `exec.Command("touch")` | Shell dependency |
| Build Pipeline | GoReleaser + shell scripts | Complex, multi-tool chain |

### Target State (Swift/SwiftUI)

| Component | Technology | Benefits |
|-----------|------------|----------|
| Core Logic | Swift 5.9+ | Native, type-safe |
| Finder Communication | `NSAppleScript` | Direct API, no third-party lib |
| User Dialog | `NSAlert` / SwiftUI | Customizable, native look |
| File Creation | `FileManager` | Pure Swift, no shell |
| Build Pipeline | Xcode + xcodebuild | Single tool, Apple-native |

---

## Phase Overview

| Phase | Name | Duration | Effort |
|-------|------|----------|--------|
| 1 | Project Setup & Foundation | 1-2 days | Low |
| 2 | Core Feature Migration | 2-3 days | Medium |
| 3 | UI Enhancement | 2-3 days | Medium |
| 4 | Build & Distribution Pipeline | 2-3 days | Medium |
| 5 | Testing & Polish | 1-2 days | Low |
| 6 | Future Enhancements (Optional) | Ongoing | Variable |

**Total Estimated Time**: 8-13 days

---

## Phase 1: Project Setup & Foundation

### Objective
Create the Xcode project structure with proper configuration for a Finder toolbar utility app.

### Steps

#### 1.1 Create Xcode Project

```bash
# Project structure (created via Xcode)
FileSummoner/
├── FileSummoner.xcodeproj/
├── FileSummoner/
│   ├── FileSummonerApp.swift      # @main entry point
│   ├── AppDelegate.swift          # NSApplicationDelegate
│   ├── Info.plist                 # Bundle configuration
│   ├── FileSummoner.entitlements  # Security entitlements
│   └── Resources/
│       └── Assets.xcassets/       # App icon
└── FileSummonerTests/             # Unit tests
```

**Xcode Settings**:
- **Template**: macOS → App → SwiftUI
- **Language**: Swift
- **Deployment Target**: macOS 11.0 (Big Sur) minimum
- **Signing**: Developer ID Application (for notarization)

#### 1.2 Configure Info.plist

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" 
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleIdentifier</key>
    <string>dev.bjesuiter.file-summoner</string>
    
    <key>CFBundleDisplayName</key>
    <string>File Summoner</string>
    
    <key>CFBundleVersion</key>
    <string>2.0.0</string>
    
    <key>CFBundleShortVersionString</key>
    <string>2.0.0</string>
    
    <!-- CRITICAL: Hide dock icon for toolbar app -->
    <key>LSUIElement</key>
    <true/>
    
    <!-- High DPI support -->
    <key>NSHighResolutionCapable</key>
    <true/>
    
    <!-- Prevent automatic termination -->
    <key>NSSupportsAutomaticTermination</key>
    <false/>
    
    <!-- Human-readable permission descriptions -->
    <key>NSAppleEventsUsageDescription</key>
    <string>File Summoner needs to communicate with Finder to detect the current folder.</string>
</dict>
</plist>
```

#### 1.3 Configure Entitlements

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" 
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- Allow AppleScript to control Finder -->
    <key>com.apple.security.automation.apple-events</key>
    <true/>
    
    <!-- File system access (if sandboxed) -->
    <key>com.apple.security.files.user-selected.read-write</key>
    <true/>
</dict>
</plist>
```

#### 1.4 Migrate App Icon

```bash
# Convert existing icon to asset catalog
# Source: resources/icon.icns
# Destination: FileSummoner/Resources/Assets.xcassets/AppIcon.appiconset/

# Required sizes for macOS app icon:
# - 16x16, 16x16@2x
# - 32x32, 32x32@2x
# - 128x128, 128x128@2x
# - 256x256, 256x256@2x
# - 512x512, 512x512@2x
```

### Deliverables
- [ ] Xcode project compiles without errors
- [ ] App launches (shows nothing, quits immediately)
- [ ] App icon displays correctly
- [ ] `LSUIElement` verified (no dock icon)

---

## Phase 2: Core Feature Migration

### Objective
Migrate all functional logic from Go to Swift while maintaining feature parity.

### Steps

#### 2.1 App Entry Point

**File**: `FileSummonerApp.swift`

```swift
import SwiftUI

@main
struct FileSummonerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        // No WindowGroup - handled in AppDelegate
        Settings {
            EmptyView()
        }
    }
}
```

**Why no `WindowGroup`?**
- Toolbar apps don't have persistent windows
- Launch → Show dialog → Quit lifecycle
- `AppDelegate` controls window lifecycle manually

#### 2.2 AppDelegate Implementation

**File**: `AppDelegate.swift`

```swift
import AppKit
import Foundation

class AppDelegate: NSObject, NSApplicationDelegate {
    
    // MARK: - Lifecycle
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Bring app to front (important for toolbar launches)
        NSApplication.shared.activate(ignoringOtherApps: true)
        
        // Main workflow
        runFileSummonerWorkflow()
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    // MARK: - Main Workflow
    
    private func runFileSummonerWorkflow() {
        // Step 1: Get Finder path
        guard let finderPath = FinderService.getActiveWindowPath() else {
            AlertService.showError(
                title: "Error",
                message: "Failed to get Finder path. Is a Finder window open?"
            )
            NSApplication.shared.terminate(self)
            return
        }
        
        // Step 2: Show filename dialog
        guard let filename = AlertService.showFilenameDialog(defaultName: "newFile.txt") else {
            // User cancelled
            NSApplication.shared.terminate(self)
            return
        }
        
        // Step 3: Validate filename
        guard let validatedFilename = FileService.validateFilename(filename) else {
            AlertService.showError(
                title: "Invalid Filename",
                message: "Filename cannot contain path separators or special characters."
            )
            NSApplication.shared.terminate(self)
            return
        }
        
        // Step 4: Create file
        let result = FileService.createFile(at: finderPath, named: validatedFilename)
        
        switch result {
        case .success:
            // Silent success - file appears in Finder
            break
        case .failure(let error):
            AlertService.showError(
                title: "Error",
                message: "Failed to create file: \(error.localizedDescription)"
            )
        }
        
        NSApplication.shared.terminate(self)
    }
}
```

#### 2.3 Finder Service (AppleScript Integration)

**File**: `Services/FinderService.swift`

```swift
import Foundation

enum FinderService {
    
    /// Gets the POSIX path of the frontmost Finder window.
    /// Falls back to Desktop if no windows are open.
    static func getActiveWindowPath() -> String? {
        let script = """
        tell application "Finder"
            if (count of Finder windows) is 0 then
                set dir to (desktop as alias)
            else
                set dir to ((target of Finder window 1) as alias)
            end if
            return POSIX path of dir
        end tell
        """
        
        return executeAppleScript(script)
    }
    
    /// Reveals a file in Finder (optional enhancement)
    static func revealInFinder(path: String) {
        let script = """
        tell application "Finder"
            reveal POSIX file "\(path)"
            activate
        end tell
        """
        _ = executeAppleScript(script)
    }
    
    // MARK: - Private
    
    private static func executeAppleScript(_ source: String) -> String? {
        var error: NSDictionary?
        
        guard let appleScript = NSAppleScript(source: source) else {
            print("[FinderService] Failed to create AppleScript")
            return nil
        }
        
        let result = appleScript.executeAndReturnError(&error)
        
        if let error = error {
            print("[FinderService] AppleScript error: \(error)")
            return nil
        }
        
        return result.stringValue
    }
}
```

**Key Differences from Go Implementation**:
- No `mack` library dependency
- Direct `NSAppleScript` usage
- No "Legacy" string workaround needed (native API doesn't have this bug)

#### 2.4 File Service

**File**: `Services/FileService.swift`

```swift
import Foundation

enum FileServiceError: LocalizedError {
    case invalidFilename(String)
    case fileExists(String)
    case creationFailed(String)
    case permissionDenied(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidFilename(let name):
            return "Invalid filename: \(name)"
        case .fileExists(let path):
            return "File already exists: \(path)"
        case .creationFailed(let path):
            return "Failed to create file: \(path)"
        case .permissionDenied(let path):
            return "Permission denied: \(path)"
        }
    }
}

enum FileService {
    
    /// Validates and sanitizes a filename.
    /// Returns nil if filename is invalid.
    static func validateFilename(_ input: String) -> String? {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check for empty
        guard !trimmed.isEmpty else { return nil }
        
        // Check for path separators or special characters
        let forbidden: [Character] = ["/", "\\", "\0", ":"]
        guard !trimmed.contains(where: { forbidden.contains($0) }) else { return nil }
        
        // Check for path traversal
        guard !trimmed.contains("..") else { return nil }
        
        // Extract just the filename (safety measure)
        let filename = (trimmed as NSString).lastPathComponent
        
        guard !filename.isEmpty else { return nil }
        
        return filename
    }
    
    /// Creates an empty file at the specified path.
    static func createFile(at directory: String, named filename: String) -> Result<URL, FileServiceError> {
        let fileManager = FileManager.default
        let fullPath = (directory as NSString).appendingPathComponent(filename)
        let fileURL = URL(fileURLWithPath: fullPath)
        
        // Check if file already exists
        if fileManager.fileExists(atPath: fullPath) {
            return .failure(.fileExists(fullPath))
        }
        
        // Check directory permissions
        guard fileManager.isWritableFile(atPath: directory) else {
            return .failure(.permissionDenied(directory))
        }
        
        // Create empty file
        let success = fileManager.createFile(
            atPath: fullPath,
            contents: nil,  // Empty file
            attributes: nil
        )
        
        if success {
            return .success(fileURL)
        } else {
            return .failure(.creationFailed(fullPath))
        }
    }
}
```

**Improvements Over Go**:
- Uses `FileManager` instead of shell `touch` command
- Better error handling with typed errors
- Permission checking before creation
- Returns `Result` type for clean error propagation

#### 2.5 Alert Service

**File**: `Services/AlertService.swift`

```swift
import AppKit

enum AlertService {
    
    /// Shows a dialog to get filename input from user.
    /// Returns nil if user cancels.
    static func showFilenameDialog(defaultName: String = "newFile.txt") -> String? {
        let alert = NSAlert()
        alert.messageText = "Create New File"
        alert.informativeText = "Enter filename:"
        alert.alertStyle = .informational
        
        // Add text field
        let textField = NSTextField(frame: NSRect(x: 0, y: 0, width: 300, height: 24))
        textField.stringValue = defaultName
        textField.selectText(nil)  // Select default text
        alert.accessoryView = textField
        
        // Add buttons
        alert.addButton(withTitle: "Create")
        alert.addButton(withTitle: "Cancel")
        
        // Make alert key window
        alert.window.makeFirstResponder(textField)
        
        // Show modal
        let response = alert.runModal()
        
        if response == .alertFirstButtonReturn {
            return textField.stringValue
        }
        
        return nil
    }
    
    /// Shows an error alert.
    static func showError(title: String, message: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = .critical
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}
```

### Feature Mapping (Go → Swift)

| Go Code | Swift Code | Notes |
|---------|------------|-------|
| `mack.Tell("Finder", ...)` | `NSAppleScript(source:)` | Direct API, no library |
| `mack.Dialog(...)` | `NSAlert + NSTextField` | More control |
| `mack.Alert(...)` | `NSAlert` | Native |
| `exec.Command("touch", ...)` | `FileManager.createFile` | No shell |
| `strings.Split(response.Text, "Legacy")` | Not needed | Bug doesn't exist |
| `filepath.Base(...)` | `NSString.lastPathComponent` | Same functionality |

### Deliverables
- [ ] App gets Finder window path correctly
- [ ] Dialog appears and accepts input
- [ ] File is created in correct location
- [ ] Error handling works for all edge cases
- [ ] No "Legacy" workaround needed

---

## Phase 3: UI Enhancement

### Objective
Create a modern, polished UI that improves on the original AppleScript dialog.

### Steps

#### 3.1 Custom SwiftUI Dialog (Optional Enhancement)

**File**: `Views/FileCreationView.swift`

```swift
import SwiftUI

struct FileCreationView: View {
    @State private var filename: String = "newFile.txt"
    @State private var showingError: Bool = false
    @State private var errorMessage: String = ""
    
    let directoryPath: String
    let onCancel: () -> Void
    let onSuccess: (String) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Image(systemName: "doc.badge.plus")
                    .font(.system(size: 32))
                    .foregroundColor(.accentColor)
                
                VStack(alignment: .leading) {
                    Text("Create New File")
                        .font(.headline)
                    Text(directoryPath)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .truncationMode(.head)
                }
                
                Spacer()
            }
            
            Divider()
            
            // Filename input
            VStack(alignment: .leading, spacing: 8) {
                Text("Filename:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                TextField("Enter filename", text: $filename)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit {
                        createFile()
                    }
            }
            
            // Error message
            if showingError {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                    Spacer()
                }
            }
            
            Divider()
            
            // Buttons
            HStack {
                Spacer()
                
                Button("Cancel") {
                    onCancel()
                }
                .keyboardShortcut(.cancelAction)
                
                Button("Create") {
                    createFile()
                }
                .keyboardShortcut(.defaultAction)
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(20)
        .frame(width: 400)
    }
    
    private func createFile() {
        guard let validatedFilename = FileService.validateFilename(filename) else {
            showError("Invalid filename. Avoid special characters like / \\ :")
            return
        }
        
        let result = FileService.createFile(at: directoryPath, named: validatedFilename)
        
        switch result {
        case .success:
            onSuccess(validatedFilename)
        case .failure(let error):
            showError(error.localizedDescription)
        }
    }
    
    private func showError(_ message: String) {
        errorMessage = message
        showingError = true
    }
}
```

#### 3.2 Window Hosting for SwiftUI View

**Update `AppDelegate.swift`** to use SwiftUI view:

```swift
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApplication.shared.activate(ignoringOtherApps: true)
        
        guard let finderPath = FinderService.getActiveWindowPath() else {
            AlertService.showError(title: "Error", message: "Could not get Finder path")
            NSApplication.shared.terminate(self)
            return
        }
        
        showSwiftUIDialog(directoryPath: finderPath)
    }
    
    private func showSwiftUIDialog(directoryPath: String) {
        let contentView = FileCreationView(
            directoryPath: directoryPath,
            onCancel: { [weak self] in
                NSApplication.shared.terminate(self)
            },
            onSuccess: { [weak self] filename in
                print("Created file: \(filename)")
                NSApplication.shared.terminate(self)
            }
        )
        
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 200),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        
        window.title = "File Summoner"
        window.center()
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
        window.level = .floating  // Keep on top
        
        self.window = window
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}
```

#### 3.3 Localization Support

**File**: `Resources/Localizable.strings` (en)

```
"create_new_file" = "Create New File";
"filename_placeholder" = "Enter filename";
"button_create" = "Create";
"button_cancel" = "Cancel";
"error_invalid_filename" = "Invalid filename. Avoid special characters.";
"error_file_exists" = "A file with this name already exists.";
"error_permission_denied" = "Permission denied. Cannot write to this folder.";
```

**Usage**:

```swift
Text(NSLocalizedString("create_new_file", comment: "Dialog title"))
```

### Deliverables
- [ ] Custom SwiftUI dialog implemented
- [ ] Shows current directory path
- [ ] Keyboard shortcuts work (Enter = Create, Escape = Cancel)
- [ ] Error messages display inline
- [ ] Localization strings prepared

---

## Phase 4: Build & Distribution Pipeline

### Objective
Replace GoReleaser with native Xcode build pipeline while maintaining signing, notarization, and DMG creation.

### Steps

#### 4.1 Xcode Project Configuration

**Build Settings**:

```
PRODUCT_NAME = File Summoner
PRODUCT_BUNDLE_IDENTIFIER = dev.bjesuiter.file-summoner
MARKETING_VERSION = 2.0.0
CURRENT_PROJECT_VERSION = 1
CODE_SIGN_IDENTITY = Developer ID Application
CODE_SIGN_STYLE = Manual
DEVELOPMENT_TEAM = <YOUR_TEAM_ID>
ENABLE_HARDENED_RUNTIME = YES
```

#### 4.2 Build Script

**File**: `scripts/build.sh`

```bash
#!/usr/bin/env bash
set -euo pipefail

# Configuration
PROJECT_NAME="FileSummoner"
SCHEME="FileSummoner"
CONFIGURATION="Release"
ARCHIVE_PATH="build/${PROJECT_NAME}.xcarchive"
EXPORT_PATH="dist"
EXPORT_OPTIONS_PLIST="scripts/ExportOptions.plist"

log() { echo "[$(date '+%H:%M:%S')] $*"; }

log "Building ${PROJECT_NAME}..."

# Clean previous builds
rm -rf build/ dist/
mkdir -p build dist

# Archive
xcodebuild archive \
    -project "${PROJECT_NAME}.xcodeproj" \
    -scheme "${SCHEME}" \
    -configuration "${CONFIGURATION}" \
    -archivePath "${ARCHIVE_PATH}" \
    CODE_SIGN_IDENTITY="${APPLE_DEVELOPER_ID_CODE:-}" \
    DEVELOPMENT_TEAM="${APPLE_TEAM_ID:-}"

# Export
xcodebuild -exportArchive \
    -archivePath "${ARCHIVE_PATH}" \
    -exportPath "${EXPORT_PATH}" \
    -exportOptionsPlist "${EXPORT_OPTIONS_PLIST}"

log "Build complete: ${EXPORT_PATH}/${PROJECT_NAME}.app"
```

#### 4.3 Export Options

**File**: `scripts/ExportOptions.plist`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" 
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>developer-id</string>
    
    <key>signingStyle</key>
    <string>manual</string>
    
    <key>teamID</key>
    <string>$(APPLE_TEAM_ID)</string>
    
    <key>signingCertificate</key>
    <string>Developer ID Application</string>
</dict>
</plist>
```

#### 4.4 Notarization Script

**File**: `scripts/notarize.sh`

```bash
#!/usr/bin/env bash
set -euo pipefail

APP_PATH="${1:-dist/File Summoner.app}"
BUNDLE_ID="dev.bjesuiter.file-summoner"

log() { echo "[$(date '+%H:%M:%S')] $*"; }

# Required environment variables
: "${APPLE_DEVELOPER_ID_NAME:?Set APPLE_DEVELOPER_ID_NAME}"
: "${APPLE_ACCOUNT_APP_PASSWORD:?Set APPLE_ACCOUNT_APP_PASSWORD}"
: "${APPLE_TEAM_ID:?Set APPLE_TEAM_ID}"

# Create ZIP for notarization
ZIP_PATH="${APP_PATH%.app}.zip"
log "Creating ZIP for notarization..."
ditto -c -k --keepParent "${APP_PATH}" "${ZIP_PATH}"

# Submit for notarization
log "Submitting for notarization..."
xcrun notarytool submit "${ZIP_PATH}" \
    --apple-id "${APPLE_DEVELOPER_ID_NAME}" \
    --password "${APPLE_ACCOUNT_APP_PASSWORD}" \
    --team-id "${APPLE_TEAM_ID}" \
    --wait

# Staple the ticket
log "Stapling notarization ticket..."
xcrun stapler staple "${APP_PATH}"

# Clean up
rm -f "${ZIP_PATH}"

log "Notarization complete!"
```

#### 4.5 DMG Creation Script

**File**: `scripts/create-dmg.sh`

```bash
#!/usr/bin/env bash
set -euo pipefail

APP_PATH="${1:-dist/File Summoner.app}"
VERSION=$(defaults read "${APP_PATH}/Contents/Info.plist" CFBundleShortVersionString)
DMG_NAME="File Summoner ${VERSION}.dmg"
DMG_PATH="dist/${DMG_NAME}"

log() { echo "[$(date '+%H:%M:%S')] $*"; }

log "Creating DMG..."

# Use create-dmg if available, otherwise hdiutil
if command -v create-dmg &> /dev/null; then
    create-dmg \
        --volname "File Summoner" \
        --volicon "${APP_PATH}/Contents/Resources/AppIcon.icns" \
        --window-pos 200 120 \
        --window-size 600 400 \
        --icon-size 100 \
        --icon "File Summoner.app" 150 190 \
        --hide-extension "File Summoner.app" \
        --app-drop-link 450 185 \
        "${DMG_PATH}" \
        "${APP_PATH}"
else
    log "create-dmg not found, using hdiutil..."
    hdiutil create -volname "File Summoner" \
        -srcfolder "${APP_PATH}" \
        -ov -format UDZO \
        "${DMG_PATH}"
fi

# Sign DMG
if [[ -n "${APPLE_DEVELOPER_ID_CODE:-}" ]]; then
    log "Signing DMG..."
    codesign --force --sign "${APPLE_DEVELOPER_ID_CODE}" "${DMG_PATH}"
fi

log "DMG created: ${DMG_PATH}"
```

#### 4.6 GitHub Actions Workflow

**File**: `.github/workflows/release.yml`

```yaml
name: Release

on:
  push:
    tags:
      - 'v*'

jobs:
  build:
    runs-on: macos-14  # macOS Sonoma with Xcode 15
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Select Xcode
        run: sudo xcode-select -s /Applications/Xcode_15.2.app
      
      - name: Install Apple Certificate
        env:
          APPLE_DEVELOPER_ID_CERT_P12: ${{ secrets.APPLE_DEVELOPER_ID_CERT_P12 }}
          APPLE_DEVELOPER_ID_CERT_PASSWD: ${{ secrets.APPLE_DEVELOPER_ID_CERT_PASSWD }}
        run: |
          # Create keychain
          security create-keychain -p "" build.keychain
          security default-keychain -s build.keychain
          security unlock-keychain -p "" build.keychain
          
          # Import certificate
          echo "$APPLE_DEVELOPER_ID_CERT_P12" | base64 --decode > certificate.p12
          security import certificate.p12 -k build.keychain \
            -P "$APPLE_DEVELOPER_ID_CERT_PASSWD" -T /usr/bin/codesign
          security set-key-partition-list -S apple-tool:,apple: -s -k "" build.keychain
          rm certificate.p12
      
      - name: Build
        env:
          APPLE_DEVELOPER_ID_CODE: ${{ secrets.APPLE_DEVELOPER_ID_CODE }}
          APPLE_TEAM_ID: ${{ secrets.APPLE_TEAM_ID }}
        run: ./scripts/build.sh
      
      - name: Notarize
        env:
          APPLE_DEVELOPER_ID_NAME: ${{ secrets.APPLE_DEVELOPER_ID_NAME }}
          APPLE_ACCOUNT_APP_PASSWORD: ${{ secrets.APPLE_ACCOUNT_APP_PASSWORD }}
          APPLE_TEAM_ID: ${{ secrets.APPLE_TEAM_ID }}
        run: ./scripts/notarize.sh "dist/File Summoner.app"
      
      - name: Create DMG
        env:
          APPLE_DEVELOPER_ID_CODE: ${{ secrets.APPLE_DEVELOPER_ID_CODE }}
        run: |
          npm install -g create-dmg
          ./scripts/create-dmg.sh "dist/File Summoner.app"
      
      - name: Create Release
        uses: softprops/action-gh-release@v1
        with:
          files: |
            dist/*.dmg
          generate_release_notes: true
```

#### 4.7 Update bonnie.toml (Task Runner)

```toml
[tasks.build]
command = "./scripts/build.sh"

[tasks.sign]
command = "./scripts/notarize.sh dist/File\\ Summoner.app"

[tasks.dmg]
command = "./scripts/create-dmg.sh dist/File\\ Summoner.app"

[tasks.release]
command = "bx build && bx sign && bx dmg"

[tasks.clean]
command = "rm -rf build/ dist/"
```

### Deliverables
- [ ] Xcode project builds via command line
- [ ] Signing works with Developer ID
- [ ] Notarization succeeds
- [ ] DMG created and signed
- [ ] GitHub Actions workflow passes

---

## Phase 5: Testing & Polish

### Objective
Ensure the app works correctly in all scenarios and matches or exceeds the Go version's functionality.

### Steps

#### 5.1 Manual Test Cases

| Test Case | Expected Result | Status |
|-----------|-----------------|--------|
| Launch from Finder toolbar | Dialog appears | [ ] |
| Launch with no Finder windows | Uses Desktop path | [ ] |
| Enter valid filename | File created | [ ] |
| Enter filename with spaces | File created correctly | [ ] |
| Enter filename with `/` | Error shown, no file created | [ ] |
| Enter filename with `..` | Error shown, no file created | [ ] |
| Enter empty filename | Error shown | [ ] |
| Click Cancel | App quits, no file created | [ ] |
| Press Escape | App quits, no file created | [ ] |
| Press Enter | File created | [ ] |
| Create file in read-only directory | Error shown | [ ] |
| File already exists | Error shown | [ ] |
| Long filename (255+ chars) | Error shown | [ ] |
| Unicode filename (emoji, CJK) | File created correctly | [ ] |

#### 5.2 Unit Tests

**File**: `FileSummonerTests/FileServiceTests.swift`

```swift
import XCTest
@testable import FileSummoner

final class FileServiceTests: XCTestCase {
    
    func testValidateFilename_validName() {
        XCTAssertEqual(FileService.validateFilename("test.txt"), "test.txt")
        XCTAssertEqual(FileService.validateFilename("my-file.md"), "my-file.md")
        XCTAssertEqual(FileService.validateFilename("file_name.swift"), "file_name.swift")
    }
    
    func testValidateFilename_trimWhitespace() {
        XCTAssertEqual(FileService.validateFilename("  test.txt  "), "test.txt")
    }
    
    func testValidateFilename_empty() {
        XCTAssertNil(FileService.validateFilename(""))
        XCTAssertNil(FileService.validateFilename("   "))
    }
    
    func testValidateFilename_pathSeparators() {
        XCTAssertNil(FileService.validateFilename("path/file.txt"))
        XCTAssertNil(FileService.validateFilename("path\\file.txt"))
        XCTAssertNil(FileService.validateFilename("../file.txt"))
    }
    
    func testValidateFilename_specialChars() {
        XCTAssertNil(FileService.validateFilename("file\0.txt"))
        XCTAssertNil(FileService.validateFilename("file:name.txt"))
    }
    
    func testValidateFilename_unicode() {
        XCTAssertEqual(FileService.validateFilename("文件.txt"), "文件.txt")
        XCTAssertEqual(FileService.validateFilename("emoji😀.txt"), "emoji😀.txt")
    }
    
    func testCreateFile_success() throws {
        let tempDir = FileManager.default.temporaryDirectory.path
        let filename = "test-\(UUID().uuidString).txt"
        
        let result = FileService.createFile(at: tempDir, named: filename)
        
        switch result {
        case .success(let url):
            XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
            try FileManager.default.removeItem(at: url)
        case .failure(let error):
            XCTFail("Failed: \(error)")
        }
    }
    
    func testCreateFile_alreadyExists() throws {
        let tempDir = FileManager.default.temporaryDirectory.path
        let filename = "test-\(UUID().uuidString).txt"
        let fullPath = (tempDir as NSString).appendingPathComponent(filename)
        
        // Create file first
        FileManager.default.createFile(atPath: fullPath, contents: nil, attributes: nil)
        defer { try? FileManager.default.removeItem(atPath: fullPath) }
        
        let result = FileService.createFile(at: tempDir, named: filename)
        
        if case .failure(let error) = result {
            XCTAssertTrue(error is FileServiceError)
        } else {
            XCTFail("Should have failed with file exists error")
        }
    }
}
```

#### 5.3 Integration Tests

**File**: `FileSummonerTests/FinderServiceTests.swift`

```swift
import XCTest
@testable import FileSummoner

final class FinderServiceTests: XCTestCase {
    
    func testGetActiveWindowPath_returnsPath() {
        // Note: This test requires Finder to be running
        let path = FinderService.getActiveWindowPath()
        
        // Should return either a Finder window path or Desktop
        XCTAssertNotNil(path)
        
        if let path = path {
            XCTAssertTrue(path.hasPrefix("/"))
            XCTAssertTrue(FileManager.default.fileExists(atPath: path))
        }
    }
}
```

### Deliverables
- [ ] All manual test cases pass
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Code coverage > 70%

---

## Phase 6: Future Enhancements (Optional)

### 6.1 File Templates

Add ability to create files from templates:

```swift
enum FileTemplate: String, CaseIterable {
    case empty = "Empty File"
    case markdown = "Markdown Document"
    case swift = "Swift File"
    case html = "HTML Document"
    case json = "JSON File"
    
    var defaultExtension: String {
        switch self {
        case .empty: return ".txt"
        case .markdown: return ".md"
        case .swift: return ".swift"
        case .html: return ".html"
        case .json: return ".json"
        }
    }
    
    var templateContent: String {
        switch self {
        case .empty: return ""
        case .markdown: return "# Title\n\n"
        case .swift: return "import Foundation\n\n"
        case .html: return "<!DOCTYPE html>\n<html>\n<head>\n  <title></title>\n</head>\n<body>\n\n</body>\n</html>"
        case .json: return "{\n  \n}"
        }
    }
}
```

### 6.2 Keyboard Shortcut Trigger

Register global keyboard shortcut to trigger File Summoner:

```swift
import Carbon

func registerGlobalHotkey() {
    // Example: Cmd + Shift + N
    var hotKeyRef: EventHotKeyRef?
    var hotKeyID = EventHotKeyID()
    hotKeyID.signature = OSType("FSHT".fourCharCode)
    hotKeyID.id = 1
    
    RegisterEventHotKey(
        UInt32(kVK_ANSI_N),
        UInt32(cmdKey | shiftKey),
        hotKeyID,
        GetEventDispatcherTarget(),
        0,
        &hotKeyRef
    )
}
```

### 6.3 Menu Bar Integration

Add optional menu bar icon for quick access:

```swift
class StatusBarController {
    private var statusItem: NSStatusItem?
    
    func setup() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem?.button?.image = NSImage(systemSymbolName: "doc.badge.plus", accessibilityDescription: "File Summoner")
        
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Create New File...", action: #selector(createFile), keyEquivalent: "n"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))
        
        statusItem?.menu = menu
    }
}
```

### 6.4 Finder Extension (Sync Extension)

Create a Finder Sync Extension for deeper integration:

> **Note**: Finder Sync Extensions are deprecated in macOS 15+. Only implement if supporting older macOS versions.

### 6.5 Automator Action

Create an Automator action/Quick Action for right-click menu integration.

---

## Migration Checklist

### Pre-Migration
- [ ] Document current Go app behavior
- [ ] Screenshot current dialogs
- [ ] List all test cases
- [ ] Back up project

### Phase 1: Setup
- [ ] Create Xcode project
- [ ] Configure Info.plist
- [ ] Configure entitlements
- [ ] Migrate app icon

### Phase 2: Core Features
- [ ] Implement FinderService
- [ ] Implement FileService
- [ ] Implement AlertService
- [ ] Implement AppDelegate
- [ ] Verify feature parity

### Phase 3: UI
- [ ] Implement SwiftUI dialog (optional)
- [ ] Add localization
- [ ] Test keyboard shortcuts

### Phase 4: Build Pipeline
- [ ] Create build script
- [ ] Create notarization script
- [ ] Create DMG script
- [ ] Update GitHub Actions

### Phase 5: Testing
- [ ] Manual testing complete
- [ ] Unit tests pass
- [ ] Integration tests pass

### Post-Migration
- [ ] Update README.md
- [ ] Update AGENTS.md for Swift
- [ ] Archive Go codebase
- [ ] Release v2.0.0

---

## Risk Assessment

| Risk | Impact | Mitigation |
|------|--------|------------|
| AppleScript behavior changes in future macOS | High | Monitor Apple releases, have fallback |
| Notarization requirements change | Medium | Follow Apple developer updates |
| SwiftUI compatibility issues | Low | Use NSAlert as fallback |
| Build pipeline complexity | Medium | Document thoroughly, CI testing |

---

## Decision Log

| Date | Decision | Rationale |
|------|----------|-----------|
| TBD | Use NSAppleScript over ScriptingBridge | Simpler, recommended by Apple |
| TBD | Use NSAlert for MVP, SwiftUI optional | Faster implementation, native feel |
| TBD | Keep LSUIElement design | Maintains toolbar app behavior |
| TBD | macOS 11+ minimum | Broad compatibility while retaining SwiftUI App lifecycle |

---

## References

- [Apple: NSAppleScript](https://developer.apple.com/documentation/foundation/nsapplescript)
- [Apple: LSUIElement](https://developer.apple.com/documentation/bundleresources/information-property-list/lsuielement)
- [Apple: FileManager](https://developer.apple.com/documentation/foundation/filemanager)
- [Apple: NSAlert](https://developer.apple.com/documentation/appkit/nsalert)
- [WWDC 2024: Tailor macOS windows with SwiftUI](https://developer.apple.com/videos/play/wwdc2024/10148/)
- [Apple: Notarizing macOS Software](https://developer.apple.com/documentation/security/notarizing_macos_software_before_distribution)
