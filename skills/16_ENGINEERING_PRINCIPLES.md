# 16 — Engineering principles

**Purpose:** State only principles supported by project guidance or observed repository evidence.

**Confidence note:** Verified against `handoff.md`, `glider-specs/git-guidelines.md`, and the working tree on 2026-11-17. The code wins (see this document).

## Principles

1. **Treat draft requirements as proposals until completed and approved.** The business-logic file contains explicit placeholders; implementing guessed details creates behavior nobody specified. Evidence: `glider-specs/business-logic-v1.0.md`.
2. **Keep knowledge tied to evidence and confidence.** Handoff instructions require concrete paths, reasons, and confidence labels; unsupported claims teach false behavior. Evidence: `handoff.md`.
3. **Preserve release gates and identify the exact artifact.** The Git guide separates QA, release testing, and production approval; skipping a gate means untested code may be treated as approved. Evidence: `glider-specs/git-guidelines.md`.
4. **Do not mistake a privacy requirement for an implemented safeguard.** The current draft names controls without code or data-flow evidence; assuming enforcement can leave sensitive information exposed. Evidence: `glider-specs/business-logic-v1.0.md` and absence of implementation in this checkout.

trust the code over any document, including this one
