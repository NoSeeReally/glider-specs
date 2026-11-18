# 02 — Project structure

**Purpose:** Show where current project material lives and how to extend the layout safely.

**Confidence note:** Verified against the working tree on 2026-11-17. The code wins (see 16); this is a documentation-only snapshot.

## Current annotated tree

```text
glider-api/       API contributor guidance only
glider-android/   Android contributor guidance only
glider-web/       Web contributor guidance only
glider-specs/     business-logic-v1.0.md, sense-making.md,
                  git-guidelines.md, skills/ (this set)
handoff.md        instructions to create this knowledge set
Agents.md         repository-level read instructions
```

There are no verified source, build, migration, CI, or test directories. Put future implementation in its product repository and durable requirements/design material in `glider-specs`; do not put product code in the specs directory. Confirm actual project conventions when manifests and code are introduced.

No naming convention beyond the documented repository names and numbered `NN_TOPIC.md` skills format is established.
