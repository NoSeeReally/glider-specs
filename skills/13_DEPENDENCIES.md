# 13 — Dependencies

**Purpose:** Explain dependency choices and safe upgrade traps.

**Confidence note:** Verified against the working tree on 2026-11-17. The code wins (see 16); no package or lock manifests are present.

No runtime, development, or platform dependencies can be inventoried. No upgrade policy or deliberate rejection is evidenced. When manifests are added, list each important dependency with its owning component, reason, supported version source, upgrade risks, and replacement/rejection rationale. Keep lockfiles with their manifests; otherwise reproducible installs cannot be established.
