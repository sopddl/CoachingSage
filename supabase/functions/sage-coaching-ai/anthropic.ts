// supabase/functions/sage-coaching-ai/anthropic.ts
// Story 3.3b — client minimaliste Anthropic Messages API avec prompt caching
// activé sur le system prompt (NFR2 cost). Retry sonnet-4-6 si haiku-4-5 émet
// un JSON invalide. Si encore invalide → propage l'erreur au caller.
//
// Modèles : claude-haiku-4-5 par défaut (rapide + bon marché), claude-sonnet-4-6
// en fallback qualité. Connaissances cutoff janvier 2026.

const ANTHROPIC_API_KEY = Deno.env.get("ANTHROPIC_API_KEY")!;
const ANTHROPIC_VERSION = "2023-06-01";
const ANTHROPIC_BETA = "prompt-caching-2024-07-31";

export const HAIKU_MODEL = "claude-haiku-4-5";
export const SONNET_MODEL = "claude-sonnet-4-6";

export interface AnthropicCallResult {
  /// JSON parsé du contenu (si parseable). Undefined si content n'est pas un JSON propre.
  parsedJSON?: unknown;
  /// Contenu brut text retourné par Anthropic.
  rawContent: string;
  /// Modèle réellement utilisé (peut différer si retry sonnet).
  modelUsed: string;
  inputTokens: number;
  outputTokens: number;
  /// Cost calculé en USD (prix officiels Anthropic au moment du release ; à
  /// re-vérifier pour Haiku 4.5 / Sonnet 4.6).
  costUsd: number;
  durationMs: number;
}

/// Appelle Anthropic puis tente de parser la réponse en JSON. Si parseable et
/// non-vide, retourne le résultat. Sinon retry avec le modèle de fallback.
/// Retourne le dernier résultat (parseable ou pas) — caller décide quoi en faire.
export async function callAnthropicWithRetry(opts: {
  systemPrompt: string;
  userMessage: string;
}): Promise<AnthropicCallResult> {
  const first = await callAnthropic({
    model: HAIKU_MODEL,
    systemPrompt: opts.systemPrompt,
    userMessage: opts.userMessage,
  });
  if (first.parsedJSON !== undefined) return first;

  console.log(`[anthropic] haiku returned non-JSON, retrying with sonnet`);
  const retry = await callAnthropic({
    model: SONNET_MODEL,
    systemPrompt: opts.systemPrompt,
    userMessage: opts.userMessage,
  });
  return retry;
}

async function callAnthropic(opts: {
  model: string;
  systemPrompt: string;
  userMessage: string;
}): Promise<AnthropicCallResult> {
  const start = Date.now();

  const body = {
    model: opts.model,
    max_tokens: 4096,
    // System en cache_control pour bénéficier du prompt caching (90% reduction
    // sur les input tokens cached après la 1ère requête).
    system: [
      {
        type: "text",
        text: opts.systemPrompt,
        cache_control: { type: "ephemeral" },
      },
    ],
    messages: [{ role: "user", content: opts.userMessage }],
  };

  const response = await fetch("https://api.anthropic.com/v1/messages", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "x-api-key": ANTHROPIC_API_KEY,
      "anthropic-version": ANTHROPIC_VERSION,
      "anthropic-beta": ANTHROPIC_BETA,
    },
    body: JSON.stringify(body),
  });

  const durationMs = Date.now() - start;

  if (!response.ok) {
    const errorText = await response.text();
    throw new Error(`Anthropic API ${response.status}: ${errorText}`);
  }

  const data = await response.json();
  const rawContent = (data.content?.[0]?.text ?? "") as string;
  const inputTokens = (data.usage?.input_tokens ?? 0) + (data.usage?.cache_read_input_tokens ?? 0);
  const outputTokens = data.usage?.output_tokens ?? 0;

  let parsedJSON: unknown | undefined;
  try {
    const trimmed = stripFence(rawContent.trim());
    if (trimmed.startsWith("{") || trimmed.startsWith("[")) {
      parsedJSON = JSON.parse(trimmed);
    }
  } catch {
    parsedJSON = undefined;
  }

  return {
    parsedJSON,
    rawContent,
    modelUsed: opts.model,
    inputTokens,
    outputTokens,
    costUsd: estimateCostUsd({ model: opts.model, inputTokens, outputTokens }),
    durationMs,
  };
}

/// Léon est instruit de ne pas mettre de fence ```json — mais on protège quand même
/// au cas où.
function stripFence(text: string): string {
  if (text.startsWith("```")) {
    const firstNewline = text.indexOf("\n");
    const lastFence = text.lastIndexOf("```");
    if (firstNewline > 0 && lastFence > firstNewline) {
      return text.slice(firstNewline + 1, lastFence).trim();
    }
  }
  return text;
}

/// Estimation grossière du coût USD. Prix indicatifs au release :
/// Haiku 4.5 ~$0.5/1M input, $2.5/1M output ; Sonnet 4.6 ~$3/1M input, $15/1M output.
/// À ajuster quand les prix officiels Haiku 4.5 / Sonnet 4.6 sont publiés.
function estimateCostUsd(opts: { model: string; inputTokens: number; outputTokens: number }): number {
  const isSonnet = opts.model.includes("sonnet");
  const inputRate = isSonnet ? 3.0 / 1_000_000 : 0.5 / 1_000_000;
  const outputRate = isSonnet ? 15.0 / 1_000_000 : 2.5 / 1_000_000;
  return opts.inputTokens * inputRate + opts.outputTokens * outputRate;
}
