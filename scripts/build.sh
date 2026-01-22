#!/usr/bin/env bash
set -euo pipefail

PROJECT_NAME="FileSummoner"
SCHEME="FileSummoner"
CONFIGURATION="Release"
ARCHIVE_PATH="build/${PROJECT_NAME}.xcarchive"
EXPORT_PATH="dist"
EXPORT_OPTIONS_PLIST="scripts/ExportOptions.plist"

log() { echo "[$(date '+%H:%M:%S')] $*"; }

log "Building ${PROJECT_NAME}..."

rm -rf build/ dist/
mkdir -p build dist

xcodebuild archive \
    -project "${PROJECT_NAME}.xcodeproj" \
    -scheme "${SCHEME}" \
    -configuration "${CONFIGURATION}" \
    -archivePath "${ARCHIVE_PATH}" \
    CODE_SIGN_IDENTITY="${APPLE_DEVELOPER_ID_CODE:-}" \
    DEVELOPMENT_TEAM="${APPLE_TEAM_ID:-}"

xcodebuild -exportArchive \
    -archivePath "${ARCHIVE_PATH}" \
    -exportPath "${EXPORT_PATH}" \
    -exportOptionsPlist "${EXPORT_OPTIONS_PLIST}"

log "Build complete: ${EXPORT_PATH}/${PROJECT_NAME}.app"
