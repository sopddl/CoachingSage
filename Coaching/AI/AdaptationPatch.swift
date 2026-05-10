// Coaching/AI/AdaptationPatch.swift
// Story 3.3b — patch JSON émis par Léon (Edge Function sage-coaching-ai mode=adapt-rare).
// Alignement 1:1 OBLIGATOIRE avec `supabase/functions/sage-coaching-ai/types.ts`.
// Toute modif côté serveur DOIT être répercutée ici sinon decode failure runtime.
import Foundation

/// Patch applicable par-dessus un `AdaptedProgram` post-3.3a. Tous les champs
/// optionnels — Léon omet ceux qu'il n'a rien à dire dessus. Un patch vide est
/// valide (signal "l'algo a déjà fait le bon job").
public struct AdaptationPatch: Codable, Equatable, Sendable {
    public let exerciseSubstitutions: [ExerciseSubstitution]?
    public let volumeAdjustments: [VolumeAdjustment]?
    public let progressionPacing: [ProgressionPacing]?
    public let safetyNotes: [String]?
    public let personalizationNote: String?

    public init(
        exerciseSubstitutions: [ExerciseSubstitution]? = nil,
        volumeAdjustments: [VolumeAdjustment]? = nil,
        progressionPacing: [ProgressionPacing]? = nil,
        safetyNotes: [String]? = nil,
        personalizationNote: String? = nil
    ) {
        self.exerciseSubstitutions = exerciseSubstitutions
        self.volumeAdjustments = volumeAdjustments
        self.progressionPacing = progressionPacing
        self.safetyNotes = safetyNotes
        self.personalizationNote = personalizationNote
    }

    enum CodingKeys: String, CodingKey {
        case exerciseSubstitutions = "exercise_substitutions"
        case volumeAdjustments = "volume_adjustments"
        case progressionPacing = "progression_pacing"
        case safetyNotes = "safety_notes"
        case personalizationNote = "personalization_note"
    }

    /// `true` si le patch contient au moins une instruction non-vide. Sert au
    /// `PatchApplier` pour décider si on persiste `aiPatchApplied = true` ou si
    /// Léon n'a finalement rien proposé.
    public var hasContent: Bool {
        let subs = !(exerciseSubstitutions?.isEmpty ?? true)
        let vols = !(volumeAdjustments?.isEmpty ?? true)
        let pacing = !(progressionPacing?.isEmpty ?? true)
        let notes = !(safetyNotes?.isEmpty ?? true)
        let perso = !(personalizationNote?.isEmpty ?? true)
        return subs || vols || pacing || notes || perso
    }

    public struct ExerciseSubstitution: Codable, Equatable, Sendable {
        public let weekNumber: Int
        public let day: Int
        public let originalExerciseName: String
        public let replacementExerciseName: String
        public let reason: String

        public init(weekNumber: Int, day: Int, originalExerciseName: String, replacementExerciseName: String, reason: String) {
            self.weekNumber = weekNumber
            self.day = day
            self.originalExerciseName = originalExerciseName
            self.replacementExerciseName = replacementExerciseName
            self.reason = reason
        }

        enum CodingKeys: String, CodingKey {
            case weekNumber = "week_number"
            case day
            case originalExerciseName = "original_exercise_name"
            case replacementExerciseName = "replacement_exercise_name"
            case reason
        }
    }

    public struct VolumeAdjustment: Codable, Equatable, Sendable {
        public let weekNumber: Int
        public let day: Int?            // nil = toute la semaine
        public let exerciseName: String? // nil = tous les exercices
        public let adjustment: String
        public let reason: String

        public init(weekNumber: Int, day: Int? = nil, exerciseName: String? = nil, adjustment: String, reason: String) {
            self.weekNumber = weekNumber
            self.day = day
            self.exerciseName = exerciseName
            self.adjustment = adjustment
            self.reason = reason
        }

        enum CodingKeys: String, CodingKey {
            case weekNumber = "week_number"
            case day
            case exerciseName = "exercise_name"
            case adjustment
            case reason
        }
    }

    public struct ProgressionPacing: Codable, Equatable, Sendable {
        public let weekNumber: Int
        public let adjustment: String
        public let reason: String

        public init(weekNumber: Int, adjustment: String, reason: String) {
            self.weekNumber = weekNumber
            self.adjustment = adjustment
            self.reason = reason
        }

        enum CodingKeys: String, CodingKey {
            case weekNumber = "week_number"
            case adjustment
            case reason
        }
    }
}

/// Réponse de l'Edge Function en cas de succès (HTTP 200). Le patch est dans
/// `patch`, les compteurs quota dans `quota`, méta technique dans `meta`.
public struct AdaptRareResponse: Codable, Equatable, Sendable {
    public let patch: AdaptationPatch
    public let quota: QuotaInfo
    public let meta: Meta?

    public struct QuotaInfo: Codable, Equatable, Sendable {
        public let used: Int
        public let limit: Int            // -1 si plus/pro (illimité)
        public let resetsAt: Date
        public let tier: String          // "free" | "plus" | "pro"

        enum CodingKeys: String, CodingKey {
            case used
            case limit
            case resetsAt = "resets_at"
            case tier
        }
    }

    public struct Meta: Codable, Equatable, Sendable {
        public let model: String
        public let promptVersion: String
        public let durationMs: Int

        enum CodingKeys: String, CodingKey {
            case model
            case promptVersion = "prompt_version"
            case durationMs = "duration_ms"
        }
    }
}

/// Erreurs possibles côté client. Mappées depuis le payload JSON `error.code`
/// retourné par l'Edge Function (cf types.ts `LeonErrorResponse`).
public enum LeonError: Error, Equatable {
    /// Quota free tier 10/j cumulé dépassé. `resetsAt` indique le prochain reset.
    case quotaExceeded(resetsAt: Date?)
    /// Anthropic API down ou erreur 5xx.
    case anthropicUnavailable
    /// Léon a renvoyé un JSON malformé ou contenant un mot banni MDR.
    case invalidPatch
    /// Authentification manquante / JWT invalide.
    case unauthorized
    /// Body de requête invalide (mode non supporté, JSON cassé).
    case invalidRequest(String)
    /// Erreur réseau ou autre erreur transport.
    case network(String)
    /// HTTP 5xx générique non identifiable.
    case server(Int)
}

/// Raison du fallback Léon — passée dans le payload `triggered_reason`.
public enum AdaptRareReason: String, Codable, Sendable {
    case atypicalConstraints = "atypical_constraints"
    case freetextRequest = "freetext_request"
    case userExplicit = "user_explicit"
}
