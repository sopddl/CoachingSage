// CoachingSageTests/Coaching/Regen/ExerciseLevelServiceTests.swift
// Chantier charge muscu V2 — TRANCHE 5b. Service apprentissage câblé au repository.
import XCTest
import TemplateModel
@testable import CoachingSage

@MainActor
final class ExerciseLevelServiceTests: XCTestCase {

    private func makeRecord(level: String = "recreational") -> AdaptedProgramRecord {
        AdaptedProgramRecord(
            userId: UUID(),
            sportCode: "strengthTraining",
            level: level,
            templateId: "t",
            adaptedAt: Date(),
            sessions: []
        )
    }

    func test_firstFeedback_usesInitialLevel() async throws {
        let repo = MockAdaptedProgramRepository()
        let rec = makeRecord(level: "recreational") // initial = 3
        repo.stubbedActive.append(rec)
        let svc = ExerciseLevelService(repository: repo)
        let out = try await svc.recordFeedback(recordId: rec.id, exerciseKey: "squat", feedback: .easy)
        XCTAssertEqual(out?.level, 3)            // 1er « facile » ne monte pas
        XCTAssertEqual(out?.consecutiveEasy, 1)
    }

    func test_twoEasy_bumps_andPersists() async throws {
        let repo = MockAdaptedProgramRepository()
        let rec = makeRecord()
        repo.stubbedActive.append(rec)
        let svc = ExerciseLevelService(repository: repo)
        _ = try await svc.recordFeedback(recordId: rec.id, exerciseKey: "squat", feedback: .easy)
        let out = try await svc.recordFeedback(recordId: rec.id, exerciseKey: "squat", feedback: .easy)
        XCTAssertEqual(out?.level, 4)
        let persisted = try await svc.currentLevel(recordId: rec.id, exerciseKey: "squat")
        XCTAssertEqual(persisted?.level, 4)
        XCTAssertFalse(repo.updatedRecords.isEmpty)
    }

    func test_tooHard_drops_fromInitial() async throws {
        let repo = MockAdaptedProgramRepository()
        let rec = makeRecord(level: "competitive") // initial = 4
        repo.stubbedActive.append(rec)
        let svc = ExerciseLevelService(repository: repo)
        let out = try await svc.recordFeedback(recordId: rec.id, exerciseKey: "bench", feedback: .tooHard)
        XCTAssertEqual(out?.level, 3)
    }

    func test_medicalClearance_bridesBump() async throws {
        let repo = MockAdaptedProgramRepository()
        let rec = makeRecord()
        repo.stubbedActive.append(rec)
        let svc = ExerciseLevelService(repository: repo)
        _ = try await svc.recordFeedback(recordId: rec.id, exerciseKey: "squat", feedback: .easy, requiresMedicalClearance: true)
        let out = try await svc.recordFeedback(recordId: rec.id, exerciseKey: "squat", feedback: .easy, requiresMedicalClearance: true)
        XCTAssertEqual(out?.level, 3) // hausse bridée malgré 2× facile
    }

    func test_unknownRecord_returnsNil() async throws {
        let repo = MockAdaptedProgramRepository()
        let svc = ExerciseLevelService(repository: repo)
        let out = try await svc.recordFeedback(recordId: UUID(), exerciseKey: "x", feedback: .easy)
        XCTAssertNil(out)
    }
}
