import Testing
@testable import MyApp

/// The state a screen switches on, and the one thing it is there for: a failed refresh
/// keeps what the user was reading.
struct LoadStateTests {
    private static let failure = AppError(.offline)

    @Test func startsWithNothing() {
        let state = LoadState<Int>.idle

        #expect(state.value == nil)
        #expect(!state.isLoading)
        #expect(!state.isLoaded)
        #expect(state.error == nil)
        #expect(state.isPriming)
    }

    @Test func keepsTheValueItHasWhileReloading() {
        let state = LoadState.loaded(7).reloading

        #expect(state.isLoading)
        #expect(state.value == 7)
        #expect(!state.isPriming)
    }

    @Test func keepsTheValueItHadWhenTheReloadFailed() {
        let state = LoadState.loaded(7).reloading.settled(.failure(Self.failure))

        #expect(state.value == 7)
        #expect(state.error == Self.failure)
        #expect(!state.isLoaded)
    }

    @Test func hasNothingToKeepWhenTheFirstReadFailed() {
        let state = LoadState<Int>.idle.reloading.settled(.failure(Self.failure))

        #expect(state.value == nil)
        #expect(state.error == Self.failure)
        #expect(!state.isPriming)
    }

    @Test func replacesTheValueOnASuccessfulRead() {
        let state = LoadState.loaded(7).reloading.settled(.success(9))

        #expect(state.value == 9)
        #expect(state.isLoaded)
        #expect(state.error == nil)
    }

    @Test func mapsTheValueWithoutLosingTheState() {
        let state = LoadState.loaded(7).reloading.settled(.failure(Self.failure)).mapValue(String.init)

        #expect(state.value == "7")
        #expect(state.error == Self.failure)
    }
}
