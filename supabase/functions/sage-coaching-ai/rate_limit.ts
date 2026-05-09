// supabase/functions/sage-coaching-ai/rate_limit.ts
// Story 3.3b — quota cumulé 10 calls Léon IA / jour pour free tier, partagé
// entre tous les modes (adapt-rare, chat, regen-week, adapt-session, generate
// non-Pro). Pro / Plus : illimité (vérifié via subscription_tier core_profiles).
//
// Compté UNIQUEMENT sur les appels success=TRUE (un user ne doit pas être
// pénalisé pour un bug Anthropic ou un retry échoué).

import type { SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2.43.0";

export const FREE_TIER_DAILY_QUOTA = 10;

export interface QuotaCheck {
  allowed: boolean;
  used: number;
  limit: number;
  /// ISO timestamp du prochain reset (00:00 UTC du jour suivant).
  resetsAt: string;
  /// "free" | "plus" | "pro". Plus / Pro = illimité.
  tier: string;
}

export async function checkQuota(opts: {
  adminClient: SupabaseClient;
  userId: string;
}): Promise<QuotaCheck> {
  const tier = await getSubscriptionTier(opts.adminClient, opts.userId);
  const resetsAt = nextMidnightUTC();

  // Tiers payants : illimité.
  if (tier === "plus" || tier === "pro") {
    return { allowed: true, used: 0, limit: -1, resetsAt, tier };
  }

  // Free tier : count last 24h success-only.
  const since = new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString();
  const { count, error } = await opts.adminClient
    .from("ai_usage_logs")
    .select("id", { count: "exact", head: true })
    .eq("user_id", opts.userId)
    .eq("success", true)
    .gte("created_at", since);

  if (error) {
    console.error(`[rate_limit] count query failed for ${opts.userId}:`, error);
    // Échec côté DB : on autorise (fail-open) pour ne pas bloquer le user, mais
    // l'audit ai_usage_logs pourra rattraper le compte exact côté facturation.
    return { allowed: true, used: 0, limit: FREE_TIER_DAILY_QUOTA, resetsAt, tier };
  }

  const used = count ?? 0;
  return {
    allowed: used < FREE_TIER_DAILY_QUOTA,
    used,
    limit: FREE_TIER_DAILY_QUOTA,
    resetsAt,
    tier,
  };
}

async function getSubscriptionTier(client: SupabaseClient, userId: string): Promise<string> {
  const { data, error } = await client
    .from("core_profiles")
    .select("subscription_tier")
    .eq("id", userId)
    .single();

  if (error || !data) return "free";
  return (data.subscription_tier as string | null) ?? "free";
}

function nextMidnightUTC(): string {
  const now = new Date();
  const midnight = new Date(Date.UTC(
    now.getUTCFullYear(),
    now.getUTCMonth(),
    now.getUTCDate() + 1,
    0, 0, 0, 0
  ));
  return midnight.toISOString();
}

export interface UsageLogEntry {
  user_id: string;
  mode: string;
  model: string;
  tokens_in: number;
  tokens_out: number;
  cost_usd: number;
  duration_ms: number;
  triggered_reason: string | null;
  success: boolean;
  error_code: string | null;
}

export async function logUsage(opts: {
  adminClient: SupabaseClient;
  entry: UsageLogEntry;
}): Promise<void> {
  const { error } = await opts.adminClient.from("ai_usage_logs").insert(opts.entry);
  if (error) {
    // On log mais on ne fail pas la requête : le résultat utilisateur prime
    // sur l'audit (qui pourra être rattrapé depuis les logs Anthropic si
    // besoin pour facturation).
    console.error(`[rate_limit] failed to insert ai_usage_logs:`, error);
  }
}
