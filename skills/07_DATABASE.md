# 07 - Database

**Purpose:** Record persistence invariants and safe schema procedures.

**Confidence note:** The local full snapshot `glider-specs/db-schema/v1.0.0.sql` and design choices were reviewed on 2026-11-19. They define a proposed Supabase PostgreSQL baseline; the SQL has not been applied to or verified against a live Supabase project.

## Proposed persistence model

- Tables use `id bigint GENERATED ALWAYS AS IDENTITY` as a server-only key and a `uuid` as cross-device row identity. Client grants omit `id`. Relationships use `*_uuid` columns; most intentionally have no physical `REFERENCES` constraint. A trusted sync path can receive children before parents; interactive RLS writes check parent ownership when the parent exists.
- The snapshot covers profiles and app roles, posts and media, recipes with ordered ingredients/instructions, cooking attempts with source attribution snapshots, follows, likes, comments, saves, reports, moderation audit actions, and account-deletion requests.
- Supabase Auth user UUIDs identify profiles. Public content is readable to guests; RLS restricts writes and private interactions. Moderator hide/restore is logged and applied by a database trigger. Storage is configured for public JPEG/PNG/WebP images up to 10 MiB with authenticated uploads in a caller-owned UUID folder.
- Soft deletion uses `archived_at`; clients must gate ordinary reads on live rows and sync tombstones. Clients are responsible for advancing `updated_at` on local changes; only sync should set client-only `synchronized_at`.

## Versioned artifacts

`db-design-choices.md` defines two tracks: forward server migrations increment the patch (`v1.0.0`, `v1.0.1`, `v1.0.2`), while complete snapshots exported from Supabase increment the minor (`v1.0.0`, `v1.1.0`, `v1.2.0`). Numbered artifacts are immutable once applied or recorded. A local snapshot is not evidence that the server has that schema.

## Open verification and policy work

Before launch, apply the snapshot to a Supabase test project and verify SQL compatibility, grants, RLS behavior for `anon`/`authenticated`, signup profile creation, storage policies, and idempotent reruns. Define and test account deletion, data retention, and backup restoration. The 10 MiB image cap, MIME allowlist, and 1-5 rating scale are provisional schema choices; stakeholders should confirm them. Username character/length rules and account deletion retention behavior remain open. The proposal does not establish real-world enforcement until deployed and tested.
