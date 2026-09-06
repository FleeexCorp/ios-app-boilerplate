import SwiftUI

/// The one view the window holds, and the only place a launch decision becomes a screen.
///
/// The configuration decides whether the app can run at all, once, before anything else
/// exists. Session, routing and deep links come next and are built here as the plan adds
/// them: this view grows, the entry point does not.
struct RootView: View {
    let destination: RootDestination

    var body: some View {
        switch destination {
        case .app:
            HomeView()
        case let .configError(fields):
            ConfigErrorView(fields: fields)
        }
    }
}

#Preview("Light") {
    RootView(destination: .app)
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    RootView(destination: .app)
        .preferredColorScheme(.dark)
}

#Preview("Invalid configuration") {
    RootView(destination: .configError([.apiBaseUrl]))
}
