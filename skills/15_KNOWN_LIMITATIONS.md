# 15 — Known limitations

**Purpose:** Make the boundaries of current project knowledge explicit and rank the work that removes them.

**Confidence note:** Verified against the working tree on 2026-11-17. The code wins (see 16); this checkout contains only a small documentation scaffold.

## Limitations, most likely to surprise first

1. **Identity and requirements are placeholders.** `business-logic-v1.0.md` contains `<Team Name>`, `<Code Name>`, placeholder user stories, and incomplete MVP feature rows. Security and product scope cannot be derived from it.
2. **No implementation is present.** API, clients, persistence, validation, and runtime behavior are unknown.
3. **No history or verification artifacts exist.** The current Git branch has no commits; there are no tests, CI, manifests, or incident records.
4. **Templates retain `code-name` placeholders.** The Git guideline is not yet project-specific, including product prefixes.
5. **Privacy promises are not evidence of controls.** The draft names safeguards but does not define data flows, thresholds, retention durations, or enforcement mechanisms.

## Ranked next work

1. Approve project identity, user roles, complete requirements, and concrete privacy/data lifecycle decisions.
2. Add source, manifests, tests, and deployment configuration; establish traceable history.
3. Resolve API/data/auth architecture and enumerate client/server lockstep contracts.
4. Configure and document release environments and gates.
5. Replace provisional sections in this skills set with evidence from code, tests, and operations.
