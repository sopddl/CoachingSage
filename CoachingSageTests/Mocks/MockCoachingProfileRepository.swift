// CoachingSageTests/Mocks/MockCoachingProfileRepository.swift
// Story 2.2 — pattern MockCoreProfileRepository.
import Foundation
@testable import CoachingSage
import SageCore

final class MockCoachingProfileRepository: CoachingProfileRepository {
    var stubbedProfile: CoachingProfile?
    var savedProfiles: [CoachingProfile] = []
    var fetchHook: (() -> Void)?
    var saveHook: ((CoachingProfile) -> Void)?
    var fetchShouldThrow: Bool = false
    var saveShouldThrow: Bool = false

    func fetchCurrentProfile() async throws -> CoachingProfile? {
        fetchHook?()
        if fetchShouldThrow { throw AppError.network(URLError(.notConnectedToInternet)) }
        return stubbedProfile
    }

    func save(_ profile: CoachingProfile) async throws {
        saveHook?(profile)
        if saveShouldThrow { throw AppError.network(URLError(.notConnectedToInternet)) }
        savedProfiles.append(profile)
        stubbedProfile = profile
    }
}
