#!/bin/bash

set -o pipefail

XCODE_VERSION=26.4

sudo xcode-select -switch /Applications/Xcode_${XCODE_VERSION}.app
/usr/bin/xcodebuild -version