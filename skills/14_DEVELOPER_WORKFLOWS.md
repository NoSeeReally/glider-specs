# 14 — Developer workflows

**Purpose:** Provide reproducible contributor recipes and keep them aligned with verified project commands.

**Confidence note:** Verified against the working tree on 2026-11-17. The code wins (see 16); no setup or build manifests are available.

## Current setup

There is no verified install, build, run, lint, or test command. Do not run guessed package-manager commands; first add the relevant manifest and setup instructions to the component repository.

## Adding a feature (once implementation exists)

1. Confirm the requirement and user access in the approved business-logic spec.
2. Trace related API, web, and Android contracts and record mirrored changes in 04.
3. Follow actual repository setup and test commands; add tests for the changed behavior and access boundary.
4. Review privacy/security implications using 09 and release gates using 10.
5. Record any newly discovered failure mode or surprising setup step in the relevant note or `INBOX.md`.

## Changing requirements

Edit the spec with evidence and rationale, update cross-component contracts only after confirming implementation, and retain decision history. The Git guide defines the intended promotion gates; verify actual branch/tag setup before relying on them.

Add what surprised you to `INBOX.md`.
