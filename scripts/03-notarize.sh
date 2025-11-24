#!/usr/bin/env bash

### Dependencies for this script:
### - xcrun notarytool (automatically enabled in github actions macOS runners)    
### - ditto - for zipping folders (already installed in macOS, at least on github runner with 10.15 Catalina)
### - xcrun - for stapling the .app folder (already installed in macOS from 10.15 Catalina with XCode)

function log() {
    echo 
    echo "${1}"
}

# Input Vars
# Required environment variables:
# - APPLE_DEVELOPER_ID_NAME: Your Apple ID email address
# - APPLE_ACCOUNT_APP_PASSWORD: App-specific password for your Apple account
# - APPLE_TEAM_ID: Your Apple Developer Team ID (optional, but recommended)
DIST_DIR=${DIST_DIR:-dist}
MACOS_APP_ARTIFACT=${MACOS_APP_ARTIFACT:-'File Summoner.app'}
MACOS_APP_ZIP=${MACOS_APP_ZIP:-$(echo "${MACOS_APP_ARTIFACT}.zip")}

# Validate required environment variables
if [ -z "$APPLE_DEVELOPER_ID_NAME" ]; then
    echo "Error: APPLE_DEVELOPER_ID_NAME environment variable is not set."
    exit 1
fi

if [ -z "$APPLE_ACCOUNT_APP_PASSWORD" ]; then
    echo "Error: APPLE_ACCOUNT_APP_PASSWORD environment variable is not set."
    exit 1
fi

# logs the script name
log "-- $(basename ${0}) --"

log "Zip App for notarization as ./${MACOS_APP_ZIP}"
ditto -c -k --rsrc --keepParent "${DIST_DIR}/${MACOS_APP_ARTIFACT}" "${MACOS_APP_ZIP}"

log 'Submitting app for notarization...'
# Build the notarytool submit command
NOTARY_CMD="xcrun notarytool submit \"${MACOS_APP_ZIP}\" --apple-id \"${APPLE_DEVELOPER_ID_NAME}\" --password \"${APPLE_ACCOUNT_APP_PASSWORD}\" --wait"

# Add team-id if provided (recommended for accounts with multiple teams)
if [ -n "$APPLE_TEAM_ID" ]; then
    NOTARY_CMD="${NOTARY_CMD} --team-id \"${APPLE_TEAM_ID}\""
fi

# Execute notarization
eval $NOTARY_CMD

# Check if notarization was successful
if [ $? -ne 0 ]; then
    echo "Error: Notarization failed. Check the output above for details."
    exit 1
fi

log 'Staple notarization ticket to app...'
xcrun stapler staple "${DIST_DIR}/${MACOS_APP_ARTIFACT}"

# Verify stapling was successful
if [ $? -ne 0 ]; then
    echo "Error: Stapling failed. The app may not have been notarized successfully."
    exit 1
fi

log 'Notarization and stapling completed successfully!'