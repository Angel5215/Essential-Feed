#!/bin/bash

set -o pipefail

SIMULATOR_UDID=$(xcrun simctl list devices --json | jq -r '
.devices["com.apple.CoreSimulator.SimRuntime.iOS-$SIMULATOR_RUNTIME"][] 
| select(.name == "$SIMULATOR_NAME") 
| .udid
')

echo "Attempting to boot the simulator with UDID: $SIMULATOR_UDID ($SIMULATOR_NAME - $SIMULATOR_RUNTIME)"
xcrun simctl boot "$SIMULATOR_UDID"

if [ $? -ne 0 ]; then
    echo "Failed to boot the simulator with UDID: $SIMULATOR_UDID"
    exit 1
else
    echo "Simulator with UDID: $SIMULATOR_UDID is booted successfully."
    xcrun simctl list devices | grep "Booted"
fi