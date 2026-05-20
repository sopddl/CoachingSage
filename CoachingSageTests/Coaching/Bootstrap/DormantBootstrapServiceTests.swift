// CoachingSageTests/Coaching/Bootstrap/DormantBootstrapServiceTests.swift
// Story 3.15 AC22 — tests du DormantBootstrapService.
//
// Pattern : mocks de dépendances (CoachingProfile + AdaptedProgram + Sport
// profile repos) + AutoProgramFactory réel câblé sur les mêmes mocks. Pas de
// container SwiftData in-memory (cf `lessons_swiftdata_inmemory_test_hang.md`).
//
// Scénarios couverts (AC22) :
//   1. flag false + no programs → persiste 3 dormants, flag → true
//   2. flag true → no-op
//   3. programs already exist → no-op (flag flipped quand même)
//   4. library plus petite → partial bootstrap (N dormants ≤ 3)
//   5. dormantCap déjà atteint → no-op + flag flipped
//   6. ProgramCapReached.dormant pendant la boucle → break silently
//   7. pas de coaching profile → no-op (paranoid)
import XCTest
import TemplateModel
@testable import CoachingSage

@MainActor
final class DormantBootstrapServiceTests: XCTestCase {

    private let userId = UUID()

    // MARK: - AC22 — scénarios bootstrap

    /// **AC22 #1** — flag false + no programs → 3 dormants persistés, flag → true.
    func testBootstrap_FlagFalseAndNoPrograms_CreatesUpTo3Dormants() async {
        let env = makeEnv(includeProfile: true)
        let persisted = await env.service.bootstrapIfNeeded()
        XCTAssertEqual(persisted, 3, "Doit créer exactement 3 dormants quand 3 templates dispo")
        XCTAssertEqual(env.programRepo.savedRecords.count, 3)
        XCTAssertTrue(env.programRepo.savedRecords.allSatisfy { $0.weekStartDate == nil },
                      "Tous les records persistés doivent être dormants (weekStartDate == nil)")
        XCTAssertEqual(env.coachingRepo.stubbedProfile?.bootstrappedDormants, true,
                       "Le flag doit être flippé à true")
    }

    /// **AC22 #2** — flag déjà true → no-op (ni save, ni persist).
    func testSkip_WhenFlagAlreadyTrue() async {
        let env = makeEnv(includeProfile: true, profileBootstrapped: true)
        let persisted = await env.service.bootstrapIfNeeded()
        XCTAssertEqual(persisted, 0)
        XCTAssertTrue(env.programRepo.savedRecords.isEmpty)
    }

    /// **AC22 #3** — l'user a déjà des programmes → no-op + flag flipped (pour
    /// éviter retry au prochain launch).
    func testSkip_WhenProgramsAlreadyExist_FlagFlippedAnyway() async {
        let env = makeEnv(includeProfile: true, existingDormants: 2)
        let persisted = await env.service.bootstrapIfNeeded()
        XCTAssertEqual(persisted, 0, "Pas de génération quand l'user a déjà des programmes")
        XCTAssertEqual(env.programRepo.savedRecords.count, 0)
        XCTAssertEqual(env.coachingRepo.stubbedProfile?.bootstrappedDormants, true,
                       "Le flag doit être flippé même si on n'a rien persisté (idempotence)")
    }

    /// **AC22 #4** — library a moins de 3 templates → persiste ce qu'on a.
    func testPartialBootstrap_LibraryHasOneTemplate() async {
        let env = makeEnv(
            includeProfile: true,
            templates: [makeTemplate(id: "t1", sport: .running, level: .beginner)]
        )
        let persisted = await env.service.bootstrapIfNeeded()
        XCTAssertEqual(persisted, 1, "1 template dispo → 1 dormant persisté")
        XCTAssertEqual(env.programRepo.savedRecords.count, 1)
    }

    /// **AC22 #5** — cap dormant déjà atteint (10) → no-op + flag flipped.
    func testSkip_WhenDormantCapAlreadyReached() async {
        let env = makeEnv(includeProfile: true, existingDormants: 10)
        let persisted = await env.service.bootstrapIfNeeded()
        XCTAssertEqual(persisted, 0, "Cap atteint → 0 dormant créé")
        XCTAssertEqual(env.coachingRepo.stubbedProfile?.bootstrappedDormants, true)
    }

    /// **AC22 #6** — `ProgramCapReached.dormant` thrown pendant la boucle →
    /// break silencieusement, retourne le nombre persisté avant le throw.
    func testHandleProgramCapReachedSilentlyDuringLoop() async {
        let env = makeEnv(includeProfile: true)
        env.programRepo.saveShouldThrow = ProgramCapReached.dormant(limit: 10)
        let persisted = await env.service.bootstrapIfNeeded()
        XCTAssertEqual(persisted, 0,
                       "Aucune persistance ne doit aboutir si save throw cap dès la 1ère itération")
        XCTAssertEqual(env.coachingRepo.stubbedProfile?.bootstrappedDormants, true,
                       "Flag flippé (étape 3 set le flag AVANT la boucle)")
    }

    /// **AC22 #7** — pas de coaching profile → no-op (cas paranoid).
    func testSkip_WhenNoCoachingProfile() async {
        let env = makeEnv(includeProfile: false)
        let persisted = await env.service.bootstrapIfNeeded()
        XCTAssertEqual(persisted, 0)
    }

    // MARK: - Helpers

    private struct Env {
        let service: DormantBootstrapService
        let coachingRepo: MockCoachingProfileRepository
        let programRepo: MockAdaptedProgramRepository
        let sportRepo: MockCoachingSportProfileRepository
    }

    private func makeEnv(
        includeProfile: Bool,
        profileBootstrapped: Bool = false,
        existingDormants: Int = 0,
        existingStarted: Int = 0,
        templates: [ProgramTemplate]? = nil
    ) -> Env {
        let coachingRepo = MockCoachingProfileRepository()
        if includeProfile {
            let p = CoachingProfile(id: userId)
            p.activeSports = ["running"]
            p.bootstrappedDormants = profileBootstrapped
            coachingRepo.stubbedProfile = p
        } else {
            coachingRepo.stubbedProfile = nil
        }

        let programRepo = MockAdaptedProgramRepository()
        for _ in 0..<existingStarted {
            programRepo.stubbedActive.append(makeExistingRecord(weekStartDate: Date()))
        }
        for _ in 0..<existingDormants {
            programRepo.stubbedActive.append(makeExistingRecord(weekStartDate: nil))
        }

        let sportRepo = MockCoachingSportProfileRepository()
        let factory = AutoProgramFactory(
            sportProfileRepository: sportRepo,
            adaptedProgramRepository: programRepo,
            coachingProfileRepository: coachingRepo
        )
        let library = ProgramTemplateLibrary(templates: templates ?? defaultTemplates())
        let service = DormantBootstrapService(
            coachingProfileRepository: coachingRepo,
            adaptedProgramRepository: programRepo,
            factory: factory,
            templateLibraryProvider: { library },
            suggestionLevelProvider: { _ in "beginner" }
        )
        return Env(service: service, coachingRepo: coachingRepo,
                   programRepo: programRepo, sportRepo: sportRepo)
    }

    private func makeExistingRecord(weekStartDate: Date?) -> AdaptedProgramRecord {
        let session = PersistedSession(
            id: UUID(), weekNumber: 1, weekTheme: "W1", weekGoal: "G1", day: 1,
            name: "S1", durationMinutes: 30, type: .endurance,
            warmup: nil, exercises: [], cooldown: nil
        )
        return AdaptedProgramRecord(
            userId: userId,
            sportCode: "running",
            level: "beginner",
            templateId: "existing-\(UUID().uuidString.prefix(4))",
            adaptedAt: Date(),
            weekStartDate: weekStartDate,
            mode: .ondemand,
            sessions: [session]
        )
    }

    /// 3 templates running de niveaux différents → selectTopN(n: 3) en retourne 3.
    private func defaultTemplates() -> [ProgramTemplate] {
        return [
            makeTemplate(id: "run-beg", sport: .running, level: .beginner),
            makeTemplate(id: "run-rec", sport: .running, level: .recreational),
            makeTemplate(id: "run-com", sport: .running, level: .competitive)
        ]
    }

    private func makeTemplate(
        id: String,
        sport: Sport,
        level: Level
    ) -> ProgramTemplate {
        ProgramTemplate(
            id: id, schemaVersion: 1, sport: sport, level: level,
            name: id, durationWeeks: 4, sessionsPerWeek: 3,
            defaultObjective: "obj", assumedProfile: "ap", summary: "sum",
            weeks: [],
            safetyNotes: "n/a", progressionLogic: "n/a"
        )
    }
}
