# Architecture reference

```
┌──────────────── App ──────────────────────────────┐
│ @main · RootView · RootDestination · deep links   │
└───────────────────────┬────────────────────────────┘
                        ▼
┌──────────────── Features (SwiftUI) ───────────────┐
│ View ──binds──▶ ViewModel (@Observable, @MainActor)│
└───────────────────────┬────────────────────────────┘
                        ▼ reads / calls
┌──────────────── Core ─────────────────────────────┐
│ Stores (session-scoped, @Observable, Resettable)  │
│ Services facades · Config (BuildConfig) · Format  │
│ LoadState · MutationResult · AppError · AppLog    │
└───────────────────────┬────────────────────────────┘
                        ▼ calls
┌──────────────── API (when there is a backend) ────┐
│ Services: protocols + live impl; DTO → domain     │
│ Middlewares · Generated/ (never edited)           │
└────────────────────────────────────────────────────┘
        DesignSystem is a leaf every layer above Core may import.
```

## Dependency direction

- Features import Core and DesignSystem. Core imports API. API imports nothing above it.
- Transport or SDK types never appear outside `API/`. Each service has a `Mapping.swift`
  extension converting to `Sendable` domain structs.
- Dependencies are injected through `init`, with protocols (`ItemsServicing`,
  `AuthProviding`…). A single `AppDependencies` struct is built in the `@main` type and
  passed via `.environment`. A build whose configuration is invalid has no dependencies and
  shows `ConfigErrorView`.

## Stores

```swift
@MainActor @Observable
final class ItemsStore: Resettable {
    private(set) var items: LoadState<[Item]> = .idle

    func ensureLoaded() async      // no-op if already loaded for this session
    func forceRefresh() async
    func reset()                    // called on sign-out or 401
}
```

- `LoadState<T>`: `.idle`, `.loading(previous:)`, `.loaded`, `.failed(AppError, previous:)`.
  Keeping `previous` lets a refresh failure show stale data with a note instead of a blank.
- A generation counter per store so late responses from a previous session or a previous
  refresh are ignored.
- `MutationResult`: `.succeeded`, `.succeededButRefreshFailed(AppError)`, `.failed(AppError)`.

## Services

- One method per endpoint, domain types in and out, `async throws(AppError)`.
- Pagination returns `Page<T>` (`items`, `nextCursor`).
- Headers, retries and auth live in middlewares, never in a view model.

## Formatting

- Formatters are pure functions taking a `Locale`: `Money.format(_:currency:locale:)`,
  `RelativeDate.format(_:now:locale:)`. Tested in en and fr.
- Money is an integer minor-unit type (`Micros`, `Cents`), never `Double`.

## Navigation

- `enum Route: Hashable` per tab or flow. `DeepLinkRouter.route(for: URL) -> DeepLink?` is
  a pure function, tested. A pending deep link is held until the session is known.

## Configuration

- `BuildConfig` reads Info.plist keys injected from xcconfig; `BuildConfigValidator`
  returns invalid **field names**, never values. Invalid config renders `ConfigErrorView`
  instead of the app. Adding a field touches `project.yml`, `Config/*.xcconfig`,
  `BuildConfig`, `BuildConfigField`, `BuildConfigValidator` and their tests, in one commit.
