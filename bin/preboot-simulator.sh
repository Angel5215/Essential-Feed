#!/bin/bash

set -o pipefail

SIMULATOR_UDID=$(xcrun simctl list devices --json | jq -r '
.devices["com.apple.CoreSimulator.SimRuntime.iOS-26-4"][] 
| select(.name == "iPhone 17") 
| .udid
')

echo "Attempting to boot the simulator with UDID: $SIMULATOR_UDID and name: $SIMULATOR_NAME for runtime: $SIMULATOR_RUNTIME"
xcrun simctl boot "$SIMULATOR_UDID"

if [ $? -ne 0 ]; then
    echo "Failed to boot the simulator with UDID: $SIMULATOR_UDID"
    exit 1
else
    echo "Simulator with UDID: $SIMULATOR_UDID is booted successfully."
    xcrun simctl list devices | grep "Booted"
fi