---
paths:
  - "MyApp/**/*.swift"
  - "MyAppTests/**/*.swift"
---

# SwiftUI and Swift rules

- State: `@Observable` classes, `@MainActor`. Never `ObservableObject` / `@Published`.
- A view is dumb: no networking, no formatting, no business branching. Logic lives in a
  `ViewModel` (`@Observable`) or a store, both testable without SwiftUI.
- One type per file; file named after the type. Views end with `View`, view models with `ViewModel`.
- `enum` over `Bool` for parameters with two meanings (`Surface.standard / .sunken`, not `isSunken`).
- Early return, no nested `if` pyramids. Braces always, even on one line.
- No magic numbers: spacing, radii and durations come from `DSSpace`, `DSRadius`, `DSMotion`.
  A dimension that belongs to one component lives in its `private enum Layout`.
  One exception, `ConfigErrorView`: it renders before the design system and the localization layer
  exist, so it hard-codes its own `Layout` constants and its bilingual copy. Nothing else may.
- Concurrency: `async/await`, structured tasks (`.task(id:)`), no `Task.detached` without a reason.
  Types crossing actors are `Sendable`.
- Errors: `AppError` (or a domain enum) mapped to i18n keys. Never surface a raw
  `Error.localizedDescription` to the user.
- Previews for every view: light, dark, and `dsForceLegacyGlass` when a `ds*` modifier is used,
  fed by mocks.
- Tests use Swift Testing (`@Test`, `#expect`), one behavior per test, mocks behind protocols.
- Accessibility: every control has a label; decorative images are hidden; charts carry an
  `accessibilityChartDescriptor`; targets clear 44 pt; Dynamic Type to AX3 without truncation.
