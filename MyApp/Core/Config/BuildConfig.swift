import Foundation

/// Build-time configuration of the app: which backend to call, which identity provider to
/// authenticate against.
///
/// Values travel from `Config/*.xcconfig` into the bundle's `Info.plist` at build time.
/// This is the only type allowed to read `Bundle`; every layer above receives a value.
/// Add a field here, its `Info.plist` key in `project.yml`, its shape check in
/// ``BuildConfigValidator`` and its name in ``BuildConfigField``, in the same commit.
struct BuildConfig: Sendable, Equatable {
    /// Base URL of the API, without a trailing slash: callers suffix it directly.
    let apiBaseUrl: String
}

extension BuildConfig {
    /// `Info.plist` keys the xcconfig values land under.
    private enum Key {
        static let apiBaseUrl = "APIBaseURL"
    }

    /// Reads the configuration from a bundle's `Info.plist`.
    ///
    /// A key that is missing, or whose xcconfig variable was never defined, reads as an
    /// empty string, which ``BuildConfigValidator`` then rejects.
    static func fromBundle(_ bundle: Bundle = .main) -> BuildConfig {
        read { bundle.object(forInfoDictionaryKey: $0) as? String }
    }

    /// Seam behind ``fromBundle(_:)``, so the mapping is testable without a bundle.
    /// `entry` returns the raw `Info.plist` value for a key, or `nil` when absent.
    static func read(_ entry: (String) -> String?) -> BuildConfig {
        BuildConfig(apiBaseUrl: entry(Key.apiBaseUrl) ?? "")
    }
}
