import XCTest

/// The way in, walked on a real simulator: launch, then the first screen.
///
/// Elements are reached by identifier, so the copy can change without breaking the walk.
final class AppLaunchUITests: XCTestCase {
    private enum Identifier {
        static let home = "home.root"
    }

    private static let timeout: TimeInterval = 10

    @MainActor
    func testLaunchingShowsTheHomeScreen() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.otherElements[Identifier.home].firstMatch.waitForExistence(timeout: Self.timeout))
    }
}
