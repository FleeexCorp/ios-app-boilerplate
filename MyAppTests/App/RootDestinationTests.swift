import Testing
@testable import MyApp

struct RootDestinationTests {
    @Test func aUsableConfigurationOpensTheApp() {
        let config = BuildConfig(apiBaseUrl: "https://api.example.com")

        #expect(RootDestination.resolve(config) == .app)
    }

    @Test func aBrokenConfigurationNamesItsFields() {
        let config = BuildConfig(apiBaseUrl: "")

        #expect(RootDestination.resolve(config) == .configError([.apiBaseUrl]))
    }
}
