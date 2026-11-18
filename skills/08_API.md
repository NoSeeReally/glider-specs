# 08 — API

**Purpose:** Describe the server contract and safe endpoint workflow when API implementation is available.

**Confidence note:** Verified against the working tree on 2026-11-17. The code wins (see 16); no route, validator, schema, or API manifest exists.

No response envelope, route inventory, authentication policy, versioning scheme, or validation library can be confirmed. `glider-api/Agents.md` contains no project-specific endpoint instructions in this snapshot.

Before adding an endpoint, first identify the established router, auth middleware, request validators, response/error conventions, and contract tests from actual source. Then document the route, access level, input/output, failure modes, and compatibility implications here. Do not model the proposed Google Sign-In requirement as a working API flow without an implementation trace.
