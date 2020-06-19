#!/usr/bin/env bash

###   Dependencies for this script       
### - an Apple Developer ID Certificate available inside macOS Keychain
### - https://www.npmjs.com/package/create-dmg (can be globally installed with npm)

function log() {
    echo 
    echo "${1}"
}

# Input Vars
# This env var should be filled with the secrets.APPLE_DEVELOPER_ID_NAME on gihub actions
APPLE_DEVELOPER_ID_NAME=${APPLE_DEVELOPER_ID_NAME:-Developer ID Application: Benjamin Jesuiter (BB38WRH6VJ)}

# logs the script name
log "-- $(basename ${0}) --"

DIST_DIR=${DIST_DIR:-dist}
# The resulting DMG file will have the form of 'File Summoner x.y.z.dmg'
create-dmg --overwrite ${DIST_DIR}/*.app --identity="${APPLE_DEVELOPER_ID_NAME}"
