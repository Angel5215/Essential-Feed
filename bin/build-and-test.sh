#!/bin/bash

set -o pipefail

xcodebuild clean build test \
    -scheme "$SCHEME" \
    -sdk "$TARGET_SDK" \
    -destination "$PLATFORM_DESTINATION" \
    -enableThreadSanitizer YES \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    ONLY_ACTIVE_ARCH=YES | xcbeautify --disable-logging --renderer github-actions --preserve-unbeautified
