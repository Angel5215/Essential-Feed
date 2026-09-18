#!/bin/bash

set -euo pipefail

# Helper paths for certificate, provisioning profile and ExportOptions.plist
CERTIFICATE_PATH=$RUNNER_TEMP/certificate.p12
PROVISIONING_PROFILE_PATH=$RUNNER_TEMP/profile.mobileprovision
KEYCHAIN_PATH=$RUNNER_TEMP/app-signing.keychain-db
EXPORT_OPTIONS_PATH=$RUNNER_TEMP/ExportOptions.plist

# Import certificate, provisioning profile, and ExportOptions.plist from secrets
echo -n "$CERTIFICATE_BASE64" | base64 --decode -o $CERTIFICATE_PATH
echo -n "$PROVISIONING_PROFILE_BASE64" | base64 --decode -o $PROVISIONING_PROFILE_PATH
echo -n "$EXPORT_OPTIONS_BASE64" | base64 --decode -o $EXPORT_OPTIONS_PATH

# Create temporary keychain
security create-keychain -p "$KEYCHAIN_PASSWORD" $KEYCHAIN_PATH
security set-keychain-settings -lut 21600 $KEYCHAIN_PATH
security unlock-keychain -p "$KEYCHAIN_PASSWORD" $KEYCHAIN_PATH

# Import certificate to keychain
security import $CERTIFICATE_PATH -P "$CERTIFICATE_PASSWORD" -A -t cert -f pkcs12 -k $KEYCHAIN_PATH
security set-key-partition-list -S apple-tool:,apple: -k "$KEYCHAIN_PASSWORD" $KEYCHAIN_PATH
security list-keychain -d user -s $KEYCHAIN_PATH

# Apply provisioning profile
mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles
cp $PROVISIONING_PROFILE_PATH ~/Library/MobileDevice/Provisioning\ Profiles/