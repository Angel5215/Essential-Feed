#!/bin/bash

set -euo pipefail

XCODE_APP=$(ls -d /Applications/Xcode_27*.app 2>/dev/null | sort -V | tail -n 1) || true

if [ -z "$XCODE_APP" ]; then
    echo "ERROR: No Xcode 27 installation found under /Applications"
    exit 1
fi

sudo xcode-select -switch "$XCODE_APP"
/usr/bin/xcodebuild -version