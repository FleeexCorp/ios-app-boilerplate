# Testing reference

Swift Testing only (`import Testing`). One behavior per `@Test`, named as a sentence.

## Mocks

Every service protocol has a `Mock…` in `<App>Tests/Mocks/` with stubbed results:

```swift
final class MockItemsService: ItemsServicing, @unchecked Sendable {
    var itemsResult: Result<[Item], AppError> = .success([.fixture()])
    var deleteCalls: [Item.ID] = []
    func items() async throws(AppError) -> [Item] { try itemsResult.get() }
    func delete(_ id: Item.ID) async throws(AppError) { deleteCalls.append(id) }
}
```

Fixtures live on the domain types: `Item.fixture(name: String = "First")`.

## What to test where

| Layer | Tests |
|---|---|
| `Mapping.swift` | every DTO → domain conversion, nil and unknown enum values |
| Formatters | en and fr, zero, negative, large values |
| `DeepLinkRouter`, `BuildConfigValidator` | pure functions, table-driven with `@Test(arguments:)` |
| Stores | `ensureLoaded` is idempotent; `forceRefresh` keeps previous data on failure; `reset()` clears; late response after reset is ignored |
| View models | each state transition, `MutationResult` variants surface the right UI state |
| Auth (if any) | state machine with a mock provider; `expireSession()` signs out once under concurrent 401s |
| UI (XCUITest) | smoke only: launch → first screen; mocked sign-in → shell; tab count; run on iOS 26 (`make test`) |

## Async

- Use `await` directly; never `sleep` to wait for a state. Expose `Task` handles or
  `AsyncStream` on the store when a test needs to observe ordering.
- `@MainActor` on tests touching stores and view models.
- Confirm cancellation: a view model started with `.task(id:)` must not update state after
  its task is cancelled.

## UI tests

Launch arguments (`-uiTesting`, `-signedIn`) swap the live dependencies for fixtures in the
`@main` type, under `#if DEBUG`. Elements are reached by `accessibilityIdentifier`, never by
copy, so a wording change does not break the walk.

## Previews are the visual test

Every view: `#Preview("Light")`, `#Preview("Dark")` with `.preferredColorScheme(.dark)`,
and `#Preview("iOS 18")` with `.environment(\.dsForceLegacyGlass, true)` when a `ds*`
modifier is used, all fed by mocks.
