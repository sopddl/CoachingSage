// CoachingSageTests/Factory/AutoProgramFactoryTests.swift
// V2 chantier #6 — tests pour la fabrique de programme pré-rempli (tap
// suggestion empty mode dashboard).
import XCTest
import TemplateModel

@MainActor
final class AutoProgramFactoryTests: XCTestCase {

    // MARK: - makeDefaultSportProfile

    /// Defaults appliqués : fréquence 3, durationMode routineCyclic, equipment/
    /// constraints vides (équipement vient du global onboarding), questionnaire
    /// version `auto_v1` (marque "généré sans questionnaire").
    func testMakeDefaultSportProfileAppliesExpectedDefaults() {
        let userId = UUID()
        let profile = AutoProgramFactory.makeDefaultSportProfile(
            userId: userId,
            sportCode: "running",
            autoprofileLevel: nil,
            medicalClearanceAcknowledged: false
        )

        XCTAssertEqual(profile.userId, userId)
        XCTAssertEqual(profile.sportCode, "running")
        XCTAssertEqual(profile.frequencyPerWeek, 3)
        XCTAssertEqual(profile.frequencyLabel, "3")
        XCTAssertEqual(profile.durationMode, .routineCyclic)
        XCTAssertNil(profile.targetDate)
        XCTAssertTrue(profile.equipment.isEmpty)
        XCTAssertTrue(profile.constraints.isEmpty)
        XCTAssertNil(profile.sessionDurationMinutes)
        XCTAssertNil(profile.freeTextNotes)
        XCTAssertEqual(profile.questionnaireVersion, "auto_v1")
        XCTAssertFalse(profile.medicalClearanceAcknowledged)
    }

    /// Sans autoprofile HK, level fallback = "recreational" (mid-range plutôt
    /// que "beginner" — évite de matcher un template débutant pur pour un user
    /// qui n'a pas qualifié son niveau).
    func testLevelFallbacksToRecreationalWhenNoAutoprofile() {
        let profile = AutoProgramFactory.makeDefaultSportProfile(
            userId: UUID(),
            sportCode: "yoga",
            autoprofileLevel: nil,
            medicalClearanceAcknowledged: false
        )
        XCTAssertEqual(profile.level, "recreational")
    }

    /// Quand l'autoprofile fournit un level, il prime sur le fallback.
    func testLevelUsesAutoprofileWhenProvided() {
        let profile = AutoProgramFactory.makeDefaultSportProfile(
            userId: UUID(),
            sportCode: "running",
            autoprofileLevel: "competitive",
            medicalClearanceAcknowledged: false
        )
        XCTAssertEqual(profile.level, "competitive")
    }

    /// Goal = premier goal du sport tel que défini dans `UniversalQuestionnaire.defaultGoal`.
    /// Vérifie 3 sports représentatifs (running = "wellness", strengthTraining =
    /// "home-basics", yoga = "initiation").
    func testGoalIsFirstGoalForSport() {
        let runningProfile = AutoProgramFactory.makeDefaultSportProfile(
            userId: UUID(), sportCode: "running", autoprofileLevel: nil, medicalClearanceAcknowledged: false
        )
        XCTAssertEqual(runningProfile.goals.primary, "wellness")

        let strengthProfile = AutoProgramFactory.makeDefaultSportProfile(
            userId: UUID(), sportCode: "strengthTraining", autoprofileLevel: nil, medicalClearanceAcknowledged: false
        )
        XCTAssertEqual(strengthProfile.goals.primary, "home-basics")

        let yogaProfile = AutoProgramFactory.makeDefaultSportProfile(
            userId: UUID(), sportCode: "yoga", autoprofileLevel: nil, medicalClearanceAcknowledged: false
        )
        XCTAssertEqual(yogaProfile.goals.primary, "initiation")
    }

    /// `medicalClearanceAcknowledged` propagé tel quel depuis l'arg (vient du
    /// CoachingProfile.requiresMedicalClearance côté factory.generate).
    func testMedicalClearanceFlagPropagated() {
        let profileTrue = AutoProgramFactory.makeDefaultSportProfile(
            userId: UUID(), sportCode: "running", autoprofileLevel: nil, medicalClearanceAcknowledged: true
        )
        XCTAssertTrue(profileTrue.medicalClearanceAcknowledged)

        let profileFalse = AutoProgramFactory.makeDefaultSportProfile(
            userId: UUID(), sportCode: "running", autoprofileLevel: nil, medicalClearanceAcknowledged: false
        )
        XCTAssertFalse(profileFalse.medicalClearanceAcknowledged)
    }

    // MARK: - generate (end-to-end avec mocks)

    /// Hot path complet : factory.generate retourne un AdaptedProgram + recordId,
    /// persiste CoachingSportProfile + AdaptedProgramRecord via les repos.
    func testGenerateEndToEndPersistsBothProfilesAndProgram() async throws {
        let coachingProfile = CoachingProfile(id: UUID())
        let sportRepo = MockCoachingSportProfileRepository()
        let programRepo = MockAdaptedProgramRepository()
        let coachingRepo = MockCoachingProfileRepository()
        coachingRepo.stubbedProfile = coachingProfile

        let factory = AutoProgramFactory(
            sportProfileRepository: sportRepo,
            adaptedProgramRepository: programRepo,
            coachingProfileRepository: coachingRepo,
            templateLibraryProvider: { ProgramTemplateLibrary(templates: [AdapterTestFixtures.makeRunningTemplate()]) }
        )

        let userId = UUID()
        let result = try await factory.generate(
            sportCode: "running",
            userId: userId,
            autoprofileLevel: "recreational"
        )

        XCTAssertEqual(sportRepo.saveCallCount, 1)
        XCTAssertEqual(programRepo.savedRecords.count, 1)
        XCTAssertEqual(result.sportProfile.sportCode, "running")
        XCTAssertEqual(result.sportProfile.level, "recreational")
        XCTAssertEqual(result.recordId, programRepo.savedRecords.first?.id)
        // routineCyclic force 12 semaines (cycle depuis week 1 du template) — le
        // fixture a 2 weeks, le resolver les cycle pour atteindre 12.
        XCTAssertEqual(result.program.durationMode, .routineCyclic)
        XCTAssertEqual(result.program.weeks.count, 12)
    }

    /// Si CoachingProfile manquant (user pas passé par l'onboarding), la
    /// fabrique throw `coachingProfileMissing` plutôt que de produire un
    /// programme avec des valeurs sentinelles.
    func testGenerateThrowsWhenCoachingProfileMissing() async {
        let sportRepo = MockCoachingSportProfileRepository()
        let programRepo = MockAdaptedProgramRepository()
        let coachingRepo = MockCoachingProfileRepository()
        // stubbedProfile reste nil

        let factory = AutoProgramFactory(
            sportProfileRepository: sportRepo,
            adaptedProgramRepository: programRepo,
            coachingProfileRepository: coachingRepo,
            templateLibraryProvider: { ProgramTemplateLibrary(templates: [AdapterTestFixtures.makeRunningTemplate()]) }
        )

        do {
            _ = try await factory.generate(sportCode: "running", userId: UUID(), autoprofileLevel: nil)
            XCTFail("Expected coachingProfileMissing to be thrown")
        } catch AutoProgramFactoryError.coachingProfileMissing {
            // Expected
        } catch {
            XCTFail("Expected AutoProgramFactoryError.coachingProfileMissing, got \(error)")
        }
        XCTAssertEqual(sportRepo.saveCallCount, 0, "Pas de save sport profile si coaching profile manque")
        XCTAssertEqual(programRepo.savedRecords.count, 0)
    }

    // MARK: - Story sœur 3.z — previewGenerate + commit (no auto-commit on tap)

    /// `previewGenerate` ne persiste NI le sport profile NI le record. Retourne
    /// l'AdaptedProgram + sportProfile in-memory pour l'écran preview.
    func testPreviewGenerateDoesNotPersist() async throws {
        let sportRepo = MockCoachingSportProfileRepository()
        let programRepo = MockAdaptedProgramRepository()
        let coachingRepo = MockCoachingProfileRepository()
        coachingRepo.stubbedProfile = CoachingProfile(id: UUID())

        let factory = AutoProgramFactory(
            sportProfileRepository: sportRepo,
            adaptedProgramRepository: programRepo,
            coachingProfileRepository: coachingRepo,
            templateLibraryProvider: { ProgramTemplateLibrary(templates: [AdapterTestFixtures.makeRunningTemplate()]) }
        )

        let preview = try await factory.previewGenerate(
            sportCode: "running",
            userId: UUID(),
            autoprofileLevel: "recreational"
        )

        XCTAssertEqual(sportRepo.saveCallCount, 0, "previewGenerate ne doit pas persister le sport profile")
        XCTAssertEqual(programRepo.savedRecords.count, 0, "previewGenerate ne doit pas persister le record")
        XCTAssertEqual(preview.sportProfile.sportCode, "running")
        XCTAssertEqual(preview.sportProfile.level, "recreational")
        XCTAssertEqual(preview.program.weeks.count, 12) // routineCyclic = 12 sem
    }

    /// `commit(preview:userId:)` persiste sport profile + record. Retourne le
    /// recordId persisté. C'est l'action déclenchée par "Démarrer ce programme"
    /// depuis l'écran preview.
    func testCommitPersistsSportProfileAndProgram() async throws {
        let sportRepo = MockCoachingSportProfileRepository()
        let programRepo = MockAdaptedProgramRepository()
        let coachingRepo = MockCoachingProfileRepository()
        coachingRepo.stubbedProfile = CoachingProfile(id: UUID())

        let factory = AutoProgramFactory(
            sportProfileRepository: sportRepo,
            adaptedProgramRepository: programRepo,
            coachingProfileRepository: coachingRepo,
            templateLibraryProvider: { ProgramTemplateLibrary(templates: [AdapterTestFixtures.makeRunningTemplate()]) }
        )

        let userId = UUID()
        let preview = try await factory.previewGenerate(
            sportCode: "running",
            userId: userId,
            autoprofileLevel: "recreational"
        )
        XCTAssertEqual(sportRepo.saveCallCount, 0)
        XCTAssertEqual(programRepo.savedRecords.count, 0)

        let recordId = try await factory.commit(preview: preview, userId: userId)

        XCTAssertEqual(sportRepo.saveCallCount, 1)
        XCTAssertEqual(programRepo.savedRecords.count, 1)
        XCTAssertEqual(programRepo.savedRecords.first?.id, recordId)
        XCTAssertEqual(programRepo.savedRecords.first?.userId, userId)
    }

    /// `previewGenerate` throw `coachingProfileMissing` si pré-requis manquant —
    /// le caller doit tomber sur le questionnaire au lieu de pousser un écran
    /// preview avec des données sentinelles.
    func testPreviewGenerateThrowsWhenCoachingProfileMissing() async {
        let sportRepo = MockCoachingSportProfileRepository()
        let programRepo = MockAdaptedProgramRepository()
        let coachingRepo = MockCoachingProfileRepository()
        // stubbedProfile reste nil
        let factory = AutoProgramFactory(
            sportProfileRepository: sportRepo,
            adaptedProgramRepository: programRepo,
            coachingProfileRepository: coachingRepo,
            templateLibraryProvider: { ProgramTemplateLibrary(templates: [AdapterTestFixtures.makeRunningTemplate()]) }
        )

        do {
            _ = try await factory.previewGenerate(sportCode: "running", userId: UUID(), autoprofileLevel: nil)
            XCTFail("Expected coachingProfileMissing to be thrown")
        } catch AutoProgramFactoryError.coachingProfileMissing {
            // Expected
        } catch {
            XCTFail("Expected AutoProgramFactoryError.coachingProfileMissing, got \(error)")
        }
        XCTAssertEqual(sportRepo.saveCallCount, 0)
        XCTAssertEqual(programRepo.savedRecords.count, 0)
    }

    // MARK: - Story 3.13 Phase D — propagation secondary

    /// `commit(preview:userId:)` propage `goals.secondary` jusqu'au record persisté
    /// via le titre composite. Vérifie ici qu'un sportProfile multi-objectifs
    /// produit bien un customTitle composite (présence du séparateur ' + ').
    func testCommitPropagatesSecondaryIntoCustomTitle() async throws {
        let sportRepo = MockCoachingSportProfileRepository()
        let programRepo = MockAdaptedProgramRepository()
        let coachingRepo = MockCoachingProfileRepository()
        coachingRepo.stubbedProfile = CoachingProfile(id: UUID())

        let factory = AutoProgramFactory(
            sportProfileRepository: sportRepo,
            adaptedProgramRepository: programRepo,
            coachingProfileRepository: coachingRepo,
            templateLibraryProvider: { ProgramTemplateLibrary(templates: [AdapterTestFixtures.makeRunningTemplate()]) }
        )

        // Override le sportProfile pour injecter un secondary valide pour running.
        var preview = try await factory.previewGenerate(
            sportCode: "running", userId: UUID(), autoprofileLevel: "recreational"
        )
        preview = AutoProgramPreview(
            program: preview.program,
            sportProfile: CoachingSportProfile(
                userId: preview.sportProfile.userId,
                sportCode: "running",
                level: preview.sportProfile.level,
                goals: GoalsPayload(primary: "10k", secondary: ["wellness"]),
                equipment: [],
                constraints: [],
                frequencyPerWeek: 3,
                frequencyLabel: "3",
                sessionDurationMinutes: nil,
                freeTextNotes: nil,
                conversationHistory: [],
                medicalClearanceAcknowledged: false,
                questionnaireVersion: "auto_v1",
                durationMode: .routineCyclic,
                targetDate: nil
            )
        )

        _ = try await factory.commit(preview: preview, userId: preview.sportProfile.userId)

        let saved = try XCTUnwrap(programRepo.savedRecords.first)
        let customTitle = try XCTUnwrap(saved.customTitle, "customTitle doit être posé via AutoTitleBuilder")
        XCTAssertTrue(customTitle.contains(" + "),
                      "customTitle doit contenir séparateur ' + ' pour secondary non vide : '\(customTitle)'")
    }

    /// Cas secondary vide → titre composite NON appliqué (format Story 3.12 préservé).
    func testCommitWithEmptySecondaryKeepsSimpleTitle() async throws {
        let sportRepo = MockCoachingSportProfileRepository()
        let programRepo = MockAdaptedProgramRepository()
        let coachingRepo = MockCoachingProfileRepository()
        coachingRepo.stubbedProfile = CoachingProfile(id: UUID())

        let factory = AutoProgramFactory(
            sportProfileRepository: sportRepo,
            adaptedProgramRepository: programRepo,
            coachingProfileRepository: coachingRepo,
            templateLibraryProvider: { ProgramTemplateLibrary(templates: [AdapterTestFixtures.makeRunningTemplate()]) }
        )

        let preview = try await factory.previewGenerate(
            sportCode: "running", userId: UUID(), autoprofileLevel: "recreational"
        )
        // Profile par défaut a goals.secondary = [].
        XCTAssertTrue(preview.sportProfile.goals.secondary.isEmpty)

        _ = try await factory.commit(preview: preview, userId: preview.sportProfile.userId)

        let saved = try XCTUnwrap(programRepo.savedRecords.first)
        let customTitle = try XCTUnwrap(saved.customTitle)
        XCTAssertFalse(customTitle.contains(" + "),
                       "Empty secondary doit produire titre simple sans ' + '")
    }

    /// `medicalClearanceAcknowledged` est snapshot depuis `coachingProfile.requiresMedicalClearance`
    /// au moment de la génération (cf review P0-6 Story 3.1).
    func testGenerateSnapshotsRequiresMedicalClearance() async throws {
        let coachingProfile = CoachingProfile(id: UUID())
        coachingProfile.requiresMedicalClearance = true

        let coachingRepo = MockCoachingProfileRepository()
        coachingRepo.stubbedProfile = coachingProfile

        let factory = AutoProgramFactory(
            sportProfileRepository: MockCoachingSportProfileRepository(),
            adaptedProgramRepository: MockAdaptedProgramRepository(),
            coachingProfileRepository: coachingRepo,
            templateLibraryProvider: { ProgramTemplateLibrary(templates: [AdapterTestFixtures.makeRunningTemplate()]) }
        )

        let result = try await factory.generate(sportCode: "running", userId: UUID(), autoprofileLevel: nil)
        XCTAssertTrue(result.sportProfile.medicalClearanceAcknowledged)
    }
}
