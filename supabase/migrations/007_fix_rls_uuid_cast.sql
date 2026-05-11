-- 007_fix_rls_uuid_cast.sql
-- CoachingSage — fix RLS UUID cast sur core_profiles + coaching_profiles
-- À appliquer dans : Supabase Dashboard → SQL Editor du projet `coachingsage-dev`
--
-- Pré-requis : migrations 001 → 006 déjà appliquées.
-- Migration idempotente : DROP IF EXISTS + CREATE.
--
-- Bug Sophie 2026-05-11 : INSERT core_profiles → "new row violates row-level
-- security policy for table core_profiles". Cause racine : la RLS de migration
-- 001 utilise `auth.uid() = id` SANS cast explicite. `auth.uid()` retourne TEXT,
-- `id` est UUID. Le comparateur Postgres peut être strict sur casing (Swift
-- envoie UUID uppercase, Postgres lowercase) → match fail → INSERT rejeté.
--
-- Pattern correct (déjà appliqué migration 003 coaching_sport_profiles) :
--   `auth.uid()::uuid = id` (cast explicite).
--
-- Réf : lesson lessons_supabase #8 (UUID casing) + commit ce fichier.

-- ==============================================================
-- core_profiles : 3 policies (SELECT / INSERT / UPDATE)
-- ==============================================================
DROP POLICY IF EXISTS "core_profiles_select_own" ON core_profiles;
CREATE POLICY "core_profiles_select_own" ON core_profiles
  FOR SELECT USING (auth.uid()::uuid = id);

DROP POLICY IF EXISTS "core_profiles_insert_own" ON core_profiles;
CREATE POLICY "core_profiles_insert_own" ON core_profiles
  FOR INSERT WITH CHECK (auth.uid()::uuid = id);

DROP POLICY IF EXISTS "core_profiles_update_own" ON core_profiles;
CREATE POLICY "core_profiles_update_own" ON core_profiles
  FOR UPDATE USING (auth.uid()::uuid = id)
  WITH CHECK (auth.uid()::uuid = id);

-- ==============================================================
-- coaching_profiles : 3 policies (SELECT / INSERT / UPDATE)
-- ==============================================================
DROP POLICY IF EXISTS "coaching_profiles_select_own" ON coaching_profiles;
CREATE POLICY "coaching_profiles_select_own" ON coaching_profiles
  FOR SELECT USING (auth.uid()::uuid = id);

DROP POLICY IF EXISTS "coaching_profiles_insert_own" ON coaching_profiles;
CREATE POLICY "coaching_profiles_insert_own" ON coaching_profiles
  FOR INSERT WITH CHECK (auth.uid()::uuid = id);

DROP POLICY IF EXISTS "coaching_profiles_update_own" ON coaching_profiles;
CREATE POLICY "coaching_profiles_update_own" ON coaching_profiles
  FOR UPDATE USING (auth.uid()::uuid = id)
  WITH CHECK (auth.uid()::uuid = id);

-- ==============================================================
-- Vérifications post-déploiement
-- ==============================================================
-- 1. Policies en place sur core_profiles :
--   SELECT polname, polcmd, pg_get_expr(polqual, polrelid) AS using_expr,
--          pg_get_expr(polwithcheck, polrelid) AS check_expr
--   FROM pg_policy
--   WHERE polrelid = 'core_profiles'::regclass
--   ORDER BY polname;
--
-- 2. Test pratique : signin user X → INSERT core_profiles avec id=auth.uid() →
--    doit accepter (vs rejeter avant fix).
