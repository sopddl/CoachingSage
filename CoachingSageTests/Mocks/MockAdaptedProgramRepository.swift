// CoachingSageTests/Mocks/MockAdaptedProgramRepository.swift
// Story 3.8 — pattern MockCoachingProfileRepository.
import Foundation
@testable import CoachingSage

@MainActor
final class MockAdaptedProgramRepository: AdaptedProgramRepository {
    var stubbedActive: [AdaptedProgramRecord] = []
    var savedRecords: [AdaptedProgramRecord] = []
    var updatedRecords: [AdaptedProgramRecord] = []
    var archivedRecords: [AdaptedProgramRecord] = []
    var fetchShouldThrow: Bool = false
    var updateShouldThrow: Bool = false
    /// Story 3.4 Phase B.4 — closure synchrone invoquée à chaque `fetchActive`.
    /// Utilisée par les tests qui vérifient l'ordering avec un autre collaborateur
    /// (ex. `FakeWeeklyRegenApplicationService.onCheckAndApply` doit avoir tick
    /// avant ce callback).
    var onFetchActive: (@MainActor (UUID) -> Void)?
    private(set) var fetchActiveCallCount: Int = 0

    func fetchActive(for userId: UUID) async throws -> [AdaptedProgramRecord] {
        fetchActiveCallCount += 1
        onFetchActive?(userId)
        if fetchShouldThrow { throw URLError(.notConnectedToInternet) }
        return stubbedActive.filter { $0.userId == userId && $0.isActive }
    }

    /// **Story 3.10** — set par les tests AC32 cap dormant atteint pour forcer le
    /// throw `ProgramCapReached.dormant` sans monter un fixture à 10 dormants.
    var saveShouldThrow: Error?

    func save(_ record: AdaptedProgramRecord) async throws {
        if let saveShouldThrow { throw saveShouldThrow }
        savedRecords.append(record)
        stubbedActive.append(record)
    }

    func fetchStartedCount(for userId: UUID) async throws -> Int {
        if fetchShouldThrow { throw URLError(.notConnectedToInternet) }
        return stubbedActive
            .filter { $0.userId == userId && $0.isActive && $0.weekStartDate != nil }
            .count
    }

    func fetchDormantCount(for userId: UUID) async throws -> Int {
        if fetchShouldThrow { throw URLError(.notConnectedToInternet) }
        return stubbedActive
            .filter { $0.userId == userId && $0.isActive && $0.weekStartDate == nil }
            .count
    }

    /// **Story 3.11** — fetchById, retourne le 1er record actif matching ou nil.
    func fetchById(recordId: UUID) async throws -> AdaptedProgramRecord? {
        if fetchShouldThrow { throw URLError(.notConnectedToInternet) }
        return stubbedActive.first(where: { $0.id == recordId && $0.isActive })
    }

    /// **Story 3.10** — set par les tests AC32 cap démarré atteint.
    var markStartedShouldThrow: Error?
    private(set) var markStartedCalls: [UUID] = []

    func markStarted(recordId: UUID) async throws {
        markStartedCalls.append(recordId)
        if let markStartedShouldThrow { throw markStartedShouldThrow }
        guard let record = stubbedActive.first(where: { $0.id == recordId }) else { return }
        record.markStarted()
    }

    func update(_ record: AdaptedProgramRecord) async throws {
        if updateShouldThrow { throw URLError(.notConnectedToInternet) }
        updatedRecords.append(record)
    }

    func archive(_ record: AdaptedProgramRecord) async throws {
        archivedRecords.append(record)
        record.isActive = false
        record.archivedAt = Date()
    }

    var appliedLeonPatches: [(recordId: UUID, patch: AdaptationPatch)] = []
    var applyLeonPatchShouldThrow: Bool = false

    func applyLeonPatch(recordId: UUID, patch: AdaptationPatch) async throws {
        if applyLeonPatchShouldThrow { throw URLError(.cannotConnectToHost) }
        appliedLeonPatches.append((recordId: recordId, patch: patch))
        if let record = stubbedActive.first(where: { $0.id == recordId }) {
            try? record.applyLeonPatch(patch)
        }
    }

    var loadCompletionShouldThrow: Bool = false
    var recordCompletionShouldThrow: Bool = false
    private(set) var recordedCompletions: [(recordId: UUID, weekNumber: Int, day: Int, record: SessionCompletionRecord?)] = []

    func loadSessionCompletion(recordId: UUID, weekNumber: Int, day: Int) async throws -> SessionCompletionRecord? {
        if loadCompletionShouldThrow { throw URLError(.notConnectedToInternet) }
        guard let program = stubbedActive.first(where: { $0.id == recordId }) else {
            throw SessionCompletionRepositoryError.recordNotFound
        }
        guard let session = program.sessions.first(where: { $0.weekNumber == weekNumber && $0.day == day }) else {
            return nil
        }
        return program.completionState.sessionRecords[session.id]
    }

    func recordSessionCompletion(
        recordId: UUID,
        weekNumber: Int,
        day: Int,
        record: SessionCompletionRecord?
    ) async throws {
        if recordCompletionShouldThrow { throw URLError(.cannotConnectToHost) }
        recordedCompletions.append((recordId, weekNumber, day, record))
        guard let program = stubbedActive.first(where: { $0.id == recordId }) else {
            throw SessionCompletionRepositoryError.recordNotFound
        }
        guard let session = program.sessions.first(where: { $0.weekNumber == weekNumber && $0.day == day }) else {
            throw SessionCompletionRepositoryError.sessionNotFound
        }
        var state = program.completionState
        if let record {
            state.sessionRecords[session.id] = record
        } else {
            state.sessionRecords.removeValue(forKey: session.id)
        }
        program.completionState = state
    }
}
