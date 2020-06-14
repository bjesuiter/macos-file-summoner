#!/usr/bin/env bash

DIST_DIR=${DIST_DIR:-dist}
MACOS_APP_ARTIFACT=${MACOS_APP_ARTIFACT:-'File Summoner.app'}
APPLE_DEVELOPER_ID_CODE=${APPLE_DEVELOPER_ID_CODE:-BB38WRH6VJ}

echo '> sign mac app ...'
# Codesign is a xcode utility to signing mac apps via comand line
# Note: the '--options runtime' flag enables the macOS hardened runtime, 
#       which is needed for notarization
codesign --deep --force --verbose --options runtime --sign "${APPLE_DEVELOPER_ID_CODE}" ${DIST_DIR}/*.app

echo '> validate signature itself ...'
codesign --verify -vvvv --deep --strict ${DIST_DIR}/*.app

# Check, whether the certificate used for the signature is valid
# Not working anymore, since apple requires notarization
echo '> validate certificate used for the signature (Note: The app should be signed at this point but is probably not notarized) ...'
spctl -a -vvvv ${DIST_DIR}/*.app