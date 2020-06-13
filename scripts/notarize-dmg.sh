#!/usr/bin/env bash

# This action needs the APPLE_ACCOUNT_APP_PASSWORD variable set with an App Password for your apple account
echo '-- Notarize dmg --'
# Notarize dmg locally with gon ./scripts/gon-dmg-local.hcl 
gon ./scripts/gon-dmg.json   