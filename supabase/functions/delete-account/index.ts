// Supabase Edge Function — delete-account (CoachingSage V1)
// Port simplifié de GardenSage : scope minimal core_profiles + auth.users.
// Aucune table garden/plant — pas de Programs/Sessions encore (Epic 3+).
// RGPD Art. 17 : hard-delete immédiat ; le filet 30j (pg_cron sur soft-delete) reste actif côté DB.
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.43.0";

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

  try {
    const authHeader = req.headers.get("authorization");
    if (!authHeader) {
      return new Response(JSON.stringify({ error: "Missing authorization" }), {
        status: 401,
        headers: { "Content-Type": "application/json", ...corsHeaders },
      });
    }

    const userClient = createClient(supabaseUrl, supabaseAnonKey, {
      global: { headers: { Authorization: authHeader } },
    });

    const {
      data: { user },
      error: authError,
    } = await userClient.auth.getUser();

    if (authError || !user) {
      return new Response(JSON.stringify({ error: "Invalid token" }), {
        status: 401,
        headers: { "Content-Type": "application/json", ...corsHeaders },
      });
    }

    const adminClient = createClient(supabaseUrl, serviceRoleKey);

    const { error: profileDeleteError } = await adminClient
      .from("core_profiles")
      .delete()
      .eq("id", user.id);

    if (profileDeleteError) {
      console.error(`[delete-account] Failed to delete core_profiles ${user.id}:`, profileDeleteError);
      return new Response(JSON.stringify({ error: "Failed to delete profile" }), {
        status: 500,
        headers: { "Content-Type": "application/json", ...corsHeaders },
      });
    }

    const { error: deleteError } = await adminClient.auth.admin.deleteUser(user.id);

    if (deleteError) {
      const msg = deleteError.message ?? String(deleteError);
      // Idempotence : si user déjà supprimé (retry après succès partiel), on est dans l'état cible.
      if (msg.toLowerCase().includes("not found") || msg.toLowerCase().includes("user_not_found")) {
        console.log(`[delete-account] auth user ${user.id} already gone, returning 200 (idempotent)`);
        return new Response(JSON.stringify({ success: true, alreadyDeleted: true }), {
          status: 200,
          headers: { "Content-Type": "application/json", ...corsHeaders },
        });
      }
      console.error(`[delete-account] Failed to delete auth user ${user.id}:`, msg);
      return new Response(JSON.stringify({ error: "Failed to delete account" }), {
        status: 500,
        headers: { "Content-Type": "application/json", ...corsHeaders },
      });
    }

    console.log(`[delete-account] User ${user.id} deleted successfully`);
    return new Response(JSON.stringify({ success: true }), {
      status: 200,
      headers: { "Content-Type": "application/json", ...corsHeaders },
    });
  } catch (error) {
    const msg = error instanceof Error ? error.message : String(error);
    console.error("[delete-account] Error:", msg);
    return new Response(JSON.stringify({ error: msg }), {
      status: 500,
      headers: { "Content-Type": "application/json", ...corsHeaders },
    });
  }
});
