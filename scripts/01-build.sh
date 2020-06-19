#!/usr/bin/env bash

# Input Vars
DIST_DIR=${DIST_DIR:-dist}
MACOS_APP_ARTIFACT=${MACOS_APP_ARTIFACT:-'File Summoner.app'}

# Local Vars
EXECUTABLE=macos-file-summoner
BUILD_DIR=build

echo 'Check GOOS and GOARCH before setting the variables...'
go env GOOS GOARCH

export GOOS=darwin
export GOARCH=amd64

echo 'Check GOOS and GOARCH after setting the variables...'
go env GOOS GOARCH

echo 'build go executable...'
go build -o ${BUILD_DIR}/${EXECUTABLE} .

echo 'clean dist folder...'
rm -rf ${DIST_DIR}
mkdir ${DIST_DIR}

echo 'copy mac-app-template/File Summoner.app to dist...'
cp -R "mac-app-template/File Summoner.app" ${DIST_DIR}/

# Rename the distribution App to the name defined in MACOS_APP_ARTIFACT
mv "${DIST_DIR}/File Summoner.app" "${DIST_DIR}/${MACOS_APP_ARTIFACT}"

echo "copy go binary into ${DIST_DIR}/${MACOS_APP_ARTIFACT}/Contents/MacOS/"
cp ${BUILD_DIR}/${EXECUTABLE} "${DIST_DIR}/${MACOS_APP_ARTIFACT}/Contents/MacOS/"

echo "cleanup placeholder for binary: ${DIST_DIR}/${MACOS_APP_ARTIFACT}/Contents/MacOS/.insert-binary-here"
rm -f "${DIST_DIR}/${MACOS_APP_ARTIFACT}/Contents/MacOS/.insert-binary-here"