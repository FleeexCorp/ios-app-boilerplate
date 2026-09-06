# The prototype kit: `design/glass.css` + `design/app.js`

Every class below is styled from tokens only. Behavior is declarative: a `data-*`
attribute on the trigger, `app.js` does the rest. `window.DS` exposes the engine
(`Spring`, `project`, `rubberband`, `openSheet`, `toast`, `money`, …) for screen scripts.

## Frame and chrome

| Class | Role |
|---|---|
| `.stage > .device` | 393 × 852 iPhone frame; `.device__island`, `.device__status`, `.device__home` |
| `.device__content` | Everything that gets pushed back when a sheet opens |
| `.chrome` | Floating top bar: left slot, `.chrome__title.glass` (fades in on scroll), right slot; `.chrome__group` for grouped buttons |
| `.icon-btn.glass` | 38 pt glyph with a 44 pt hit area; `.icon-btn--label` adds text |
| `.edge.edge--top / --bottom` | Progressive blur where content meets floating chrome |
| `.screen` | The scroll container; `.screen--plain` (no tab bar), `.screen--centered` |
| `.title-block` | Large title `h1` + lead `p` |
| `.tabbar.glass > .tab` | Floating tab bar; `aria-current="page"` on the selected tab; minimizes on scroll down |

## Content

| Class | Role |
|---|---|
| `.card`, `.card--sunken`, `.card__head` | Surface + hairline, radius lg |
| `.section`, `.section__label` | Vertical rhythm and a `.label` header |
| `.list > .row` | Inset list; `.row--tappable`, `.row__icon`, `.row__main`, `.row__title`, `.row__sub`, `.row__trail`, `.chevron` |
| `.avatar`, `.avatar--lg` | Initial on a sunken tile |
| `.stat`, `.stat__value`, `--hero`, `--sm`, `.stat__delta--up/--down`, `.stat-grid` | Figures; pair `.num` |
| `.pill`, `--positive/--warn/--danger/--accent`, `--mono`, `--plain` | Status: colour + dot + label |
| `.meter > .meter__fill`, `.meter--warn/--danger` | Progress toward a cap |
| `.banner`, `--warn/--danger/--positive` | Inline notice with icon and optional action |
| `.empty` | Icon + bold sentence + explanation |
| `.skeleton` | Loading placeholder, shimmer off under reduced motion |
| `.bars > span`, `.bars-axis` | Bar chart stand-in; `data-today`, `data-future` |
| `.share` | Breakdown row with a meter |
| `.kv > dt/dd` | Key/value detail list |
| `.steps > .step`, `.step__n`, `[data-done]` | Numbered steps |
| `.secret` | One-time secret with copy |
| `.wordmark`, `em` | App name set as a logo |
| Type: `.t-xs … .t-3xl`, `.label`, `.num`, `.mono`, `.display`, `.muted` | Scale and variants |

## Controls

| Class | Role |
|---|---|
| `.btn`, `--prominent/--glass/--tinted/--danger/--danger-filled/--ghost`, `--block`, `--sm` | Buttons, 44 pt, press dip |
| `.field > label + .input`, `.hint`, `.error`, `[data-invalid]` | Form field; `.input--mono`, `.input--amount`, `textarea.input`; `data-autofocus` focuses the field when its sheet opens (never `autofocus`: it scrolls the frame on load) |
| `.otp > .otp__box[data-active]` | One-time code boxes |
| `.segmented > button[aria-selected]` | Sliding thumb on a spring; `data-panel` + `[data-panel-group][data-panel-id]` switch panels |
| `.chips > .chip[aria-pressed]` | Filter chips; `data-press="group"` for single choice |
| `.toggle[aria-checked]` | Switch; `data-toggle` flips it |
| `.check` | Round checkbox, filled when the parent is `aria-checked` / `aria-selected` |

## Layers

| Element | Trigger | Notes |
|---|---|---|
| `.sheet.glass.glass--thick[data-sheet=id]` | `data-open-sheet="id"`, `data-close-sheet`, `?sheet=id` | Draggable, spring-driven, interruptible; `.sheet__grabber`, `.sheet__head`, `.sheet__body`, `.sheet__actions`; children radius is concentric |
| `.alert.glass.glass--thick[data-alert=id]` | `data-open-alert="id"`, `data-close-alert` | Destructive irreversible actions only |
| `.menu.glass.glass--thick[data-menu=id]` | `data-toggle-menu="id"` on the anchor | Grows out of its trigger; `hr` separators; `.danger` items |
| `.toast` (created on demand) | `data-toast="text"`, `data-copy="value"` | Auto-dismiss 1.8 s; copy also vibrates |
| `.scrim` | Automatic | Closes sheets and alerts on tap |

## Global behaviors

- `data-en` / `data-fr` on any element: language switch; `data-lang-option` buttons.
- `data-theme-option` buttons: system / light / dark, persisted in `localStorage`.
- `data-icon="name"`: inline SVG from the icon set in `app.js` (24 grid, 1.75 stroke).
  Add an icon there, and its SF Symbol in `DSIcon.swift`, with the same name.
- `data-go="url"`: navigate after the press feedback.
- `?state=` handled by the screen's own script (see the template); `?sheet=` by the kit.
- `Escape` closes the topmost layer.

## Motion constants (app.js)

`SHEET_SPRING = { damping: 0.8, response: 0.3 }`, `UI_SPRING = { damping: 1.0, response: 0.3 }`,
`DECELERATION = 0.998`, `DRAG_THRESHOLD = 10`, `DISMISS_RATIO = 0.4`. They mirror
`Animation.dsSpring` and the values in the `apple-design` skill; change both or neither.
