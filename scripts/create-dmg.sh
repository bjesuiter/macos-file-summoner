#!/usr/bin/env bash
set -euo pipefail

APP_PATH="${1:-dist/File Summoner.app}"
VERSION=$(defaults read "${APP_PATH}/Contents/Info.plist" CFBundleShortVersionString)
DMG_NAME="File Summoner ${VERSION}.dmg"
DMG_PATH="dist/${DMG_NAME}"

log() { echo "[$(date '+%H:%M:%S')] $*"; }

log "Creating DMG..."

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

if [[ -n "${APPLE_DEVELOPER_ID_CODE:-}" ]]; then
    log "Signing DMG..."
    codesign --force --sign "${APPLE_DEVELOPER_ID_CODE}" "${DMG_PATH}"
fi

log "DMG created: ${DMG_PATH}"
