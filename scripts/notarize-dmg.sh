#!/usr/bin/env bash

function log() {
    echo 
    echo "${1}"
}

###   Dependencies for this script       
### - an Apple Account App Password for the developer account used to sign the dmg!
### - https://www.npmjs.com/package/json (can be globally installed with npm)

# logs the script name
log "-- $(basename ${0}) --"

log 'Update path for dmg to notarize in gon-dmg.json config'
json -I -f scripts/gon-dmg.json -e "this.notarize[0].path='File Summoner $(cat ./version).dmg'"

# Notarize dmg locally with gon ./scripts/gon-dmg-local.hcl 
gon ./scripts/gon-dmg.json   