#!/usr/bin/env bash

DIST_DIR=${DIST_DIR:-dist}

# This action needs the APPLE_ACCOUNT_APP_PASSWORD variable set with an App Password for your apple account
echo '-- Notarize app --'

# This command needs the npm package json to be installed
echo 'Update path for app to notarize in gon-app.json config'
json -I -f scripts/gon-app.json -e "this.notarize[0].path='${DIST_DIR}/File Summoner.app'"

gon ./scripts/gon-app.json   