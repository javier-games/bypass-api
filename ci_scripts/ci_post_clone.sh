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

file="$CI_PROJECT_FILE_PATH/xcshareddata/xcschemes/Bypass API.xcscheme"

CRYPTO_KEY_ESCAPED=$(printf '%s\n' "$CRYPTO_KEY" | sed -e 's/[\/&]/\\&/g')

sed -i.bak -e '/key = "CRYPTO_KEY"/N;s/value = ""/value = "'"$CRYPTO_KEY_ESCAPED"'"/' "$file"

echo "CRYPTO_KEY updated successfully in $file"
