// validate-receipt/index.ts
// Léon+ — Server-side receipt validation for App Store IAP (StoreKit 2).
// Portage du pattern GardenSage (Epic 17 Story 17.5, Flore+ en prod) : décode le
// JWS signé côté StoreKit 2, upsert dans subscription_receipts (idempotent sur
// original_transaction_id), met à jour core_profiles.subscription_tier.
//
// Un seul produit en V1 : "leon.plus.monthly" → tier "plus" (illimité). Pas de
// branche consommable (pas de pack questions) — à ajouter dans TIER_MAP le jour
// où un produit consommable Léon existera, pas avant.
//
// Dette assumée (identique GardenSage) : le JWS est décodé (base64url) mais sa
// signature n'est PAS vérifiée cryptographiquement contre Apple Root CA G3. On
// fait confiance à la couche auth Supabase (JWT user requis) + à l'origine de
// l'appel (app cliente authentifiée). À industrialiser un jour via la lib
// officielle Apple `app-store-server-library` si le volume le justifie.

import { createClient } from "https://esm.sh/@supabase/supabase-js@2.43.0";

const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY")!;
const supabaseServiceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const adminSupabase = createClient(supabaseUrl, supabaseServiceRoleKey);

interface ReceiptRequest {
  signed_transaction: string; // JWS from StoreKit 2
  product_id: string;
}

interface JWSPayload {
  transactionId: string;
  originalTransactionId: string;
  productId: string;
  purchaseDate: number; // ms
  expiresDate?: number; // ms, subscriptions only
  type: string; // "Auto-Renewable Subscription"
  environment: string; // "Sandbox" | "Production"
}

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization",
};

// Product ID → subscription tier mapping.
const TIER_MAP: Record<string, string> = {
  "leon.plus.monthly": "plus",
};

// Decode JWS payload (base64url middle part). Cf. dette signature ci-dessus.
function decodeJWSPayload(jws: string): JWSPayload {
  const parts = jws.split(".");
  if (parts.length !== 3) {
    throw new Error("Invalid JWS format");
  }
  const payload = parts[1].replace(/-/g, "+").replace(/_/g, "/");
  const decoded = atob(payload);
  return JSON.parse(decoded);
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const authHeader = req.headers.get("authorization");
    if (!authHeader) {
      return new Response(JSON.stringify({ error: "Missing authorization" }), {
        status: 401,
        headers: { "Content-Type": "application/json", ...corsHeaders },
      });
    }

    const supabase = createClient(supabaseUrl, supabaseAnonKey, {
      global: { headers: { Authorization: authHeader } },
    });

    const { data: { user }, error: authError } = await supabase.auth.getUser();
    if (authError || !user) {
      return new Response(JSON.stringify({ error: "Invalid token" }), {
        status: 401,
        headers: { "Content-Type": "application/json", ...corsHeaders },
      });
    }

    const body = (await req.json()) as ReceiptRequest;
    if (!body.signed_transaction || !body.product_id) {
      return new Response(
        JSON.stringify({ error: "invalid_receipt", reason: "Missing signed_transaction or product_id" }),
        { status: 400, headers: { "Content-Type": "application/json", ...corsHeaders } }
      );
    }

    let payload: JWSPayload;
    try {
      payload = decodeJWSPayload(body.signed_transaction);
    } catch (e) {
      console.error(`[${user.id}] JWS decode failed:`, e);
      return new Response(
        JSON.stringify({ error: "invalid_receipt", reason: "Failed to decode JWS" }),
        { status: 400, headers: { "Content-Type": "application/json", ...corsHeaders } }
      );
    }

    if (payload.productId !== body.product_id) {
      return new Response(
        JSON.stringify({ error: "invalid_receipt", reason: "Product ID mismatch" }),
        { status: 400, headers: { "Content-Type": "application/json", ...corsHeaders } }
      );
    }

    const environment = payload.environment?.toLowerCase() === "production" ? "production" : "sandbox";
    const originalTransactionId = payload.originalTransactionId || payload.transactionId;
    const expiresAt = payload.expiresDate ? new Date(payload.expiresDate).toISOString() : null;

    console.log(`[${user.id}] Validating receipt: product=${payload.productId}, env=${environment}, txn=${originalTransactionId}`);

    const { error: receiptError } = await adminSupabase
      .from("subscription_receipts")
      .upsert(
        {
          user_id: user.id,
          product_id: payload.productId,
          original_transaction_id: originalTransactionId,
          environment,
          verified_at: new Date().toISOString(),
          expires_at: expiresAt,
        },
        { onConflict: "original_transaction_id" }
      );

    if (receiptError) {
      console.error(`[${user.id}] Receipt storage error:`, receiptError);
    }

    const tier = TIER_MAP[payload.productId];
    if (!tier) {
      return new Response(
        JSON.stringify({ error: "invalid_receipt", reason: `Unknown product: ${payload.productId}` }),
        { status: 400, headers: { "Content-Type": "application/json", ...corsHeaders } }
      );
    }

    const { error: updateError } = await adminSupabase
      .from("core_profiles")
      .update({
        subscription_tier: tier,
        subscription_expires_at: expiresAt,
        updated_at: new Date().toISOString(),
      })
      .eq("id", user.id);

    if (updateError) {
      console.error(`[${user.id}] Profile update error:`, updateError);
      return new Response(
        JSON.stringify({ error: "server_error", reason: "Failed to update subscription" }),
        { status: 500, headers: { "Content-Type": "application/json", ...corsHeaders } }
      );
    }

    console.log(`[${user.id}] Subscription updated: tier=${tier}, expires=${expiresAt}`);

    return new Response(
      JSON.stringify({ status: "ok", tier, expires_at: expiresAt }),
      { status: 200, headers: { "Content-Type": "application/json", ...corsHeaders } }
    );
  } catch (error) {
    console.error("validate-receipt error:", error);
    return new Response(
      JSON.stringify({ error: "Internal error" }),
      { status: 500, headers: { "Content-Type": "application/json", ...corsHeaders } }
    );
  }
});
