#!/bin/bash

set -o pipefail

XCODE_APP=$(ls -d /Applications/Xcode_27*.app | sort -V | tail -n 1)

sudo xcode-select -switch "$XCODE_APP"
/usr/bin/xcodebuild -version