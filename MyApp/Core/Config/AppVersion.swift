import Foundation

/// Which build of the app is running, as a settings footer states it.
///
/// It sits next to ``BuildConfig`` and reads the same `Info.plist`, but it is not
/// configuration: ``BuildConfig`` carries the values the xcconfig chooses, while this is
/// the bundle's own identity, the one thing a support conversation always starts with.
struct AppVersion: Sendable, Equatable {
    /// The marketing version, `CFBundleShortVersionString`.
    let short: String

    /// The build number, `CFBundleVersion`.
    let build: String
}

extension AppVersion {
    /// `Info.plist` keys the two figures live under.
    private enum Key {
        static let short = "CFBundleShortVersionString"
        static let build = "CFBundleVersion"
    }

    /// Stands in for a figure the bundle does not carry, which only happens in a test
    /// bundle: an empty parenthesis would read as a defect.
    private static let unknown = "?"

    /// The running build, read once. Immutable for the life of the process, so nothing
    /// gains from having it injected the way a configuration value is.
    static let current = fromBundle()

    static func fromBundle(_ bundle: Bundle = .main) -> AppVersion {
        read { bundle.object(forInfoDictionaryKey: $0) as? String }
    }

    /// Seam behind ``fromBundle(_:)``, so the mapping is testable without a bundle.
    static func read(_ entry: (String) -> String?) -> AppVersion {
        AppVersion(
            short: entry(Key.short) ?? unknown,
            build: entry(Key.build) ?? unknown
        )
    }
}
