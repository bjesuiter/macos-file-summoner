#!/usr/bin/env bash

# This input param should be filled with the secrets.APPLE_DEVELOPER_ID_NAME on gihub actions
APPLE_DEVELOPER_ID_NAME=$1
APPLE_DEVELOPER_ID_NAME=${APPLE_DEVELOPER_ID_NAME:-Developer ID Application: Benjamin Jesuiter (BB38WRH6VJ)}

echo '-- Package dmg --'
DIST_DIR=${DIST_DIR:-dist}
create-dmg --overwrite ${DIST_DIR}/*.app --identity="${APPLE_DEVELOPER_ID_NAME}"