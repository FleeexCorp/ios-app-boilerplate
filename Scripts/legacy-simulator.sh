#!/bin/sh
# Prints the UDID of an iPhone simulator running the legacy iOS major (18, the deployment
# target), creating the device when the machine has the runtime but not the device.
#
# The patch version drifts between machines (18.3.1 here, 18.6 on a CI image), so
# `-destination 'OS=18.3'` breaks as soon as the runtime is updated. Resolving to a UDID
# keeps the destination stable wherever the workflow runs.
set -eu

MAJOR=${LEGACY_IOS_MAJOR:-18}
NAME=${LEGACY_DEVICE_NAME:-iPhone 15}
TYPE=${LEGACY_DEVICE_TYPE:-com.apple.CoreSimulator.SimDeviceType.iPhone-15}

PICK_RUNTIME='
import json, sys

major = sys.argv[1]
prefix = "com.apple.CoreSimulator.SimRuntime.iOS-" + major + "-"
runtimes = [
    r for r in json.load(sys.stdin)["runtimes"]
    if r.get("isAvailable") and r["identifier"].startswith(prefix)
]

def version(runtime):
    return tuple(int(part) for part in runtime["version"].split("."))

print(max(runtimes, key=version)["identifier"] if runtimes else "")
'

PICK_DEVICE='
import json, sys

runtime, name = sys.argv[1], sys.argv[2]
devices = [
    d for d in json.load(sys.stdin)["devices"].get(runtime, [])
    if d.get("isAvailable") and d["name"] == name
]

print(devices[0]["udid"] if devices else "")
'

runtime=$(xcrun simctl list runtimes --json | python3 -c "$PICK_RUNTIME" "$MAJOR")

if [ -z "$runtime" ]; then
	echo "no available iOS $MAJOR simulator runtime; install one with 'xcodebuild -downloadPlatform iOS'" >&2
	exit 1
fi

udid=$(xcrun simctl list devices --json | python3 -c "$PICK_DEVICE" "$runtime" "$NAME")

if [ -z "$udid" ]; then
	udid=$(xcrun simctl create "$NAME" "$TYPE" "$runtime")
fi

echo "$udid"
