import SwiftUI

/// The grey shape that stands in for content while it loads.
///
/// The shimmer is a solid band crossing a sunken well, never a gradient: the charter
/// forbids gradients, and a translating band reads the same. Reduce Motion removes the
/// band and leaves the well, which still says "loading" without moving anything.
struct Skeleton: View {
    var width: CGFloat?
    var height: CGFloat = DSSpace.s3
    var radius: CGFloat = DSRadius.sm

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var phase = Layout.startPhase

    var body: some View {
        shape
            .fill(DSColor.surfaceSunken)
            .frame(width: width, height: height)
            .overlay { shimmer }
            .clipShape(shape)
            .accessibilityHidden(true)
    }

    @ViewBuilder
    private var shimmer: some View {
        if reduceMotion {
            EmptyView()
        } else {
            GeometryReader { proxy in
                Rectangle()
                    .fill(DSColor.bgHover)
                    .offset(x: phase * proxy.size.width)
            }
            .onAppear {
                withAnimation(
                    .linear(duration: Layout.shimmerDuration).repeatForever(autoreverses: false)
                ) {
                    phase = Layout.endPhase
                }
            }
        }
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: radius)
    }

    private enum Layout {
        /// Phases are multiples of the width: the band enters left and exits right.
        static let startPhase: CGFloat = -1
        static let endPhase: CGFloat = 1

        /// One sweep, in seconds. Slower than any interaction duration on purpose: it is
        /// ambient, not feedback, so it has no motion token.
        static let shimmerDuration: Double = 1.4
    }
}

extension View {
    /// Redacts the view while it is waiting for its data.
    ///
    /// Pair it with `Skeleton` when the placeholder needs a shape of its own; use it alone
    /// when the real layout is already there and only the values are missing.
    func dsSkeleton(_ loading: Bool) -> some View {
        redacted(reason: loading ? .placeholder : [])
            .allowsHitTesting(!loading)
    }
}

#Preview("Light") {
    SkeletonPreview()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    SkeletonPreview()
        .preferredColorScheme(.dark)
}

private struct SkeletonPreview: View {
    var body: some View {
        VStack(alignment: .leading, spacing: DSSpace.s3) {
            DSCard {
                VStack(alignment: .leading, spacing: DSSpace.s2) {
                    Skeleton(width: DSSpace.s8, height: DSSpace.s3)
                    Skeleton(height: DSSpace.s5, radius: DSRadius.md)
                }
            }

            DSCard {
                Text(verbatim: "Loaded content, redacted")
                    .font(DSTypography.body)
                    .dsSkeleton(true)
            }
        }
        .padding(DSSpace.s4)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(DSColor.bgDefault)
    }
}
