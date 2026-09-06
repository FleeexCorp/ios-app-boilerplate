import SwiftUI

/// The three curves the app animates with, so a screen never writes a duration.
///
/// Durations come from `DSMotion`; the spring pair is Apple's, not a token, because a
/// spring is described by response and damping rather than by a length of time.
extension Animation {
    /// Press feedback and colour-only state changes.
    static let dsQuick = Animation.easeOut(duration: DSMotion.duration1)

    /// The default: layout changes, overlays appearing, content swapping.
    static let dsStandard = Animation.smooth(duration: DSMotion.duration3)

    /// Anything that moves under a finger, sheets first among them.
    static let dsSpring = Animation.spring(
        response: Spring.sheetResponse,
        dampingFraction: Spring.sheetDamping
    )

    private enum Spring {
        /// Apple's sheet pair, the one the prototypes' spring engine is tuned to.
        static let sheetResponse = 0.3
        static let sheetDamping = 0.8
    }
}

extension View {
    /// Animates `value` changes, and stops animating them under Reduce Motion.
    ///
    /// Prefer it to `.animation(_:value:)`: the accessibility setting is honoured once
    /// here instead of at every call site.
    func dsAnimation(_ animation: Animation, value: some Equatable) -> some View {
        modifier(DSAnimation(animation: animation, value: value))
    }
}

private struct DSAnimation<Value: Equatable>: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let animation: Animation
    let value: Value

    func body(content: Content) -> some View {
        content.animation(DSMotionMode(reduceMotion: reduceMotion).animation(animation), value: value)
    }
}
