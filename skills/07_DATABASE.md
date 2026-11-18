# 07 — Database

**Purpose:** Record persistence invariants and safe schema procedures.

**Confidence note:** Verified against the working tree on 2026-11-17. The code wins (see 16); no database configuration, schema, or migration is present.

No identity strategy, tables, constraints, delete policy, migration tool, indexes, or backup procedure can be verified. The draft's mention of backups under System Administrator is a proposed responsibility, not evidence of an implemented backup system.

When persistence is introduced, document table ownership, keys and uniqueness, referential integrity, deletion/retention behavior, migration ordering and rollback limits, indexes for measured queries, and tested backup restoration. Never infer data lifecycle from a UI requirement; a missed retention rule could leave sensitive records indefinitely.
