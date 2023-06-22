#!/bin/sh

#  ci_post_clone.sh
#  Bypass API
#
#  Created by Francisco Javier García Gutiérrez on 2023/06/22.
#  

set -e

if [ -z "$CRYPTO_KEY" ]
then
    echo "\$CRYPTO_KEY is empty. Please set the value and try again."
    exit 1
fi

brew install xmlstarlet

SCHEME_FILE_PATH="$CI_PROJECT_FILE_PATH/xcshareddata/xcschemes/Bypass API.xcscheme"

xmlstarlet ed --inplace -u "//EnvironmentVariable[@key='CRYPTO_KEY']/@value" -v "$CRYPTO_KEY" "$SCHEME_FILE_PATH"

echo $(cat "$SCHEME_FILE_PATH")

echo "CRYPTO_KEY updated successfully in $SCHEME_FILE_PATH"
