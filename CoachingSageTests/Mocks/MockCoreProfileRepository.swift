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

    /// Si true, softDelete throw avant d'enregistrer le profil dans deletedProfiles (Story 1.4 tests).
    var softDeleteShouldThrow: Bool = false

    /// Hook appelé au début de softDelete (Story 1.4 tests : vérifier l'ordre).
    var softDeleteHook: (() -> Void)? = nil

    func fetchCurrentProfile() async throws -> SageCoreProfile? {
        if shouldThrow { throw AppError.network(URLError(.notConnectedToInternet)) }
        return stubbedProfile
    }

    func save(_ profile: SageCoreProfile) async throws {
        if shouldThrow { throw AppError.network(URLError(.notConnectedToInternet)) }
        savedProfiles.append(profile)
    }

    func softDelete(_ profile: SageCoreProfile) async throws {
        softDeleteHook?()
        if shouldThrow || softDeleteShouldThrow {
            throw AppError.network(URLError(.notConnectedToInternet))
        }
        // Reflète le comportement réel du repository : profil flaggé soft-deleted, deletedAt posé,
        // et fetchCurrentProfile() renverra nil (filtre isSoftDeleted == false).
        profile.isSoftDeleted = true
        profile.deletedAt = Date()
        if stubbedProfile === profile {
            stubbedProfile = nil
        }
        deletedProfiles.append(profile)
    }

    func cleanupOrphanProfiles() {}
    func ensureLocalProfileExists() {}
}
