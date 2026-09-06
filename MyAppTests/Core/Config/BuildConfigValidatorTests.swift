import Testing
@testable import MyApp

struct BuildConfigValidatorTests {
    @Test func acceptsAUsableConfiguration() {
        let config = BuildConfig(apiBaseUrl: "https://api.example.com")

        #expect(BuildConfigValidator.validate(config).isEmpty)
    }

    @Test(arguments: [
        "https://api.example.com",
        "http://localhost:3000",
        "https://api.example.com/v1",
    ])
    func acceptsAnOriginCallersCanSuffix(value: String) {
        #expect(BuildConfigValidator.isUsableBaseUrl(value))
    }

    @Test(arguments: [
        "",
        "api.example.com",
        "ftp://api.example.com",
        "https://api.example.com/",
        "https://api.example.com?x=1",
        "https://api.example.com#top",
        " https://api.example.com",
        "https://",
    ])
    func rejectsWhatWouldBuildADeadUrl(value: String) {
        #expect(!BuildConfigValidator.isUsableBaseUrl(value))
    }

    @Test func neverLeaksAValueIntoTheReportedList() {
        let secretish = "not-a-url"
        let fields = BuildConfigValidator.validate(BuildConfig(apiBaseUrl: secretish))

        #expect(fields == [.apiBaseUrl])
        #expect(!fields.map(\.rawValue).joined(separator: " ").contains(secretish))
    }
}
