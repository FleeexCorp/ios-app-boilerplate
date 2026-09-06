# GlassCompat: Liquid Glass on iOS 26, classic on iOS 18

`DesignSystem/GlassCompat.swift` is the **only** file allowed to contain
`#available(iOS 26, *)`. Everything else calls its modifiers.

```swift
extension EnvironmentValues {
    /// Forces the iOS 18 rendering, for previews and UI tests on iOS 26.
    @Entry var dsForceLegacyGlass = false
}

extension View {
    func dsGlassButton() -> some View       // glass capsule button; bordered on material on iOS 18
    func dsGlassProminent() -> some View    // primary CTA tinted action.primary; .dsProminent on iOS 18
    func dsTabBarMinimize() -> some View    // floating tab bar minimizes on scroll; no-op on iOS 18
    func dsScrollEdge() -> some View        // soft scroll edge; material toolbar background on iOS 18
    func dsGlassBackground() -> some View   // sheet ground; .ultraThinMaterial on iOS 18
    func dsGlassEffect(in shape:) -> some View // custom chrome; material + hairline on iOS 18
}
```

Each `…Compat` modifier:

```swift
struct GlassButtonCompat: ViewModifier {
    @Environment(\.dsForceLegacyGlass) private var legacy
    func body(content: Content) -> some View {
        if #available(iOS 26, *), !legacy {
            content.buttonStyle(.glass)
        } else {
            content.buttonStyle(.bordered).background(.ultraThinMaterial, in: Capsule())
        }
    }
}
```

Rules:

- `accessibilityReduceTransparency` turns every fallback material into solid `surfaceDefault`.
- Primary CTAs call `dsGlassProminent()`; `.dsProminent` is its iOS 18 half, never used
  directly by a screen.
- Standard containers (`TabView`, toolbars, `.sheet`, `Menu`, `Picker`) get glass for free
  when built with the iOS 26 SDK: do not re-style them.
- Custom glass is for **controls and navigation surfaces only**, never for content cards.
  Cards stay `surface` + hairline on both OS versions.
- Keep one specular hairline; no gradients, no glows (charter).
- Every primitive using a `ds*` modifier ships two previews: default and
  `.environment(\.dsForceLegacyGlass, true)`.
- CI runs the unit tests on an iOS 26 and an iOS 18 simulator; `GlassCompatTests` hosts
  every modifier in both branches.
- When the deployment target moves to iOS 26, delete the `else` branches and the
  environment key; the call sites do not change.
