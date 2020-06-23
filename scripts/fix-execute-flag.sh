#!/usr/bin/env bash

# TODO: Improve script with failsafety of input path, 
# see import-mysql.sh from flavia for that

# ${1} will be used as path to the executable which should be tested
EXECUTABLE_PATH=${1}

echo "Testing input file whether it's exec flag (-x) is set or not"
echo Input File: ${EXECUTABLE_PATH}

if [[ -x ${EXECUTABLE_PATH} ]]
then
    echo 'File is executable'
else 
    echo 'File is NOT executable, attempting chmod...'
    chmod +x ${EXECUTABLE_PATH}
    if [[ -x ${EXECUTABLE_PATH} ]]
    then
        echo "File is NOW executable!"
    else 
        # TODO: Make it configurable if script calls exit or does only return non-zero exit code
        echo 'File is STILL NOT executable, quitting...'
        exit 1
    fi
fi