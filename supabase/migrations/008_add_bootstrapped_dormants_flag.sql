-- 008_add_bootstrapped_dormants_flag.sql
-- CoachingSage — Story 3.15 : flag `bootstrapped_dormants` sur coaching_profiles.
-- À appliquer dans : Supabase Dashboard → SQL Editor du projet `coachingsage-dev`.
--
-- Pré-requis : migrations 001 → 007 déjà appliquées.
-- Migration idempotente : `ADD COLUMN IF NOT EXISTS`.
--
-- Contexte Story 3.15 : au 1er launch post-onboarding, l'app persiste 3 dormants
-- via `ProgramTemplateSelector.selectTopN` pour ne plus perdre les "suggestions"
-- dès qu'un programme est lancé. Le flag empêche la re-génération à chaque
-- refresh dashboard. Pas de regénération automatique après — si l'user delete
-- les 3 dormants bootstrappés, ils ne reviennent pas.
--
-- Cible volontaire : `coaching_profiles` (CoachingSage-spécifique), PAS
-- `core_profiles` (cross-app GardenSage/TailorSage/CoachingSage).

ALTER TABLE coaching_profiles
  ADD COLUMN IF NOT EXISTS bootstrapped_dormants BOOLEAN NOT NULL DEFAULT FALSE;

-- Notes déploiement :
-- 1. Sophie (seul user actuel) aura `bootstrapped_dormants = false` à la première
--    ouverture post-3.15. Comme `startedSummaries.isEmpty == false` (elle a déjà
--    des programmes), le bootstrap est skip de toute façon — le flag passera à
--    `true` au prochain refresh dashboard via `DormantBootstrapService` (qui
--    no-op tout en flagant pour éviter les re-tentatives futures).
-- 2. Si Sophie veut tester le bootstrap : delete tous ses programmes via Profil
--    + flip manuel du flag à `false` via dashboard Supabase.

-- ==============================================================
-- Vérification post-déploiement
-- ==============================================================
-- SELECT column_name, data_type, column_default, is_nullable
-- FROM information_schema.columns
-- WHERE table_name = 'coaching_profiles' AND column_name = 'bootstrapped_dormants';
--   → attendu : data_type=boolean, column_default=false, is_nullable=NO
