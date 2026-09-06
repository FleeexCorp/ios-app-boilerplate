import SwiftUI

/// What a list says when it has nothing to say.
///
/// One icon, one sentence in bold, one explaining it, and at most one way out. The icon is
/// drawn in `border.control` so it reads as furniture, not as an alarm.
struct EmptyState<Action: View>: View {
    let icon: DSIcon
    let title: String
    let message: String
    @ViewBuilder var action: Action

    @ScaledMetric(relativeTo: .largeTitle) private var iconSize = DSFontSize.xxl

    var body: some View {
        VStack(spacing: DSSpace.s3) {
            Image(dsIcon: icon)
                .font(.system(size: iconSize))
                .foregroundStyle(DSColor.borderControl)
                .accessibilityHidden(true)

            VStack(spacing: DSSpace.s1) {
                Text(title)
                    .font(DSTypography.bodyMedium)
                    .foregroundStyle(DSColor.textPrimary)

                Text(message)
                    .font(DSTypography.label)
                    .foregroundStyle(DSColor.textMuted)
            }
            .multilineTextAlignment(.center)
            .accessibilityElement(children: .combine)

            action
        }
        .frame(maxWidth: .infinity)
        .padding(DSSpace.s6)
    }
}

extension EmptyState where Action == EmptyView {
    init(icon: DSIcon, title: String, message: String) {
        self.init(icon: icon, title: title, message: message) {
            EmptyView()
        }
    }
}

#Preview("Light") {
    EmptyStatePreview()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    EmptyStatePreview()
        .preferredColorScheme(.dark)
}

private struct EmptyStatePreview: View {
    var body: some View {
        VStack(spacing: DSSpace.s5) {
            EmptyState(
                icon: .doc,
                title: "Nothing here yet",
                message: "Add a first item and it will show up here."
            ) {
                Button("Add an item") {}
                    .buttonStyle(.dsProminent)
            }

            EmptyState(
                icon: .search,
                title: "No result",
                message: "Try another word."
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(DSColor.bgDefault)
    }
}
