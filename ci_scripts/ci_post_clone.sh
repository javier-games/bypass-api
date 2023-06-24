#!/bin/sh

#  ci_post_clone.sh
#  Bypass API
#
#  Created by Francisco Javier García Gutiérrez on 2023/06/22.
#  

set -e

if [ -z "$CRYPTO_PASS" ]
then
    echo "\$CRYPTO_PASS is empty. Please set the value and try again."
    exit 1
fi

if [ -z "$CRYPTO_SALT" ]
then
    echo "\$CRYPTO_SALT is empty. Please set the value and try again."
    exit 1
fi

echo "public struct EncryptionData { static let password = \"$CRYPTO_PASS\"; static let salt = \"$CRYPTO_SALT\"}" > "$CI_WORKSPACE/Requests/EncryptionData.swift"
