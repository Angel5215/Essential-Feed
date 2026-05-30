#!/bin/bash

set -o pipefail

DERIVED_DATA_PATH=DerivedData
ARCHIVE_PATH=$DERIVED_DATA_PATH/Archive/EssentialAppCaseStudy.xcarchive

WORKSPACE="Main.xcworkspace"
APP_SCHEME="EssentialAppCaseStudy"
BUILD_CONFIGURATION="Automation"

xcodebuild clean archive \
    -sdk iphoneos \
    -workspace $WORKSPACE \
    -configuration $BUILD_CONFIGURATION \
    -scheme $APP_SCHEME \
    -derivedDataPath $DERIVED_DATA_PATH \
    -archivePath $ARCHIVE_PATH | xcbeautify --disable-logging --renderer github-actions --preserve-unbeautified