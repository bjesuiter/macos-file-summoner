#!/usr/bin/env bash

# This action needs the APPLE_ACCOUNT_APP_PASSWORD variable set with an App Password for your apple account
echo '-- Notarize dmg --'

# This command needs the npm package json to be installed
echo 'Update path for dmg to notarize in gon-dmg.json config'
json -I -f scripts/gon-dmg.json -e "this.notarize[0].path='File Summoner $(cat ./version).dmg'"

# Notarize dmg locally with gon ./scripts/gon-dmg-local.hcl 
gon ./scripts/gon-dmg.json   