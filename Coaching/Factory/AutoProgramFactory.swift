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
        guard let coachingProfile = try await coachingProfileRepository.fetchCurrentProfile() else {
            throw AutoProgramFactoryError.coachingProfileMissing
        }

        let sportProfile = Self.makeDefaultSportProfile(
            userId: userId,
            sportCode: sportCode,
            autoprofileLevel: autoprofileLevel,
            medicalClearanceAcknowledged: coachingProfile.requiresMedicalClearance
        )

        try await sportProfileRepository.save(sportProfile)

        let library = try await templateLibraryProvider()
        let selector = ProgramTemplateSelector(library: library)
        let template = selector.select(profile: sportProfile)

        let adapted = adapterService.adapt(
            template: template,
            sportProfile: sportProfile,
            coachingProfile: coachingProfile
        )

        let record = AdaptedProgramRecord(from: adapted, userId: userId)
        try await adaptedProgramRepository.save(record)

        return AutoProgramResult(program: adapted, recordId: record.id, sportProfile: sportProfile)
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
