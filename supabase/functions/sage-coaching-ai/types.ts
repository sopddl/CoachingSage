// supabase/functions/sage-coaching-ai/types.ts
// Story 3.3b — contrats partagés Edge Function ⇄ client iOS.
// La struct Swift `AdaptationPatch` (Coaching/AI/AdaptationPatch.swift) doit rester
// alignée 1:1 avec ces types. Tout changement = bump version client + Edge Function.

/// Modes supportés : 'adapt-rare' (Story 3.3b) + 'onboarding-intent' (fil de Léon inc2).
/// Stories suivantes ajouteront 'chat' (3.6), 'regen-week' (3.4), etc.
export type LeonMode = "adapt-rare" | "onboarding-intent";

// MARK: - Onboarding intent (fil de Léon inc2)
//
// Contrat aligné 1:1 avec Swift `LeonIntentService.swift` (clés camelCase = noms de
// propriété Swift, décodage par défaut). Valeurs d'enum = rawValues Swift.

export type LeonIntentRoute = "supported" | "not_yet" | "refused_safety";

/// Doit matcher Swift `LeonRefusalFamily.rawValue`. Présent seulement si route == refused_safety.
export type LeonRefusalFamily = "risky_goal" | "health_condition";

/// Doit matcher Swift `LeonUnmetCategory.rawValue`.
export type LeonUnmetCategory =
  | "periodisation_temporelle"
  | "multi_sport_combine"
  | "nutrition"
  | "weight_loss"
  | "health_condition"
  | "unknown";

export interface LeonIntentSlots {
  /// rawValues SportCode reconnus (le 1ᵉʳ amorce la proposition, V1 mono-sport).
  sportCodes?: string[];
  /// Rythme séances/semaine si exprimé.
  frequencyPerWeek?: number;
}

export interface LeonIntent {
  route: LeonIntentRoute;
  /// Phrase de restitution mot-à-mot, DÉJÀ localisée selon la locale demandée.
  restitution: string;
  /// Catégorie backlog (requise si route ≠ supported ; sinon null).
  category?: LeonUnmetCategory | null;
  /// Famille du refus (seulement si route == refused_safety ; sinon null).
  refusalFamily?: LeonRefusalFamily | null;
  slots?: LeonIntentSlots | null;
}

export interface OnboardingIntentRequest {
  mode: "onboarding-intent";
  /// Texte libre de l'user (demande initiale ou relance).
  text: string;
  /// Sports déclarés de l'user (rawValues SportCode).
  active_sports: string[];
  /// Sport déjà sélectionné au carrousel, s'il y en a un.
  selected_sport?: string | null;
  /// Locale in-app ("fr", "en", "es", ou variantes "fr_FR"…).
  locale: string;
}

/// Réponse renvoyée au client : 1+ intentions (une demande peut mêler ✓ + ⏳ + 🚫).
export interface LeonIntentResponse {
  intents: LeonIntent[];
}

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
