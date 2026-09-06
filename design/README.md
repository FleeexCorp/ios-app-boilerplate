# design/

Interactive HTML prototypes of every screen of the app. They are the pixel and motion
reference for the SwiftUI implementation described in `../.plan/`, one file per screen,
every state reachable, en and fr, light and dark.

Open `index.html` for the gallery, or any screen directly. Serve the folder over HTTP
(`python3 -m http.server 8765`, or the `design` entry of `.claude/launch.json`) so the
gallery iframes load.

## What is where

| File | Role |
|---|---|
| `tokens.json` | The source of truth for colours, type, spacing, radii, motion. `make tokens` regenerates the two outputs below plus `MyApp/DesignSystem/Generated`. |
| `tokens.css` | Generated. Never edited here. |
| `glass.css` | The Liquid Glass layer on top of the tokens: device frame, glass material, chrome, floating tab bar, sheets, primitives. Shared by every screen. |
| `app.js` | Behavior: spring engine, draggable sheets (velocity handoff, momentum projection, rubber-band, interruptible), tab bar minimize on scroll, menus, alerts, toast, copy, theme, language. |
| `home.html` | A sample screen showing the kit: chrome, title block, four states via `?state=`, list rows, sheets, menu, alert, tab bar. Replace it with the app's own screens. |
| `index.html` | Gallery of every screen and state, with theme and language toggles. |

The classes and data attributes the kit offers are catalogued in
`.claude/skills/design-prototypes/references/kit.md`.

## Liquid Glass, within the charter

Glass here is a **material**, not a wash:

- `backdrop-filter: blur() saturate()` over a `color-mix` of the `surface` token;
- one specular hairline (`inset 0 1px 0`) and one shade hairline; no colored light;
- content scrolls **under** the chrome; the only "gradient" is a `mask-image` on a blur
  edge, which is a transparency ramp, not a painted color;
- concentric corners: children of a sheet use `sheet-radius − padding`;
- reduced transparency and increased contrast fall back to solid surfaces.

Springs use Apple's damping / response pairs (sheet 0.8 / 0.3, UI 1.0 / 0.3), and
every sheet animation starts from its live on-screen value.

## SwiftUI mapping

Deployment target is iOS 18; the glass column applies on iOS 26 and the fallback column on 18.
Both live behind the `ds*` modifiers of `DesignSystem/GlassCompat.swift`.

| Prototype | SwiftUI iOS 26 | Fallback iOS 18 |
|---|---|---|
| `.glass` chrome buttons | `.buttonStyle(.glass)`, `ToolbarItemGroup` | `.buttonStyle(.bordered)` on `.ultraThinMaterial` |
| `.tabbar` minimizing | `TabView` + `.tabBarMinimizeBehavior(.onScrollDown)` | `TabView`, standard bar |
| `.sheet` + drag | `.sheet(item:)` with `.presentationDetents`, glass by default | same API, `.presentationBackground(.ultraThinMaterial)` |
| `.edge` | scroll edge effect, `.scrollEdgeEffectStyle(.soft, for: .top)` | `.toolbarBackground(.ultraThinMaterial)` |
| `.segmented` | `Picker(.segmented)` | same |
| `.alert` | `.alert` / `.confirmationDialog`, destructive actions only | same |
| `.menu` | `Menu` anchored to its button | same |
| `.btn--prominent` | `.buttonStyle(.glassProminent)` tinted `action.primary` | `.borderedProminent` |
| `.card` | `DSCard` | same |
| `.pill` | `StatusBadge` | same |
| `.empty` | `EmptyState` | same |
| `.skeleton` | `Skeleton`, `dsSkeleton(_:)` | same |
| `data-en / data-fr` | `Localizable.xcstrings` | same |
| `?state=` | the view model's `enum` state; every value in the prototype must exist | same |
