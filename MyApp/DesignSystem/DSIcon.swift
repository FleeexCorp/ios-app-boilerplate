import SwiftUI

/// The icon vocabulary of the app, mapped to SF Symbols.
///
/// Screens name what they mean, never a symbol string, so a symbol can be retuned in one
/// place and a house icon set can replace it without touching a call site. Add a case per
/// meaning the app needs; the prototypes' `data-icon` names should match these cases.
///
/// Cases whose raw value is omitted carry a symbol name identical to the case name.
enum DSIcon: String {
    // Navigation
    case home = "house"
    case homeSelected = "house.fill"
    case settings = "slider.horizontal.3"
    case chevron = "chevron.right"
    case back = "chevron.left"
    case close = "xmark"
    case external = "arrow.up.right.square"

    // Actions
    case plus
    case ellipsis
    case check = "checkmark"
    case copy = "doc.on.doc"
    case refresh = "arrow.clockwise"
    case trash
    case share = "square.and.arrow.up"
    case search = "magnifyingglass"
    case filter = "line.3.horizontal.decrease"

    // Feedback
    case warning = "exclamationmark.triangle"
    case info = "info.circle"
    case arrowUp = "arrow.up"
    case arrowDown = "arrow.down"

    // Common domain
    case doc = "doc.text"
    case person
    case clock
    case link
    case globe
    case envelope
    case bell
}

extension Image {
    /// Builds the SF Symbol behind a semantic icon.
    init(dsIcon: DSIcon) {
        self.init(systemName: dsIcon.rawValue)
    }
}
