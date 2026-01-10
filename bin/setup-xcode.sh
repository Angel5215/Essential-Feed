#!/bin/bash

set -o pipefail

XCODE_VERSION=26.2

sudo xcode-select -switch /Applications/Xcode_${XCODE_VERSION}.app
/usr/bin/xcodebuild -version