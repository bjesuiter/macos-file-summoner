#!/usr/bin/env bash

DIST_DIR=${DIST_DIR:-dist}
create-dmg --overwrite ${DIST_DIR}/*.app --identity="Developer ID Application: Benjamin Jesuiter (BB38WRH6VJ)"