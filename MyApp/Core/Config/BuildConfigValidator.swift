import Foundation

/// Shape checks on the build configuration, run once before the app starts.
///
/// A build whose xcconfig values were never supplied still compiles and still launches,
/// while every call to the outside is dead. These checks give the launch something to
/// refuse on.
enum BuildConfigValidator {
    private static let httpScheme = "http"
    private static let httpsScheme = "https"

    /// Names the fields whose value cannot work at runtime, in declaration order. An
    /// empty array means the configuration is usable.
    ///
    /// Callers get field names only, never values.
    static func validate(_ config: BuildConfig) -> [BuildConfigField] {
        var invalid: [BuildConfigField] = []

        if !isUsableBaseUrl(config.apiBaseUrl) {
            invalid.append(.apiBaseUrl)
        }

        return invalid
    }

    /// An http(s) origin, optionally carrying a path prefix, that callers can suffix
    /// directly: `"\(apiBaseUrl)/items"`. A trailing slash, a query or a fragment would
    /// each build a URL the server never answers, so they count as invalid rather than
    /// untidy.
    static func isUsableBaseUrl(_ value: String) -> Bool {
        // The URL parser silently trims surrounding whitespace; the string concatenation
        // callers do does not, so padding has to be caught before parsing.
        if value.contains(where: \.isWhitespace) {
            return false
        }
        if value.hasSuffix("/") {
            return false
        }

        guard let url = URL(string: value) else {
            return false
        }
        guard let scheme = url.scheme?.lowercased(), scheme == httpScheme || scheme == httpsScheme else {
            return false
        }
        guard let host = url.host(), !host.isEmpty else {
            return false
        }

        return url.query() == nil && url.fragment() == nil
    }
}
