# ios-app-boilerplate

A starting point for a native iOS app (Swift 6, SwiftUI, iOS 18+, Liquid Glass on iOS 26)
with the Claude Code workflow that built `fleeex-ios`: grill the product, prototype the
screens in HTML, plan in commits, execute one agent per task.

## What you get

- A project that builds, lints and tests on iOS 26 and iOS 18 from day one: XcodeGen,
  xcconfig configuration with validation, SwiftFormat + SwiftLint, a Makefile, GitHub CI.
- A design system skeleton: `design/tokens.json` → CSS for prototypes and Swift + asset
  catalog for the app (`make tokens`), `GlassCompat` (glass on 26, classic on 18),
  typography on Dynamic Type, `DSCard`, `DSButtonStyle`, `StatusBadge`, `EmptyState`,
  `Skeleton`, `LoadState`, `MutationResult`, `AppError`, strings in en and fr.
- A prototype kit: `design/glass.css` + `design/app.js` (device frame, glass chrome,
  draggable spring sheets, tab bar, menus, alerts, toasts) and a gallery.
- The Claude environment: rules, permissions, Xcode MCP, 7 house skills and 15 audited
  third-party Swift skills. See [`.claude/skills/README.md`](.claude/skills/README.md).

## Requirements

- macOS 26 and **Xcode 26** (iOS 26 SDK). The deployment target is iOS 18.0, but the Liquid
  Glass APIs need the newer SDK.
- Command line tools, all from Homebrew:

```sh
brew install xcodegen swiftformat swiftlint
brew install xcbeautify   # optional, prettier build output
```

- An iOS 26 simulator (iPhone 17) for `make test`, and an iOS 18 runtime for `make test-legacy`.
  Install a missing runtime with `xcodebuild -downloadPlatform iOS`.

## Start an app

```sh
git clone <this repo> my-app && cd my-app
make generate && make test      # the boilerplate is green before you touch it
claude                          # then, in Claude Code:
/kickoff une app qui …
```

`/kickoff` walks four steps and stops at each for your approval:

| Step | Skill | Output |
|---|---|---|
| 1 | `/grill-product` | `docs/product.md`: pitch, killer flow, v1 screens, cuts, store rules, decisions, design direction, identity |
| 2 | `Scripts/rename.sh` | the project renamed (`MyApp` → your name, bundle id, display name) |
| 3 | `/design-prototypes` | `design/*.html`: one prototype per screen, every state, en + fr, light + dark |
| 4 | `/create-plan` | `.plan/`: overview, phases, `PROGRESS.md` |

Then `/apply-plan 01`, one phase at a time. Each step can also be run on its own.

## Commands

`make` on its own lists every target:

| Target | What it does |
|---|---|
| `make generate` | Regenerates `MyApp.xcodeproj` from `project.yml` |
| `make tokens` | Regenerates `design/tokens.css` and `MyApp/DesignSystem/Generated` from `design/tokens.json` |
| `make build` | Builds for iPhone 17 (iOS 26) |
| `make test` | Unit tests and UI smoke on iPhone 17 (iOS 26, Liquid Glass) |
| `make test-legacy` | Unit tests on iPhone 15 (iOS 18, classic look) |
| `make test-all` | Both simulators |
| `make lint` | `swiftformat --lint` + `swiftlint --strict` |
| `make format` | Applies SwiftFormat, then `swiftlint --fix` |
| `make resolve` | Resolves SPM and updates the tracked `Package.resolved` |
| `make clean` | Removes build products and result bundles |

Always go through `make`, not raw `xcodebuild`: every non-interactive build needs
`-skipPackagePluginValidation -skipMacroValidation`, and the iOS 18 simulator is resolved
by UDID.

## Configuration

Two build configurations, one scheme each: `MyApp-Staging` (debug) and `MyApp-Production`
(release). Values live in `Config/*.xcconfig`, reach the bundle through `Info.plist` keys and
are read by `Core/Config/BuildConfig.swift` alone. They are public deployment identifiers:
no secret belongs in an xcconfig. An unusable value launches the app on a bilingual
configuration error screen listing the field names, never their values.

Local overrides (a local API, a Personal Team for your own iPhone):

```sh
cp Config/Local.xcconfig.example Config/Local.xcconfig
```

## Design prototypes

`design/` holds the kit and one functional HTML prototype per screen. They are the pixel
and motion reference for the SwiftUI implementation.

```sh
python3 -m http.server 8765 --directory design   # then open http://localhost:8765/index.html
```

## Layout

```
Config/            xcconfig per configuration
Scripts/           build-tokens.py, rename.sh, legacy-simulator.sh, sync-package-resolved.sh
MyApp/App          entry point, root routing
MyApp/Core         config, errors, log, session, stores
MyApp/DesignSystem generated tokens, GlassCompat, typography, icons, primitives
MyApp/Features     one folder per screen
MyApp/Resources    Localizable.xcstrings (en, fr), assets, privacy manifest
MyAppTests/        Swift Testing
MyAppUITests/      XCUITest smoke
design/            tokens.json, kit, prototypes, gallery
.claude/           rules, skills, permissions, launch config
```
