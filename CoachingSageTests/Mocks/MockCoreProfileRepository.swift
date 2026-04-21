// CoachingSageTests/Mocks/MockCoreProfileRepository.swift
// [COPIE IDENTIQUE] — synchroniser avec GardenSage et TailorSage.
import Foundation
@testable import CoachingSage
import SageCore

final class MockCoreProfileRepository: CoreProfileRepository {
    var stubbedProfile: SageCoreProfile? = nil
    var savedProfiles: [SageCoreProfile] = []
    var deletedProfiles: [SageCoreProfile] = []
    var shouldThrow: Bool = false

    func fetchCurrentProfile() async throws -> SageCoreProfile? {
        if shouldThrow { throw AppError.network(URLError(.notConnectedToInternet)) }
        return stubbedProfile
    }

    func save(_ profile: SageCoreProfile) async throws {
        if shouldThrow { throw AppError.network(URLError(.notConnectedToInternet)) }
        savedProfiles.append(profile)
    }

    func softDelete(_ profile: SageCoreProfile) async throws {
        if shouldThrow { throw AppError.network(URLError(.notConnectedToInternet)) }
        deletedProfiles.append(profile)
    }

    func cleanupOrphanProfiles() {}
    func ensureLocalProfileExists() {}
}
