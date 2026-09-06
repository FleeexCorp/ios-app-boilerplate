import SwiftUI

/// The type roles of the app, on the platform font and Apple's Dynamic Type styles.
///
/// The system face is the default for a reason: it ships optical sizing, tracking tables
/// and every accessibility size for free. A brand face replaces a role here, and only
/// here, with `Font.custom(DSFontFamily.body, size: DSFontSize.md, relativeTo: .subheadline)`
/// after the files are bundled and listed under `UIAppFonts` in `project.yml`.
enum DSTypography {
    /// The large title of a screen and the hero figure.
    static let display = Font.largeTitle.weight(.bold)

    /// Section and sheet titles.
    static let title = Font.title2.weight(.semibold)

    /// A stat value: always paired with `dsNumeric()`.
    static let kpi = Font.title.weight(.semibold)

    /// Emphasised body: row titles, button labels.
    static let headline = Font.headline

    /// Reading text.
    static let body = Font.body

    static let bodyMedium = Font.body.weight(.medium)

    /// Dense UI: secondary lines, form labels.
    static let label = Font.subheadline

    static let labelMedium = Font.subheadline.weight(.medium)

    /// Micro-labels: group headers, badges, timestamps.
    static let caption = Font.caption

    static let captionMedium = Font.caption.weight(.medium)

    /// Ids, keys, raw values.
    static let mono = Font.subheadline.monospaced()
}

extension View {
    /// Locks digits to a single width so amounts, counts and ids stay column-aligned.
    func dsNumeric() -> some View {
        monospacedDigit()
    }
}
