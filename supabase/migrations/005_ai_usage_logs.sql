-- 005_ai_usage_logs.sql
-- CoachingSage V1 — Epic 3 / Story 3.3b (Léon IA fallback)
-- À appliquer dans : Supabase Dashboard → SQL Editor du projet `coachingsage-dev`
--
-- Pré-requis : migrations 001 + 002 + 003 + 004 déjà appliquées.
-- Migration idempotente : CREATE TABLE IF NOT EXISTS, ALTER + IF NOT EXISTS sur l'index.
--
-- Objectif : journaliser tous les appels IA Léon (cost monitoring NFR2 +
-- enforcement rate limit 10/j cumulé entre `adapt-rare` (3.3b), `chat` (3.6),
-- `regen-week` (3.4), `adapt-session` (3.6 FR12), `generate` (3.5 — Pro only).
--
-- Le rate limit cumulé est calculé côté Edge Function avec :
--   SELECT count(*) FROM ai_usage_logs
--   WHERE user_id = $1 AND success = TRUE
--     AND created_at >= NOW() - INTERVAL '24 hours';
--
-- Les appels échoués (success = FALSE) ne comptent PAS dans le quota — sinon
-- on pénaliserait l'utilisateur pour un bug réseau côté Anthropic.

-- ==============================================================
-- TABLE: ai_usage_logs (journal append-only)
-- ==============================================================
CREATE TABLE IF NOT EXISTS ai_usage_logs (
  id                UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id           UUID         NOT NULL,                                   -- = auth.users.id
  mode              TEXT         NOT NULL,                                   -- 'adapt-rare' | 'chat' | 'regen-week' | 'adapt-session' | 'generate'
  model             TEXT         NOT NULL,                                   -- 'haiku-4-5' | 'sonnet-4-6' | etc.
  tokens_in         INTEGER      NOT NULL DEFAULT 0,
  tokens_out        INTEGER      NOT NULL DEFAULT 0,
  cost_usd          NUMERIC(10,6) NOT NULL DEFAULT 0,
  duration_ms       INTEGER      NOT NULL DEFAULT 0,
  triggered_reason  TEXT,                                                    -- 'atypical_constraints' | 'freetext_request' | 'user_explicit' | 'natural' | 'soft_paywall_7_8' | 'soft_paywall_9_10' | 'hard_paywall' | NULL
  success           BOOLEAN      NOT NULL DEFAULT TRUE,
  error_code        TEXT,                                                    -- 'quota_exceeded' | 'anthropic_unavailable' | 'invalid_json' | NULL si success
  created_at        TIMESTAMPTZ  NOT NULL DEFAULT NOW(),

  -- Garde-fou : un appel réussi a 0 error_code, un appel échoué a un error_code.
  CONSTRAINT ai_usage_logs_success_error_consistency CHECK (
    (success = TRUE AND error_code IS NULL) OR
    (success = FALSE AND error_code IS NOT NULL)
  )
);

-- Index principal : rate limit query (count last 24h pour un user) + audit.
CREATE INDEX IF NOT EXISTS idx_ai_usage_logs_user_created
  ON ai_usage_logs(user_id, created_at DESC);

-- ==============================================================
-- RLS : user lit ses propres logs (transparence usage), Edge Function (service_role)
-- écrit. Pas d'UPDATE ni DELETE permis (table append-only — audit trail).
-- ==============================================================
ALTER TABLE ai_usage_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "ai_usage_logs_select_own" ON ai_usage_logs
  FOR SELECT USING (auth.uid() = user_id);

-- Pas de policy INSERT public : seules les Edge Functions avec service_role
-- bypassent RLS et peuvent insérer (auth.uid() est NULL côté Edge Function).
-- C'est volontaire : un client iOS ne doit jamais pouvoir falsifier un log.

-- ==============================================================
-- Pas de pg_cron purge : on garde les logs indéfiniment pour audit cost +
-- preuve quota. Volumes attendus : 10 calls/j × 30k users × 365j = 110M lignes/an
-- max théorique → reverra purge si on s'approche de ce volume.
-- ==============================================================

-- Vérifier la table créée :
--   SELECT column_name, data_type, is_nullable, column_default
--     FROM information_schema.columns
--    WHERE table_name = 'ai_usage_logs'
--    ORDER BY ordinal_position;
--
-- Vérifier RLS active :
--   SELECT relname, relrowsecurity FROM pg_class WHERE relname = 'ai_usage_logs';
--
-- Vérifier les policies :
--   SELECT polname, polcmd, polqual FROM pg_policy
--     WHERE polrelid = 'ai_usage_logs'::regclass;
