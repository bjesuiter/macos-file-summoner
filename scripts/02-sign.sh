#!/usr/bin/env bash

log() { echo -e "\n${1}"; }

# Input Vars
DIST_DIR=${DIST_DIR:-dist}
MACOS_APP_ARTIFACT=${MACOS_APP_ARTIFACT:-'File Summoner.app'}
IS_CI=${IS_CI:-false}

# Required Env Var
if [ -z "$APPLE_DEVELOPER_ID_CODE" ]; then
  echo "Error: APPLE_DEVELOPER_ID_CODE environment variable is not set."
  exit 1
fi

log "-- $(basename ${0}) --"

APP_PATH="${DIST_DIR}/${MACOS_APP_ARTIFACT}"
BIN_PATH="${APP_PATH}/Contents/MacOS/macos-file-summoner"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENTITLEMENTS="${SCRIPT_DIR}/02-sign/entitlements.plist"

# Sign nested binaries first (frameworks, helpers)
find "$APP_PATH/Contents" -type f \( -name "*.dylib" -o -name "*.framework" \) \
  -exec codesign --force --timestamp --options runtime \
  --sign "$APPLE_DEVELOPER_ID_CODE" {} \;

# Sign the binary with entitlements
codesign --force --timestamp --options runtime \
  --entitlements "$ENTITLEMENTS" \
  --sign "$APPLE_DEVELOPER_ID_CODE" "$BIN_PATH"

# Sign the main app with entitlements
codesign --force --timestamp --options runtime \
  --entitlements "$ENTITLEMENTS" \
  --sign "$APPLE_DEVELOPER_ID_CODE" "$APP_PATH"

log 'Validating signature...'
codesign --verify --verbose=2 "$APP_PATH"

# DO NOT RUN THIS IN GITHUB ACTIONS CI!: 
# Check notarization-readiness (offline check)
if [ "$IS_CI" = false ]; then
  spctl --assess --type execute --verbose=4 "$APP_PATH" || \
    log 'Warning: Gatekeeper check failed (expected if not yet notarized)'
fi