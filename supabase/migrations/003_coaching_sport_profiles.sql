-- 003_coaching_sport_profiles.sql
-- CoachingSage V1 — Story 3.1 SportQuestionnaire local (Epic 3)
-- À appliquer dans : Supabase Dashboard → SQL Editor du projet `coachingsage-dev`
--
-- Pré-requis : migrations 001 + 002 déjà appliquées.
-- Migration idempotente : peut être re-run sans erreur (CREATE IF NOT EXISTS / DROP IF EXISTS).
--
-- Alignement avec les DTO Swift (CoachingSage/Models/CoachingSportProfile.swift + DTO) :
--   - sport       : TEXT avec CHECK constraint sur les 10 sports supportés (cohérent active_sports[] migration 002)
--   - level       : TEXT avec CHECK constraint sur les 4 niveaux du RunningQuestionnaire
--   - goals_json / equipment_json / constraints_json / records_json : JSONB typés côté Swift via structs Codable
--                  (jamais [String: Any] — lesson lessons_supabase #3 DTO match exact)
--   - conversation_history_json : JSONB liste typée [ConversationEntry] pour audit + futur prompt Léon Story 3.3
--   - frequency_per_week  : INTEGER mappé depuis Q3 ("2"/"3"/"4_or_more" → 2/3/4)
--   - frequency_label     : TEXT préserve "4_or_more" pour Léon Story 3.3 (sinon perte sémantique — review P1-3)
--   - medical_clearance_acknowledged : snapshot du flag coaching_profiles.requires_medical_clearance au save
--                  (garantit cohérence temporelle pour Léon Story 3.3 — review P0-6)
--   - questionnaire_version : marker pour migrations futures du flow (review P2-7)
--   - UNIQUE (user_id, sport) : 1 profil par sport par user, upsert ON CONFLICT user_id+sport (review P0-7)
--
-- Sécurité (review P0-3) : RLS policies utilisent `auth.uid()::uuid = user_id` avec cast explicite
-- pour éviter les ambiguïtés type/casing UUID Swift uppercase vs Supabase lowercase (lesson lessons_supabase #8).

-- ==============================================================
-- TABLE: coaching_sport_profiles
-- ==============================================================
CREATE TABLE IF NOT EXISTS coaching_sport_profiles (
  id                              UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id                         UUID         NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  sport                           TEXT         NOT NULL,
  level                           TEXT         NOT NULL,
  goals_json                      JSONB        NOT NULL DEFAULT '{}'::jsonb,
  equipment_json                  JSONB        NOT NULL DEFAULT '[]'::jsonb,
  constraints_json                JSONB        NOT NULL DEFAULT '[]'::jsonb,
  records_json                    JSONB,                                                         -- nullable, populé V2 sports avec records
  frequency_per_week              INTEGER      NOT NULL,
  frequency_label                 TEXT         NOT NULL,                                        -- "2" | "3" | "4_or_more" (préserve l'intention)
  session_duration_minutes        INTEGER,                                                      -- nullable, calculé Story 3.2/3.3
  free_text_notes                 TEXT,                                                         -- nullable, max 200 chars (CHECK)
  conversation_history_json       JSONB        NOT NULL DEFAULT '[]'::jsonb,                    -- [ConversationEntry] typé Codable côté Swift
  medical_clearance_acknowledged  BOOLEAN      NOT NULL DEFAULT FALSE,                          -- snapshot coaching_profiles.requires_medical_clearance au save
  questionnaire_version           TEXT         NOT NULL DEFAULT 'v1',                           -- ex "running_v1", permet migrations futures
  created_at                      TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  last_updated_at                 TIMESTAMPTZ  NOT NULL DEFAULT NOW(),

  CONSTRAINT coaching_sport_profiles_user_sport_unique UNIQUE (user_id, sport),
  -- Codes alignés avec enum SportCode (Models/CoachingProfile.swift Story 2.2)
  -- Notes :
  --   strengthTraining : camelCase = rawValue Swift par défaut (cohérent enum existant)
  --   active_sports[] (migration 002) utilise les mêmes codes → cohérence cross-table garantie
  CONSTRAINT coaching_sport_profiles_sport_valid CHECK (
    sport IN ('running','cycling','swimming','triathlon','strengthTraining','yoga','hiit','hiking','tennis','football')
  ),
  CONSTRAINT coaching_sport_profiles_level_valid CHECK (
    level IN ('beginner','recreational','regular','competitive')
  ),
  CONSTRAINT coaching_sport_profiles_free_text_notes_length CHECK (
    free_text_notes IS NULL OR length(free_text_notes) <= 200
  ),
  CONSTRAINT coaching_sport_profiles_frequency_per_week_range CHECK (
    frequency_per_week >= 1 AND frequency_per_week <= 14
  )
);

-- Index pour les queries fréquentes (fetch par user × sport)
CREATE INDEX IF NOT EXISTS idx_coaching_sport_profiles_user_sport
  ON coaching_sport_profiles(user_id, sport);

-- ==============================================================
-- RLS : 4 policies (SELECT / INSERT / UPDATE / DELETE)
-- DELETE policy ajoutée pour permettre cleanup côté Swift quand l'user retire un sport via Story 2.3
-- (cohérence orpheline — review P1-13).
-- ==============================================================
ALTER TABLE coaching_sport_profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "coaching_sport_profiles_select_own" ON coaching_sport_profiles;
CREATE POLICY "coaching_sport_profiles_select_own" ON coaching_sport_profiles
  FOR SELECT USING (auth.uid()::uuid = user_id);

DROP POLICY IF EXISTS "coaching_sport_profiles_insert_own" ON coaching_sport_profiles;
CREATE POLICY "coaching_sport_profiles_insert_own" ON coaching_sport_profiles
  FOR INSERT WITH CHECK (auth.uid()::uuid = user_id);

DROP POLICY IF EXISTS "coaching_sport_profiles_update_own" ON coaching_sport_profiles;
CREATE POLICY "coaching_sport_profiles_update_own" ON coaching_sport_profiles
  FOR UPDATE USING (auth.uid()::uuid = user_id)
  WITH CHECK (auth.uid()::uuid = user_id);

DROP POLICY IF EXISTS "coaching_sport_profiles_delete_own" ON coaching_sport_profiles;
CREATE POLICY "coaching_sport_profiles_delete_own" ON coaching_sport_profiles
  FOR DELETE USING (auth.uid()::uuid = user_id);

-- ==============================================================
-- TRIGGER auto-update last_updated_at sur UPDATE
-- (review P1-9 — sans trigger, le DTO Swift doit penser à bumper le champ et oubli probable)
-- search_path = public obligatoire (lesson lessons_supabase #2)
-- ==============================================================
CREATE OR REPLACE FUNCTION update_last_updated_at_column()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path = public
AS $$
BEGIN
  NEW.last_updated_at = NOW();
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS update_coaching_sport_profiles_last_updated ON coaching_sport_profiles;
CREATE TRIGGER update_coaching_sport_profiles_last_updated
  BEFORE UPDATE ON coaching_sport_profiles
  FOR EACH ROW EXECUTE FUNCTION update_last_updated_at_column();

-- ==============================================================
-- Vérifications post-déploiement (à lancer dans SQL Editor après apply)
-- ==============================================================
-- 1. Schema attendu :
--   SELECT column_name, data_type, is_nullable
--   FROM information_schema.columns
--   WHERE table_name = 'coaching_sport_profiles'
--   ORDER BY ordinal_position;
--
-- 2. RLS policies en place :
--   SELECT polname, polcmd, pg_get_expr(polqual, polrelid) AS using_expr,
--          pg_get_expr(polwithcheck, polrelid) AS check_expr
--   FROM pg_policy
--   WHERE polrelid = 'coaching_sport_profiles'::regclass
--   ORDER BY polname;
--
-- 3. Test RLS cross-user (lesson lessons_supabase #1) :
--   - Insert un row pour user A via service_role.
--   - Signin user B.
--   - SELECT * FROM coaching_sport_profiles → doit retourner 0 row.
--
-- 4. Test trigger last_updated_at :
--   - INSERT puis UPDATE → vérifier que last_updated_at change.
