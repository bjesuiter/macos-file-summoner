#!/usr/bin/env bash
set -euo pipefail

log() { echo -e "\n==> ${1}"; }

BINARY_PATH="${1:-}"
if [ -z "$BINARY_PATH" ]; then
    echo "Error: Binary path not provided"
    echo "Usage: $0 <path-to-universal-binary>"
    exit 1
fi

DIST_DIR="dist"
APP_NAME="File Summoner.app"
APP_PATH="${DIST_DIR}/${APP_NAME}"
EXECUTABLE_NAME="macos-file-summoner"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENTITLEMENTS="${SCRIPT_DIR}/02-sign/entitlements.plist"

log "GoReleaser Post-Build: Assembling .app bundle, signing, notarizing, creating DMG"
log "Binary path: ${BINARY_PATH}"

if [ -z "${APPLE_DEVELOPER_ID_CODE:-}" ]; then
    log "WARNING: APPLE_DEVELOPER_ID_CODE not set - skipping signing/notarization"
    log "Set this env var to enable code signing"
    SKIP_SIGNING=true
else
    SKIP_SIGNING=false
fi

log "Step 1: Assembling .app bundle"
rm -rf "${APP_PATH}"
mkdir -p "${APP_PATH}"
cp -a "mac-app-template/." "${APP_PATH}/"
cp "${BINARY_PATH}" "${APP_PATH}/Contents/MacOS/${EXECUTABLE_NAME}"
rm -f "${APP_PATH}/Contents/MacOS/.insert-binary-here"
chmod +x "${APP_PATH}/Contents/MacOS/${EXECUTABLE_NAME}"

if [ "$SKIP_SIGNING" = true ]; then
    log "Skipping signing (no APPLE_DEVELOPER_ID_CODE)"
else
    log "Step 2: Signing .app bundle"
    
    find "$APP_PATH/Contents" -type f \( -name "*.dylib" -o -name "*.framework" \) \
        -exec codesign --force --timestamp --options runtime \
        --sign "$APPLE_DEVELOPER_ID_CODE" {} \; 2>/dev/null || true

    codesign --force --timestamp --options runtime \
        --entitlements "$ENTITLEMENTS" \
        --sign "$APPLE_DEVELOPER_ID_CODE" \
        "${APP_PATH}/Contents/MacOS/${EXECUTABLE_NAME}"

    codesign --force --timestamp --options runtime \
        --entitlements "$ENTITLEMENTS" \
        --sign "$APPLE_DEVELOPER_ID_CODE" \
        "$APP_PATH"

    log "Validating signature..."
    codesign --verify --verbose=2 "$APP_PATH"
fi

if [ "$SKIP_SIGNING" = true ]; then
    log "Skipping notarization (no signing credentials)"
elif [ -z "${APPLE_DEVELOPER_ID_NAME:-}" ] || [ -z "${APPLE_ACCOUNT_APP_PASSWORD:-}" ]; then
    log "WARNING: Notarization credentials not set - skipping notarization"
    log "Required: APPLE_DEVELOPER_ID_NAME, APPLE_ACCOUNT_APP_PASSWORD"
else
    log "Step 3: Notarizing .app bundle"
    
    APP_ZIP="${DIST_DIR}/${APP_NAME}.zip"
    ditto -c -k --rsrc --keepParent "$APP_PATH" "$APP_ZIP"

    NOTARY_CMD=(xcrun notarytool submit "$APP_ZIP"
        --apple-id "${APPLE_DEVELOPER_ID_NAME}"
        --password "${APPLE_ACCOUNT_APP_PASSWORD}"
        --wait)

    if [ -n "${APPLE_TEAM_ID:-}" ]; then
        NOTARY_CMD+=(--team-id "${APPLE_TEAM_ID}")
    fi

    "${NOTARY_CMD[@]}"

    log "Stapling notarization ticket..."
    xcrun stapler staple "$APP_PATH"
    
    log "Recreating zip with stapled app..."
    rm -f "$APP_ZIP"
    ditto -c -k --rsrc --keepParent "$APP_PATH" "$APP_ZIP"
fi

if [ -z "${APPLE_DEVELOPER_ID_LABEL:-}" ]; then
    log "WARNING: APPLE_DEVELOPER_ID_LABEL not set - skipping DMG creation"
    log "Set this env var to enable DMG packaging"
else
    log "Step 4: Creating DMG"
    
    if ! command -v bunx &> /dev/null; then
        log "WARNING: bunx not found - trying npx instead"
        NPX_CMD="npx"
    else
        NPX_CMD="bunx"
    fi
    
    $NPX_CMD create-dmg --overwrite "$APP_PATH" --identity="${APPLE_DEVELOPER_ID_LABEL}" || {
        log "DMG creation failed - this may be due to missing create-dmg"
        log "Install with: npm install -g create-dmg"
    }
    
    if ls ./*.dmg 1> /dev/null 2>&1; then
        mv ./*.dmg "${DIST_DIR}/"
        log "DMG moved to ${DIST_DIR}/"
    fi
fi

log "Post-build complete!"
log "Artifacts:"
ls -la "${DIST_DIR}/"*.app "${DIST_DIR}/"*.zip "${DIST_DIR}/"*.dmg 2>/dev/null || log "Some artifacts may be missing (check warnings above)"
