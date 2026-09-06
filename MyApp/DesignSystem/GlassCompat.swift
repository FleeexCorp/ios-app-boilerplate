import SwiftUI

// The one file allowed to say `#available(iOS 26, *)`, and therefore the one file that
// holds more than a single type: splitting these modifiers across files would spread the
// availability check instead of containing it. Screens call the `ds*` modifiers below.
//
// Liquid Glass is a material for controls and navigation surfaces, never for content:
// cards stay `surface` plus hairline on both OS versions. When the deployment target
// moves to iOS 26, delete the `else` branches and the environment key; no call site
// changes.

extension EnvironmentValues {
    /// Forces the iOS 18 rendering on an OS that could draw glass.
    ///
    /// Previews and UI tests use it to see both looks on one simulator, which is the only
    /// way to review the fallback without booting an iOS 18 device.
    @Entry var dsForceLegacyGlass: Bool = false
}

extension View {
    /// Glass capsule button: toolbar and secondary actions. Bordered on a material on iOS 18.
    func dsGlassButton() -> some View {
        modifier(GlassButtonCompat())
    }

    /// The one primary action of a screen, tinted with `action.primary`.
    ///
    /// `.dsProminent` is the iOS 18 half of this modifier, not a parallel style: screens
    /// call `dsGlassProminent()` and let it pick.
    func dsGlassProminent() -> some View {
        modifier(GlassProminentCompat())
    }

    /// Floating tab bar that minimizes on scroll down. No-op on iOS 18, which has no
    /// floating bar to minimize.
    func dsTabBarMinimize() -> some View {
        modifier(TabBarMinimizeCompat())
    }

    /// Soft scroll edge under the navigation bar, so content dissolves rather than clips.
    func dsScrollEdge() -> some View {
        modifier(ScrollEdgeCompat())
    }

    /// Glass ground for a sheet or a popover. Applied to the presented root view, since
    /// `presentationBackground` reads from the presentation's own content.
    func dsGlassBackground() -> some View {
        modifier(GlassBackgroundCompat())
    }

    /// Glass behind a piece of custom chrome, such as a floating pill.
    ///
    /// Layout and appearance first, glass last: the effect takes the shape it is given at
    /// the size the modifiers before it settled on.
    func dsGlassEffect(in shape: some InsettableShape = Capsule()) -> some View {
        modifier(GlassEffectCompat(shape: shape))
    }
}

private struct GlassButtonCompat: ViewModifier {
    @Environment(\.dsForceLegacyGlass) private var legacy
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    func body(content: Content) -> some View {
        if #available(iOS 26, *), !legacy {
            content.buttonStyle(.glass)
        } else {
            content
                .buttonStyle(.bordered)
                .buttonBorderShape(.capsule)
                // Large is the only bordered size that clears the touch target on its own,
                // so the material capsule and the button's own fill share one frame.
                .controlSize(.large)
                .frame(minHeight: DSLayout.minTouchTarget)
                .background(LegacyGlass(reduceTransparency: reduceTransparency).fill, in: .capsule)
                .overlay {
                    Capsule().strokeBorder(DSColor.borderDefault, lineWidth: DSLayout.hairline)
                }
        }
    }
}

private struct GlassProminentCompat: ViewModifier {
    @Environment(\.dsForceLegacyGlass) private var legacy

    func body(content: Content) -> some View {
        if #available(iOS 26, *), !legacy {
            content
                .buttonStyle(.glassProminent)
                .tint(DSColor.actionPrimary)
        } else {
            content.buttonStyle(.dsProminent)
        }
    }
}

private struct TabBarMinimizeCompat: ViewModifier {
    @Environment(\.dsForceLegacyGlass) private var legacy

    func body(content: Content) -> some View {
        if #available(iOS 26, *), !legacy {
            content.tabBarMinimizeBehavior(.onScrollDown)
        } else {
            content
        }
    }
}

private struct ScrollEdgeCompat: ViewModifier {
    @Environment(\.dsForceLegacyGlass) private var legacy
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    func body(content: Content) -> some View {
        if #available(iOS 26, *), !legacy {
            content.scrollEdgeEffectStyle(.soft, for: .top)
        } else {
            // Material only, visibility left automatic. iOS 18 already reveals the bar
            // background as content scrolls under it and hides it at the top, which is the
            // behaviour the soft edge keeps; forcing `.visible` would paint a bar over a
            // screen that has not been scrolled.
            content.toolbarBackground(
                LegacyGlass(reduceTransparency: reduceTransparency).fill,
                for: .navigationBar
            )
        }
    }
}

private struct GlassBackgroundCompat: ViewModifier {
    @Environment(\.dsForceLegacyGlass) private var legacy
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    func body(content: Content) -> some View {
        if #available(iOS 26, *), !legacy {
            // Sheets and popovers built with the iOS 26 SDK are glass already. Re-styling
            // them would replace the system material with a copy of it.
            content
        } else {
            content.presentationBackground(LegacyGlass(reduceTransparency: reduceTransparency).fill)
        }
    }
}

private struct GlassEffectCompat<S: InsettableShape>: ViewModifier {
    @Environment(\.dsForceLegacyGlass) private var legacy
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    let shape: S

    func body(content: Content) -> some View {
        if #available(iOS 26, *), !legacy {
            content.glassEffect(.regular, in: shape)
        } else {
            content
                .background(LegacyGlass(reduceTransparency: reduceTransparency).fill, in: shape)
                .overlay {
                    shape.strokeBorder(DSColor.borderDefault, lineWidth: DSLayout.hairline)
                }
        }
    }
}

/// The iOS 18 stand-in for glass: one thin material, one hairline, nothing else.
///
/// On iOS 26 the system material behind `glassEffect` answers Reduce Transparency by
/// itself; the fallback has to be told, hence the two cases.
private enum LegacyGlass {
    case blurred
    case solid

    init(reduceTransparency: Bool) {
        self = reduceTransparency ? .solid : .blurred
    }

    /// `.ultraThinMaterial` is the closest system blur to the prototypes' 22 px backdrop
    /// filter over a 62 % surface. Reduce Transparency swaps it for the surface it would
    /// have blurred, which is what the prototypes do under the same setting.
    var fill: AnyShapeStyle {
        switch self {
        case .blurred: AnyShapeStyle(.ultraThinMaterial)
        case .solid: AnyShapeStyle(DSColor.surfaceDefault)
        }
    }
}
