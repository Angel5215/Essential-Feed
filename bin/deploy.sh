#!/bin/bash

set -o pipefail

DERIVED_DATA_PATH=DerivedData
IPA_FOLDER=$DERIVED_DATA_PATH/ipa
IPA_PATH=$IPA_FOLDER/EssentialAppCaseStudy.ipa

xcrun altool --upload-app \
    --type ios \
    --file "$IPA_PATH" \
    --username "$USERNAME" \
    --password "$PASSWORD" \
    --verbose
