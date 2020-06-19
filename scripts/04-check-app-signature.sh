#!/usr/bin/env bash

function log() {
    echo 
    echo "${1}"
}

# Input Vars
DIST_DIR=${DIST_DIR:-dist}
MACOS_APP_ARTIFACT=${MACOS_APP_ARTIFACT:-'File Summoner.app'}

# logs the script name
log "-- $(basename ${0}) --"

log 'Check, whether the app is correctly signed and notarized'
spctl -a -vvvv "${DIST_DIR}/${MACOS_APP_ARTIFACT}"

log 'Some debug values from codesign tool'
# Useful command for checking code signature in verbosity level 4 manually
codesign -dv --verbose=4 "${DIST_DIR}/${MACOS_APP_ARTIFACT}"