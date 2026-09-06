---
name: create-plan
description: >-
  Write a work plan under .plan/: one .md for a small piece of work, an overview + one .md
  per phase + PROGRESS.md for a big one (the first plan of an app, from docs/product.md and
  design/). The output is consumable as-is by /apply-plan: branch, decisions settled with
  the user, tasks = commits with the exact commit message. Use whenever the user wants to
  plan work: "fais un plan pour X", "planifie le chantier X", "découpe-moi X en tâches",
  /create-plan, or as step 4 of /kickoff. Do NOT use to APPLY an existing plan
  (→ apply-plan) or for a one-off fix that needs no plan.
argument-hint: <chantier> (ex. v1, ipad-layout, widgets) + free-form description
---

## Goal
Produce a plan `/apply-plan` can execute as-is: each task is one commit, and every structural decision is **settled with the user before** the plan is written.

Plan files are **French**; everything they ask to produce (code, comments, commit messages) is **English**. No em dash anywhere.

## Step 0: framing
1. Name the chantier: kebab-case slug → `.plan/<chantier>/` (or `.plan/NN-<slug>.md` if it extends a numbered sequence) and branch `feat/<chantier>`. The first plan of an app is the numbered sequence itself: `.plan/00-overview.md`, `01-…`, plus `PROGRESS.md`.
2. Read what exists **without loading your own context**: `docs/product.md` (screens, decisions, out of scope, cross-repo impacts), `design/README.md` and the list of `design/*.html` with their states, then one or two Explore agents (sonnet) on the code: which features, stores, services and `DesignSystem` primitives exist, what the boilerplate already provides (config, `LoadState`, `MutationResult`, `GlassCompat`, `DSCard`, `StatusBadge`, `EmptyState`, `Skeleton`, CI, gates), what is missing, whether a prototype exists for every screen involved.
3. Carry the repo constraints: `.claude/rules/`, `ios-craft` (layers, tokens, GlassCompat, xcstrings en + fr, mutation truth, `AppError`), deployment target iOS 18 with glass on 26, SPM only.

## Step 1: settle the decisions BEFORE writing
List the structural choices the brief left open: where state lives (view model vs `Core` store); new `DesignSystem` primitive vs feature-local component; new route vs section; sheet vs alert vs inline confirm; what needs a **change outside this repo** (API endpoint or DTO, infra, store listing) vs what exists; loading / empty / error states; whether a **design prototype** must be produced or updated first in `design/`; dependency additions (each justified). Put them to the user in **one salvo** (AskUserQuestion). What wasn't asked isn't decided. A decision already in `docs/product.md` is cited, not re-asked.

Never left open: anything that shows **money** (an integer minor-unit type plus one formatter, never `Double`), anything touching **auth** or **session reset** (`Resettable`), anything adding `#available` (must land in `GlassCompat`), anything persisting user data (which store owns it).

## Step 2: size it
- **Small** (≲ 8 tasks, one branch) → one file.
- **Big** → `00-overview.md` (vision, decisions, layer map, phase order, cross-repo impacts, risks) + one file per phase, each **self-sufficient for /apply-plan** (own « Branche : », own tasks and commits) + `PROGRESS.md` (state table, next action, tests count, pitfalls discovered). A phase must be mergeable alone: it builds, tests pass, no dead route, no half-wired store, no string in one language only.

The first plan of an app usually goes: `01` identity and configuration (the boilerplate is already renamed: remaining config fields, CI green, README and CLAUDE.md rewritten for the app, dependencies) → `02` design system (tokens already retuned: brand fonts if any, the primitives the prototypes need beyond the kit, icon cases) → `03` data layer (API client or persistence, services, mapping, `AppError` cases) → `04` auth and session (if any) → one phase per screen or tab, in the order of the killer flow → last phase QA and release (a11y audit, i18n parity, privacy manifest, App Store assets, TestFlight).

## Step 3: write the plan (contractual format)

```markdown
# Phase NN : <titre>

Branche : `feat/<x>`. **1 commit par tâche**, chaque commit passe
`make lint`, `make generate` et `make test` (simulateur iOS 26 ; `make test-legacy`
sur iOS 18 si GlassCompat ou le shell bougent). Pas de push sans demande.
Mettre à jour `.plan/PROGRESS.md` après chaque tâche commitée.

## Décisions
- … (citer les réponses de l'utilisateur et docs/product.md)

## Hors périmètre
- …

## T1 : <TAG> · <titre> *(skill `ios-craft`)*
- <fichiers précis, primitives DesignSystem à réutiliser, états loading/empty/error,
  prototype design/<screen>.html de référence, cas limites>
- <invariants : tokens, pas de #available hors GlassCompat, xcstrings en + fr, LoadState /
  MutationResult, AppError, 44 pt, Reduce Motion, Locale en paramètre>
- <tests attendus : view model / store / mapping / formatter>
- Commit : `<type>(<scope>): <message exact en anglais, ≤ 50 caractères>`
…

## Impacts hors repo
| Repo / système | Impact |
|---|---|
| … | … |
```

Per-task requirements: executable by a sonnet agent without coming back to the user; tagged **API / STORE / UI / FEATURE / ROUTING / I18N / DOCS / TESTS / DESIGN / CONFIG**; mapping and services before stores, stores before view models, view models before views, views before routing; strings and both languages in the same commit; commit message final, conventional, English; **never** a plan reference in code.

Order of dependencies inside a phase: `API/Mapping` → `Core` → `DesignSystem` primitive (if reusable) → `Features` → routing → strings → tests.

`PROGRESS.md` format: a « Fichier de reprise » header (read first by any session resuming the work, updated after each committed task), a state table (phase, branch, state, commits), « Prochaine action », « Tests » (counts), « Découvertes qui changent la donne ».

## Step 4: report back
Show the folder or file created, the phase split, the task list with commits, the cross-repo impacts as separate tracks. Offer `/apply-plan <phase>` as the next step without launching it. Don't branch, don't commit here.

## Known pitfalls
- A task with an untaken decision: back to step 1.
- A screen without a prototype: add a DESIGN task in `design/` first, or ask.
- Writing a backend or infra change as a task of this repo: it goes to « Impacts hors repo ».
- Deferred ideas go to « Hors périmètre », not into tasks.
- A phase that names `MyApp`: the rename has not happened; stop and say so.
