import SwiftUI

/// The placeholder first screen: it exists so the boilerplate launches, tests and shows
/// the design system in both looks. The plan replaces it with the app's own shell.
struct HomeView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DSSpace.s3) {
                    Text("home.subtitle")
                        .font(DSTypography.label)
                        .foregroundStyle(DSColor.textMuted)

                    DSCard {
                        VStack(alignment: .leading, spacing: DSSpace.s2) {
                            Text("home.card.title")
                                .font(DSTypography.headline)
                                .foregroundStyle(DSColor.textPrimary)

                            Text("home.card.body")
                                .font(DSTypography.body)
                                .foregroundStyle(DSColor.textMuted)

                            StatusBadge(kind: .positive, text: String(localized: "home.card.status"))
                        }
                    }

                    Button("common.continue") {}
                        .dsGlassProminent()
                        .frame(maxWidth: .infinity)
                }
                .padding(DSSpace.s4)
            }
            .dsScrollEdge()
            .background(DSColor.bgDefault)
            .navigationTitle(Text("home.title"))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {} label: {
                        Image(dsIcon: .settings)
                    }
                    .accessibilityLabel(Text("home.settings"))
                    .dsGlassButton()
                }
            }
        }
        .accessibilityIdentifier(Identifier.root)
    }

    /// Hooks the UI smoke test finds the screen by.
    enum Identifier {
        static let root = "home.root"
    }
}

#Preview("Light") {
    HomeView()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    HomeView()
        .preferredColorScheme(.dark)
}

#Preview("iOS 18") {
    HomeView()
        .environment(\.dsForceLegacyGlass, true)
}
