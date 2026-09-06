# From `design/<screen>.html` to SwiftUI

Read the prototype in a browser first (`python3 -m http.server 8765 --directory design`), in
light and dark, and try its sheets and states (`?state=`). Then map, do not reinterpret.

| Prototype class / behavior | SwiftUI |
|---|---|
| `.device`, `.screen` | `NavigationStack` inside the tab's `TabView` slot; content in a `ScrollView` with `dsScrollEdge()` |
| `.chrome` buttons (`.icon-btn.glass`) | `.toolbar { ToolbarItem { Button } }` + `dsGlassButton()`; grouped buttons → `ToolbarItemGroup` |
| `.chrome__title` compact + `.title-block` large | `.navigationTitle` with `.navigationBarTitleDisplayMode(.large)`; the lead paragraph is the first `Text` of the content |
| `.tabbar` (minimizing) | `TabView` with `Tab(title, systemImage:)` + `dsTabBarMinimize()` |
| `.card`, `.card--sunken` | `DSCard`, `DSCard(surface: .sunken)` |
| `.list` + `.row` | `List` with `.listStyle(.insetGrouped)`, or a `VStack` of feature rows inside `DSCard` for dense rows |
| `.stat`, `.stat__value--hero` | a `StatTile` primitive (create it in `DesignSystem/Components` when two screens need it) with `dsNumeric()` |
| `.pill` | `StatusBadge(kind:text:mark:)` |
| `.meter` | a `Meter` primitive; fill from the base status role, label beside it |
| `.bars` | Swift Charts `BarMark`, `DSDataViz.palette`, `accessibilityChartDescriptor` |
| `.banner` | an inline notice view with icon + text + optional Retry |
| `.sheet` | a dedicated `…Sheet` view, `.sheet(item:)`, `.presentationDetents([.medium, .large])`, `.presentationDragIndicator(.visible)`, `dsGlassBackground()` |
| `.alert` | `.confirmationDialog` / `.alert` for destructive actions only |
| `.menu` | `Menu { Button… }` on the toolbar button |
| `.toast` | an overlay driven by a `ToastCenter` (auto-dismiss 1.8 s) |
| `.segmented` | `Picker(selection:) { }.pickerStyle(.segmented)` |
| `.chips` | horizontal `ScrollView` of toggle chips |
| `.otp` | an `OTPField` (boxes over a hidden `TextField` with `.textContentType(.oneTimeCode)`) |
| `.empty` | `EmptyState(icon:title:message:action:)` |
| `.skeleton` | `Skeleton` and `dsSkeleton(_:)` honoring Reduce Motion |
| `.btn--prominent` | `Button` + `dsGlassProminent()`; other variants `.buttonStyle(.dsTinted / .dsDanger / .dsGhost)` |
| `data-icon="x"` | `DSIcon.x` (add the case if missing) |
| `data-en` / `data-fr` | `Localizable.xcstrings`, en + fr |
| `?state=` / `?sheet=` | the view model's `enum State` / `enum Modal`; every value in the prototype must exist |

Motion: sheets use `.dsSpring`, the rest `.dsStandard` or `.dsQuick`, always through
`dsAnimation(_:value:)` so Reduce Motion is honored. Anything the user drags stays
interruptible: animate state changes, never a fixed-duration timer.

Checklist before calling a screen done:

- [ ] Every state in the prototype (loading, empty, error, success, …) reachable.
- [ ] Every sheet and dialog present, with the same copy.
- [ ] Light and dark previews match the prototype; `dsForceLegacyGlass` preview reviewed.
- [ ] Dynamic Type AX3: figures wrap, never truncate.
- [ ] VoiceOver order follows the visual order; charts have descriptors.
- [ ] No `#available`, no literal color, no literal spacing in the screen.
