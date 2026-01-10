#!/bin/bash

set -o pipefail

DERIVED_DATA_PATH=DerivedData
ARCHIVE_PATH=$DERIVED_DATA_PATH/Archive/App.xcarchive
IPA_FOLDER=$DERIVED_DATA_PATH/ipa
EXPORT_OPTIONS_PATH=$RUNNER_TEMP/ExportOptions.plist

xcodebuild -exportArchive \
    -archivePath $ARCHIVE_PATH \
    -exportOptionsPlist $EXPORT_OPTIONS_PATH \
    -exportPath $IPA_FOLDER