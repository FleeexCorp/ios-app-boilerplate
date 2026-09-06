import SwiftUI

/// A status, said three ways at once: a colour, a mark, and a word.
///
/// The label is not optional. Colour alone fails colour-blind users and fails in a
/// screenshot, so the charter forbids it.
struct StatusBadge: View {
    /// What the status means, which picks the colour pair.
    enum Kind: Sendable, CaseIterable {
        case neutral
        case positive
        case warn
        case danger
        case accent
    }

    /// The mark next to the word.
    enum Mark: Sendable, Equatable {
        /// The default dot of the prototypes.
        case dot

        /// An icon, when the status has one that says more than a dot.
        case icon(DSIcon)
    }

    let kind: Kind
    let text: String
    var mark: Mark = .dot

    @ScaledMetric(relativeTo: .caption) private var height = Layout.height
    @ScaledMetric(relativeTo: .caption) private var dotSize = Layout.dotSize

    var body: some View {
        HStack(spacing: Layout.spacing) {
            markView

            Text(text)
                .font(DSTypography.captionMedium)
                .foregroundStyle(kind.textColor)
        }
        .padding(.horizontal, DSSpace.s2)
        .frame(minHeight: height)
        .background(DSColor.surfaceSunken, in: .capsule)
        .overlay {
            Capsule().strokeBorder(DSColor.borderSubtle, lineWidth: DSLayout.hairline)
        }
        .fixedSize()
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var markView: some View {
        switch mark {
        case .dot:
            Circle()
                .fill(kind.markColor)
                .frame(width: dotSize, height: dotSize)
                .accessibilityHidden(true)
        case let .icon(icon):
            Image(dsIcon: icon)
                .font(DSTypography.captionMedium)
                .foregroundStyle(kind.markColor)
                .accessibilityHidden(true)
        }
    }

    private enum Layout {
        /// The 22 pt pill of the prototypes, scaled with the caption text style.
        static let height: CGFloat = 22

        /// The 6 pt status dot.
        static let dotSize: CGFloat = 6
        static let spacing: CGFloat = 5
    }
}

extension StatusBadge.Kind {
    /// Small text, so the `*Text` roles: the base status colours never reach AA at 12 pt.
    var textColor: Color {
        switch self {
        case .neutral: DSColor.textMuted
        case .positive: DSColor.positiveText
        case .warn: DSColor.warnText
        case .danger: DSColor.dangerText
        case .accent: DSColor.accentText
        }
    }

    /// A dot or an icon is a non-text mark, which is what the base roles are for.
    var markColor: Color {
        switch self {
        case .neutral: DSColor.textMuted
        case .positive: DSColor.positiveDefault
        case .warn: DSColor.warnDefault
        case .danger: DSColor.dangerDefault
        case .accent: DSColor.accentDefault
        }
    }
}

#Preview("Light") {
    StatusBadgePreview()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    StatusBadgePreview()
        .preferredColorScheme(.dark)
}

private struct StatusBadgePreview: View {
    var body: some View {
        VStack(alignment: .leading, spacing: DSSpace.s3) {
            StatusBadge(kind: .positive, text: "Active")
            StatusBadge(kind: .warn, text: "Pending", mark: .icon(.warning))
            StatusBadge(kind: .danger, text: "Blocked", mark: .icon(.close))
            StatusBadge(kind: .accent, text: "New")
            StatusBadge(kind: .neutral, text: "Archived")
        }
        .padding(DSSpace.s4)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(DSColor.bgDefault)
    }
}
