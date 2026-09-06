import SwiftUI

/// Whether motion may play, as the accessibility setting reports it.
///
/// It exists so the decision is a value a test can make, rather than an environment read
/// buried in a view. Views convert once, at the boundary: `DSMotionMode(reduceMotion:)`.
enum DSMotionMode: Sendable, CaseIterable {
    case full
    case reduced

    init(reduceMotion: Bool) {
        self = reduceMotion ? .reduced : .full
    }

    /// The animation to actually run, or `nil` to apply the change without animating it.
    ///
    /// `nil` rather than a near-zero duration: SwiftUI then skips the transaction entirely
    /// instead of scheduling a frame nobody sees. `DSMotion.duration0` stays for the CSS
    /// prototypes, which need an `animationend` to fire.
    func animation(_ animation: Animation) -> Animation? {
        switch self {
        case .full: animation
        case .reduced: nil
        }
    }
}
