-- 010_leon_plus_subscription.sql
-- CoachingSage — Léon+ (abonnement mensuel 4,99€, quota illimité).
-- À appliquer dans : Supabase Dashboard → SQL Editor du projet `coachingsage-dev`.
--
-- Pré-requis : migrations 001 → 009 déjà appliquées. Idempotente (IF NOT EXISTS).
--
-- `core_profiles.subscription_tier`/`subscription_expires_at` existent déjà
-- depuis 001_initial_schema.sql (colonnes présentes dès le schéma initial, sans
-- contrainte CHECK) — on se contente d'ajouter la contrainte manquante ici.
-- Portage du pattern GardenSage (`032_monetisation_tables.sql`, Flore+ en prod),
-- réduit au strict nécessaire : pas de packs consommables (hors scope Léon+ V1).

-- ==============================================================
-- 1. Contrainte manquante sur core_profiles.subscription_tier
-- ==============================================================
-- ADD CONSTRAINT n'a pas de IF NOT EXISTS natif → on passe par un bloc DO pour
-- rester idempotent (ré-exécution de la migration sans erreur).
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'core_profiles_subscription_tier_check'
  ) THEN
    ALTER TABLE core_profiles
      ADD CONSTRAINT core_profiles_subscription_tier_check
      CHECK (subscription_tier IN ('free', 'plus', 'pro'));
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_core_profiles_subscription_expires
  ON core_profiles(subscription_expires_at)
  WHERE subscription_tier != 'free' AND subscription_expires_at IS NOT NULL;

-- ==============================================================
-- 2. Table subscription_receipts (reçus StoreKit 2 validés App Store)
-- ==============================================================
CREATE TABLE IF NOT EXISTS subscription_receipts (
  id                        UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id                   UUID        NOT NULL,  -- = auth.users.id (même pattern que core_profiles)
  product_id                TEXT        NOT NULL,
  original_transaction_id   TEXT        NOT NULL UNIQUE,
  environment               TEXT        NOT NULL CHECK (environment IN ('sandbox', 'production')),
  verified_at               TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  expires_at                TIMESTAMPTZ           -- NULL pour les consumables (aucun ici en V1)
);

CREATE INDEX IF NOT EXISTS idx_subscription_receipts_user_id
  ON subscription_receipts(user_id);

CREATE INDEX IF NOT EXISTS idx_subscription_receipts_transaction_id
  ON subscription_receipts(original_transaction_id);

-- RLS
ALTER TABLE subscription_receipts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "subscription_receipts_select_own" ON subscription_receipts
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "subscription_receipts_insert_own" ON subscription_receipts
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "subscription_receipts_update_own" ON subscription_receipts
  FOR UPDATE USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- ==============================================================
-- 3. Fonction utilitaire : expiration des abonnements
--    Appelée par pg_cron quotidien OU lazy check dans l'edge function.
--    Filet de sécurité si un renouvellement StoreKit échoue silencieusement
--    (l'app ne rappelle `refreshSubscriptionStatus`/`validate-receipt` qu'au
--    prochain lancement) — sans ça, un tier expiré resterait "plus" jusqu'au
--    prochain boot de l'app.
-- ==============================================================
CREATE OR REPLACE FUNCTION expire_lapsed_leon_subscriptions()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  UPDATE core_profiles
  SET subscription_tier = 'free',
      subscription_expires_at = NULL,
      updated_at = NOW()
  WHERE subscription_tier != 'free'
    AND subscription_expires_at IS NOT NULL
    AND subscription_expires_at < NOW();
END;
$$;

-- Seul le service_role (pg_cron, edge functions) peut appeler cette fonction.
REVOKE EXECUTE ON FUNCTION expire_lapsed_leon_subscriptions() FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION expire_lapsed_leon_subscriptions() FROM authenticated;

-- ==============================================================
-- Vérification :
--   SELECT conname FROM pg_constraint WHERE conname = 'core_profiles_subscription_tier_check';
--   SELECT column_name, data_type FROM information_schema.columns
--     WHERE table_name = 'subscription_receipts' ORDER BY ordinal_position;
--   SELECT polname FROM pg_policy WHERE polrelid = 'subscription_receipts'::regclass;
-- ==============================================================
