import os

/// The app's loggers, one per area. Values that identify a person (email, ids, tokens)
/// are interpolated with `privacy: .private` at every call site.
enum AppLog {
    private static let subsystem = "com.example.myapp"

    static let app = Logger(subsystem: subsystem, category: "app")

    static let api = Logger(subsystem: subsystem, category: "api")
}
