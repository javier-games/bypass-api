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

xmlstarlet ed --inplace -u "//EnvironmentVariable[@key='CRYPTO_KEY']/@value" -v "$CRYPTO_KEY" "$CI_PROJECT_FILE_PATH/xcshareddata/xcschemes/Bypass API.xcscheme"

echo "CRYPTO_KEY updated successfully in $CI_PROJECT_FILE_PATH/xcshareddata/xcschemes/Bypass API.xcscheme"
