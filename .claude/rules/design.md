---
paths:
  - "design/**"
  - "MyApp/DesignSystem/**"
---

# Design rules

Source of truth: `design/tokens.json`. `make tokens` regenerates `design/tokens.css` and
`MyApp/DesignSystem/Generated`. Charter is non-negotiable; craft is where the work is.

- Tokens only. HTML prototypes consume `design/tokens.css`; Swift consumes
  `DesignSystem/Generated`. No hex, no hard-coded size, outside `tokens.json`.
- Depth from 1 px alpha hairlines (`border.default / strong / subtle`), not shadows. Shadows only
  on things that float (menus, toasts, sheets).
- `border.control` is the only border allowed on an unfilled interactive control.
- Status = color + icon + label. Base status colors (`positive`, `warn`, `danger`, `accent`) are
  for icons, meters and large figures, never for text; use the `*.text` roles.
- One accent (`action.primary`) for the primary action, links and selection. Nothing else.
- Type from `DSTypography` (Dynamic Type styles). Tabular numerals on every figure and id.
- Radius `sm / md / lg` + pill. No full radius on cards.
- Forbidden: gradients, glows, neon, `transition: all`, decorative blur on content.
- Dark mode is a semantic remap in `tokens.json`, never a second set of components.
- Glass (`ds*` modifiers, `.glass` classes) is for controls and navigation surfaces, never for
  content cards. Standard containers get glass for free on iOS 26: do not re-style them.
- Motion: follow the `apple-design` skill (springs, interruptible, respond on pointer-down,
  reduced motion). Durations from the motion tokens.
- Mobile: 44 pt targets, safe areas, one primary action per screen, sheets over full-page modals,
  destructive confirmation only for the irreversible.
