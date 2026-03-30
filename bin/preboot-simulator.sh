#!/bin/bash

set -o pipefail

xcrun simctl boot "$SIMULATOR_UDID"
xcrun simctl list devices | grep "Booted"

if [ $? -ne 0 ]; then
    echo "Failed to boot the simulator with UDID: $SIMULATOR_UDID"
    exit 1
else
    echo "Simulator with UDID: $SIMULATOR_UDID is booted successfully."
fi