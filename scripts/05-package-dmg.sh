#!/usr/bin/env bash

###   Dependencies for this script       
### - an Apple Developer ID Certificate available inside macOS Keychain
### - https://www.npmjs.com/package/create-dmg (can be globally installed with npm)

function log() {
    echo 
    echo "${1}"
}

# Required Env Var
if [ -z "$APPLE_DEVELOPER_ID_LABEL" ]; then
  echo "Error: APPLE_DEVELOPER_ID_LABEL environment variable is not set."
  exit 1
fi

# logs the script name
log "-- $(basename ${0}) --"

DIST_DIR=${DIST_DIR:-dist}
# The resulting DMG file will have the form of 'File Summoner x.y.z.dmg'
bunx create-dmg --overwrite "${DIST_DIR}/File Summoner.app" --identity="${APPLE_DEVELOPER_ID_LABEL}"
