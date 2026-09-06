import SwiftUI

@main
struct MyAppApp: App {
    private let destination: RootDestination

    init() {
        destination = RootDestination.resolve(BuildConfig.fromBundle())
    }

    var body: some Scene {
        WindowGroup {
            RootView(destination: destination)
                // System controls (bordered buttons, links) pick up the tint as their label
                // colour on both OS versions; without it they fall back to system blue.
                .tint(DSColor.actionPrimary)
        }
    }
}
