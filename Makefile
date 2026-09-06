# Entry point for every local and CI check. CI runs these exact targets.
#
# Toolchain (Homebrew, same versions in CI):
#   Xcode 26 (iOS 26 SDK)  ·  xcodegen 2.46  ·  swiftformat 0.63  ·  swiftlint 0.65
#   brew install xcodegen swiftformat swiftlint
#
# Some SPM packages ship build tool plugins or macros Xcode wants a human to trust, and
# that trust lives in the gitignored .xcodeproj. Every non-interactive xcodebuild therefore
# passes -skipPackagePluginValidation -skipMacroValidation.

SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c

PROJECT := MyApp.xcodeproj
SCHEME ?= MyApp-Staging
MODERN_DEVICE ?= iPhone 17
RESULTS := build/results

# XCB_EXTRA is CI's hook: it pins -clonedSourcePackagesDirPath so SPM checkouts can be cached.
XCB_EXTRA ?=
XCB_FLAGS := -skipPackagePluginValidation -skipMacroValidation -quiet $(XCB_EXTRA)

# Prettier output when xcbeautify happens to be installed, raw xcodebuild otherwise.
PRETTY := $(shell command -v xcbeautify >/dev/null 2>&1 && echo xcbeautify || echo cat)

.DEFAULT_GOAL := help

.PHONY: help
help: ## List the available targets
	@grep -hE '^[a-z-]+:.*?## ' $(MAKEFILE_LIST) | sort | awk -F':.*?## ' '{printf "  %-12s %s\n", $$1, $$2}'

.PHONY: generate
generate: ## Regenerate the Xcode project from project.yml
	xcodegen generate
	Scripts/sync-package-resolved.sh restore

.PHONY: tokens
tokens: ## Regenerate design/tokens.css and DesignSystem/Generated from design/tokens.json
	python3 Scripts/build-tokens.py

.PHONY: resolve
resolve: ## Resolve SPM dependencies and update the tracked Package.resolved
	xcodebuild -resolvePackageDependencies -project $(PROJECT) -scheme $(SCHEME) $(XCB_FLAGS)
	Scripts/sync-package-resolved.sh save

.PHONY: build
build: ## Build the app for the modern simulator
	xcodebuild build -project $(PROJECT) -scheme $(SCHEME) \
		-destination 'platform=iOS Simulator,name=$(MODERN_DEVICE)' $(XCB_FLAGS) | $(PRETTY)

.PHONY: test
test: test-unit test-ui ## Unit tests then UI smoke on the modern simulator (iOS 26, Liquid Glass)

# Xcode 26's test harness stalls at 0% CPU when the simulator carries state from a previous
# run (killed run, other device booted). Every test target therefore restarts the device.
define BOOT_MODERN
udid=$$(xcrun simctl list devices available -j | python3 -c 'import json,sys; d=json.load(sys.stdin); print(next(x["udid"] for v in d["devices"].values() for x in v if x["name"]=="$(MODERN_DEVICE)"))'); \
xcrun simctl shutdown all >/dev/null 2>&1 || true; \
xcrun simctl boot "$$udid" >/dev/null 2>&1 || true; \
xcrun simctl bootstatus "$$udid" -b >/dev/null
endef

.PHONY: test-unit
test-unit: ## Unit tests on the modern simulator (fast, no app launch)
	rm -rf $(RESULTS)/modern.xcresult
	$(BOOT_MODERN); \
	xcodebuild test -project $(PROJECT) -scheme $(SCHEME) \
		-destination "id=$$udid" -only-testing:MyAppTests \
		-resultBundlePath $(RESULTS)/modern.xcresult $(XCB_FLAGS) | $(PRETTY)

.PHONY: test-ui
test-ui: ## UI smoke on the modern simulator, freshly rebooted
	rm -rf $(RESULTS)/ui.xcresult
	$(BOOT_MODERN); \
	xcodebuild test -project $(PROJECT) -scheme $(SCHEME) \
		-destination "id=$$udid" -only-testing:MyAppUITests \
		-resultBundlePath $(RESULTS)/ui.xcresult $(XCB_FLAGS) | $(PRETTY)

.PHONY: test-legacy
test-legacy: ## Unit tests on the legacy simulator (iOS 18, classic look)
	rm -rf $(RESULTS)/legacy.xcresult
	# Unit tests only: the XCUITest harness stalls for 20+ minutes on the iOS 18 runtime
	# under Xcode 26 (the UI smoke runs on iOS 26 in `test`). The device is booted first
	# and waited for, because letting xcodebuild boot it is where the stall starts.
	udid=$$(Scripts/legacy-simulator.sh); \
	xcrun simctl boot "$$udid" 2>/dev/null || true; \
	xcrun simctl bootstatus "$$udid" -b >/dev/null; \
	xcodebuild test -project $(PROJECT) -scheme $(SCHEME) \
		-destination "id=$$udid" -only-testing:MyAppTests \
		-resultBundlePath $(RESULTS)/legacy.xcresult $(XCB_FLAGS) | $(PRETTY)

.PHONY: test-all
test-all: test test-legacy ## Test on both simulators

.PHONY: lint
lint: ## Check formatting and style without changing anything
	swiftformat --lint .
	swiftlint --strict

.PHONY: format
format: ## Apply formatting and the autocorrectable lint fixes
	swiftformat .
	# SwiftFormat 0.63 adds a trailing comma to only the first array nested in an
	# attribute argument list per file, which `@Test(arguments: [...])` hits constantly.
	# SwiftLint's own trailing_comma fix picks up the rest.
	swiftlint --fix

.PHONY: clean
clean: ## Remove build products and result bundles
	rm -rf build
	xcodebuild clean -project $(PROJECT) -scheme $(SCHEME) $(XCB_FLAGS) >/dev/null
