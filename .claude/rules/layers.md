# Layer boundaries

```
MyApp/App          entry point, root routing, deep links
      ↓
MyApp/Features     views, view models (one folder per screen)
      ↓
MyApp/Core         stores, session, service facades, config, formatters
      ↓
MyApp/API          domain services, middlewares, generated client (when the app has a backend)
```

Each layer talks only to the one directly below it. No hole punching.

- `Features` may import `Core` and `DesignSystem`. Never a network client, an SDK,
  `URLSession`, `UserDefaults`, `Keychain`.
- `Core` may import `API`. It exposes domain models and stores, never transport types.
- `API` owns everything network. Generated or SDK types never leave `MyApp/API/`: services
  map them to `Sendable` domain structs at the boundary.
- `DesignSystem` is a leaf: it imports nothing from `Features`, `Core` or `API`.
- A view holds no logic: no networking, no formatting, no business branching. That lives in a
  `ViewModel` or a store, testable without SwiftUI.

## Single-owner rules

- Only `Core/Config/BuildConfig.swift` (and its sibling `AppVersion`) reads `Bundle`. Every
  layer above receives a value.
- Only `DesignSystem/GlassCompat.swift` uses `#available(iOS 26, *)`. Screens call its `ds*`
  modifiers.
- Only stores touch `UserDefaults`. A view reads and writes through the store.
- Formatters take a `Locale` argument; views read `@Environment(\.locale)`. `Locale.current`
  appears in one place at most (the service that decides the app language), never in a view
  or a formatter.
- Only the API layer knows HTTP. Errors reach the UI as `AppError` (or a domain enum of its
  own, mapped to i18n keys).

## Generated code

`MyApp/DesignSystem/Generated/` (from `design/tokens.json`, `make tokens`) and any
`MyApp/API/Generated/` are regenerated, never edited. A needed change belongs to the
generator, to `tokens.json`, or to a hand-written extension outside those folders.
