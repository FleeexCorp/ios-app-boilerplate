/// What the app shows at launch, decided from the build configuration alone.
///
/// Pure and free of SwiftUI so the launch decision stays testable.
enum RootDestination: Equatable {
    case app
    case configError([BuildConfigField])

    /// `.configError` when the configuration cannot work, naming the offending fields.
    static func resolve(_ config: BuildConfig) -> RootDestination {
        let invalid = BuildConfigValidator.validate(config)

        guard invalid.isEmpty else {
            return .configError(invalid)
        }

        return .app
    }
}
