#!/usr/bin/env bash

DIST_DIR=${DIST_DIR:-dist}
MACOS_APP_ARTIFACT=${MACOS_APP_ARTIFACT:-'File Summoner.app'}

echo '> sign mac app ...'
# Codesign is a xcode utility to signing mac apps via comand line
# Note: the '--options runtime' flag enables the macOS hardened runtime, 
#       which is needed for notarization
codesign --deep --force --verbose --options runtime --sign "BB38WRH6VJ" ${DIST_DIR}/*.app

echo '> validate signature itself ...'

# Check, whether the signature is valid 
codesign --verify -vvvv --deep --strict ${DIST_DIR}/*.app

# Check, whether the certificate used for the signature is valid
# Not working anymore, since apple requires notarization
echo '> validate certificate (Note: The app should be signed at this point but is probably not notarized) ...'
spctl -a -vvvv ${DIST_DIR}/*.app