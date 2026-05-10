-- 006_coaching_sport_profiles_duration.sql
-- CoachingSage — Story sœur post-3.3b (Epic 3) — ajout dimension durée du programme.
-- À appliquer dans : Supabase Dashboard → SQL Editor du projet `coachingsage-dev`.
--
-- Pré-requis : migrations 001 → 005 déjà appliquées.
-- Migration idempotente : peut être re-run sans erreur (IF NOT EXISTS / DO blocks).
--
-- Aligné avec :
--   - `Models/CoachingSportProfile.swift` (champs durationModeRaw + targetDate)
--   - `Services/DTOs/CoachingSportProfileDTO.swift` (clés `duration_mode` + `target_date`)
--   - `Coaching/Adapter/AdaptedProgram.swift` (enum `ProgramDurationMode`)
--
-- Sémantique :
--   - duration_mode = 'routineCyclic' (défaut) | 'deadlineFixed' | 'deadlineEstimated'
--   - target_date NULL pour routineCyclic, NOT NULL pour les modes deadline (CHECK appliqué)

-- ==============================================================
-- COLONNES : duration_mode + target_date
-- ==============================================================
ALTER TABLE coaching_sport_profiles
  ADD COLUMN IF NOT EXISTS duration_mode TEXT NOT NULL DEFAULT 'routineCyclic';

ALTER TABLE coaching_sport_profiles
  ADD COLUMN IF NOT EXISTS target_date TIMESTAMPTZ;

-- ==============================================================
-- CHECK constraints
-- ==============================================================
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'coaching_sport_profiles_duration_mode_valid'
  ) THEN
    ALTER TABLE coaching_sport_profiles
      ADD CONSTRAINT coaching_sport_profiles_duration_mode_valid
      CHECK (duration_mode IN ('routineCyclic', 'deadlineFixed', 'deadlineEstimated'));
  END IF;

  -- target_date doit être NULL si routineCyclic, NOT NULL sinon.
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'coaching_sport_profiles_target_date_consistency'
  ) THEN
    ALTER TABLE coaching_sport_profiles
      ADD CONSTRAINT coaching_sport_profiles_target_date_consistency
      CHECK (
        (duration_mode = 'routineCyclic' AND target_date IS NULL)
        OR (duration_mode IN ('deadlineFixed', 'deadlineEstimated') AND target_date IS NOT NULL)
      );
  END IF;
END $$;

-- ==============================================================
-- Vérifications post-déploiement
-- ==============================================================
-- 1. Colonnes ajoutées :
--   SELECT column_name, data_type, is_nullable, column_default
--   FROM information_schema.columns
--   WHERE table_name = 'coaching_sport_profiles' AND column_name IN ('duration_mode', 'target_date')
--   ORDER BY ordinal_position;
--
-- 2. CHECK constraints en place :
--   SELECT conname, pg_get_constraintdef(oid)
--   FROM pg_constraint
--   WHERE conrelid = 'coaching_sport_profiles'::regclass
--     AND conname LIKE '%duration%' OR conname LIKE '%target_date%';
--
-- 3. Backfill rows existantes (rien à faire — DEFAULT 'routineCyclic' s'applique).
