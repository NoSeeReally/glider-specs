-- Glider MVP full schema snapshot v1.0.0 for Supabase PostgreSQL.
-- Apply as a privileged project owner (for example, from the Supabase SQL Editor).
-- Re-running this snapshot is safe on the same baseline. Forward changes belong in
-- v1.0.x migrations; do not edit a snapshot already adopted by an environment.
--
-- Every table's bigint id is server-only. Clients identify rows by uuid and use
-- *_uuid columns for relationships. UUID links intentionally have no REFERENCES
-- constraints so a trusted sync path can accept child rows before parents; direct
-- client writes validate ownership through RLS, triggers, and the sync/API layer.
-- profile.uuid is the Supabase Auth user's uuid (auth.uid()). Other uuids are
-- client-minted. Do not expose id through grants or API payloads.

BEGIN;

CREATE SCHEMA IF NOT EXISTS private;
REVOKE ALL ON SCHEMA private FROM PUBLIC, anon, authenticated;
GRANT USAGE ON SCHEMA private TO authenticated;

DO $$ BEGIN
  CREATE TYPE public.post_kind AS ENUM ('general', 'recipe', 'attempt');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
  CREATE TYPE public.post_state AS ENUM ('draft', 'published', 'hidden');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
  CREATE TYPE public.app_role AS ENUM ('moderator', 'administrator');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
  CREATE TYPE public.report_state AS ENUM ('submitted', 'under_review', 'resolved', 'dismissed');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
  CREATE TYPE public.moderation_action_kind AS ENUM ('hide', 'restore');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

CREATE TABLE IF NOT EXISTS public.profiles (
  id                bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid              uuid NOT NULL UNIQUE,
  created_by_uuid   uuid NOT NULL,
  username          text,
  display_name      text,
  bio               text,
  avatar_path       text,
  created_at        timestamptz NOT NULL DEFAULT now(),
  updated_at        timestamptz NOT NULL DEFAULT now(),
  archived_at       timestamptz,
  deleted_at        timestamptz,
  CONSTRAINT profiles_username_nonblank CHECK (username IS NULL OR length(btrim(username)) > 0)
);

CREATE TABLE IF NOT EXISTS public.account_roles (
  id                bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid              uuid NOT NULL UNIQUE,
  account_uuid      uuid NOT NULL,
  role              public.app_role NOT NULL,
  assigned_by_uuid  uuid NOT NULL,
  revoked_by_uuid   uuid,
  created_at        timestamptz NOT NULL DEFAULT now(),
  updated_at        timestamptz NOT NULL DEFAULT now(),
  archived_at       timestamptz,
  revoked_at        timestamptz
);

CREATE TABLE IF NOT EXISTS public.posts (
  id                bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid              uuid NOT NULL UNIQUE,
  created_by_uuid   uuid NOT NULL,
  kind              public.post_kind NOT NULL DEFAULT 'general',
  status            public.post_state NOT NULL DEFAULT 'draft',
  caption           text NOT NULL DEFAULT '',
  created_at        timestamptz NOT NULL DEFAULT now(),
  updated_at        timestamptz NOT NULL DEFAULT now(),
  published_at      timestamptz,
  archived_at       timestamptz
);

CREATE TABLE IF NOT EXISTS public.post_media (
  id                bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid              uuid NOT NULL UNIQUE,
  post_uuid         uuid NOT NULL,
  created_by_uuid   uuid NOT NULL,
  storage_path      text NOT NULL,
  mime_type         text NOT NULL CHECK (mime_type IN ('image/jpeg', 'image/png', 'image/webp')),
  byte_length       integer NOT NULL CHECK (byte_length BETWEEN 1 AND 10485760),
  alt_text          text,
  sort_order        integer NOT NULL DEFAULT 1 CHECK (sort_order > 0),
  created_at        timestamptz NOT NULL DEFAULT now(),
  updated_at        timestamptz NOT NULL DEFAULT now(),
  archived_at       timestamptz
);

CREATE TABLE IF NOT EXISTS public.recipes (
  id                bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid              uuid NOT NULL UNIQUE,
  post_uuid         uuid NOT NULL UNIQUE,
  created_by_uuid   uuid NOT NULL,
  title             text NOT NULL CHECK (length(btrim(title)) > 0),
  servings          integer CHECK (servings IS NULL OR servings > 0),
  prep_minutes      integer CHECK (prep_minutes IS NULL OR prep_minutes >= 0),
  cook_minutes      integer CHECK (cook_minutes IS NULL OR cook_minutes >= 0),
  created_at        timestamptz NOT NULL DEFAULT now(),
  updated_at        timestamptz NOT NULL DEFAULT now(),
  archived_at       timestamptz
);

CREATE TABLE IF NOT EXISTS public.recipe_ingredients (
  id                bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid              uuid NOT NULL UNIQUE,
  recipe_uuid       uuid NOT NULL,
  created_by_uuid   uuid NOT NULL,
  sort_order        integer NOT NULL CHECK (sort_order > 0),
  name              text NOT NULL CHECK (length(btrim(name)) > 0),
  quantity          text,
  unit              text,
  note              text,
  created_at        timestamptz NOT NULL DEFAULT now(),
  updated_at        timestamptz NOT NULL DEFAULT now(),
  archived_at       timestamptz
);

CREATE TABLE IF NOT EXISTS public.recipe_instructions (
  id                bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid              uuid NOT NULL UNIQUE,
  recipe_uuid       uuid NOT NULL,
  created_by_uuid   uuid NOT NULL,
  step_number       integer NOT NULL CHECK (step_number > 0),
  instruction       text NOT NULL CHECK (length(btrim(instruction)) > 0),
  created_at        timestamptz NOT NULL DEFAULT now(),
  updated_at        timestamptz NOT NULL DEFAULT now(),
  archived_at       timestamptz
);

CREATE TABLE IF NOT EXISTS public.cooking_attempts (
  id                    bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid                  uuid NOT NULL UNIQUE,
  post_uuid             uuid NOT NULL UNIQUE,
  recipe_uuid           uuid NOT NULL,
  created_by_uuid       uuid NOT NULL,
  source_recipe_title   text NOT NULL,
  source_author_uuid    uuid NOT NULL,
  rating                smallint NOT NULL CHECK (rating BETWEEN 1 AND 5),
  notes                 text,
  changes               text,
  created_at            timestamptz NOT NULL DEFAULT now(),
  updated_at            timestamptz NOT NULL DEFAULT now(),
  archived_at           timestamptz
);

CREATE TABLE IF NOT EXISTS public.follows (
  id                bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid              uuid NOT NULL UNIQUE,
  follower_uuid     uuid NOT NULL,
  followed_uuid     uuid NOT NULL,
  created_at        timestamptz NOT NULL DEFAULT now(),
  updated_at        timestamptz NOT NULL DEFAULT now(),
  archived_at       timestamptz,
  CONSTRAINT follows_no_self CHECK (follower_uuid <> followed_uuid)
);

CREATE TABLE IF NOT EXISTS public.post_likes (
  id                bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid              uuid NOT NULL UNIQUE,
  post_uuid         uuid NOT NULL,
  account_uuid      uuid NOT NULL,
  created_at        timestamptz NOT NULL DEFAULT now(),
  updated_at        timestamptz NOT NULL DEFAULT now(),
  archived_at       timestamptz
);

CREATE TABLE IF NOT EXISTS public.comments (
  id                bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid              uuid NOT NULL UNIQUE,
  post_uuid         uuid NOT NULL,
  created_by_uuid   uuid NOT NULL,
  body              text NOT NULL CHECK (length(btrim(body)) > 0),
  is_hidden         boolean NOT NULL DEFAULT false,
  created_at        timestamptz NOT NULL DEFAULT now(),
  updated_at        timestamptz NOT NULL DEFAULT now(),
  archived_at       timestamptz
);

CREATE TABLE IF NOT EXISTS public.saved_recipes (
  id                bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid              uuid NOT NULL UNIQUE,
  account_uuid      uuid NOT NULL,
  recipe_uuid       uuid NOT NULL,
  created_at        timestamptz NOT NULL DEFAULT now(),
  updated_at        timestamptz NOT NULL DEFAULT now(),
  archived_at       timestamptz
);

CREATE TABLE IF NOT EXISTS public.content_reports (
  id                bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid              uuid NOT NULL UNIQUE,
  reporter_uuid     uuid NOT NULL,
  target_type       text NOT NULL CHECK (target_type IN ('post', 'comment')),
  target_uuid       uuid NOT NULL,
  reason            text NOT NULL CHECK (length(btrim(reason)) > 0),
  details           text,
  status            public.report_state NOT NULL DEFAULT 'submitted',
  resolution_note  text,
  resolved_by_uuid  uuid,
  resolved_at       timestamptz,
  created_at        timestamptz NOT NULL DEFAULT now(),
  updated_at        timestamptz NOT NULL DEFAULT now(),
  archived_at       timestamptz
);

CREATE TABLE IF NOT EXISTS public.moderation_actions (
  id                bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid              uuid NOT NULL UNIQUE,
  actor_uuid        uuid NOT NULL,
  target_type       text NOT NULL CHECK (target_type IN ('post', 'comment')),
  target_uuid       uuid NOT NULL,
  action            public.moderation_action_kind NOT NULL,
  reason            text NOT NULL CHECK (length(btrim(reason)) > 0),
  created_at        timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.account_deletion_requests (
  id                bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid              uuid NOT NULL UNIQUE,
  account_uuid      uuid NOT NULL,
  status            text NOT NULL DEFAULT 'pending'
                    CHECK (status IN ('pending', 'approved', 'rejected', 'completed')),
  requested_at      timestamptz NOT NULL DEFAULT now(),
  resolved_by_uuid  uuid,
  resolved_at       timestamptz,
  resolution_note   text,
  created_at        timestamptz NOT NULL DEFAULT now(),
  updated_at        timestamptz NOT NULL DEFAULT now(),
  archived_at       timestamptz
);

-- Partial uniqueness lets an archived relationship be recreated after an unfollow,
-- unlike, save removal, or resolution of a report/deletion request.
CREATE UNIQUE INDEX IF NOT EXISTS profiles_username_live_uq
  ON public.profiles (lower(username)) WHERE archived_at IS NULL AND deleted_at IS NULL AND username IS NOT NULL;
CREATE UNIQUE INDEX IF NOT EXISTS account_roles_active_uq
  ON public.account_roles (account_uuid, role) WHERE archived_at IS NULL AND revoked_at IS NULL;
CREATE INDEX IF NOT EXISTS account_roles_account_idx ON public.account_roles (account_uuid);
CREATE INDEX IF NOT EXISTS posts_creator_idx ON public.posts (created_by_uuid);
CREATE INDEX IF NOT EXISTS posts_recent_public_idx ON public.posts (published_at DESC, uuid)
  WHERE status = 'published' AND archived_at IS NULL;
CREATE INDEX IF NOT EXISTS post_media_post_idx ON public.post_media (post_uuid, sort_order)
  WHERE archived_at IS NULL;
CREATE UNIQUE INDEX IF NOT EXISTS post_media_path_live_uq ON public.post_media (storage_path)
  WHERE archived_at IS NULL;
CREATE INDEX IF NOT EXISTS recipes_post_idx ON public.recipes (post_uuid);
CREATE INDEX IF NOT EXISTS recipes_title_search_idx ON public.recipes USING gin (to_tsvector('simple', title));
CREATE UNIQUE INDEX IF NOT EXISTS ingredients_recipe_order_live_uq
  ON public.recipe_ingredients (recipe_uuid, sort_order) WHERE archived_at IS NULL;
CREATE INDEX IF NOT EXISTS ingredients_name_search_idx ON public.recipe_ingredients
  USING gin (to_tsvector('simple', name));
CREATE UNIQUE INDEX IF NOT EXISTS instructions_recipe_order_live_uq
  ON public.recipe_instructions (recipe_uuid, step_number) WHERE archived_at IS NULL;
CREATE INDEX IF NOT EXISTS attempts_recipe_idx ON public.cooking_attempts (recipe_uuid, created_at DESC)
  WHERE archived_at IS NULL;
CREATE INDEX IF NOT EXISTS attempts_creator_idx ON public.cooking_attempts (created_by_uuid);
CREATE UNIQUE INDEX IF NOT EXISTS follows_live_pair_uq ON public.follows (follower_uuid, followed_uuid)
  WHERE archived_at IS NULL;
CREATE INDEX IF NOT EXISTS follows_followed_idx ON public.follows (followed_uuid, follower_uuid)
  WHERE archived_at IS NULL;
CREATE UNIQUE INDEX IF NOT EXISTS post_likes_live_pair_uq ON public.post_likes (account_uuid, post_uuid)
  WHERE archived_at IS NULL;
CREATE INDEX IF NOT EXISTS post_likes_post_idx ON public.post_likes (post_uuid) WHERE archived_at IS NULL;
CREATE INDEX IF NOT EXISTS comments_post_recent_idx ON public.comments (post_uuid, created_at)
  WHERE archived_at IS NULL AND is_hidden = false;
CREATE INDEX IF NOT EXISTS comments_creator_idx ON public.comments (created_by_uuid);
CREATE UNIQUE INDEX IF NOT EXISTS saved_recipes_live_pair_uq ON public.saved_recipes (account_uuid, recipe_uuid)
  WHERE archived_at IS NULL;
CREATE INDEX IF NOT EXISTS saved_recipes_recipe_idx ON public.saved_recipes (recipe_uuid)
  WHERE archived_at IS NULL;
CREATE INDEX IF NOT EXISTS reports_queue_idx ON public.content_reports (status, created_at)
  WHERE archived_at IS NULL;
CREATE INDEX IF NOT EXISTS reports_reporter_idx ON public.content_reports (reporter_uuid, created_at DESC);
CREATE UNIQUE INDEX IF NOT EXISTS reports_open_target_uq
  ON public.content_reports (reporter_uuid, target_type, target_uuid)
  WHERE archived_at IS NULL AND status IN ('submitted', 'under_review');
CREATE INDEX IF NOT EXISTS moderation_target_idx ON public.moderation_actions (target_type, target_uuid, created_at DESC);
CREATE INDEX IF NOT EXISTS moderation_actor_idx ON public.moderation_actions (actor_uuid, created_at DESC);
CREATE INDEX IF NOT EXISTS deletion_requests_queue_idx ON public.account_deletion_requests (status, requested_at);
CREATE UNIQUE INDEX IF NOT EXISTS deletion_requests_pending_uq ON public.account_deletion_requests (account_uuid)
  WHERE archived_at IS NULL AND status IN ('pending', 'approved');

-- Role lookup is isolated from the exposed schema and bypasses the role table's RLS
-- only to answer whether the current authenticated account holds one requested role.
CREATE OR REPLACE FUNCTION private.has_app_role(role_name text)
RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = ''
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.account_roles ar
    WHERE ar.account_uuid = (SELECT auth.uid())
      AND ar.role::text = role_name
      AND ar.archived_at IS NULL
      AND ar.revoked_at IS NULL
  );
$$;
REVOKE ALL ON FUNCTION private.has_app_role(text) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION private.has_app_role(text) TO authenticated;

-- Create a public profile when Supabase Auth creates a user. Usernames are chosen
-- during onboarding; provider metadata is display-only and is never authorization data.
CREATE OR REPLACE FUNCTION private.create_profile_for_auth_user()
RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  INSERT INTO public.profiles (uuid, created_by_uuid, display_name)
  VALUES (
    NEW.id,
    NEW.id,
    COALESCE(NULLIF(NEW.raw_user_meta_data ->> 'full_name', ''),
             NULLIF(NEW.raw_user_meta_data ->> 'name', ''))
  )
  ON CONFLICT (uuid) DO NOTHING;
  RETURN NEW;
END;
$$;
REVOKE ALL ON FUNCTION private.create_profile_for_auth_user() FROM PUBLIC, anon, authenticated;

CREATE OR REPLACE FUNCTION private.stamp_report_resolution()
RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  IF NEW.status IS DISTINCT FROM OLD.status THEN
    IF NEW.status IN ('resolved', 'dismissed') THEN
      NEW.resolved_by_uuid := COALESCE((SELECT auth.uid()), NEW.resolved_by_uuid);
      NEW.resolved_at := COALESCE(NEW.resolved_at, now());
    ELSE
      NEW.resolved_by_uuid := NULL;
      NEW.resolved_at := NULL;
    END IF;
    NEW.updated_at := now();
  END IF;
  RETURN NEW;
END;
$$;
REVOKE ALL ON FUNCTION private.stamp_report_resolution() FROM PUBLIC, anon, authenticated;
DROP TRIGGER IF EXISTS reports_stamp_resolution ON public.content_reports;
CREATE TRIGGER reports_stamp_resolution BEFORE UPDATE ON public.content_reports
  FOR EACH ROW EXECUTE FUNCTION private.stamp_report_resolution();

CREATE OR REPLACE FUNCTION private.stamp_deletion_resolution()
RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  IF NEW.status IS DISTINCT FROM OLD.status THEN
    IF NEW.status IN ('approved', 'rejected', 'completed') THEN
      NEW.resolved_by_uuid := COALESCE((SELECT auth.uid()), NEW.resolved_by_uuid);
      NEW.resolved_at := COALESCE(NEW.resolved_at, now());
    ELSE
      NEW.resolved_by_uuid := NULL;
      NEW.resolved_at := NULL;
    END IF;
    NEW.updated_at := now();
  END IF;
  RETURN NEW;
END;
$$;
REVOKE ALL ON FUNCTION private.stamp_deletion_resolution() FROM PUBLIC, anon, authenticated;
DROP TRIGGER IF EXISTS deletion_requests_stamp_resolution ON public.account_deletion_requests;
CREATE TRIGGER deletion_requests_stamp_resolution BEFORE UPDATE ON public.account_deletion_requests
  FOR EACH ROW EXECUTE FUNCTION private.stamp_deletion_resolution();

CREATE OR REPLACE FUNCTION private.stamp_role_revocation_actor()
RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  IF OLD.revoked_at IS NULL AND NEW.revoked_at IS NOT NULL THEN
    NEW.revoked_by_uuid := COALESCE((SELECT auth.uid()), NEW.revoked_by_uuid);
    NEW.updated_at := now();
  END IF;
  RETURN NEW;
END;
$$;
REVOKE ALL ON FUNCTION private.stamp_role_revocation_actor() FROM PUBLIC, anon, authenticated;
DROP TRIGGER IF EXISTS account_roles_stamp_revocation ON public.account_roles;
CREATE TRIGGER account_roles_stamp_revocation BEFORE UPDATE ON public.account_roles
  FOR EACH ROW EXECUTE FUNCTION private.stamp_role_revocation_actor();
DROP TRIGGER IF EXISTS glider_create_profile_after_signup ON auth.users;
CREATE TRIGGER glider_create_profile_after_signup
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION private.create_profile_for_auth_user();

-- Freeze recipe title/author attribution into an attempt at creation. The snapshot
-- remains displayable if the source recipe is later archived or removed.
CREATE OR REPLACE FUNCTION private.capture_attempt_source()
RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  SELECT r.title, p.created_by_uuid
    INTO NEW.source_recipe_title, NEW.source_author_uuid
  FROM public.recipes r
  JOIN public.posts p ON p.uuid = r.post_uuid
  WHERE r.uuid = NEW.recipe_uuid
    AND r.archived_at IS NULL
    AND p.kind = 'recipe'
    AND p.status = 'published'
    AND p.archived_at IS NULL;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'attempt source recipe must be published and available';
  END IF;
  RETURN NEW;
END;
$$;
REVOKE ALL ON FUNCTION private.capture_attempt_source() FROM PUBLIC, anon, authenticated;
DROP TRIGGER IF EXISTS cooking_attempts_capture_source ON public.cooking_attempts;
CREATE TRIGGER cooking_attempts_capture_source
  BEFORE INSERT ON public.cooking_attempts
  FOR EACH ROW EXECUTE FUNCTION private.capture_attempt_source();

-- Publishing is the validation gate: a recipe needs its structured record,
-- at least one live ingredient/instruction, and image media; an attempt needs its
-- linked attempt data. Attempts may omit photos as allowed by the MVP requirements.
CREATE OR REPLACE FUNCTION private.validate_post_publication()
RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  IF NEW.status = 'published' THEN
    IF NEW.kind IN ('general', 'recipe') AND NOT EXISTS (
      SELECT 1 FROM public.post_media m
      WHERE m.post_uuid = NEW.uuid AND m.archived_at IS NULL
    ) THEN
      RAISE EXCEPTION 'published general and recipe posts require at least one image';
    END IF;
    IF NEW.kind = 'recipe' AND NOT EXISTS (
      SELECT 1 FROM public.recipes r
      WHERE r.post_uuid = NEW.uuid AND r.archived_at IS NULL
        AND EXISTS (SELECT 1 FROM public.recipe_ingredients i
                    WHERE i.recipe_uuid = r.uuid AND i.archived_at IS NULL)
        AND EXISTS (SELECT 1 FROM public.recipe_instructions s
                    WHERE s.recipe_uuid = r.uuid AND s.archived_at IS NULL)
    ) THEN
      RAISE EXCEPTION 'published recipe posts require a recipe, ingredient, and instruction';
    END IF;
    IF NEW.kind = 'attempt' AND NOT EXISTS (
      SELECT 1 FROM public.cooking_attempts a
      WHERE a.post_uuid = NEW.uuid AND a.archived_at IS NULL
    ) THEN
      RAISE EXCEPTION 'published attempt posts require a cooking attempt';
    END IF;
    NEW.published_at := COALESCE(NEW.published_at, now());
  END IF;
  RETURN NEW;
END;
$$;
REVOKE ALL ON FUNCTION private.validate_post_publication() FROM PUBLIC, anon, authenticated;
DROP TRIGGER IF EXISTS posts_validate_publication ON public.posts;
CREATE TRIGGER posts_validate_publication
  BEFORE INSERT OR UPDATE OF status ON public.posts
  FOR EACH ROW EXECUTE FUNCTION private.validate_post_publication();

-- A moderator action is an append-only audit event and applies its hide/restore
-- operation to the referenced content in the same transaction.
CREATE OR REPLACE FUNCTION private.apply_moderation_action()
RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  IF NEW.target_type = 'post' THEN
    UPDATE public.posts
       SET status = CASE NEW.action WHEN 'hide' THEN 'hidden'::public.post_state
                                    ELSE 'published'::public.post_state END,
           updated_at = now()
     WHERE uuid = NEW.target_uuid AND archived_at IS NULL;
  ELSE
    UPDATE public.comments
       SET is_hidden = (NEW.action = 'hide'), updated_at = now()
     WHERE uuid = NEW.target_uuid AND archived_at IS NULL;
  END IF;
  IF NOT FOUND THEN RAISE EXCEPTION 'moderation target not found'; END IF;
  RETURN NEW;
END;
$$;
REVOKE ALL ON FUNCTION private.apply_moderation_action() FROM PUBLIC, anon, authenticated;
DROP TRIGGER IF EXISTS moderation_actions_apply ON public.moderation_actions;
CREATE TRIGGER moderation_actions_apply
  AFTER INSERT ON public.moderation_actions
  FOR EACH ROW EXECUTE FUNCTION private.apply_moderation_action();

-- Verify that reported targets exist, preventing arbitrary UUIDs from entering the queue.
CREATE OR REPLACE FUNCTION private.validate_report_target()
RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  IF NEW.target_type = 'post' THEN
    IF NOT EXISTS (SELECT 1 FROM public.posts p WHERE p.uuid = NEW.target_uuid
      AND p.status = 'published' AND p.archived_at IS NULL) THEN
      RAISE EXCEPTION 'reported post not found';
    END IF;
  ELSE
    IF NOT EXISTS (SELECT 1 FROM public.comments c JOIN public.posts p ON p.uuid = c.post_uuid
      WHERE c.uuid = NEW.target_uuid AND c.is_hidden = false AND c.archived_at IS NULL
        AND p.status = 'published' AND p.archived_at IS NULL) THEN
      RAISE EXCEPTION 'reported comment not found';
    END IF;
  END IF;
  RETURN NEW;
END;
$$;
REVOKE ALL ON FUNCTION private.validate_report_target() FROM PUBLIC, anon, authenticated;
DROP TRIGGER IF EXISTS content_reports_validate_target ON public.content_reports;
CREATE TRIGGER content_reports_validate_target
  BEFORE INSERT ON public.content_reports
  FOR EACH ROW EXECUTE FUNCTION private.validate_report_target();

-- Keep public profile rows readable, while account owners retain access to their
-- own record during deletion handling.
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.account_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.post_media ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recipes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recipe_ingredients ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recipe_instructions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cooking_attempts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.follows ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.post_likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.saved_recipes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.content_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.moderation_actions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.account_deletion_requests ENABLE ROW LEVEL SECURITY;

-- Policies are recreated so this full snapshot can be safely re-applied.
DO $$ DECLARE p record; BEGIN
  FOR p IN SELECT schemaname, tablename, policyname FROM pg_policies
           WHERE schemaname = 'public'
             AND tablename IN ('profiles','account_roles','posts','post_media','recipes',
               'recipe_ingredients','recipe_instructions','cooking_attempts','follows','post_likes',
               'comments','saved_recipes','content_reports','moderation_actions','account_deletion_requests')
             AND policyname = ANY (ARRAY[
               'profiles_public_read','profiles_owner_update',
               'roles_self_or_admin_read','roles_admin_insert','roles_admin_update',
               'posts_public_read','posts_owner_read','posts_moderator_read','posts_owner_insert',
               'posts_owner_update',
               'post_media_public_read','post_media_owner_read','post_media_moderator_read',
               'post_media_owner_insert','post_media_owner_update',
               'recipes_public_read','recipes_owner_read','recipes_moderator_read',
               'recipes_owner_insert','recipes_owner_update',
               'ingredients_read','ingredients_moderator_read','ingredients_owner_insert','ingredients_owner_update',
               'instructions_read','instructions_moderator_read','instructions_owner_insert','instructions_owner_update',
               'attempts_public_read','attempts_owner_read','attempts_moderator_read','attempts_owner_insert','attempts_owner_update',
               'follows_owner_read','follows_owner_insert','follows_owner_update',
               'likes_owner_read','likes_owner_insert','likes_owner_update',
               'comments_public_read','comments_owner_read','comments_moderator_read',
               'comments_owner_insert','comments_owner_update',
               'saves_owner_read','saves_owner_insert','saves_owner_update',
               'reports_read_own_or_moderator','reports_owner_insert','reports_moderator_update',
               'moderation_read_moderator','moderation_insert_moderator',
               'deletion_read_owner_or_admin','deletion_owner_insert','deletion_admin_update'
             ]::text[])
  LOOP EXECUTE format('DROP POLICY IF EXISTS %I ON %I.%I', p.policyname, p.schemaname, p.tablename); END LOOP;
END $$;

CREATE POLICY profiles_public_read ON public.profiles FOR SELECT TO anon, authenticated
  USING ((archived_at IS NULL AND deleted_at IS NULL) OR uuid = (SELECT auth.uid()));
CREATE POLICY profiles_owner_update ON public.profiles FOR UPDATE TO authenticated
  USING (uuid = (SELECT auth.uid()))
  WITH CHECK (uuid = (SELECT auth.uid()) AND
    (avatar_path IS NULL OR split_part(avatar_path, '/', 1) = (SELECT auth.uid())::text));

CREATE POLICY roles_self_or_admin_read ON public.account_roles FOR SELECT TO authenticated
  USING (account_uuid = (SELECT auth.uid()) OR (SELECT private.has_app_role('administrator')));
CREATE POLICY roles_admin_insert ON public.account_roles FOR INSERT TO authenticated
  WITH CHECK ((SELECT private.has_app_role('administrator')) AND assigned_by_uuid = (SELECT auth.uid()));
CREATE POLICY roles_admin_update ON public.account_roles FOR UPDATE TO authenticated
  USING ((SELECT private.has_app_role('administrator')))
  WITH CHECK ((SELECT private.has_app_role('administrator')));

CREATE POLICY posts_public_read ON public.posts FOR SELECT TO anon, authenticated
  USING (status = 'published' AND archived_at IS NULL);
CREATE POLICY posts_owner_read ON public.posts FOR SELECT TO authenticated
  USING (created_by_uuid = (SELECT auth.uid()));
CREATE POLICY posts_moderator_read ON public.posts FOR SELECT TO authenticated
  USING ((SELECT private.has_app_role('moderator')) OR (SELECT private.has_app_role('administrator')));
CREATE POLICY posts_owner_insert ON public.posts FOR INSERT TO authenticated
  WITH CHECK (created_by_uuid = (SELECT auth.uid()) AND status IN ('draft','published'));
CREATE POLICY posts_owner_update ON public.posts FOR UPDATE TO authenticated
  USING (created_by_uuid = (SELECT auth.uid()) AND status <> 'hidden')
  WITH CHECK (created_by_uuid = (SELECT auth.uid()) AND status IN ('draft','published'));
CREATE POLICY post_media_public_read ON public.post_media FOR SELECT TO anon, authenticated
  USING (archived_at IS NULL AND EXISTS (SELECT 1 FROM public.posts p
    WHERE p.uuid = post_uuid AND p.status = 'published' AND p.archived_at IS NULL));
CREATE POLICY post_media_owner_read ON public.post_media FOR SELECT TO authenticated
  USING (EXISTS (SELECT 1 FROM public.posts p WHERE p.uuid = post_uuid AND p.created_by_uuid = (SELECT auth.uid())));
CREATE POLICY post_media_moderator_read ON public.post_media FOR SELECT TO authenticated
  USING ((SELECT private.has_app_role('moderator')) OR (SELECT private.has_app_role('administrator')));
CREATE POLICY post_media_owner_insert ON public.post_media FOR INSERT TO authenticated
  WITH CHECK (created_by_uuid = (SELECT auth.uid()) AND
    split_part(storage_path, '/', 1) = (SELECT auth.uid())::text AND
    EXISTS (SELECT 1 FROM public.posts p
      WHERE p.uuid = post_uuid AND p.created_by_uuid = (SELECT auth.uid()) AND p.archived_at IS NULL));
CREATE POLICY post_media_owner_update ON public.post_media FOR UPDATE TO authenticated
  USING (created_by_uuid = (SELECT auth.uid()) AND archived_at IS NULL)
  WITH CHECK (created_by_uuid = (SELECT auth.uid()) AND EXISTS (SELECT 1 FROM public.posts p
    WHERE p.uuid = post_uuid AND p.created_by_uuid = (SELECT auth.uid())));

CREATE POLICY recipes_public_read ON public.recipes FOR SELECT TO anon, authenticated
  USING (archived_at IS NULL AND EXISTS (SELECT 1 FROM public.posts p
    WHERE p.uuid = post_uuid AND p.kind = 'recipe' AND p.status = 'published' AND p.archived_at IS NULL));
CREATE POLICY recipes_owner_read ON public.recipes FOR SELECT TO authenticated
  USING (EXISTS (SELECT 1 FROM public.posts p WHERE p.uuid = post_uuid AND p.created_by_uuid = (SELECT auth.uid())));
CREATE POLICY recipes_moderator_read ON public.recipes FOR SELECT TO authenticated
  USING ((SELECT private.has_app_role('moderator')) OR (SELECT private.has_app_role('administrator')));
CREATE POLICY recipes_owner_insert ON public.recipes FOR INSERT TO authenticated
  WITH CHECK (created_by_uuid = (SELECT auth.uid()) AND EXISTS (SELECT 1 FROM public.posts p
    WHERE p.uuid = post_uuid AND p.kind = 'recipe' AND p.created_by_uuid = (SELECT auth.uid())));
CREATE POLICY recipes_owner_update ON public.recipes FOR UPDATE TO authenticated
  USING (created_by_uuid = (SELECT auth.uid()) AND archived_at IS NULL)
  WITH CHECK (created_by_uuid = (SELECT auth.uid()) AND EXISTS (SELECT 1 FROM public.posts p
    WHERE p.uuid = post_uuid AND p.kind = 'recipe' AND p.created_by_uuid = (SELECT auth.uid()) AND p.status <> 'hidden'));

CREATE POLICY ingredients_read ON public.recipe_ingredients FOR SELECT TO anon, authenticated
  USING (archived_at IS NULL AND EXISTS (SELECT 1 FROM public.recipes r JOIN public.posts p ON p.uuid = r.post_uuid
    WHERE r.uuid = recipe_uuid AND r.archived_at IS NULL AND
      (p.status = 'published' AND p.archived_at IS NULL OR p.created_by_uuid = (SELECT auth.uid()))));
CREATE POLICY ingredients_moderator_read ON public.recipe_ingredients FOR SELECT TO authenticated
  USING ((SELECT private.has_app_role('moderator')) OR (SELECT private.has_app_role('administrator')));
CREATE POLICY ingredients_owner_insert ON public.recipe_ingredients FOR INSERT TO authenticated
  WITH CHECK (created_by_uuid = (SELECT auth.uid()) AND EXISTS (SELECT 1 FROM public.recipes r JOIN public.posts p ON p.uuid = r.post_uuid
    WHERE r.uuid = recipe_uuid AND p.created_by_uuid = (SELECT auth.uid()) AND p.kind = 'recipe'));
CREATE POLICY ingredients_owner_update ON public.recipe_ingredients FOR UPDATE TO authenticated
  USING (created_by_uuid = (SELECT auth.uid()) AND archived_at IS NULL)
  WITH CHECK (created_by_uuid = (SELECT auth.uid()) AND EXISTS (SELECT 1 FROM public.recipes r JOIN public.posts p ON p.uuid = r.post_uuid
    WHERE r.uuid = recipe_uuid AND p.created_by_uuid = (SELECT auth.uid()) AND p.kind = 'recipe' AND p.status <> 'hidden'));

CREATE POLICY instructions_read ON public.recipe_instructions FOR SELECT TO anon, authenticated
  USING (archived_at IS NULL AND EXISTS (SELECT 1 FROM public.recipes r JOIN public.posts p ON p.uuid = r.post_uuid
    WHERE r.uuid = recipe_uuid AND r.archived_at IS NULL AND
      (p.status = 'published' AND p.archived_at IS NULL OR p.created_by_uuid = (SELECT auth.uid()))));
CREATE POLICY instructions_moderator_read ON public.recipe_instructions FOR SELECT TO authenticated
  USING ((SELECT private.has_app_role('moderator')) OR (SELECT private.has_app_role('administrator')));
CREATE POLICY instructions_owner_insert ON public.recipe_instructions FOR INSERT TO authenticated
  WITH CHECK (created_by_uuid = (SELECT auth.uid()) AND EXISTS (SELECT 1 FROM public.recipes r JOIN public.posts p ON p.uuid = r.post_uuid
    WHERE r.uuid = recipe_uuid AND p.created_by_uuid = (SELECT auth.uid()) AND p.kind = 'recipe'));
CREATE POLICY instructions_owner_update ON public.recipe_instructions FOR UPDATE TO authenticated
  USING (created_by_uuid = (SELECT auth.uid()) AND archived_at IS NULL)
  WITH CHECK (created_by_uuid = (SELECT auth.uid()) AND EXISTS (SELECT 1 FROM public.recipes r JOIN public.posts p ON p.uuid = r.post_uuid
    WHERE r.uuid = recipe_uuid AND p.created_by_uuid = (SELECT auth.uid()) AND p.kind = 'recipe' AND p.status <> 'hidden'));

CREATE POLICY attempts_public_read ON public.cooking_attempts FOR SELECT TO anon, authenticated
  USING (archived_at IS NULL AND EXISTS (SELECT 1 FROM public.posts p
    WHERE p.uuid = post_uuid AND p.kind = 'attempt' AND p.status = 'published' AND p.archived_at IS NULL));
CREATE POLICY attempts_owner_read ON public.cooking_attempts FOR SELECT TO authenticated
  USING (created_by_uuid = (SELECT auth.uid()));
CREATE POLICY attempts_moderator_read ON public.cooking_attempts FOR SELECT TO authenticated
  USING ((SELECT private.has_app_role('moderator')) OR (SELECT private.has_app_role('administrator')));
CREATE POLICY attempts_owner_insert ON public.cooking_attempts FOR INSERT TO authenticated
  WITH CHECK (created_by_uuid = (SELECT auth.uid()) AND EXISTS (SELECT 1 FROM public.posts p
    WHERE p.uuid = post_uuid AND p.kind = 'attempt' AND p.created_by_uuid = (SELECT auth.uid())));
CREATE POLICY attempts_owner_update ON public.cooking_attempts FOR UPDATE TO authenticated
  USING (created_by_uuid = (SELECT auth.uid()) AND archived_at IS NULL)
  WITH CHECK (created_by_uuid = (SELECT auth.uid()) AND EXISTS (SELECT 1 FROM public.posts p
    WHERE p.uuid = post_uuid AND p.kind = 'attempt' AND p.created_by_uuid = (SELECT auth.uid()) AND p.status <> 'hidden'));

CREATE POLICY follows_owner_read ON public.follows FOR SELECT TO authenticated
  USING (follower_uuid = (SELECT auth.uid()));
CREATE POLICY follows_owner_insert ON public.follows FOR INSERT TO authenticated
  WITH CHECK (follower_uuid = (SELECT auth.uid()));
CREATE POLICY follows_owner_update ON public.follows FOR UPDATE TO authenticated
  USING (follower_uuid = (SELECT auth.uid())) WITH CHECK (follower_uuid = (SELECT auth.uid()));
CREATE POLICY likes_owner_read ON public.post_likes FOR SELECT TO authenticated
  USING (account_uuid = (SELECT auth.uid()));
CREATE POLICY likes_owner_insert ON public.post_likes FOR INSERT TO authenticated
  WITH CHECK (account_uuid = (SELECT auth.uid()) AND EXISTS (SELECT 1 FROM public.posts p
    WHERE p.uuid = post_uuid AND p.status = 'published' AND p.archived_at IS NULL));
CREATE POLICY likes_owner_update ON public.post_likes FOR UPDATE TO authenticated
  USING (account_uuid = (SELECT auth.uid())) WITH CHECK (account_uuid = (SELECT auth.uid()));

CREATE POLICY comments_public_read ON public.comments FOR SELECT TO anon, authenticated
  USING (archived_at IS NULL AND is_hidden = false AND EXISTS (SELECT 1 FROM public.posts p
    WHERE p.uuid = post_uuid AND p.status = 'published' AND p.archived_at IS NULL));
CREATE POLICY comments_owner_read ON public.comments FOR SELECT TO authenticated
  USING (created_by_uuid = (SELECT auth.uid()));
CREATE POLICY comments_moderator_read ON public.comments FOR SELECT TO authenticated
  USING ((SELECT private.has_app_role('moderator')) OR (SELECT private.has_app_role('administrator')));
CREATE POLICY comments_owner_insert ON public.comments FOR INSERT TO authenticated
  WITH CHECK (created_by_uuid = (SELECT auth.uid()) AND is_hidden = false AND EXISTS (SELECT 1 FROM public.posts p
    WHERE p.uuid = post_uuid AND p.status = 'published' AND p.archived_at IS NULL));
CREATE POLICY comments_owner_update ON public.comments FOR UPDATE TO authenticated
  USING (created_by_uuid = (SELECT auth.uid()) AND is_hidden = false AND archived_at IS NULL)
  WITH CHECK (created_by_uuid = (SELECT auth.uid()) AND is_hidden = false);
CREATE POLICY saves_owner_read ON public.saved_recipes FOR SELECT TO authenticated
  USING (account_uuid = (SELECT auth.uid()));
CREATE POLICY saves_owner_insert ON public.saved_recipes FOR INSERT TO authenticated
  WITH CHECK (account_uuid = (SELECT auth.uid()) AND EXISTS (SELECT 1 FROM public.recipes r JOIN public.posts p ON p.uuid = r.post_uuid
    WHERE r.uuid = recipe_uuid AND r.archived_at IS NULL AND p.status = 'published' AND p.archived_at IS NULL));
CREATE POLICY saves_owner_update ON public.saved_recipes FOR UPDATE TO authenticated
  USING (account_uuid = (SELECT auth.uid())) WITH CHECK (account_uuid = (SELECT auth.uid()));

CREATE POLICY reports_read_own_or_moderator ON public.content_reports FOR SELECT TO authenticated
  USING (reporter_uuid = (SELECT auth.uid()) OR (SELECT private.has_app_role('moderator'))
    OR (SELECT private.has_app_role('administrator')));
CREATE POLICY reports_owner_insert ON public.content_reports FOR INSERT TO authenticated
  WITH CHECK (reporter_uuid = (SELECT auth.uid()) AND status = 'submitted');
CREATE POLICY reports_moderator_update ON public.content_reports FOR UPDATE TO authenticated
  USING ((SELECT private.has_app_role('moderator')) OR (SELECT private.has_app_role('administrator')))
  WITH CHECK ((SELECT private.has_app_role('moderator')) OR (SELECT private.has_app_role('administrator')));

CREATE POLICY moderation_read_moderator ON public.moderation_actions FOR SELECT TO authenticated
  USING ((SELECT private.has_app_role('moderator')) OR (SELECT private.has_app_role('administrator')));
CREATE POLICY moderation_insert_moderator ON public.moderation_actions FOR INSERT TO authenticated
  WITH CHECK (actor_uuid = (SELECT auth.uid()) AND
    ((SELECT private.has_app_role('moderator')) OR (SELECT private.has_app_role('administrator'))));

CREATE POLICY deletion_read_owner_or_admin ON public.account_deletion_requests FOR SELECT TO authenticated
  USING (account_uuid = (SELECT auth.uid()) OR (SELECT private.has_app_role('administrator')));
CREATE POLICY deletion_owner_insert ON public.account_deletion_requests FOR INSERT TO authenticated
  WITH CHECK (account_uuid = (SELECT auth.uid()) AND status = 'pending');
CREATE POLICY deletion_admin_update ON public.account_deletion_requests FOR UPDATE TO authenticated
  USING ((SELECT private.has_app_role('administrator')))
  WITH CHECK ((SELECT private.has_app_role('administrator')));

-- Supabase Storage: public image delivery, authenticated uploads restricted to
-- each user's UUID folder. The chosen MVP baseline is JPEG/PNG/WebP, max 10 MiB.
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES ('glider-images', 'glider-images', true, 10485760,
        ARRAY['image/jpeg', 'image/png', 'image/webp'])
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  public = EXCLUDED.public,
  file_size_limit = EXCLUDED.file_size_limit,
  allowed_mime_types = EXCLUDED.allowed_mime_types;
DROP POLICY IF EXISTS glider_images_upload_own_folder ON storage.objects;
CREATE POLICY glider_images_upload_own_folder ON storage.objects FOR INSERT TO authenticated
  WITH CHECK (bucket_id = 'glider-images' AND (storage.foldername(name))[1] = (SELECT auth.uid())::text);
DROP POLICY IF EXISTS glider_images_update_own_folder ON storage.objects;
CREATE POLICY glider_images_update_own_folder ON storage.objects FOR UPDATE TO authenticated
  USING (bucket_id = 'glider-images' AND (storage.foldername(name))[1] = (SELECT auth.uid())::text)
  WITH CHECK (bucket_id = 'glider-images' AND (storage.foldername(name))[1] = (SELECT auth.uid())::text);
DROP POLICY IF EXISTS glider_images_delete_own_folder ON storage.objects;
CREATE POLICY glider_images_delete_own_folder ON storage.objects FOR DELETE TO authenticated
  USING (bucket_id = 'glider-images' AND (storage.foldername(name))[1] = (SELECT auth.uid())::text);

-- Remove table-level defaults so client roles cannot read or write the server-only
-- identity id. Grant only the columns needed by the MVP clients.
REVOKE ALL ON TABLE public.profiles, public.account_roles, public.posts, public.post_media,
  public.recipes, public.recipe_ingredients, public.recipe_instructions, public.cooking_attempts,
  public.follows, public.post_likes, public.comments, public.saved_recipes,
  public.content_reports, public.moderation_actions, public.account_deletion_requests
  FROM PUBLIC, anon, authenticated;
GRANT USAGE ON SCHEMA public TO anon, authenticated;

GRANT SELECT (uuid, username, display_name, bio, avatar_path, created_at, updated_at, archived_at, deleted_at)
  ON public.profiles TO anon, authenticated;
GRANT UPDATE (username, display_name, bio, avatar_path, updated_at)
  ON public.profiles TO authenticated;
GRANT SELECT (uuid, account_uuid, role, assigned_by_uuid, revoked_by_uuid, created_at, updated_at, archived_at, revoked_at)
  ON public.account_roles TO authenticated;
GRANT INSERT (uuid, account_uuid, role, assigned_by_uuid)
  ON public.account_roles TO authenticated;
GRANT UPDATE (revoked_at, archived_at, updated_at)
  ON public.account_roles TO authenticated;

GRANT SELECT (uuid, created_by_uuid, kind, status, caption, created_at, updated_at, published_at, archived_at)
  ON public.posts TO anon, authenticated;
GRANT INSERT (uuid, created_by_uuid, kind, status, caption, created_at, updated_at, published_at)
  ON public.posts TO authenticated;
GRANT UPDATE (caption, status, updated_at, published_at, archived_at)
  ON public.posts TO authenticated;
GRANT SELECT (uuid, post_uuid, created_by_uuid, storage_path, mime_type, byte_length, alt_text, sort_order,
  created_at, updated_at, archived_at) ON public.post_media TO anon, authenticated;
GRANT INSERT (uuid, post_uuid, created_by_uuid, storage_path, mime_type, byte_length, alt_text, sort_order)
  ON public.post_media TO authenticated;
GRANT UPDATE (alt_text, sort_order, updated_at, archived_at) ON public.post_media TO authenticated;
GRANT SELECT (uuid, post_uuid, created_by_uuid, title, servings, prep_minutes, cook_minutes,
  created_at, updated_at, archived_at) ON public.recipes TO anon, authenticated;
GRANT INSERT (uuid, post_uuid, created_by_uuid, title, servings, prep_minutes, cook_minutes)
  ON public.recipes TO authenticated;
GRANT UPDATE (title, servings, prep_minutes, cook_minutes, updated_at, archived_at)
  ON public.recipes TO authenticated;
GRANT SELECT (uuid, recipe_uuid, created_by_uuid, sort_order, name, quantity, unit, note,
  created_at, updated_at, archived_at) ON public.recipe_ingredients TO anon, authenticated;
GRANT INSERT (uuid, recipe_uuid, created_by_uuid, sort_order, name, quantity, unit, note)
  ON public.recipe_ingredients TO authenticated;
GRANT UPDATE (sort_order, name, quantity, unit, note, updated_at, archived_at)
  ON public.recipe_ingredients TO authenticated;
GRANT SELECT (uuid, recipe_uuid, created_by_uuid, step_number, instruction, created_at, updated_at, archived_at)
  ON public.recipe_instructions TO anon, authenticated;
GRANT INSERT (uuid, recipe_uuid, created_by_uuid, step_number, instruction)
  ON public.recipe_instructions TO authenticated;
GRANT UPDATE (step_number, instruction, updated_at, archived_at) ON public.recipe_instructions TO authenticated;
GRANT SELECT (uuid, post_uuid, recipe_uuid, created_by_uuid, source_recipe_title, source_author_uuid,
  rating, notes, changes, created_at, updated_at, archived_at) ON public.cooking_attempts TO anon, authenticated;
GRANT INSERT (uuid, post_uuid, recipe_uuid, created_by_uuid, rating, notes, changes)
  ON public.cooking_attempts TO authenticated;
GRANT UPDATE (rating, notes, changes, updated_at, archived_at) ON public.cooking_attempts TO authenticated;
GRANT SELECT (uuid, follower_uuid, followed_uuid, created_at, updated_at, archived_at)
  ON public.follows TO authenticated;
GRANT INSERT (uuid, follower_uuid, followed_uuid) ON public.follows TO authenticated;
GRANT UPDATE (archived_at, updated_at) ON public.follows TO authenticated;
GRANT SELECT (uuid, post_uuid, account_uuid, created_at, updated_at, archived_at)
  ON public.post_likes TO authenticated;
GRANT INSERT (uuid, post_uuid, account_uuid) ON public.post_likes TO authenticated;
GRANT UPDATE (archived_at, updated_at) ON public.post_likes TO authenticated;
GRANT SELECT (uuid, post_uuid, created_by_uuid, body, is_hidden, created_at, updated_at, archived_at)
  ON public.comments TO anon, authenticated;
GRANT INSERT (uuid, post_uuid, created_by_uuid, body) ON public.comments TO authenticated;
GRANT UPDATE (body, updated_at, archived_at, is_hidden) ON public.comments TO authenticated;
GRANT SELECT (uuid, account_uuid, recipe_uuid, created_at, updated_at, archived_at)
  ON public.saved_recipes TO authenticated;
GRANT INSERT (uuid, account_uuid, recipe_uuid) ON public.saved_recipes TO authenticated;
GRANT UPDATE (archived_at, updated_at) ON public.saved_recipes TO authenticated;
GRANT SELECT (uuid, reporter_uuid, target_type, target_uuid, reason, details, status, resolution_note,
  resolved_by_uuid, resolved_at, created_at, updated_at, archived_at) ON public.content_reports TO authenticated;
GRANT INSERT (uuid, reporter_uuid, target_type, target_uuid, reason, details)
  ON public.content_reports TO authenticated;
GRANT UPDATE (status, resolution_note, updated_at)
  ON public.content_reports TO authenticated;
GRANT SELECT (uuid, actor_uuid, target_type, target_uuid, action, reason, created_at)
  ON public.moderation_actions TO authenticated;
GRANT INSERT (uuid, actor_uuid, target_type, target_uuid, action, reason)
  ON public.moderation_actions TO authenticated;
GRANT SELECT (uuid, account_uuid, status, requested_at, resolved_by_uuid, resolved_at,
  resolution_note, created_at, updated_at, archived_at) ON public.account_deletion_requests TO authenticated;
GRANT INSERT (uuid, account_uuid) ON public.account_deletion_requests TO authenticated;
GRANT UPDATE (status, resolution_note, updated_at, archived_at)
  ON public.account_deletion_requests TO authenticated;

-- Bootstrap the first administrator manually after authenticating the owner in
-- Supabase, using that profile's uuid as account_uuid; never expose a service key.
-- INSERT INTO public.account_roles (uuid, account_uuid, role, assigned_by_uuid)
-- VALUES (gen_random_uuid(), '<auth-user-uuid>'::uuid, 'administrator', '<auth-user-uuid>'::uuid);

COMMIT;
