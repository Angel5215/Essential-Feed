#!/bin/bash

set -o pipefail

xcodebuild clean build test \
    -scheme $SCHEME \
    -sdk $TARGET_SDK \
    -destination $PLATFORM_DESTINATION \
    -enableThreadSanitizer YES \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    ONLY_ACTIVE_ARCH=YES | xcbeautify --disable-logging --renderer github-actions --quieter --is-ci


xcodebuild clean build test \
    -scheme "CI-iOS" \
    -sdk iphonesimulator \
    -destination "platform=iOS Simulator,OS=26.2,name=iPhone 17" \
    -enableThreadSanitizer YES \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    ONLY_ACTIVE_ARCH=YES | xcbeautify --disable-logging --renderer github-actions --quieter --is-ci