-- 002_coaching_profiles.sql
-- CoachingSage V1 — Story 2.2 Onboarding Core Minimal (Epic 2)
-- À appliquer dans : Supabase Dashboard → SQL Editor du projet `coachingsage-dev`
--
-- Pré-requis : migration 001 déjà appliquée (table core_profiles + fonction update_updated_at_column).
-- Migration idempotente : peut être re-run sans erreur (DROP IF EXISTS sur policies/triggers/cron).
--
-- Alignement avec les DTO Swift (CoachingSage/Services/DTOs/CoachingProfileDTO.swift) :
--   - active_sports utilise TEXT[] (Postgres array natif) → permet `WHERE 'running' = ANY(active_sports)` pour Léon Epic 3.
--   - parq_responses utilise JSONB avec 5 keys figées (q1_chest_pain, q2_dizziness, q3_joint_aggravated, q4_heart_medication, q5_other_reason).
--   - 3 policies RLS (SELECT/INSERT/UPDATE) — pas de DELETE policy : suppression via edge function service_role Story 1.4 + CASCADE depuis core_profiles.

-- ==============================================================
-- TABLE: coaching_profiles (profil sportif spécifique CoachingSage)
-- id = core_profiles.id avec FK + ON DELETE CASCADE → suppression Story 1.4 atomique sans modif AccountService
-- ==============================================================
CREATE TABLE IF NOT EXISTS coaching_profiles (
  id                          UUID             PRIMARY KEY REFERENCES core_profiles(id) ON DELETE CASCADE,
  biological_sex              TEXT,                                            -- "female" | "male" | "other" | "prefer_not_to_say" | null
  date_of_birth               DATE,
  weight_kg                   DECIMAL(5,2),                                    -- 30.00-250.00
  height_cm                   DECIMAL(5,2),                                    -- 100.00-230.00
  active_sports               TEXT[]           NOT NULL DEFAULT '{}',          -- {"running","cycling",...}
  parq_responses              JSONB            NOT NULL DEFAULT '{}'::jsonb,   -- 5 keys figées Swift PARQQuestion enum
  requires_medical_clearance  BOOLEAN          NOT NULL DEFAULT FALSE,         -- calculé Swift : true si toute réponse PARQ = true
  disclaimer_version_accepted TEXT,                                            -- "1.0"
  disclaimer_accepted_at      TIMESTAMPTZ,
  onboarding_completed_at     TIMESTAMPTZ,                                    -- source of truth "onboarding done"
  created_at                  TIMESTAMPTZ      DEFAULT NOW(),
  updated_at                  TIMESTAMPTZ      DEFAULT NOW(),
  is_soft_deleted             BOOLEAN          DEFAULT FALSE,
  deleted_at                  TIMESTAMPTZ
);

-- Index partiel pour le pg_cron purge (cohérent migration 001:32-33)
CREATE INDEX IF NOT EXISTS idx_coaching_profiles_soft_deleted
  ON coaching_profiles(is_soft_deleted, deleted_at) WHERE is_soft_deleted = TRUE;

-- ==============================================================
-- RLS : auth.uid() = id (chaque user ne voit que son propre profil)
-- 3 policies : SELECT / INSERT / UPDATE — pas de DELETE
-- (suppression via edge function service_role Story 1.4 + CASCADE FK)
-- ==============================================================
ALTER TABLE coaching_profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "coaching_profiles_select_own" ON coaching_profiles;
CREATE POLICY "coaching_profiles_select_own" ON coaching_profiles
  FOR SELECT USING (auth.uid() = id);

DROP POLICY IF EXISTS "coaching_profiles_insert_own" ON coaching_profiles;
CREATE POLICY "coaching_profiles_insert_own" ON coaching_profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "coaching_profiles_update_own" ON coaching_profiles;
CREATE POLICY "coaching_profiles_update_own" ON coaching_profiles
  FOR UPDATE USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- ==============================================================
-- TRIGGER auto-update updated_at
-- Réutilise update_updated_at_column() défini en migration 001.
-- ==============================================================
DROP TRIGGER IF EXISTS update_coaching_profiles_updated_at ON coaching_profiles;
CREATE TRIGGER update_coaching_profiles_updated_at
  BEFORE UPDATE ON coaching_profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ==============================================================
-- pg_cron purge RGPD : suppression définitive après 30 jours (Art. 17)
-- Prérequis : extension `pg_cron` activée (déjà fait migration 001).
-- ==============================================================
SELECT cron.unschedule('purge-rgpd-coaching-profiles')
  WHERE EXISTS (SELECT 1 FROM cron.job WHERE jobname = 'purge-rgpd-coaching-profiles');

SELECT cron.schedule(
  'purge-rgpd-coaching-profiles',
  '0 2 * * *',
  $$
    DELETE FROM coaching_profiles
    WHERE is_soft_deleted = TRUE
      AND deleted_at < NOW() - INTERVAL '30 days';
  $$
);

-- Vérifier le job créé :
--   SELECT jobid, jobname, schedule, command FROM cron.job WHERE jobname = 'purge-rgpd-coaching-profiles';

-- Vérifier la table créée :
--   SELECT * FROM coaching_profiles LIMIT 1;
