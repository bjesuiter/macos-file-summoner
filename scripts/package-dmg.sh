#!/usr/bin/env bash

echo '-- Package dmg --'
DIST_DIR=${DIST_DIR:-dist}
create-dmg --overwrite ${DIST_DIR}/*.app --identity="Developer ID Application: Benjamin Jesuiter (BB38WRH6VJ)"