-- 004_coaching_profiles_equipment.sql
-- CoachingSage V1 — Epic 3 / Story Équipement onboarding global
-- À appliquer dans : Supabase Dashboard → SQL Editor du projet `coachingsage-dev`
--
-- Pré-requis : migrations 001 + 002 + 003 déjà appliquées.
-- Migration idempotente : ADD COLUMN IF NOT EXISTS.
--
-- Alignement avec les DTO Swift (CoachingSage/Services/DTOs/CoachingProfileDTO.swift) :
--   - equipment TEXT[] : aligné avec active_sports (TEXT[] natif Postgres — `WHERE 'gps_watch' = ANY(equipment)`)
--   - codes snake_case figés via Swift `EquipmentCode` enum :
--     gps_watch, heart_rate_monitor, indoor_bike, home_weights
--   - L'équipement spécifique sport (treadmill_access running, home_trainer cycling) reste
--     dans coaching_sport_profiles.equipment_json (questionnaire sport).
--   - L'adapter (EquipmentSubstitutionRule Story 3.3a) consomme l'union des deux.

ALTER TABLE coaching_profiles
  ADD COLUMN IF NOT EXISTS equipment TEXT[] NOT NULL DEFAULT '{}';

-- Vérifier la colonne ajoutée :
--   SELECT column_name, data_type, is_nullable, column_default
--     FROM information_schema.columns
--    WHERE table_name = 'coaching_profiles' AND column_name = 'equipment';
