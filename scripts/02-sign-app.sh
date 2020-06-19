#!/usr/bin/env bash

function log() {
    echo 
    echo "${1}"
}

# Input Vars
DIST_DIR=${DIST_DIR:-dist}
MACOS_APP_ARTIFACT=${MACOS_APP_ARTIFACT:-'File Summoner.app'}
APPLE_DEVELOPER_ID_CODE=${APPLE_DEVELOPER_ID_CODE:-BB38WRH6VJ}

# logs the script name
log "-- $(basename ${0}) --"

# Codesign is a xcode utility to signing mac apps via comand line
# Note: the '--options runtime' flag enables the macOS hardened runtime, 
#       which is needed for notarization
codesign --deep --force --verbose --options runtime --sign "${APPLE_DEVELOPER_ID_CODE}" ${DIST_DIR}/*.app

log 'validate signature itself with codesign ...'
codesign --verify -vvvv --deep --strict "${DIST_DIR}/${MACOS_APP_ARTIFACT}"

# Check, whether the certificate used for the signature is valid
# DO NOT ENABLE THIS HERE IN GITHUB ACTIONS -> has an exit code which is not 0 because the .app itself is not notarized at this point
# Will be run later when the app is notarized!
# spctl -a -vvvv ${DIST_DIR}/"${DIST_DIR}/${MACOS_APP_ARTIFACT}"

# Useful command for checking code signature in verbosity level 4 manually
# codesign -dv --verbose=4 dist/*.app 