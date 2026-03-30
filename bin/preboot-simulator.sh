#!/bin/bash

set -o pipefail

xcrun simctl boot "$SIMULATOR_UDID"
xcrun simctl list devices | grep "Booted"