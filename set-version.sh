#!/bin/sh

if [ $# -ne 2 ]; then
    echo "Usage: $0 arg1 arg2"
    exit 1
fi

VERSION="$1"
NOTES="$2"

PROJECT_FILE="Bypass API.xcodeproj/project.pbxproj"
NOTES_FILE="TestFlight/WhatToTest.en-US.txt"

echo "You provided the following arguments:"
echo "Version: ${VERSION}"
echo "Notes: ${NOTES}"

echo "${VERSION}" > .VERSION
echo "${NOTES}" > "$NOTES_FILE"

#sed -i'' -e 's/#/\\-/g; s/\*/-/g' "$NOTES_FILE"
#echo "Fixed Notes: $(cat ${NOTES_FILE})"

PROJECT_FILE="Bypass API.xcodeproj/project.pbxproj"
sed -i'' -e '/Debug \*\/ = {/,/};/s/MARKETING_VERSION = [0-9]*\.[0-9]*\.[0-9]*/MARKETING_VERSION = '"$VERSION"'/g' "$PROJECT_FILE"
sed -i'' -e '/Release \*\/ = {/,/};/s/MARKETING_VERSION = [0-9]*\.[0-9]*\.[0-9]*/MARKETING_VERSION = '"$VERSION"'/g' "$PROJECT_FILE"