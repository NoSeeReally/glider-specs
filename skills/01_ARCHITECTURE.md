# 01 — Architecture

**Purpose:** Establish current system boundaries and decisions; read first before proposing cross-component changes.

**Confidence note:** Verified against the working tree on 2026-11-17. The code wins (see 16); no executable code or commit history is present.

## Current model

The checkout has three named product directories (`glider-api`, `glider-web`, `glider-android`) and a specification directory (`glider-specs`). Only Markdown guidance and draft requirements are present. No end-to-end data flow, deployed component, persistence layer, or integration can be verified.

| Area | Verified ownership | Current evidence |
|---|---|---|
| API | Intended backend area; implementation unknown | `glider-api/Agents.md` is empty in this snapshot |
| Web | Intended web client area; implementation unknown | `glider-web/Agents.md` is empty in this snapshot |
| Android | Intended Android client area; implementation unknown | `glider-android/Agents.md` is empty in this snapshot |
| Specs | Requirements and contributor guidance | `glider-specs/business-logic-v1.0.md`, `sense-making.md`, `git-guidelines.md` |

The business-logic draft names Web and Android as allowed platforms and proposes Google Sign-In, but its project identity, user needs, and most requirements remain placeholders. Treat that as a proposal, not an implemented architecture.

## Decisions and inherited tradeoffs

No accepted architecture decision records or commit history are available. Do not infer why a framework, database, or authentication design was selected.

## Debt register (ranked)

1. **Requirements are placeholders:** implementation against them would encode guesses. Complete and approve the business logic before feature work.
2. **No implementation evidence:** routes, data ownership, authorization, and deployment order cannot be reviewed. Add source and operational manifests, then replace this provisional model.
3. **Git history unavailable:** incident and design rationale cannot be reconstructed. Preserve meaningful commit history when establishing the repositories.
