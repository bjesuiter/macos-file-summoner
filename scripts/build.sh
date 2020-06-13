#!/usr/bin/env bash

EXECUTABLE=${EXECUTABLE:-macos-file-summoner}
BUILD_DIR=${BUILD_DIR:-build}
DIST_DIR=${DIST_DIR:-dist}

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
cp -R "mac-app-template/File Summoner.app" ${DIST_DIR}

echo 'copy go binary into dist/File Summoner.app/Contents/MacOS/'
cp ${BUILD_DIR}/${EXECUTABLE} "${DIST_DIR}/File Summoner.app/Contents/MacOS/"