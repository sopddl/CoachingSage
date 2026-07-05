// CoachingSageTests/DurationScaling/SessionDurationAdjustmentServiceTests.swift
// Chantier durée réglable, pilote cycling (Increment 3) — filet du pont persistance
// `DefaultSessionDurationAdjustmentService` (doctrine section 8, Inc.3) : id de session
// préservé après ajustement (non-régression `ProgramCompletionState`), séance déjà
// complétée bloque l'ajustement (doctrine 9.3), séance non annotée rejetée proprement.
import XCTest
import SwiftData
import TemplateModel

@MainActor
final class SessionDurationAdjustmentServiceTests: XCTestCase {
    private var repo: MockAdaptedProgramRepository!
    private var service: DefaultSessionDurationAdjustmentService!
    /// **Dette SwiftData test_host hang (2026-05-22)** — `AdaptedProgramRecord` est un
    /// `@Model` : sa seule construction exige un `ModelContainer` actif quelque part dans
    /// le process (sinon crash "failed to find a currently active container"), même si
    /// `MockAdaptedProgramRepository` ne le persiste jamais réellement. Le container DOIT
    /// être retenu en property (cf `lessons_unit_tests_logic_mode`), sinon désalloué avant
    /// usage.
    private var container: ModelContainer!

    override func setUp() async throws {
        try await super.setUp()
        container = try ModelContainer(
            for: AdaptedProgramRecord.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        repo = MockAdaptedProgramRepository()
        service = DefaultSessionDurationAdjustmentService(adaptedProgramRepository: repo)
    }

    // MARK: - Happy path

    func testAdjustDuration_persistsRescaledSession_idPreserved() async throws {
        let core = makeExercise(estimatedMinutes: 45, role: .core, scalingUnit: .continuous)
        let target = makeSession(weekNumber: 1, day: 2, exercises: [core], durationMinutes: 60)
        let other = makeSession(weekNumber: 1, day: 5, exercises: [], durationMinutes: 30)
        let record = makeRecord(sessions: [target, other], level: "beginner")
        repo.stubbedActive = [record]

        let result = try await service.adjustDuration(
            programId: record.id, weekNumber: 1, day: 2, targetMinutes: 50
        )

        XCTAssertEqual(result.session.id, target.id, "Doctrine D-T2 : id préservé (ProgramCompletionState reste valide)")
        XCTAssertFalse(result.wasBounded)
        XCTAssertEqual(result.session.durationMinutes, 50)

        let updated = try XCTUnwrap(repo.updatedRecords.last)
        let persisted = try XCTUnwrap(updated.sessions.first { $0.id == target.id })
        XCTAssertEqual(persisted.durationMinutes, 50, "La mutation doit être persistée via update()")
        // La 2ᵉ séance du programme reste inchangée (remplacement en place, pas un rebuild).
        XCTAssertEqual(updated.sessions.first { $0.id == other.id }?.durationMinutes, 30)
    }

    // MARK: - Garde-fous

    func testAdjustDuration_throwsWhenProgramNotFound() async {
        do {
            _ = try await service.adjustDuration(programId: UUID(), weekNumber: 1, day: 1, targetMinutes: 30)
            XCTFail("Devrait throw")
        } catch SessionDurationAdjustmentError.programNotFound {
            // OK
        } catch {
            XCTFail("Mauvaise erreur : \(error)")
        }
    }

    func testAdjustDuration_throwsWhenSessionNotFound() async {
        let record = makeRecord(sessions: [makeSession(weekNumber: 1, day: 1, exercises: [], durationMinutes: 30)], level: "beginner")
        repo.stubbedActive = [record]

        do {
            _ = try await service.adjustDuration(programId: record.id, weekNumber: 2, day: 1, targetMinutes: 30)
            XCTFail("Devrait throw")
        } catch SessionDurationAdjustmentError.sessionNotFound {
            // OK
        } catch {
            XCTFail("Mauvaise erreur : \(error)")
        }
    }

    func testAdjustDuration_throwsWhenSessionAlreadyCompleted() async {
        // Doctrine section 9.3 — garde-fou service EN PLUS du gate UI (masquage bouton).
        let core = makeExercise(estimatedMinutes: 45, role: .core, scalingUnit: .continuous)
        let target = makeSession(weekNumber: 1, day: 1, exercises: [core], durationMinutes: 60)
        let record = makeRecord(sessions: [target], level: "beginner")
        record.completionState = ProgramCompletionState(sessionRecords: [target.id: SessionCompletionRecord(completedAt: Date())])
        repo.stubbedActive = [record]

        do {
            _ = try await service.adjustDuration(programId: record.id, weekNumber: 1, day: 1, targetMinutes: 30)
            XCTFail("Devrait throw")
        } catch SessionDurationAdjustmentError.sessionAlreadyCompleted {
            // OK
        } catch {
            XCTFail("Mauvaise erreur : \(error)")
        }
        XCTAssertTrue(repo.updatedRecords.isEmpty, "Aucune mutation ne doit être persistée")
    }

    func testAdjustDuration_throwsWhenSessionNotAdjustable() async {
        // Pas annoté (hors V1 cycling, ou overlay synthétique) : role/scalingUnit nil.
        let notAnnotated = AdaptedExercise(name: "Exo", originalName: "Exo", estimatedMinutes: 30)
        let target = makeSession(weekNumber: 1, day: 1, exercises: [notAnnotated], durationMinutes: 45, warmupMinutes: nil, cooldownMinutes: nil)
        let record = makeRecord(sessions: [target], level: "beginner")
        repo.stubbedActive = [record]

        do {
            _ = try await service.adjustDuration(programId: record.id, weekNumber: 1, day: 1, targetMinutes: 30)
            XCTFail("Devrait throw")
        } catch SessionDurationAdjustmentError.notAdjustable {
            // OK
        } catch {
            XCTFail("Mauvaise erreur : \(error)")
        }
        XCTAssertTrue(repo.updatedRecords.isEmpty)
    }

    // MARK: - Helpers

    private func makeExercise(
        estimatedMinutes: Int?, role: BlockRole, scalingUnit: ScalingUnit
    ) -> AdaptedExercise {
        AdaptedExercise(
            name: LocalizedText(fr: "Exo"), originalName: "Exo",
            role: role, scalingUnit: scalingUnit, estimatedMinutes: estimatedMinutes
        )
    }

    private func makeSession(
        weekNumber: Int, day: Int, exercises: [AdaptedExercise], durationMinutes: Int,
        warmupMinutes: Int? = 10, cooldownMinutes: Int? = 5
    ) -> PersistedSession {
        PersistedSession(
            weekNumber: weekNumber,
            weekTheme: "Semaine \(weekNumber)",
            weekGoal: "Goal",
            day: day,
            name: "S\(weekNumber)D\(day)",
            durationMinutes: durationMinutes,
            type: .endurance,
            warmup: "Échauffement",
            exercises: exercises,
            cooldown: "Retour au calme",
            warmupMinutes: warmupMinutes,
            cooldownMinutes: cooldownMinutes
        )
    }

    private func makeRecord(sessions: [PersistedSession], level: String) -> AdaptedProgramRecord {
        AdaptedProgramRecord(
            userId: UUID(),
            sportCode: "cycling",
            level: level,
            templateId: "test",
            adaptedAt: Date(),
            weekStartDate: Date(timeIntervalSinceNow: -7 * 86_400),
            mode: .planned,
            sessions: sessions,
            durationMode: .routineCyclic
        )
    }
}
