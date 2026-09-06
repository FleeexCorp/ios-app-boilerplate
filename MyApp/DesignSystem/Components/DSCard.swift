import SwiftUI

/// The container every block of content sits in.
///
/// Depth comes from a hairline, never from a shadow: shadows are reserved for layers that
/// actually float above the page (menus, toasts, sheets).
struct DSCard<Content: View>: View {
    /// Which of the two card grounds this is.
    ///
    /// An enum rather than a `sunken` flag, so a call site reads as a surface and not as a
    /// switch.
    enum Surface: Sendable {
        /// The default card: surface on the page canvas.
        case standard

        /// A well inside a card: a code block, a table header, a nested list.
        case sunken
    }

    var surface: Surface = .standard
    @ViewBuilder var content: Content

    var body: some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(DSSpace.s4)
            .background(fill, in: shape)
            .overlay {
                shape.strokeBorder(stroke, lineWidth: DSLayout.hairline)
            }
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: DSRadius.lg)
    }

    private var fill: Color {
        switch surface {
        case .standard: DSColor.surfaceDefault
        case .sunken: DSColor.surfaceSunken
        }
    }

    private var stroke: Color {
        switch surface {
        case .standard: DSColor.borderDefault
        case .sunken: DSColor.borderSubtle
        }
    }
}

#Preview("Light") {
    DSCardPreview()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    DSCardPreview()
        .preferredColorScheme(.dark)
}

private struct DSCardPreview: View {
    var body: some View {
        VStack(spacing: DSSpace.s3) {
            DSCard {
                Text(verbatim: "A card holds one block of content and nothing more.")
                    .font(DSTypography.body)
                    .foregroundStyle(DSColor.textPrimary)
            }

            DSCard(surface: .sunken) {
                Text(verbatim: "itm_01J7ZK3Q9V8M2N4P6R8T")
                    .font(DSTypography.mono)
                    .foregroundStyle(DSColor.textPrimary)
            }
        }
        .padding(DSSpace.s4)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(DSColor.bgDefault)
    }
}
