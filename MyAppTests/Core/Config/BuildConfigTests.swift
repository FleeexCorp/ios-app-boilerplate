import Foundation
import Testing
@testable import MyApp

struct BuildConfigTests {
    private static let entries = [
        "APIBaseURL": "https://api.staging.example.com",
    ]

    @Test func readsEveryInfoPlistKey() {
        let config = BuildConfig.read { Self.entries[$0] }

        #expect(config.apiBaseUrl == "https://api.staging.example.com")
        #expect(BuildConfigValidator.validate(config).isEmpty)
    }

    @Test func readsMissingKeysAsEmptyStrings() {
        let config = BuildConfig.read { _ in nil }

        #expect(config.apiBaseUrl.isEmpty)
        #expect(!BuildConfigValidator.validate(config).isEmpty)
    }

    /// Guards the xcconfig wiring itself: the `$()` trick that keeps `//` out of a URL,
    /// and the `$(VAR)` expansion Xcode performs on the generated `Info.plist`.
    @Test func hostBundleCarriesTheExpandedXcconfigValues() {
        let config = BuildConfig.fromBundle()

        #expect(config.apiBaseUrl.hasPrefix("http"))
        #expect(config.apiBaseUrl.contains("://"))
    }
}
