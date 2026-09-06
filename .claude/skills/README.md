# .claude/skills

Skills available in this repo, their origin and when to reach for them.

## House skills (the workflow)

| Skill | Use when |
|---|---|
| `kickoff` | Starting an app from this boilerplate: runs grill → rename → design → plan, resumes from the artifacts present, hands over to `/apply-plan`. |
| `grill-product` | Thinking the product through, one question at a time, until `docs/product.md` reads as a shared understanding. |
| `design-prototypes` | Making or changing the HTML prototypes in `design/` on the Liquid Glass kit, tokens first, every state, en + fr, reviewed in the browser. |
| `create-plan` | Writing a plan in the `.plan/` format (tasks = commits) from the brief and the prototypes. |
| `apply-plan` | Executing one phase of `.plan/` as an orchestrator: one agent per task, one commit per task, gates green. |
| `ios-craft` | Any code change under the app folder: layers, tokens, GlassCompat, xcstrings, load and mutation truth, project invariants. The repo-specific standard. |
| `apple-design` | Motion, gestures, sheets, materials, typography, reduced motion, the eight design principles. Used by the prototypes and by SwiftUI motion work. |

## Third-party skills (audited before installation, vendored as-is)

Audit of 2026-09-02 with `/audit-skill` (in the fleeex-ios repo, same files): 15 skills, no
credential access, no network call, no script executed by the skill, no obfuscation, no
persistence, no prompt injection. Only findings: documentation links to `sosumi.ai` (Apple
docs mirror) and a `launchctl kickstart` line quoted in a simctl troubleshooting reference.
Verdict SAFE for all.

| Skill | Source | Commit | License | Use when |
|---|---|---|---|---|
| `swiftui-pro` | [twostraws/SwiftUI-Agent-Skill](https://github.com/twostraws/SwiftUI-Agent-Skill) | `be297ff` (2026-04-20) | MIT | Reviewing or writing SwiftUI: modern API, data flow, navigation, a11y, performance, hygiene. |
| `swift-concurrency-pro` | [twostraws/Swift-Concurrency-Agent-Skill](https://github.com/twostraws/Swift-Concurrency-Agent-Skill) | `bee3f69` (2026-05-17) | MIT | async/await, actors, Sendable, cancellation, Swift 6 strict concurrency diagnostics. |
| `swift-testing-pro` | [twostraws/Swift-Testing-Agent-Skill](https://github.com/twostraws/Swift-Testing-Agent-Skill) | `2d6bba1` (2026-05-17) | MIT | Writing Swift Testing tests, migrating from XCTest, async tests. |
| `swift-architecture` | [dpearson2699/swift-ios-skills](https://github.com/dpearson2699/swift-ios-skills) | `8d90fd1` (2026-07-31) | PolyForm Perimeter 1.0.0 | Choosing or reviewing an architecture pattern, module boundaries, test seams. |
| `swiftui-liquid-glass` | same | same | same | `GlassCompat.swift`: glassEffect, glass buttons, toolbar, scroll edge, availability gating. |
| `swiftui-navigation` | same | same | same | `NavigationStack`, routes, deep links, `TabView`. |
| `swift-charts` | same | same | same | Any Swift Charts work. |
| `ios-localization` | same | same | same | `.xcstrings`, plurals, locale handling. |
| `ios-accessibility` | same | same | same | VoiceOver, Dynamic Type, Reduce Motion audits. |
| `ios-networking` | same | same | same | URLSession, middlewares, retries, background transfers. |
| `swift-codable` | same | same | same | DTO decoding edge cases in `API/Mapping`. |
| `app-store-review` | same | same | same | Preparing the App Store submission, privacy manifest, guideline checks. |
| `swiftlint` | same | same | same | `.swiftlint.yml` configuration and rule triage. |
| `ios-simulator` | same | same | same | `simctl` commands, runtimes, device setup for CI. |
| `swiftui-performance-audit` | [patrickserrano/skills](https://github.com/patrickserrano/skills) | `e90c832` (2026-01-17) | MIT | Profiling and fixing slow SwiftUI views. |

Not installed, for the record: `AvdLee/Swift-Concurrency-Agent-Skill` (overlaps
`swift-concurrency-pro`), the other 75 skills of `dpearson2699/swift-ios-skills` (frameworks
a given app may not use: HealthKit, StoreKit, SwiftData, MapKit…). When the brief adopts
one of those frameworks, add the matching skill by copying its folder from the upstream
repo after an `/audit-skill` pass, and record it here.

License note: the dpearson2699 skills are under PolyForm Perimeter, which permits internal use
and forbids offering a competing product built from them. Vendoring them here to build an
app is within the license.

## Updating a third-party skill

```sh
git clone --depth 1 https://github.com/<owner>/<repo> /tmp/skill-src
# run /audit-skill on /tmp/skill-src, then copy the skill folder over the existing one
cp -R /tmp/skill-src/<path-to-skill>/. .claude/skills/<skill>/
```

Update the commit column above in the same commit.
