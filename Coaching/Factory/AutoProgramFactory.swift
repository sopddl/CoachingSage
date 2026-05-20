// Coaching/Factory/AutoProgramFactory.swift
// V2 chantier #6 — génère un AdaptedProgram pour un sport donné en SKIPPANT le
// questionnaire. Utilisé sur le hot path "tap suggestion mode vide" (dashboard
// Séances). Defaults sensibles : level autoprofil HK (ou recreational en
// fallback), premier goal du sport, fréquence 3, équipement onboarding global,
// durationMode `.routineCyclic` (12 sem cyclique, pas de date cible).
//
// Persiste à la fois `CoachingSportProfile` (pour que les visites ultérieures
// passent par `presentAdaptedProgram` existant au lieu de re-générer) et
// `AdaptedProgramRecord` (pour le dashboard).
//
// Sémantique : la fabrique ne tente PAS de vérifier l'existence d'un profil
// pour ce sport — c'est au caller de décider (ex : SessionView fait fetchProfile
// → si exist alors presentAdaptedProgram normal, sinon AutoProgramFactory).
import Foundation
import TemplateModel

@MainActor
final class AutoProgramFactory {
    private let adapterService: ProgramAdapterService
    private let sportProfileRepository: any CoachingSportProfileRepository
    private let adaptedProgramRepository: any AdaptedProgramRepository
    private let coachingProfileRepository: any CoachingProfileRepository
    private let templateLibraryProvider: () async throws -> ProgramTemplateLibrary

    init(
        adapterService: ProgramAdapterService? = nil,
        sportProfileRepository: any CoachingSportProfileRepository,
        adaptedProgramRepository: any AdaptedProgramRepository,
        coachingProfileRepository: any CoachingProfileRepository,
        templateLibraryProvider: @escaping () async throws -> ProgramTemplateLibrary = ProgramTemplateLibrary.bundled
    ) {
        self.adapterService = adapterService ?? ProgramAdapterService()
        self.sportProfileRepository = sportProfileRepository
        self.adaptedProgramRepository = adaptedProgramRepository
        self.coachingProfileRepository = coachingProfileRepository
        self.templateLibraryProvider = templateLibraryProvider
    }

    /// Génère et persiste un AdaptedProgram avec les defaults V2. Retourne le
    /// programme + le recordId persisté pour navigation.
    func generate(
        sportCode: String,
        userId: UUID,
        autoprofileLevel: String? = nil
    ) async throws -> AutoProgramResult {
        let preview = try await previewGenerate(
            sportCode: sportCode,
            userId: userId,
            autoprofileLevel: autoprofileLevel
        )
        let recordId = try await commit(preview: preview, userId: userId)
        return AutoProgramResult(program: preview.program, recordId: recordId, sportProfile: preview.sportProfile)
    }

    /// Story 3.15 AC12bis — variant "preview" avec **template + sportProfile
    /// injectés** : skip la sélection interne (`selector.select`) pour
    /// permettre au `DormantBootstrapService` de générer N dormants à partir
    /// de templates choisis par `selectTopN`. Sans cette variante, la méthode
    /// existante `previewGenerate(sportCode:userId:autoprofileLevel:)` re-pick
    /// le template via la matrice `(sport, level)` → impossible de générer 3
    /// templates running de levels différents si `selectTopN` les retourne.
    ///
    /// `userId` est conservé pour symétrie + sanity check possible côté caller.
    func previewGenerate(
        template: ProgramTemplate,
        sportProfile: CoachingSportProfile,
        userId: UUID
    ) async throws -> AutoProgramPreview {
        guard let coachingProfile = try await coachingProfileRepository.fetchCurrentProfile() else {
            throw AutoProgramFactoryError.coachingProfileMissing
        }
        let adapted = adapterService.adapt(
            template: template,
            sportProfile: sportProfile,
            coachingProfile: coachingProfile
        )
        return AutoProgramPreview(program: adapted, sportProfile: sportProfile)
    }

    /// Story sœur 3.z (2026-05-17) — variant "preview" : adapte le programme en
    /// mémoire SANS persister (ni sportProfile ni AdaptedProgramRecord). Utilisé
    /// par le tap suggestion empty mode pour permettre à l'utilisateur de
    /// visualiser un programme avant de le démarrer. Conserve les 3 suggestions
    /// affichées tant qu'il ne confirme pas. La commit ultérieure se fait via
    /// `commit(preview:userId:)`.
    func previewGenerate(
        sportCode: String,
        userId: UUID,
        autoprofileLevel: String? = nil
    ) async throws -> AutoProgramPreview {
        guard let coachingProfile = try await coachingProfileRepository.fetchCurrentProfile() else {
            throw AutoProgramFactoryError.coachingProfileMissing
        }

        let sportProfile = Self.makeDefaultSportProfile(
            userId: userId,
            sportCode: sportCode,
            autoprofileLevel: autoprofileLevel,
            medicalClearanceAcknowledged: coachingProfile.requiresMedicalClearance
        )

        let library = try await templateLibraryProvider()
        let selector = ProgramTemplateSelector(library: library)
        let template = selector.select(profile: sportProfile)

        let adapted = adapterService.adapt(
            template: template,
            sportProfile: sportProfile,
            coachingProfile: coachingProfile
        )

        return AutoProgramPreview(program: adapted, sportProfile: sportProfile)
    }

    /// Story sœur 3.z (2026-05-17) — persiste la preview (sportProfile +
    /// AdaptedProgramRecord). Retourne le recordId pour navigation/dashboard.
    /// Appelée quand l'utilisateur confirme "Démarrer ce programme" depuis
    /// l'écran de preview.
    ///
    /// **Story 3.12** : `locale` permet de générer le `customTitle` auto dans
    /// la langue in-app courante (cf `LanguageManager.currentLocale`).
    func commit(
        preview: AutoProgramPreview,
        userId: UUID,
        locale: Locale = .current
    ) async throws -> UUID {
        try await sportProfileRepository.save(preview.sportProfile)
        let record = AdaptedProgramRecord(
            from: preview.program,
            userId: userId,
            goal: preview.sportProfile.goals.primary,
            secondary: preview.sportProfile.goals.secondary,
            locale: locale
        )
        try await adaptedProgramRepository.save(record)
        return record.id
    }

    /// Construit le `CoachingSportProfile` defaults sans aucune persistance.
    /// Exposé statique pour permettre les tests unit sans monter de repo.
    static func makeDefaultSportProfile(
        userId: UUID,
        sportCode: String,
        autoprofileLevel: String?,
        medicalClearanceAcknowledged: Bool
    ) -> CoachingSportProfile {
        // Fallback recreational > beginner : moins de chance de matcher un
        // template "débutant pur" (peu adapté à un user qui n'a pas qualifié
        // son niveau). Le selector retombera sur le niveau template le plus
        // proche si "recreational" n'existe pas pour ce sport.
        let level = autoprofileLevel ?? "recreational"
        let goal = UniversalQuestionnaire.defaultGoal(for: sportCode)

        return CoachingSportProfile(
            userId: userId,
            sportCode: sportCode,
            level: level,
            goals: GoalsPayload(primary: goal),
            equipment: [],
            constraints: [],
            frequencyPerWeek: 3,
            frequencyLabel: "3",
            sessionDurationMinutes: nil,
            freeTextNotes: nil,
            conversationHistory: [],
            medicalClearanceAcknowledged: medicalClearanceAcknowledged,
            questionnaireVersion: "auto_v1",
            durationMode: .routineCyclic,
            targetDate: nil
        )
    }
}

enum AutoProgramFactoryError: LocalizedError {
    case coachingProfileMissing

    var errorDescription: String? {
        switch self {
        case .coachingProfileMissing:
            return String(localized: "session.adapter.profileMissing")
        }
    }
}

struct AutoProgramResult {
    let program: AdaptedProgram
    let recordId: UUID
    let sportProfile: CoachingSportProfile
}

/// Story sœur 3.z (2026-05-17) — résultat in-memory d'`previewGenerate`. Pas
/// encore persisté. La commit se fait via `AutoProgramFactory.commit(preview:userId:)`
/// quand l'utilisateur valide "Démarrer ce programme" depuis l'écran preview.
struct AutoProgramPreview {
    let program: AdaptedProgram
    let sportProfile: CoachingSportProfile
}
