// CoachingSageTests/Coaching/Session/ExerciseWeightServiceTests.swift
// Chantier charge muscu V2 — increment 2 (décision B). Service de persistance du poids
// noté, câblé au repository (fetchById + update). Vérifie : enregistrement + persistance,
// effacement quand ramené à 0 (jamais « 0 kg »), record absent = no-op.
import XCTest

@MainActor
final class ExerciseWeightServiceTests: XCTestCase {

    private func makeRecord() -> AdaptedProgramRecord {
        AdaptedProgramRecord(
            userId: UUID(),
            sportCode: "strengthTraining",
            level: "recreational",
            templateId: "t",
            adaptedAt: Date(),
            sessions: []
        )
    }

    func test_recordWeight_persists() async throws {
        let repo = MockAdaptedProgramRepository()
        let rec = makeRecord()
        repo.stubbedActive.append(rec)
        let svc = ExerciseWeightService(repository: repo)

        try await svc.recordWeight(recordId: rec.id, exerciseKey: "Goblet squat", kg: 22.5)

        let persisted = try await svc.currentWeights(recordId: rec.id)
        XCTAssertEqual(persisted?.weight(for: "Goblet squat"), 22.5)
        XCTAssertFalse(repo.updatedRecords.isEmpty)
    }

    func test_recordWeight_zeroOrNil_clearsEntry() async throws {
        let repo = MockAdaptedProgramRepository()
        let rec = makeRecord()
        repo.stubbedActive.append(rec)
        let svc = ExerciseWeightService(repository: repo)

        try await svc.recordWeight(recordId: rec.id, exerciseKey: "Goblet squat", kg: 22.5)
        try await svc.recordWeight(recordId: rec.id, exerciseKey: "Goblet squat", kg: 0)
        let afterZero = try await svc.currentWeights(recordId: rec.id)?.weight(for: "Goblet squat")
        XCTAssertNil(afterZero)

        try await svc.recordWeight(recordId: rec.id, exerciseKey: "Goblet squat", kg: 30)
        try await svc.recordWeight(recordId: rec.id, exerciseKey: "Goblet squat", kg: nil)
        let afterNil = try await svc.currentWeights(recordId: rec.id)?.weight(for: "Goblet squat")
        XCTAssertNil(afterNil)
    }

    func test_unknownRecord_isNoOp() async throws {
        let repo = MockAdaptedProgramRepository()
        let svc = ExerciseWeightService(repository: repo)
        try await svc.recordWeight(recordId: UUID(), exerciseKey: "x", kg: 20)
        XCTAssertTrue(repo.updatedRecords.isEmpty)
        let weights = try await svc.currentWeights(recordId: UUID())
        XCTAssertNil(weights)
    }
}
