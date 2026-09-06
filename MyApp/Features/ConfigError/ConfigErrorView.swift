import SwiftUI

/// Shown instead of the app when the build configuration cannot work.
///
/// It renders before the design system and the localization layer exist, so it uses
/// plain SwiftUI, system fonts, and both languages side by side rather than a picked
/// one. This is the only view in the app allowed to hard-code user-facing strings.
///
/// Field names are listed, never their values: a value carries deployment detail that
/// has no business being shown on a device.
struct ConfigErrorView: View {
    let fields: [BuildConfigField]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Layout.sectionSpacing) {
                section(.english)
                section(.french)
            }
            .padding(Layout.padding)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func section(_ copy: Copy) -> some View {
        VStack(alignment: .leading, spacing: Layout.blockSpacing) {
            Text(verbatim: copy.title)
                .font(.title2.weight(.semibold))
                .accessibilityAddTraits(.isHeader)

            Text(verbatim: copy.intro)

            VStack(alignment: .leading, spacing: Layout.itemSpacing) {
                ForEach(fields, id: \.self) { field in
                    Text(verbatim: "\(Layout.bullet) \(field.rawValue)")
                        .font(.body.monospaced())
                }
            }

            Text(verbatim: copy.outro)
        }
        .environment(\.locale, copy.locale)
        .accessibilityElement(children: .contain)
    }

    private enum Layout {
        static let bullet = "•"
        static let sectionSpacing: CGFloat = 32
        static let blockSpacing: CGFloat = 12
        static let itemSpacing: CGFloat = 4
        static let padding: CGFloat = 24
    }

    /// One language's wording. Hard-coded on purpose, see the type's documentation.
    private struct Copy {
        let locale: Locale
        let title: String
        let intro: String
        let outro: String

        static let english = Copy(
            locale: Locale(identifier: "en"),
            title: "The application cannot start",
            intro: "These build settings are missing or invalid:",
            outro: "Contact whoever built this version: the build has to be made again."
        )

        static let french = Copy(
            locale: Locale(identifier: "fr"),
            title: "L'application ne peut pas démarrer",
            intro: "Ces paramètres de build sont manquants ou invalides :",
            outro: "Contactez la personne qui a produit cette version : le build doit être refait."
        )
    }
}

#Preview("Light") {
    ConfigErrorView(fields: [.apiBaseUrl])
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    ConfigErrorView(fields: BuildConfigField.allCases)
        .preferredColorScheme(.dark)
}

#Preview("AX3") {
    ConfigErrorView(fields: BuildConfigField.allCases)
        .dynamicTypeSize(.accessibility3)
}
