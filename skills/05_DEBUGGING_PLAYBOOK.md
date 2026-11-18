# 05 — Debugging playbook

**Purpose:** Give maintainers verified diagnostics and a home for exact runtime symptoms.

**Confidence note:** Verified against the working tree on 2026-11-17. The code wins (see 16); no runtime, logs, or executable commands are present.

## Current diagnostic shortcut

1. Confirm the intended repo and branch, then inspect `git status` and the changed files.
2. Search source and tests for the exact error text once source has been added; this checkout has no such messages.
3. Reproduce with the repository's documented command after manifests are available. No build or test command is currently supported by evidence.

| Exact symptom | Status |
|---|---|
| Runtime/API error messages | None available to inventory |
| Build or test failures | No manifests or commands available |

Do not invent log locations or run guessed commands: a plausible command may target the wrong project or conceal that setup is missing. Add symptom, frequency-ranked causes, diagnostic shortcut, and verified fix when an actual failure is observed.
