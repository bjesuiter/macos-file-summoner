#!/usr/bin/env bash
set -euo pipefail

APP_PATH="${1:-dist/File Summoner.app}"

log() { echo "[$(date '+%H:%M:%S')] $*"; }

: "${APPLE_DEVELOPER_ID_NAME:?Set APPLE_DEVELOPER_ID_NAME}"
: "${APPLE_ACCOUNT_APP_PASSWORD:?Set APPLE_ACCOUNT_APP_PASSWORD}"
: "${APPLE_TEAM_ID:?Set APPLE_TEAM_ID}"

ZIP_PATH="${APP_PATH%.app}.zip"

log "Creating ZIP for notarization..."
ditto -c -k --keepParent "${APP_PATH}" "${ZIP_PATH}"

log "Submitting for notarization..."
xcrun notarytool submit "${ZIP_PATH}" \
    --apple-id "${APPLE_DEVELOPER_ID_NAME}" \
    --password "${APPLE_ACCOUNT_APP_PASSWORD}" \
    --team-id "${APPLE_TEAM_ID}" \
    --wait

log "Stapling notarization ticket..."
xcrun stapler staple "${APP_PATH}"

rm -f "${ZIP_PATH}"

log "Notarization complete!"
