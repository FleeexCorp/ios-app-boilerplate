---
name: ios-craft
description: >-
  The manufacturing standard of this app. Follow it WHENEVER you create or modify a
  SwiftUI screen, view, view model, store, service, mapping, design-system primitive,
  GlassCompat modifier, string, or test in this repo, or turn a design/*.html prototype
  into SwiftUI. Triggers on: "crée un écran", "ajoute une vue", "implémente la page X",
  "porte design/x.html", "ajoute un store", "ajoute un service", "branche l'endpoint",
  "ajoute une clé i18n", "scaffold", "refactore cette vue", any edit under the app
  folder. Enforces the layer boundaries, tokens only, GlassCompat-only #available,
  xcstrings en+fr, LoadState / MutationResult truth, AppError, 44pt targets, and the
  project invariants listed below. Use it even if the user doesn't say "skill". Pair it
  with swiftui-pro (review), swift-concurrency-pro, swift-testing-pro for the generic
  Swift rules; this skill carries what is specific to this app.
---

# ios-craft

Goal: every piece of code produced here is **small, layered, testable without SwiftUI,
tokenized, bilingual, and honest about failures**. Generic Swift and SwiftUI quality is
covered by `swiftui-pro`, `swift-concurrency-pro`, `swift-testing-pro`; this skill only
carries what is specific to this app.

Context: SwiftUI, Swift 6 strict concurrency, deployment target iOS 18, built with the
iOS 26 SDK (Liquid Glass on 26, classic on 18). Brief in `docs/product.md`, plan in
`.plan/`, prototypes in `design/`, tokens in `design/tokens.json`.

## Rule 0: before writing

1. **Which layer am I in?** `App → Features → Core → API`. A view never imports a network
   client, an SDK, `URLSession`, `UserDefaults`, `Keychain`. Read
   `references/architecture.md` for the shape of each layer and the file naming.
2. **Does the primitive already exist in `DesignSystem/`?** `DSCard`, `DSButtonStyle`
   (`.dsProminent`, `.dsTinted`, `.dsDanger`, `.dsDangerFilled`, `.dsGhost`),
   `StatusBadge`, `EmptyState`, `Skeleton` / `dsSkeleton`, `DSIcon`, `DSTypography`,
   `dsAnimation`, the `ds*` glass modifiers. Reuse, never re-style inline. A primitive the
   prototypes use twice goes to `DesignSystem/Components`, once to the feature's `Components`.
3. **Is there a prototype?** Every screen has one in `design/<screen>.html`. Read it first;
   `references/screen-from-prototype.md` maps its classes to SwiftUI.
4. **Is this money, a secret, a session, or a mutation?** Then the invariants below apply
   verbatim.

## Invariants (non-negotiable)

- **Tokens only.** Colors from `DSColor`, spacing from `DSSpace`, radii from `DSRadius`,
  type from `DSTypography`, durations from `DSMotion`. No literal `Color(red:)`, no
  literal `padding(13)`. A component's own dimensions live in its `private enum Layout`.
- **`#available(iOS 26, *)` exists in one file**: `DesignSystem/GlassCompat.swift`. Screens
  call `dsGlassButton()`, `dsGlassProminent()`, `dsTabBarMinimize()`, `dsScrollEdge()`,
  `dsGlassBackground()`, `dsGlassEffect(in:)`. See `references/glass-compat.md`.
- **Every user-facing string**, `accessibilityLabel` included, lives in
  `Localizable.xcstrings` with **en and fr filled in the same commit**. Keys:
  `zone.screen.element` (`home.card.title`). Formatters take a `Locale`; views read
  `@Environment(\.locale)`; `Locale.current` never appears in a view or a formatter.
- **Load truth.** Anything that loads is a `LoadState<T>`: the view switches on it and
  renders `Skeleton` (priming), `EmptyState`, content, or an inline error with Retry,
  keeping stale content visible under a failed refresh. No screen-wide error page.
- **Mutation truth.** A mutation that succeeded and a refresh that failed are two
  outcomes (`MutationResult`): show success plus a "could not refresh" note with Retry,
  never an error that hides the success.
- **Errors are `AppError`** (or a domain enum of the same shape) mapped to i18n keys, with
  an optional `technicalNote`. Never `error.localizedDescription` in UI.
- **Session scope.** Every store holding user data implements `Resettable`; nothing of a
  previous user survives a sign-out or a 401.
- **Secrets shown once.** Anything credential-like is never persisted, never logged (use
  `privacy: .private`), copied with an expiring pasteboard, rendered `.privacySensitive()`.
- **Accessibility floor**: 44 pt targets, Dynamic Type to AX3 without truncating figures,
  Reduce Motion honored through `dsAnimation`, every chart has an
  `accessibilityChartDescriptor`, status is color + icon + label.

## Project invariants

Filled in by `/kickoff` from `docs/product.md`. Until then, none.

- <e.g. Money is `Micros` (`Int64`); formatting goes through `Money.format`, never in a view.>
- <e.g. Admin is out of scope: never call `/admin/*`.>

## Shape of a feature (one folder under `<App>/Features/<Feature>/`)

```
Features/Library/
├── LibraryView.swift          # dumb: layout + bindings to the view model
├── LibraryViewModel.swift     # @Observable @MainActor, talks to stores/services
├── Components/
│   ├── LibraryRow.swift
│   └── AddItemSheet.swift
└── LibraryRoute.swift         # only if the feature owns sub-routes
```

- One type per file, file named after the type. `…View`, `…ViewModel`, `…Store`,
  `…Service`, `…Sheet`, `…Row`, `…Card`.
- A view model owns loading / error / data state as `LoadState<T>`; the view switches on it.
- Sheets are their own views, presented with `.sheet(item:)` on an enum of the feature's
  modals, never with several booleans.
- Destructive, irreversible actions use `confirmationDialog` or `alert`; everything else
  confirms inline.

## Tests expected with every task

- View model: one `@Test` per state transition, services behind protocols and mocked.
- Store: load, `reset()`, mutation success + refresh failure.
- Mapping: DTO → domain model, including optional and enum edge cases.
- Formatter: en and fr outputs.
- No test of SwiftUI layout. Previews (light, dark, `dsForceLegacyGlass`) are the visual
  check. See `references/testing.md`.

## Gates before handing back

```sh
make lint         # swiftformat --lint + swiftlint --strict (make format to fix)
make generate     # xcodegen + Package.resolved restore
make test         # iOS 26 simulator: unit + UI smoke
make test-legacy  # iOS 18 simulator: required when GlassCompat or the shell changed
make tokens       # when design/tokens.json changed; the generated files are versioned
```

Never call `xcodebuild` directly: the Makefile carries the `-skipPackagePluginValidation
-skipMacroValidation` flags and resolves the iOS 18 simulator by UDID.

Then a `/code-review` pass. No plan reference (task id, `.plan/` path) in code comments.

## Known traps

- A `Double` for an amount "just for the chart": convert at the chart boundary, keep the
  integer type everywhere else.
- `Locale.current` sneaking in through `Text(date, format:)`: pass `.environment(\.locale)`
  from the root and give formatters a `Locale` argument.
- `#available` inside a screen "because it's one line": move it to `GlassCompat`.
- A view that calls a service directly "to save a store": route through the store or the
  view model.
- A string added to `Localizable.xcstrings` in English only: the fr value is part of the
  same commit, even if it is a placeholder to review.
- `Task {}` fired from `init`: use `.task(id:)` on the view so it cancels with the view.
- Editing `DesignSystem/Generated`: it is regenerated from `tokens.json`; the change is lost.
