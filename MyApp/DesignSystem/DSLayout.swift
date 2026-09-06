import CoreGraphics

/// Structural dimensions the token pipeline does not carry, because they answer to the
/// platform rather than to the brand.
///
/// Anything narrower than "every control in the app" belongs to a component's own
/// `private enum Layout`, not here.
enum DSLayout {
    /// The smallest comfortable hit area on iOS. Every tappable control clears it.
    static let minTouchTarget: CGFloat = 44

    /// Width of a hairline border or separator, the 1 px rule of the prototypes.
    /// The hairline tokens carry an alpha tuned for exactly this width.
    static let hairline: CGFloat = 1
}
