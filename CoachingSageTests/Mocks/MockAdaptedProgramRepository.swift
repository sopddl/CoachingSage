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

    func fetchActive(for userId: UUID) async throws -> [AdaptedProgramRecord] {
        if fetchShouldThrow { throw URLError(.notConnectedToInternet) }
        return stubbedActive.filter { $0.userId == userId && $0.isActive }
    }

    func save(_ record: AdaptedProgramRecord) async throws {
        savedRecords.append(record)
        stubbedActive.append(record)
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
}
