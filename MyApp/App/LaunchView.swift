import SwiftUI

/// What is on screen while the app decides what to show first.
///
/// That usually takes milliseconds, and a spinner shown for milliseconds reads as a flicker
/// rather than as progress. So the canvas stands alone first, and only a wait long enough
/// to be noticed admits itself. The spinner's room is reserved from the start, so nothing
/// moves when it appears.
struct LaunchView: View {
    /// Milliseconds the canvas stands alone before the wait is worth acknowledging.
    private static let spinnerDelay = 300

    @State private var isSlow = false

    var body: some View {
        ProgressView()
            .tint(DSColor.textMuted)
            .opacity(isSlow ? Layout.shown : Layout.hidden)
            .accessibilityHidden(!isSlow)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(DSColor.bgDefault)
            .dsAnimation(.dsStandard, value: isSlow)
            .task {
                try? await Task.sleep(for: .milliseconds(Self.spinnerDelay))
                isSlow = true
            }
    }

    private enum Layout {
        static let shown: Double = 1
        static let hidden: Double = 0
    }
}

#Preview("Light") {
    LaunchView()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    LaunchView()
        .preferredColorScheme(.dark)
}
