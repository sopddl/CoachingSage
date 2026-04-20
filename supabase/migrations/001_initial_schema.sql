-- 001_initial_schema.sql
-- CoachingSage V1 — Schéma initial (Epic 1 Foundation, Story 1.1a)
-- Projet hébergé en région eu-central-1 (Frankfurt) — obligatoire RGPD NFR-S04
-- À appliquer dans : Supabase Dashboard → SQL Editor du projet `coachingsage-dev`
--
-- Alignement avec les DTO Swift (CoachingSage/Services/DTOs/CoreProfileDTO.swift) :
--   colonne is_soft_deleted (PAS is_deleted — leçon tirée du drift GardenSage migration 050).

-- ==============================================================
-- TABLE: core_profiles (profil commun à toutes les apps Sage)
-- id = auth.users.id (pas de FK directe : Supabase ne permet pas FK sur auth.users avec RLS public)
-- ==============================================================
CREATE TABLE IF NOT EXISTS core_profiles (
  id                        UUID             PRIMARY KEY,           -- = auth.users.id
  first_name                TEXT,
  language                  TEXT             DEFAULT 'fr',
  region                    TEXT             DEFAULT '',
  latitude                  DOUBLE PRECISION,
  longitude                 DOUBLE PRECISION,
  altitude                  DOUBLE PRECISION,
  analytics_consent         BOOLEAN          DEFAULT FALSE,          -- RGPD opt-in explicite
  notification_preferences  JSONB,                                   -- decoded by NotificationPreferences
  vacation_end_date         TIMESTAMPTZ,                             -- nil si pas en vacances
  subscription_tier         TEXT             DEFAULT 'free',         -- "free" | "plus" | "pro"
  subscription_expires_at   TIMESTAMPTZ,
  created_at                TIMESTAMPTZ      DEFAULT NOW(),
  updated_at                TIMESTAMPTZ      DEFAULT NOW(),
  is_soft_deleted           BOOLEAN          DEFAULT FALSE,
  deleted_at                TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_core_profiles_soft_deleted
  ON core_profiles(is_soft_deleted, deleted_at) WHERE is_soft_deleted = TRUE;

-- ==============================================================
-- RLS : auth.uid() = id (chaque user ne voit que son propre profil)
-- ==============================================================
ALTER TABLE core_profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "core_profiles_select_own" ON core_profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "core_profiles_insert_own" ON core_profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "core_profiles_update_own" ON core_profiles
  FOR UPDATE USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- ==============================================================
-- TRIGGER auto-update updated_at
-- PostgreSQL ne met JAMAIS updated_at à jour seul : ce trigger est obligatoire.
-- Les DTO d'upsert côté app n'ont PAS besoin de setter updated_at manuellement.
-- ==============================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_core_profiles_updated_at
  BEFORE UPDATE ON core_profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ==============================================================
-- pg_cron purge RGPD : suppression définitive après 30 jours (Art. 17)
-- Prérequis : extension `pg_cron` activée dans Database > Extensions.
-- ==============================================================
SELECT cron.schedule(
  'purge-rgpd-core-profiles',
  '0 2 * * *',
  $$
    DELETE FROM core_profiles
    WHERE is_soft_deleted = TRUE
      AND deleted_at < NOW() - INTERVAL '30 days';
  $$
);

-- Vérifier les jobs créés :
--   SELECT jobid, jobname, schedule, command FROM cron.job;
