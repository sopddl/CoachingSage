// CoachingSageTests/Mocks/MockRoutineRepository.swift
// Story 3.8 — pattern MockCoachingProfileRepository.
import Foundation
@testable import CoachingSage

@MainActor
final class MockRoutineRepository: RoutineRepository {
    var stubbedRoutines: [RoutineRecord] = []
    var fetchShouldThrow: Bool = false

    func fetchAll(for userId: UUID) async throws -> [RoutineRecord] {
        if fetchShouldThrow { throw URLError(.notConnectedToInternet) }
        return stubbedRoutines.filter { $0.userId == userId }
    }
}
