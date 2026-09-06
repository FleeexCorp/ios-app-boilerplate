#!/bin/sh
# Renames the boilerplate app in one pass: `MyApp` becomes the product name, the
# placeholder bundle id becomes yours, and the display name follows.
#
#   Scripts/rename.sh <ProductName> <bundle.id> [Display Name]
#   Scripts/rename.sh Fleeex io.fleeex.app fleeex
#
# The product name is a Swift module name: letters and digits, no space, no leading
# digit. It renames the target, the folders, the schemes, the test bundles and every
# mention in the tooling and the docs. Run it once, on a clean tree, then `make generate`.
set -eu

NAME=${1:-}
BUNDLE=${2:-}
DISPLAY=${3:-$NAME}
OLD_NAME=MyApp
OLD_BUNDLE=com.example.myapp

usage() {
	echo "usage: $(basename "$0") <ProductName> <bundle.id> [Display Name]" >&2
	exit 2
}

[ -n "$NAME" ] && [ -n "$BUNDLE" ] || usage

case "$NAME" in
*[!A-Za-z0-9]* | [0-9]*)
	echo "product name must be a Swift module name: letters and digits, no leading digit" >&2
	exit 2
	;;
esac

ROOT=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT"

if [ -n "$(git status --porcelain)" ]; then
	echo "working tree must be clean before renaming" >&2
	exit 1
fi

if [ ! -d "$OLD_NAME" ]; then
	echo "nothing named $OLD_NAME here: already renamed?" >&2
	exit 1
fi

# Folders and the entry point first, while the old paths still exist.
git mv "$OLD_NAME" "$NAME"
git mv "${OLD_NAME}Tests" "${NAME}Tests"
git mv "${OLD_NAME}UITests" "${NAME}UITests"
git mv "$NAME/App/${OLD_NAME}App.swift" "$NAME/App/${NAME}App.swift"

# Then every mention in tracked text files. Third-party skills are left alone: they never
# mention the app. `-I` skips binaries (fonts, images).
git ls-files -z \
	| grep -zv '^\.claude/skills/\(swift\|ios\|app-store\)' \
	| xargs -0 grep -lI -e "$OLD_NAME" -e "$OLD_BUNDLE" 2>/dev/null \
	| while IFS= read -r file; do
		sed -i '' \
			-e "s/$OLD_BUNDLE/$BUNDLE/g" \
			-e "s/$OLD_NAME/$NAME/g" \
			"$file"
	done

# The display name is a separate setting: it may carry spaces and lowercase.
sed -i '' "s/^APP_DISPLAY_NAME = .*/APP_DISPLAY_NAME = $DISPLAY/" Config/Base.xcconfig

echo "renamed $OLD_NAME to $NAME ($BUNDLE, display name '$DISPLAY')"
echo "next: make generate && make lint && make test, then commit 'chore: rename app to $NAME'"
