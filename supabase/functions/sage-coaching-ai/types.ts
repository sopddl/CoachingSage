// supabase/functions/sage-coaching-ai/types.ts
// Story 3.3b — contrats partagés Edge Function ⇄ client iOS.
// La struct Swift `AdaptationPatch` (Coaching/AI/AdaptationPatch.swift) doit rester
// alignée 1:1 avec ces types. Tout changement = bump version client + Edge Function.

/// Mode supporté pour l'instant : 'adapt-rare' uniquement (Story 3.3b).
/// Stories suivantes ajouteront 'chat' (3.6), 'regen-week' (3.4), 'adapt-session' (3.6),
/// 'generate' (3.5).
export type LeonMode = "adapt-rare";

export type TriggeredReason =
  | "atypical_constraints"   // adapter (3.3a) a remonté requiresAIAssist
  | "freetext_request"       // user a tapé un texte libre dans le questionnaire
  | "user_explicit";         // user a tapé "Léon, retravaille ce programme"

export interface AdaptRareRequest {
  mode: "adapt-rare";
  triggered_reason: TriggeredReason;
  /// JSON brut du `ProgramTemplate` source (~3-8KB).
  template_json: unknown;
  /// JSON profil consolidé : CoreProfile + CoachingProfile + sport profile (~1-2KB).
  profile_json: unknown;
  /// JSON `HealthSummary` produit par `HealthSummaryBuilder` iOS (~500B). Peut être
  /// quasi-vide si user a refusé HealthKit — Léon doit tolérer.
  health_summary: unknown;
  /// JSON `AdaptedProgram` post-3.3a (~5-15KB).
  adapted_program_json: unknown;
}

/// Patch JSON applicable par-dessus l'`AdaptedProgram` côté client iOS.
/// Tous les champs sont optionnels : un patch vide = "Léon n'a rien à proposer en plus".
export interface AdaptationPatch {
  /// Substitutions d'exercices : remplace l'exercice `original_exercise_name` (week+day)
  /// par `replacement_exercise_name`, en justifiant brièvement.
  exercise_substitutions?: ExerciseSubstitution[];
  /// Ajustements de volume globaux (ex: "réduire reps de 12 à 8 sur W3-W4").
  volume_adjustments?: VolumeAdjustment[];
  /// Ajustement de rythme de progression (ex: "passer en RPE 6 au lieu de 7 sur W2").
  progression_pacing?: ProgressionPacing[];
  /// Notes de sécurité contextualisées (ex: "garder un kiné disponible pour les pliométries").
  /// JAMAIS d'avis médical (refus prompt système + filtre côté client).
  safety_notes?: string[];
  /// Note personnalisée de Léon, max 200 caractères. Affichée en hero de l'AdaptedProgramView.
  personalization_note?: string;
}

export interface ExerciseSubstitution {
  week_number: number;
  day: number;
  original_exercise_name: string;
  replacement_exercise_name: string;
  reason: string;
}

export interface VolumeAdjustment {
  week_number: number;
  day?: number;                  // null = toute la semaine
  exercise_name?: string;        // null = tous les exercices
  adjustment: string;            // texte court "réduire de 15%" ou "passer de 4×8 à 3×6"
  reason: string;
}

export interface ProgressionPacing {
  week_number: number;
  adjustment: string;            // texte court "RPE cible 6 au lieu de 7"
  reason: string;
}

/// Erreur structurée renvoyée au client iOS. `code` doit matcher `LeonError` côté Swift.
export interface LeonErrorResponse {
  error: {
    code: "quota_exceeded" | "anthropic_unavailable" | "invalid_patch" | "invalid_request" | "unauthorized";
    message: string;
    /// Pour quota_exceeded : reset à minuit UTC du jour suivant.
    quota_resets_at?: string;
  };
}
