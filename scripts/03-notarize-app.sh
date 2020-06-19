#!/usr/bin/env bash

###   Dependencies for this script       
### - https://github.com/mitchellh/gon (can be installed via homebrew)  
### - https://www.npmjs.com/package/json (can be globally installed with npm)  
### - ditto - for zippingg folders (already installed in macOS, at least on github runner with 10.15 Catalina)
### - xcrun - for stapling the .app folder (already installed in macOS from 10.15 Catalina with XCode)

function log() {
    echo 
    echo "${1}"
}

# Input Vars
# This action needs the APPLE_ACCOUNT_APP_PASSWORD variable set with an App Password for your apple account
# Since this does not have any default value, it is not created here
DIST_DIR=${DIST_DIR:-dist}
MACOS_APP_ARTIFACT=${MACOS_APP_ARTIFACT:-'File Summoner.app'}

# Local Vars
MACOS_APP_ZIP="${MACOS_APP_ARTIFACT}.zip"

# logs the script name
log "-- $(basename ${0}) --"

log "Zip App for notarization as ./${MACOS_APP_ZIP}"
ditto -c -k --rsrc --keepParent "${DIST_DIR}/${MACOS_APP_ARTIFACT}" "${MACOS_APP_ZIP}"

# This command needs the npm package json to be installed
log "Update path in gon-app.json config for notarization to be ${MACOS_APP_ZIP}. (Since folders can't be notarized)" 
json -I -f scripts/gon-app.json -e "this.notarize[0].path='${MACOS_APP_ZIP}'"

log 'Notarize zipped app...'
gon ./scripts/gon-app.json   

log 'Staple original app folder after notarization...'
xcrun stapler staple "${DIST_DIR}/${MACOS_APP_ARTIFACT}"