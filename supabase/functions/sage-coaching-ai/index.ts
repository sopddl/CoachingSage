// supabase/functions/sage-coaching-ai/index.ts
// Story 3.3b — Edge Function Léon IA fallback (mode=adapt-rare uniquement V1).
// Stories suivantes ajouteront les autres modes (chat, regen-week, etc.) en
// branchant ici via le param `mode`.
//
// Flow :
//   1. CORS + auth (JWT user) + parse body
//   2. checkQuota → si dépassé, return 429 quota_exceeded
//   3. Build system prompt versionné + 4 garde-fous EU MDR (cf prompts.ts)
//   4. callAnthropicWithRetry (haiku → sonnet si JSON invalide)
//   5. Filter banned-words sur la réponse (filet de sécurité)
//   6. Log dans ai_usage_logs (success ou failure) — sans bloquer la response
//   7. Return AdaptationPatch JSON au client iOS
//
// Env vars requises :
//   SUPABASE_URL, SUPABASE_ANON_KEY, SUPABASE_SERVICE_ROLE_KEY (auto-set par Supabase)
//   ANTHROPIC_API_KEY (à set manuellement dans Edge Function secrets)

import { createClient } from "https://esm.sh/@supabase/supabase-js@2.43.0";
import type { SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2.43.0";
import type {
  AdaptRareRequest,
  AdaptationPatch,
  LeonErrorResponse,
  OnboardingIntentRequest,
} from "./types.ts";
import {
  buildAdaptRareSystemPrompt,
  buildOnboardingIntentSystemPrompt,
  findBannedWord,
  PROMPT_VERSION,
} from "./prompts.ts";
import { callAnthropicWithRetry } from "./anthropic.ts";
import { checkQuota, logUsage } from "./rate_limit.ts";

// Type attendu par rate_limit (checkQuota/logUsage). createClient() infère un type
// au schéma plus large → cast unique au site de dispatch.
type AdminClient = SupabaseClient;

const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY")!;
const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization",
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  // 1. Auth user via JWT
  const authHeader = req.headers.get("authorization");
  if (!authHeader) {
    return errorResponse(401, "unauthorized", "Missing authorization");
  }
  const userClient = createClient(supabaseUrl, supabaseAnonKey, {
    global: { headers: { Authorization: authHeader } },
  });
  const {
    data: { user },
    error: authError,
  } = await userClient.auth.getUser();
  if (authError || !user) {
    return errorResponse(401, "unauthorized", "Invalid token");
  }

  // 2. Parse body
  let rawBody: Record<string, unknown>;
  try {
    rawBody = (await req.json()) as Record<string, unknown>;
  } catch {
    return errorResponse(400, "invalid_request", "Body is not valid JSON");
  }

  const adminClient = createClient(supabaseUrl, serviceRoleKey);
  const mode = rawBody.mode;

  // Dispatch — fil de Léon inc2 : interprétation NL de la demande d'onboarding.
  if (mode === "onboarding-intent") {
    return await handleOnboardingIntent({
      adminClient: adminClient as unknown as AdminClient,
      userId: user.id,
      body: rawBody as unknown as OnboardingIntentRequest,
    });
  }

  if (mode !== "adapt-rare") {
    return errorResponse(400, "invalid_request", `Mode '${String(mode)}' not supported`);
  }
  const body = rawBody as unknown as AdaptRareRequest;

  // 3. Quota
  const quota = await checkQuota({ adminClient, userId: user.id });
  if (!quota.allowed) {
    const errorBody: LeonErrorResponse = {
      error: {
        code: "quota_exceeded",
        message: "Daily Léon quota exceeded",
        quota_resets_at: quota.resetsAt,
      },
    };
    return jsonResponse(429, errorBody);
  }

  // 4. Build prompt + call Anthropic
  const language = inferLanguage(body.profile_json);
  const systemPrompt = buildAdaptRareSystemPrompt(language);
  const userMessage = JSON.stringify({
    triggered_reason: body.triggered_reason,
    template: body.template_json,
    profile: body.profile_json,
    health_summary: body.health_summary,
    adapted_program: body.adapted_program_json,
  });

  let result;
  try {
    result = await callAnthropicWithRetry({ systemPrompt, userMessage });
  } catch (err) {
    console.error(`[sage-coaching-ai] anthropic call failed:`, err);
    await logUsage({
      adminClient,
      entry: {
        user_id: user.id,
        mode: "adapt-rare",
        model: "haiku-4-5",
        tokens_in: 0,
        tokens_out: 0,
        cost_usd: 0,
        duration_ms: 0,
        triggered_reason: body.triggered_reason,
        success: false,
        error_code: "anthropic_unavailable",
      },
    });
    return errorResponse(502, "anthropic_unavailable", "Anthropic API unavailable");
  }

  // 5. JSON shape validation
  if (result.parsedJSON === undefined || !isValidPatch(result.parsedJSON)) {
    console.error(`[sage-coaching-ai] invalid patch from ${result.modelUsed}:`, result.rawContent.slice(0, 500));
    await logUsage({
      adminClient,
      entry: {
        user_id: user.id,
        mode: "adapt-rare",
        model: result.modelUsed,
        tokens_in: result.inputTokens,
        tokens_out: result.outputTokens,
        cost_usd: result.costUsd,
        duration_ms: result.durationMs,
        triggered_reason: body.triggered_reason,
        success: false,
        error_code: "invalid_patch",
      },
    });
    return errorResponse(502, "invalid_patch", "Léon returned an unparseable patch");
  }

  // 6. Banned words filter (sécurité dernière ligne)
  const banned = findBannedWord(result.rawContent, language);
  if (banned) {
    console.error(`[sage-coaching-ai] banned word '${banned}' in ${result.modelUsed} output`);
    await logUsage({
      adminClient,
      entry: {
        user_id: user.id,
        mode: "adapt-rare",
        model: result.modelUsed,
        tokens_in: result.inputTokens,
        tokens_out: result.outputTokens,
        cost_usd: result.costUsd,
        duration_ms: result.durationMs,
        triggered_reason: body.triggered_reason,
        success: false,
        error_code: "invalid_patch",
      },
    });
    return errorResponse(502, "invalid_patch", `Léon output contained a forbidden term`);
  }

  // 7. Log success + return patch
  await logUsage({
    adminClient,
    entry: {
      user_id: user.id,
      mode: "adapt-rare",
      model: result.modelUsed,
      tokens_in: result.inputTokens,
      tokens_out: result.outputTokens,
      cost_usd: result.costUsd,
      duration_ms: result.durationMs,
      triggered_reason: body.triggered_reason,
      success: true,
      error_code: null,
    },
  });

  const patch = result.parsedJSON as AdaptationPatch;
  return jsonResponse(200, {
    patch,
    quota: {
      used: quota.used + 1,
      limit: quota.limit,
      resets_at: quota.resetsAt,
      tier: quota.tier,
    },
    meta: {
      model: result.modelUsed,
      prompt_version: PROMPT_VERSION,
      duration_ms: result.durationMs,
    },
  });
});

// MARK: - Onboarding intent handler (fil de Léon inc2)

/// Interprète la demande NL → restitution + routage ✓/⏳/🚫. Renvoie directement
/// le JSON `LeonIntentResponse` (le client iOS le décode tel quel).
async function handleOnboardingIntent(opts: {
  adminClient: AdminClient;
  userId: string;
  body: OnboardingIntentRequest;
}): Promise<Response> {
  const { adminClient, userId, body } = opts;

  if (typeof body.text !== "string") {
    return errorResponse(400, "invalid_request", "Missing 'text'");
  }

  // Quota partagé (même pool que adapt-rare).
  const quota = await checkQuota({ adminClient, userId });
  if (!quota.allowed) {
    const errorBody: LeonErrorResponse = {
      error: {
        code: "quota_exceeded",
        message: "Daily Léon quota exceeded",
        quota_resets_at: quota.resetsAt,
      },
    };
    return jsonResponse(429, errorBody);
  }

  const systemPrompt = buildOnboardingIntentSystemPrompt();
  const userMessage = JSON.stringify({
    text: body.text,
    active_sports: Array.isArray(body.active_sports) ? body.active_sports : [],
    selected_sport: body.selected_sport ?? null,
    locale: normalizeLocale(body.locale),
  });

  const logFailure = (errorCode: string, result?: { modelUsed: string; inputTokens: number; outputTokens: number; costUsd: number; durationMs: number }) =>
    logUsage({
      adminClient,
      entry: {
        user_id: userId,
        mode: "onboarding-intent",
        model: result?.modelUsed ?? "haiku-4-5",
        tokens_in: result?.inputTokens ?? 0,
        tokens_out: result?.outputTokens ?? 0,
        cost_usd: result?.costUsd ?? 0,
        duration_ms: result?.durationMs ?? 0,
        triggered_reason: null,
        success: false,
        error_code: errorCode,
      },
    });

  let result;
  try {
    result = await callAnthropicWithRetry({ systemPrompt, userMessage });
  } catch (err) {
    console.error(`[onboarding-intent] anthropic call failed:`, err);
    await logFailure("anthropic_unavailable");
    return errorResponse(502, "anthropic_unavailable", "Anthropic API unavailable");
  }

  if (result.parsedJSON === undefined || !isValidIntentResponse(result.parsedJSON)) {
    console.error(`[onboarding-intent] invalid response from ${result.modelUsed}:`, result.rawContent.slice(0, 500));
    await logFailure("invalid_patch", result);
    return errorResponse(502, "invalid_patch", "Léon returned an unparseable response");
  }

  // Filet MDR dernière ligne : mots bannis (FR + EN + ES, cf. C1 revue MDR).
  const banned = findBannedWord(result.rawContent, "fr")
    ?? findBannedWord(result.rawContent, "en")
    ?? findBannedWord(result.rawContent, "es");
  if (banned) {
    console.error(`[onboarding-intent] banned word '${banned}' in ${result.modelUsed} output`);
    await logFailure("invalid_patch", result);
    return errorResponse(502, "invalid_patch", "Léon output contained a forbidden term");
  }

  await logUsage({
    adminClient,
    entry: {
      user_id: userId,
      mode: "onboarding-intent",
      model: result.modelUsed,
      tokens_in: result.inputTokens,
      tokens_out: result.outputTokens,
      cost_usd: result.costUsd,
      duration_ms: result.durationMs,
      triggered_reason: null,
      success: true,
      error_code: null,
    },
  });

  // Renvoie directement le LeonIntentResponse (décodé tel quel côté iOS).
  return jsonResponse(200, result.parsedJSON);
}

/// Normalise une locale ("fr_FR" → "fr") vers fr/en/es (défaut fr).
function normalizeLocale(locale: unknown): string {
  if (typeof locale !== "string") return "fr";
  const code = locale.toLowerCase().split(/[_-]/)[0];
  return code === "en" || code === "es" ? code : "fr";
}

/// Valide la forme `LeonIntentResponse` : { intents: [{ route, restitution, ... }] }.
function isValidIntentResponse(value: unknown): boolean {
  if (typeof value !== "object" || value === null || Array.isArray(value)) return false;
  const v = value as Record<string, unknown>;
  if (!Array.isArray(v.intents) || v.intents.length === 0) return false;
  for (const item of v.intents) {
    if (typeof item !== "object" || item === null) return false;
    const i = item as Record<string, unknown>;
    if (i.route !== "supported" && i.route !== "not_yet" && i.route !== "refused_safety") return false;
    if (typeof i.restitution !== "string" || i.restitution.trim().length === 0) return false;
  }
  return true;
}

// MARK: - Helpers

function jsonResponse(status: number, body: unknown): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json", ...corsHeaders },
  });
}

function errorResponse(
  status: number,
  code: LeonErrorResponse["error"]["code"],
  message: string
): Response {
  const body: LeonErrorResponse = { error: { code, message } };
  return jsonResponse(status, body);
}

/// Best-effort : on lit `language` dans le profil JSON pour décider FR vs EN.
/// Si absent / inconnu → fallback FR (langue par défaut MVP).
function inferLanguage(profileJSON: unknown): "fr" | "en" {
  if (typeof profileJSON !== "object" || profileJSON === null) return "fr";
  const lang = (profileJSON as Record<string, unknown>)["language"];
  return lang === "en" ? "en" : "fr";
}

/// Validation très laxiste : on accepte tout objet JSON dont les champs connus
/// ont le bon type (ou sont absents). Un patch vide `{}` est valide. Un patch
/// avec un type primitif au lieu d'un array est invalide.
function isValidPatch(value: unknown): boolean {
  if (typeof value !== "object" || value === null || Array.isArray(value)) return false;
  const v = value as Record<string, unknown>;
  if (v.exercise_substitutions !== undefined && !Array.isArray(v.exercise_substitutions)) return false;
  if (v.volume_adjustments !== undefined && !Array.isArray(v.volume_adjustments)) return false;
  if (v.progression_pacing !== undefined && !Array.isArray(v.progression_pacing)) return false;
  if (v.safety_notes !== undefined && !Array.isArray(v.safety_notes)) return false;
  if (v.personalization_note !== undefined && typeof v.personalization_note !== "string") return false;
  return true;
}
