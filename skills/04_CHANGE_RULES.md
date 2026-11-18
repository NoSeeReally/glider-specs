# 04 — Change rules

**Purpose:** Track synchronized edits and high-risk changes so mirrored contracts do not drift.

**Confidence note:** Verified against the working tree on 2026-11-17. The code wins (see 16); no API, client, schema, or generated files are present.

## Lockstep inventory

No verified lockstep set can yet be enumerated: there are no shared enums, error codes, route contracts, schema columns, or generated types in the checkout. In particular, Google Sign-In appears only as a draft requirement in `glider-specs/business-logic-v1.0.md`; its provider configuration and client/server contract are unknown.

When implementation establishes a mirrored value, list every concrete path here, explain the consequence of a missed update (`Miss → ...`), and name the checks that cover it. Until then, do not claim a change is complete based on one repository alone.

## High-risk unknowns

Authentication and authorization, privacy and location handling, persisted identity, API compatibility, and release ordering are unresolved by the available files. Retest decisions cannot be specified until their implementation and test commands exist.
