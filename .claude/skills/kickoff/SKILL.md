---
name: kickoff
description: >-
  Orchestrates the birth of an iOS app from this boilerplate, the way fleeex-ios was
  built: (1) grill the product idea until scope, decisions and identity are settled
  (docs/product.md), (2) rename the project, (3) build the HTML design prototypes in
  design/ with apple-design, (4) write the execution plan in .plan/ with create-plan, then
  hand over to /apply-plan. Resumes from the artifacts already present. Use whenever the
  user starts an app from this repo: "kickoff", "on démarre", "nouvelle app", "je veux
  faire une app qui…", "lance le boilerplate", /kickoff, or wants to go from an idea to
  an implementation plan. Do NOT use to execute a plan (→ apply-plan) or to change one
  screen (→ ios-craft).
argument-hint: [l'idée en une phrase]
---

## Stance: you orchestrate, the steps do the work

You run four steps in order, each owned by a dedicated skill. You keep the thread (what was
decided, what is next), you never redo a step's work yourself, and you stop at every
checkpoint so the user can redirect. Chat is French; every artifact that is code, comment
or commit message is English; plans and the product brief are French. No em dash anywhere.

```
 idea ──▶ 1. grill-product ──▶ docs/product.md
              │
              ▼
          2. rename ─────────▶ Scripts/rename.sh, make generate, green gates
              │
              ▼
          3. design-prototypes ▶ design/<screen>.html, index.html, tokens.json
              │
              ▼
          4. create-plan ────▶ .plan/00-overview.md, phases, PROGRESS.md
              │
              ▼
          hand-off: /apply-plan 01
```

## Step 0: where are we?

Detect the state from the repo, never from memory:

| Artifact | Present means |
|---|---|
| `docs/product.md` with a « Décisions » table | step 1 done |
| a folder other than `MyApp/` holding `App/` (`ls */App/*App.swift`) | step 2 done |
| `design/index.html` listing screens other than `home.html` | step 3 done |
| `.plan/00-overview.md` (or `.plan/<slug>/`) | step 4 done |

Announce the detected state in two lines and resume at the first missing step. If
`$ARGUMENTS` carries the idea, pass it to step 1. If everything is present, say so and
offer `/apply-plan` on the first unapplied phase (read `.plan/PROGRESS.md`).

Prerequisite check, once: `xcodebuild -version` is Xcode 26, `xcrun simctl list runtimes`
lists iOS 26 and iOS 18, `xcodegen`, `swiftformat`, `swiftlint` are installed. Missing tool →
say what to install (`README.md`, Requirements) and stop.

## Step 1: grill the product

Invoke the `grill-product` skill. It interviews the user one question at a time, looks
facts up itself, challenges the idea, and writes `docs/product.md`. It ends when the user
confirms the brief reads as a shared understanding.

Checkpoint: summarize the brief in five lines (pitch, killer flow, v1 screens, stack,
biggest risk). Propose the commit `docs: product brief` and make it on a yes.

## Step 2: rename

The brief names the app (« Identité »: product name, bundle id, display name). Run:

```sh
Scripts/rename.sh <ProductName> <bundle.id> "<Display Name>"
make generate && make lint && make test
```

The tree must be clean before the script runs; a failure here is a stop, not a workaround.
Then update `CLAUDE.md`: the first paragraph (what the app is, one sentence from the brief)
and the « Project invariants » list of `.claude/skills/ios-craft/SKILL.md` with the
invariants the brief settled (money type, session scope, offline policy, anything the app
must never do). Commit `chore: rename app to <ProductName>`.

## Step 3: design prototypes

Invoke the `design-prototypes` skill with the brief. It retunes `design/tokens.json`,
writes one HTML prototype per screen of the brief with every state, the gallery and the
mapping README, reviews them in the browser in light and dark, en and fr.

Checkpoint: open the gallery for the user (`preview_start` on the `design` entry of
`.claude/launch.json`), list the screens and states produced, ask whether the design is
approved before planning on it. Commit `design: prototypes v1` on a yes. A change of scope
here goes back to `docs/product.md` first (update the « Décisions » table with the date).

## Step 4: plan

Invoke the `create-plan` skill with the brief and the prototypes. It settles the remaining
structural decisions with the user in one salvo, then writes `.plan/00-overview.md`, one
file per phase and `.plan/PROGRESS.md`.

Checkpoint: show the phase table and the cross-repo impacts. Commit `docs: plan v1`.

## Hand-off

Recap in one message: the four artifacts with their paths, the commits made, what could
not be verified, and the next command: `/apply-plan 01`. Do not launch it.

## Known pitfalls

- Skipping the grill because « the idea is clear »: the brief is what the plan and every
  agent read later; an unasked question becomes an agent's guess.
- Renaming after the plan is written: the plan would name `MyApp` everywhere. Rename first.
- Designing screens the brief does not list, or planning screens the design does not show:
  the three artifacts must name the same screens. Fix the upstream one.
- Committing without asking at a checkpoint: the user may want to amend the artifact first.
- Doing a step's work in this session « to save a call »: the step skills carry the method.
