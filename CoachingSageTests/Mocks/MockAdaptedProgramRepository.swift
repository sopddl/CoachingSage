// CoachingSageTests/Mocks/MockAdaptedProgramRepository.swift
// Story 3.8 — pattern MockCoachingProfileRepository.
import Foundation
@testable import CoachingSage

@MainActor
final class MockAdaptedProgramRepository: AdaptedProgramRepository {
    var stubbedActive: [AdaptedProgramRecord] = []
    var savedRecords: [AdaptedProgramRecord] = []
    var archivedRecords: [AdaptedProgramRecord] = []
    var fetchShouldThrow: Bool = false

    func fetchActive(for userId: UUID) async throws -> [AdaptedProgramRecord] {
        if fetchShouldThrow { throw URLError(.notConnectedToInternet) }
        return stubbedActive.filter { $0.userId == userId && $0.isActive }
    }

    func save(_ record: AdaptedProgramRecord) async throws {
        savedRecords.append(record)
        stubbedActive.append(record)
    }

    func archive(_ record: AdaptedProgramRecord) async throws {
        archivedRecords.append(record)
        record.isActive = false
        record.archivedAt = Date()
    }
}
