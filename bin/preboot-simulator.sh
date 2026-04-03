#!/bin/bash

set -o pipefail

SIMULATOR_UDID=$(xcrun simctl list devices --json | jq -r \
  --arg runtime "$SIMULATOR_RUNTIME" \
  --arg name "$SIMULATOR_NAME" \
  '.devices["com.apple.CoreSimulator.SimRuntime.iOS-\($runtime)"][] | select(.name == $name) | .udid'
)

if [ -z "$SIMULATOR_UDID" ]; then
    echo "ERROR: Could not find simulator $SIMULATOR_NAME for runtime iOS-$SIMULATOR_RUNTIME"
    xcrun simctl list devices available
    exit 1
fi

echo "Attempting to boot the simulator with UDID: $SIMULATOR_UDID ($SIMULATOR_NAME - $SIMULATOR_RUNTIME)"
xcrun simctl boot "$SIMULATOR_UDID"

if [ $? -ne 0 ]; then
    echo "Failed to boot the simulator with UDID: $SIMULATOR_UDID"
    exit 2
else
    echo "Simulator with UDID: $SIMULATOR_UDID is booted successfully."
    xcrun simctl list devices | grep "Booted"
fi