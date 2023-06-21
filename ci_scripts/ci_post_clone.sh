#!/bin/sh

#  ci_post_clone.sh
#  Bypass API
#
#  Created by Francisco Javier García Gutiérrez on 2023/06/22.
#  

if [ -z "$CRYPTO_KEY" ]
then
    echo "\$CRYPTO_KEY is empty. Please set the value and try again."
    exit 1
fi

file="Bypass API.xcodeproj/xcshareddata/xcschemes/Bypass API.xcscheme"

# Escape special characters in the CRYPTO_KEY variable for usage in the sed command
CRYPTO_KEY_ESCAPED=$(printf '%s\n' "$CRYPTO_KEY" | sed -e 's/[\/&]/\\&/g')

# Use sed to substitute the value attribute for the key CRYPTO_KEY
sed -i.bak -e '/key = "CRYPTO_KEY"/N;s/value = ""/value = "'"$CRYPTO_KEY_ESCAPED"'"/' "$file"

echo "CRYPTO_KEY updated successfully in $file"
