import Foundation
import Testing
import UIKit
@testable import MyApp

/// `DSColor` resolves every role by name in the main bundle. A colour set missing from
/// the generated catalogue renders as a system default instead of failing, so the whole
/// roster is checked against `design/tokens.json`, the source the generator read.
struct ColorAssetTests {
    /// `text.on-action` -> `DSTextOnAction`, the generator's naming rule.
    private static let roles: [String] = {
        guard
            let url = Bundle(for: Marker.self).url(forResource: "tokens", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let colors = root["color"] as? [String: Any]
        else {
            return []
        }

        return colors.keys.sorted().map { role in
            let words = role.split(whereSeparator: { $0 == "." || $0 == "-" })
            return "DS" + words.map { $0.prefix(1).uppercased() + $0.dropFirst() }.joined()
        }
    }()

    private final class Marker {}

    @Test func readsTheTokenSource() {
        #expect(!Self.roles.isEmpty)
    }

    @Test(arguments: roles)
    func resolvesColorRole(name: String) {
        #expect(UIColor(named: name) != nil)
    }

    @Test func resolvesADistinctColorPerAppearance() {
        let color = UIColor(named: "DSBgDefault")
        let light = color?.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))
        let dark = color?.resolvedColor(with: UITraitCollection(userInterfaceStyle: .dark))

        #expect(light != nil)
        #expect(light != dark)
    }
}
