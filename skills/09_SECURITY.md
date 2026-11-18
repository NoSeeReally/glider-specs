# 09 — Security

**Purpose:** Track verified security boundaries and privacy controls.

**Confidence note:** Verified against the working tree on 2026-11-17. The code wins (see 16); security implementation cannot be inspected yet.

## Draft requirements, not verified controls

`glider-specs/business-logic-v1.0.md` proposes Google Sign-In and a privacy-by-design layer mentioning Data Privacy Act compliance, location protection, retention limits, no per-user trails, aggregation thresholds, and consent for data resale. The project identity and actual data flows are unspecified. No authentication code, authorization checks, secret configuration, or privacy enforcement is present to verify these promises.

Do not describe these as shipped safeguards. When implementation exists, trace identity validation, authorization at each server boundary, session/token lifetime, secret sources (names only), injection surfaces, debug gates, data minimization, retention/deletion, aggregation thresholds, and consent enforcement. A missed check can expose another user's data; capture the concrete path and test for each actual control.
