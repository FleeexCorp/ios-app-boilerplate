---
name: apply-plan
description: >-
  Apply a plan from .plan/ (format: tasks = commits, commit message given per task) in
  ORCHESTRATOR mode: the session keeps only the plan in context, delegates each task to a
  sub-agent, reviews each agent's diff and sends it back for correction if needed. Starts
  from an up-to-date main, branch feat/<x>, one commit per task, every commit passing
  make lint + make generate + make test. Use whenever the user asks to apply, execute or
  implement an existing plan: "applique le plan X", "exécute .plan/03-…", "implémente la
  phase 5", "lance le plan", /apply-plan. Do NOT use to WRITE a plan (→ create-plan) or
  for a one-off fix with no plan.
argument-hint: <plan> (ex. 01, 03-data-layer, widgets)
---

## Stance: you ORCHESTRATE, you don't implement
You are **site manager, not worker**. Your context must stay light enough to hold the whole plan without compaction:

- You keep in context: the **plan**, task progress, and the **reviewed diffs** (stat + targeted excerpts, never whole files).
- You **never** implement yourself: no Edit/Write on code, no broad codebase exploration. Each task goes to a **sub-agent** (Agent tool) with its own context.
- You only do: the framing git (branch), launching agents, **reviewing** their changes, asking for corrections, committing, updating `.plan/PROGRESS.md`, and the final recap.

## Step 0: select the plan
- `$ARGUMENTS` given → look up, in order: `.plan/$ARGUMENTS.md`, `.plan/$ARGUMENTS/`, then a glob `.plan/**/*$ARGUMENTS*.md`.
- A multi-phase plan has `.plan/00-overview.md` (cross-cutting decisions, phase order) and `.plan/PROGRESS.md` (where the work stands). Apply **one phase at a time**: the one passed as argument, otherwise the first unapplied phase according to `PROGRESS.md` and `git log`; confirm it with the user before starting. One run = one phase = one branch.
- Read the phase **in full**, plus `00-overview.md` and `PROGRESS.md` (decisions, layer boundaries, pitfalls already met, cross-repo impacts).

## Step 1: clarify BEFORE touching git
For each task, check it is executable without ambiguity. If clearing a doubt requires reading code, **delegate that to an Explore agent** (one salvo, grouped questions). If real questions remain (untaken technical choice, product/UX decision), ask them in **one message** and wait. If the plan is clear: proceed without asking anything.

Items outside this repo (an API, infra, a store listing) are **not implemented here**. If the phase depends on one, say so up front: it may block runtime verification.

Prerequisite check on the first phase and whenever the plan says so: `xcodebuild -version` must be Xcode 26; `xcrun simctl list runtimes` must list iOS 26 and iOS 18. If not, stop and tell the user.

## Step 2: git, up-to-date main → branch
1. Require a **clean** tree (`git status`). Pending changes → stop and ask; never stash or discard on your own.
2. `git checkout main && git pull --ff-only` (skip the pull when there is no remote).
3. Branch name: the one in the phase (« Branche : » line), otherwise `feat/<phase-slug>`.
   - If the branch **already exists** and the plan continues it: check it out and resume at the first uncommitted task (compare `git log` against the plan's commit messages).
   - Otherwise `git checkout -b feat/<x>` from main.
4. If the plan files are not committed yet, they are the branch's **first commit** (`docs: plan <phase>`): git, not implementation, so you may do it.

## Step 3: one task = one agent = one commit
Tasks run **in sequence**. For each task:

### 3.1 Choose the agent's model
Announce it with the task (`→ Tâche N/X : <titre> : sonnet`):

- **sonnet**: mechanical and fully specified: xcconfig values, a string pair in `Localizable.xcstrings`, a small `DesignSystem` primitive, a formatter with its tests, a DTO mapping, a file move, a straightforward test.
- **opus**: the heavy pieces: anything in **auth or session**, **stores**, `GlassCompat`, a new **feature screen** with its view model and sheets, deep links, an API client setup, anything with real a11y or concurrency stakes, or any task the plan marks as touching more than ~4 non-trivial files.

When in doubt → opus. The step-1 Explore agent stays on sonnet.

### 3.2 Launch the agent
Launch an Agent (`general-purpose`, `run_in_background: false`, chosen model) with an **autonomous** prompt containing:

- the **full text of the task** as written in the plan + the relevant decisions from `00-overview.md`;
- a 2-3 line recap of what previous tasks did;
- the execution instructions:
  - implement **only this task**, no drive-by improvements;
  - invoke **`ios-craft`** (layers, tokens, GlassCompat, xcstrings, mutation truth, project invariants) and follow `.claude/rules/`; use `swiftui-pro`, `swift-concurrency-pro`, `swift-testing-pro` for the generic Swift rules, `swiftui-liquid-glass` when touching `GlassCompat`, `swiftui-navigation` for routes and deep links, `apple-design` for motion, `ios-localization`, `ios-accessibility`, `swift-charts`, `ios-networking`, `swift-codable` when the task is in their area;
  - the screen's prototype `design/<screen>.html` is the pixel and motion reference: every state and sheet it shows must exist;
  - **reuse `DesignSystem/`** primitives; never restyle inline; no literal color or spacing;
  - **i18n**: every user-facing string in `Localizable.xcstrings`, en **and** fr in the same change; formatters take a `Locale`;
  - **a11y**: 44 pt, Dynamic Type AX3, VoiceOver labels, Reduce Motion;
  - gates before handing back: `make lint`, `make generate`, `make test` (iOS 26); on a `GlassCompat` or shell task also `make test-legacy` (iOS 18). Never raw `xcodebuild`: the Makefile carries the plugin-validation flags and resolves the legacy simulator by UDID;
  - **no plan reference in code comments**; explain the WHY directly; comments and code in English;
  - **DO NOT commit**;
  - finish with a report: files touched, choices made, gate results, what surprised it.

### 3.3 Review (you)
- `git diff --stat`, then a **targeted** read of the diff on the key files.
- Check: the task does what the plan says, all of it and nothing else; layer boundaries respected (no transport or SDK type, `URLSession` or `UserDefaults` above its layer); `#available` only in `GlassCompat.swift`; no literal color/spacing; the project's money type for money; en + fr both present; tests added where the plan asks; gates green (re-run them yourself if the report leaves any doubt).
- On an auth, store or `GlassCompat` task, a second review pass is worth the round-trip.

### 3.4 Correct if needed
Don't fix it yourself. Send the agent back with **SendMessage** describing precisely what to fix; if it died, launch a fresh agent with the current diff + the requested correction. Loop until clean.

### 3.5 Commit (you)
`git add -A` + commit with the **message written in the plan** (« Commit : » line), verbatim; otherwise a conventional English message `type(scope): title`, subject ≤ 50 chars. **No `Co-Authored-By` trailer, no AI mention.** Never a red commit, never two tasks in one commit. Then update `.plan/PROGRESS.md` (state table, next action, discoveries) and fold it into the same commit or the next docs commit. Then the next task, without asking.

**Never `git push`** without an explicit request.

## Step 4: verification and recap
1. If the change is visible: build and launch on the simulator (iOS Simulator tools, `attach` first), check the touched screens in light and dark, in en and fr, and once on the iOS 18 simulator when `GlassCompat` or the shell moved. Anything needing a real backend or a real account is not locally verifiable: say so instead of improvising a bypass.
2. Final recap: commits (`short hash : message`), gate results, corrections requested along the way, what could **not** be verified, the cross-repo tasks from the phase's « Impacts hors repo », the phase's « Hors périmètre ». Then a `/code-review` pass on the branch.

## Known pitfalls
- The orchestrator that "helps a bit": the moment you open a source file to edit it, you've left your role.
- An agent handing back with gates "probably fine": re-run them.
- An agent that writes `#available` in a screen, a `Double` for money, a string in en only, or a view calling a service directly: reject and send it back.
- Don't "improve" along the way: anything not in the plan goes into the recap.
- If a task turns out infeasible as written: stop, explain, propose; never silently reinterpret the plan.
