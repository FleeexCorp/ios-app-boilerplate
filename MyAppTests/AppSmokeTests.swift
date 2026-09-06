import Testing
@testable import MyApp

struct AppSmokeTests {
    @Test func appVersionReadsTheHostBundle() {
        let version = AppVersion.read { ["CFBundleShortVersionString": "1.2.3", "CFBundleVersion": "42"][$0] }

        #expect(version.short == "1.2.3")
        #expect(version.build == "42")
    }

    @Test func appVersionNamesWhatTheBundleLacks() {
        let version = AppVersion.read { _ in nil }

        #expect(version.short == "?")
        #expect(version.build == "?")
    }
}
