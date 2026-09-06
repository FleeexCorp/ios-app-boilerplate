#!/bin/sh
# Mirrors Package.resolved between the generated .xcodeproj and the repo root.
# The .xcodeproj is gitignored and wiped by `xcodegen generate`, so the root copy is the
# versioned one: `save` after resolving dependencies, `restore` right after generating.
set -eu

ROOT=$(cd "$(dirname "$0")/.." && pwd)
TRACKED="$ROOT/Package.resolved"
GENERATED="$ROOT/MyApp.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved"

usage() {
	echo "usage: $(basename "$0") save|restore" >&2
	exit 2
}

[ $# -eq 1 ] || usage

case "$1" in
save)
	[ -f "$GENERATED" ] || { echo "no resolved file at $GENERATED" >&2; exit 1; }
	cp "$GENERATED" "$TRACKED"
	echo "saved $TRACKED"
	;;
restore)
	[ -f "$TRACKED" ] || { echo "no tracked $TRACKED, nothing to restore"; exit 0; }
	mkdir -p "$(dirname "$GENERATED")"
	cp "$TRACKED" "$GENERATED"
	echo "restored $GENERATED"
	;;
*)
	usage
	;;
esac
