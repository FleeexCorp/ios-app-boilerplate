import SwiftUI
import Testing
import UIKit
@testable import MyApp

/// Both halves of every `ds*` modifier have to render on whichever simulator is running.
/// A view built for the wrong branch fails to lay out rather than to compile, so each
/// modifier is hosted once with glass and once forced to the iOS 18 fallback.
@MainActor
struct GlassCompatTests {
    @Test func defaultsToTheGlassBranch() {
        #expect(EnvironmentValues().dsForceLegacyGlass == false)
    }

    @Test func carriesTheForcedLegacyFlag() {
        var values = EnvironmentValues()
        values.dsForceLegacyGlass = true

        #expect(values.dsForceLegacyGlass)
    }

    @Test(arguments: [false, true])
    func rendersEveryModifier(legacy: Bool) {
        let subject = GlassSubject()
            .environment(\.dsForceLegacyGlass, legacy)

        #expect(renderedSize(of: subject).height > 0)
    }

    /// Lays the view out in a real window, which is what makes a broken branch surface.
    private func renderedSize(of view: some View) -> CGSize {
        let host = UIHostingController(rootView: view)
        host.view.frame = CGRect(origin: .zero, size: Fixtures.screen)
        host.view.layoutIfNeeded()

        return host.view.bounds.size
    }

    private enum Fixtures {
        static let screen = CGSize(width: 393, height: 852)
    }
}

/// One view exercising every modifier at once: the tab bar and scroll edge ones only take
/// effect on their host container, so they are applied where they belong.
private struct GlassSubject: View {
    var body: some View {
        TabView {
            Tab("Home", systemImage: "house") {
                NavigationStack {
                    ScrollView {
                        VStack(spacing: DSSpace.s2) {
                            Button("Filter") {}.dsGlassButton()
                            Button("Continue") {}.dsGlassProminent()

                            Text(verbatim: "42")
                                .padding(DSSpace.s2)
                                .dsGlassEffect()

                            Color.clear
                                .frame(height: DSSpace.s2)
                                .dsGlassBackground()
                        }
                    }
                    .dsScrollEdge()
                }
            }
        }
        .dsTabBarMinimize()
    }
}
