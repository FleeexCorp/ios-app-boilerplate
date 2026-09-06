import SwiftUI

/// Every button of the app, in five weights.
///
/// The shape is always the same capsule at the minimum touch target; only the fill and the
/// text colour change. Feedback happens on pointer-down, not on release: the label dips as
/// the finger lands, and holds until it lifts.
struct DSButtonStyle: ButtonStyle {
    enum Variant: Sendable, CaseIterable {
        /// The one primary action of a screen.
        case prominent

        /// A secondary action that still reads as an action.
        case tinted

        /// A destructive action offered among others.
        case danger

        /// A destructive action the user has already asked for.
        case dangerFilled

        /// A tertiary action, text only.
        case ghost
    }

    let variant: Variant

    func makeBody(configuration: Configuration) -> some View {
        StyledLabel(variant: variant, configuration: configuration)
    }

    private struct StyledLabel: View {
        @Environment(\.accessibilityReduceMotion) private var reduceMotion
        @Environment(\.isEnabled) private var isEnabled

        let variant: Variant
        let configuration: Configuration

        var body: some View {
            configuration.label
                .font(DSTypography.bodyMedium)
                .foregroundStyle(variant.foreground)
                .padding(.horizontal, variant.horizontalPadding)
                .frame(minHeight: DSLayout.minTouchTarget)
                .background(variant.background, in: .capsule)
                .opacity(isEnabled ? Layout.enabledOpacity : Layout.disabledOpacity)
                .scaleEffect(scale)
                .dsAnimation(.dsQuick, value: configuration.isPressed)
        }

        private var scale: CGFloat {
            guard configuration.isPressed, !reduceMotion else {
                return Layout.restingScale
            }

            return Layout.pressedScale
        }
    }
}

private enum Layout {
    /// The press dip of the prototypes: felt, not seen.
    static let pressedScale: CGFloat = 0.97
    static let restingScale: CGFloat = 1
    static let enabledOpacity: Double = 1
    static let disabledOpacity: Double = 0.45

    /// A status colour used as a fill behind its own text, as the prototypes mix it.
    static let tintOpacity: Double = 0.12
}

extension DSButtonStyle.Variant {
    var foreground: Color {
        switch self {
        case .prominent: DSColor.textOnAction
        case .tinted, .ghost: DSColor.actionPrimary
        case .danger: DSColor.dangerText
        case .dangerFilled: DSColor.textOnAction
        }
    }

    var background: Color {
        switch self {
        case .prominent: DSColor.actionPrimary
        case .tinted: DSColor.actionPrimary.opacity(Layout.tintOpacity)
        case .danger: DSColor.dangerDefault.opacity(Layout.tintOpacity)
        case .dangerFilled: DSColor.dangerDefault
        case .ghost: .clear
        }
    }

    /// A ghost button is text: it keeps only enough room to stay tappable.
    var horizontalPadding: CGFloat {
        self == .ghost ? DSSpace.s3 : DSSpace.s5
    }
}

extension ButtonStyle where Self == DSButtonStyle {
    static var dsProminent: Self {
        DSButtonStyle(variant: .prominent)
    }

    static var dsTinted: Self {
        DSButtonStyle(variant: .tinted)
    }

    static var dsDanger: Self {
        DSButtonStyle(variant: .danger)
    }

    static var dsDangerFilled: Self {
        DSButtonStyle(variant: .dangerFilled)
    }

    static var dsGhost: Self {
        DSButtonStyle(variant: .ghost)
    }
}

#Preview("Light") {
    DSButtonStylePreview()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    DSButtonStylePreview()
        .preferredColorScheme(.dark)
}

private struct DSButtonStylePreview: View {
    var body: some View {
        VStack(spacing: DSSpace.s3) {
            Button("Continue") {}
                .buttonStyle(.dsProminent)

            Button("Secondary") {}
                .buttonStyle(.dsTinted)

            Button("Remove") {}
                .buttonStyle(.dsDanger)

            Button("Delete") {}
                .buttonStyle(.dsDangerFilled)

            Button("Show more") {}
                .buttonStyle(.dsGhost)

            Button("Continue") {}
                .buttonStyle(.dsProminent)
                .disabled(true)
        }
        .padding(DSSpace.s4)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DSColor.bgDefault)
    }
}
