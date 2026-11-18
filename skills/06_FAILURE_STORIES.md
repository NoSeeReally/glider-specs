# 06 — Failure stories

**Purpose:** Preserve incident causes and fixes so future changes avoid repeating them.

**Confidence note:** Verified against the working tree on 2026-11-17. The code wins (see 16); no commits or incident reports are available.

## No reconstructed incidents

`git log` reports that the current `main` branch has no commits. There are no issue reports, tests, or runtime artifacts to substantiate an outage, regression, or fix. Therefore no incident is reconstructed here; attributing a cause would be fabrication.

When an incident is documented, give it an append-only number and include what happened, impact, cause and evidence, detection, fix, lesson, and confidence. Link its prevention rule from 04, its diagnostic from 05, and its principle from 16 where relevant.
