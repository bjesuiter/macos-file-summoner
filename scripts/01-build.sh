#!/usr/bin/env bash

function log() {
    echo 
    echo "${1}"
}

# Input Vars
DIST_DIR=${DIST_DIR:-dist}
MACOS_APP_ARTIFACT=${MACOS_APP_ARTIFACT:-'File Summoner.app'}

# Local Vars
EXECUTABLE=macos-file-summoner
BUILD_DIR=build

# logs the script name
log "-- $(basename ${0}) --"

log 'build go executable...'
GOOS=darwin GOARCH=arm64 go build -o ${BUILD_DIR}/${EXECUTABLE} .

log 'check, whether new executable has executable flag set & fix it if necessary'
./scripts/helpers/fix-execute-flag.sh "${BUILD_DIR}/${EXECUTABLE}"

log 'clean dist folder...'
rm -rf "${DIST_DIR}"    
mkdir "${DIST_DIR}"

log "create target folder: ${DIST_DIR}/${MACOS_APP_ARTIFACT}/"
mkdir -p "${DIST_DIR}/${MACOS_APP_ARTIFACT}/"

log "copy mac-app-template/* to ${DIST_DIR}/${MACOS_APP_ARTIFACT}/"
cp -a "mac-app-template/." "${DIST_DIR}/${MACOS_APP_ARTIFACT}/"

log "copy go binary into ${DIST_DIR}/${MACOS_APP_ARTIFACT}/Contents/MacOS/${EXECUTABLE}"
cp ${BUILD_DIR}/${EXECUTABLE} "${DIST_DIR}/${MACOS_APP_ARTIFACT}/Contents/MacOS/"

log "cleanup placeholder for binary: ${DIST_DIR}/${MACOS_APP_ARTIFACT}/Contents/MacOS/.insert-binary-here"
rm -f "${DIST_DIR}/${MACOS_APP_ARTIFACT}/Contents/MacOS/.insert-binary-here"