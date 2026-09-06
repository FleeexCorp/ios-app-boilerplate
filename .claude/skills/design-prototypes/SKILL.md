---
name: design-prototypes
description: >-
  Builds the HTML design prototypes of an iOS app in design/: retunes design/tokens.json
  from the product brief, writes one prototype per screen with every state (loading, empty,
  error, success, sheets) on the Liquid Glass kit (glass.css, app.js), the gallery
  index.html and the SwiftUI mapping README, then reviews them in the browser in light and
  dark, en and fr. Uses the apple-design skill for motion, materials and typography. Use
  when the user wants screens designed or a prototype made or changed: "maquette", "design
  de l'écran X", "prototype", "ajoute un état au proto", /design-prototypes, or as step 3
  of /kickoff. Do NOT use to write SwiftUI (→ ios-craft).
argument-hint: [écran ou "all"]
---

## Goal

One functional HTML file per screen of `docs/product.md`, the pixel and motion reference
the SwiftUI work is checked against. A prototype is done when every state the brief lists
is reachable, every sheet and dialog exists with its final copy in en and fr, and it reads
right in light and dark.

Load the `apple-design` skill before writing: springs, interruptibility, materials, type
tracking, reduced motion, the eight principles. If `ui-ux-pro-max` is available, use it for
palette and font pairing options; the charter in `.claude/rules/design.md` wins.

## Step 0: read

`docs/product.md` (screens, states, actions, design direction), `design/README.md`,
`references/kit.md` (what the kit offers), the existing `design/*.html`. A screen missing
from the brief is a question for the user, not an invention.

## Step 1: tokens

Retune `design/tokens.json` to the brief's direction, then `make tokens`:

- `action.primary` / `action.hover` carry the one accent, light and dark; `focus` and
  `accent.*` follow. Check contrast: `text.*` roles AA (4.5:1) on `bg` and `surface`,
  `border.control` and every `*.default` mark 3:1.
- Fonts: system by default. A brand face changes `font.family.*`, adds a Google Fonts link
  to the prototypes, and creates a DESIGN task for the plan (bundle the files, `UIAppFonts`,
  `DSTypography`). Sizes stay on the iOS scale unless the brief argues otherwise.
- Radii, spacing, motion: only if the direction asks for it. Dark is a remap, never a
  second design.

Never edit `tokens.css` or `MyApp/DesignSystem/Generated` by hand.

## Step 2: one file per screen

Copy `references/screen-template.html` to `design/<screen>.html` and fill it with the kit
(`references/kit.md`). Rules:

- Device frame, chrome with compact title, `.edge` blurs, `.screen` content, tab bar when
  the screen is a tab. Content scrolls under the chrome.
- States via `?state=`: a `<section data-state="…">` per state the brief lists, plus
  `loading`, `empty`, `error` for anything that loads. The switcher at the bottom of the
  template shows one.
- Sheets via `?sheet=`, alerts for destructive irreversible actions only, menus anchored to
  their trigger. Every piece of copy carries `data-en` and `data-fr`.
- One primary action per screen (`.btn--prominent`), 44 pt targets, tabular numerals on
  figures (`.num`), status as colour + mark + label (`.pill`).
- Screen-local CSS stays in the file's `<style>`; anything reused twice moves to
  `glass.css`. No new colour, size or duration outside the tokens.
- Delete `home.html` once the app's own first screen exists.

## Step 3: gallery and mapping

- `design/index.html`: the `screens` array lists every screen and every state worth a
  thumbnail; « Flows to try » and « States via URL » describe the real app.
- `design/README.md`: the file table and the SwiftUI mapping table (prototype class →
  iOS 26 API → iOS 18 fallback) cover every kit element the screens use.

## Step 4: review in the browser

Serve with `preview_start` on the `design` entry of `.claude/launch.json` (or
`python3 -m http.server 8765 --directory design`). For each screen: screenshot default
state light and dark, switch to fr, try each state URL, open each sheet and drag it.
Checklist:

- [ ] Every state and sheet of the brief reachable; copy final in both languages.
- [ ] Nothing clips under the chrome or the tab bar; safe areas respected.
- [ ] Dark reads as the same design; hairlines visible on both.
- [ ] Sheets track 1:1, rubber-band, dismiss on a flick; reduced motion cross-fades.
- [ ] One primary action per screen; destructive actions confirmed once, inline or alert.
- [ ] No hex, no literal size outside `tokens.json`; `make tokens && git diff --exit-code` is clean.

Report: screens produced, states per screen, tokens changed, what the SwiftUI side will
need beyond the kit (a new primitive, a custom font, a chart). Do not commit: the
orchestrator or the user decides.

## Known pitfalls

- Designing from memory of the brief: re-read the screen table before each file.
- A gradient « just for the hero »: the charter forbids it; use surface + hairline + type.
- A state the brief lists but the prototype lacks: the SwiftUI agent will not build it.
- Editing `tokens.css`: it is regenerated; the change is lost and the Swift side diverges.
- A sheet for a destructive irreversible action: that is an alert; a sheet for a form.
