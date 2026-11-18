# 10 — Deployment

**Purpose:** Record release order, artifacts, and gates for each deployable.

**Confidence note:** Verified against the working tree on 2026-11-17. The code wins (see 16); no CI, deployment config, or release tags exist.

The Git guide prescribes a maturity flow `main → beta → release → production`, with QA before release testing and separate approval of the exact RC candidate. It also defines product tag prefixes as templates (`WCN`, `BCN`, `ACN`, `SCN`) but uses placeholder product identity. This working tree has no commits, tags, or evidence that branches, environments, or deployments are configured; treat the guide as policy text, not observed practice.

No deployable artifacts, environment variables, secrets setup, release order, rollback, or operational owner is established. Before a real release, replace `code-name` placeholders, identify actual repositories and branch protections, and document reproducible build/publish commands. Never deploy based only on a tag name; verify the approved commit and artifact.
