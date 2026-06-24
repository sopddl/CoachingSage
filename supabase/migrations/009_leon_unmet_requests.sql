-- 009_leon_unmet_requests.sql
-- CoachingSage — fil de Léon inc2 : backlog des demandes non satisfaites (⏳/🚫).
-- À appliquer dans : Supabase Dashboard → SQL Editor du projet `coachingsage-dev`.
--
-- Pré-requis : migrations 001 → 008 déjà appliquées. Idempotente (IF NOT EXISTS).
--
-- CONTRAT RGPD STRICT (party onboarding 2026-06-23, lentille MDR/RGPD) :
--   - AUCUN champ texte libre (pas de raw_text / verbatim / note) — uniquement
--     des enums fermés + timestamp. La catégorie ≠ verbatim santé.
--   - PAS de program_id : lier `weight_loss`/`health_condition` à un programme
--     ré-identifierait un objectif de santé (art. 9 RGPD). On garde `user_id`
--     uniquement pour la RLS (insert scopé), JAMAIS exposé en analytics.
--   - Finalité nommée : priorisation produit. Écriture gated par le consentement
--     analytics (core_profiles.analytics_consent) côté app — la RLS ne suffit pas
--     à exprimer le consentement, c'est l'app qui n'insère pas sans consentement.
--   - Exploitation analytics = service role only : `SELECT category, count(*)
--     FROM leon_unmet_requests GROUP BY category ORDER BY count DESC`.

CREATE TABLE IF NOT EXISTS leon_unmet_requests (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  category    TEXT NOT NULL CHECK (category IN (
                'periodisation_temporelle',
                'multi_sport_combine',
                'nutrition',
                'weight_loss',
                'health_condition',
                'unknown'
              )),
  response    TEXT NOT NULL CHECK (response IN ('not_yet', 'refused_safety')),
  locale      TEXT,
  app_version TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_leon_unmet_requests_category
  ON leon_unmet_requests (category);

-- RLS : l'user ne peut qu'INSÉRER ses propres lignes. Aucune lecture côté user
-- (analytics = service role only → pas de policy SELECT pour authenticated).
ALTER TABLE leon_unmet_requests ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "insert own unmet requests" ON leon_unmet_requests;
CREATE POLICY "insert own unmet requests"
  ON leon_unmet_requests
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- ==============================================================
-- Vérification post-déploiement :
--   SELECT category, response, count(*) FROM leon_unmet_requests
--   GROUP BY category, response ORDER BY count DESC;
