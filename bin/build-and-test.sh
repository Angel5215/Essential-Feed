#!/bin/bash

set -euo pipefail

RESULT_BUNDLE_PATH="TestResults.xcresult"
rm -rf "$RESULT_BUNDLE_PATH"

xcodebuild clean build test \
    -scheme "$SCHEME" \
    -sdk "$TARGET_SDK" \
    -destination "$PLATFORM_DESTINATION" \
    -enableThreadSanitizer YES \
    -resultBundlePath "$RESULT_BUNDLE_PATH" \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    ONLY_ACTIVE_ARCH=YES | xcbeautify --disable-logging --renderer github-actions --preserve-unbeautified
