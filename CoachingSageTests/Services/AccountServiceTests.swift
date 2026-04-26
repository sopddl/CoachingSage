// CoachingSageTests/Services/AccountServiceTests.swift
// Story 1.4 — vérifie l'orchestration ceinture-bretelles côté serveur (softDelete → deleteAuthUser).
// signOut est testé côté AccountViewModel (séparé pour éviter race authStateChanges → démontage VM).
import XCTest
@testable import CoachingSage
import SageCore

@MainActor
final class AccountServiceTests: XCTestCase {

    // MARK: - Helpers

    private func makeService(
        coreRepo: MockCoreProfileRepository,
        deleteAuthUser: (@Sendable () async throws -> Void)? = nil
    ) -> AccountService {
        AccountService(
            coreProfileRepository: coreRepo,
            deleteAuthUser: deleteAuthUser
        )
    }

    // MARK: - Orchestration

    func testDeleteAccountOrchestratesSoftDeleteThenDeleteAuthUser() async throws {
        let coreRepo = MockCoreProfileRepository()
        coreRepo.stubbedProfile = SageCoreProfile(id: UUID())

        var callOrder: [String] = []
        coreRepo.softDeleteHook = { callOrder.append("softDelete") }
        let deleteAuthUser: @Sendable () async throws -> Void = {
            await MainActor.run { callOrder.append("deleteAuthUser") }
        }

        let service = makeService(coreRepo: coreRepo, deleteAuthUser: deleteAuthUser)
        try await service.deleteAccount()

        XCTAssertEqual(callOrder, ["softDelete", "deleteAuthUser"])
        XCTAssertEqual(coreRepo.deletedProfiles.count, 1)
    }

    // MARK: - No local profile

    func testDeleteAccountWhenNoLocalProfileSkipsSoftDeleteButStillCallsDeleteAuthUser() async throws {
        let coreRepo = MockCoreProfileRepository()
        coreRepo.stubbedProfile = nil

        var deleteAuthCalled = false
        let deleteAuthUser: @Sendable () async throws -> Void = {
            deleteAuthCalled = true
        }

        let service = makeService(coreRepo: coreRepo, deleteAuthUser: deleteAuthUser)
        try await service.deleteAccount()

        XCTAssertTrue(coreRepo.deletedProfiles.isEmpty)
        XCTAssertTrue(deleteAuthCalled)
    }

    // MARK: - Erreur edge function HTTP 500 (test critique du review P1.9)

    func testDeleteAccountThrowsOnEdgeFunctionHTTP500() async {
        let coreRepo = MockCoreProfileRepository()
        coreRepo.stubbedProfile = SageCoreProfile(id: UUID())

        let deleteAuthUser: @Sendable () async throws -> Void = {
            throw AppError.sync("delete-account HTTP 500")
        }

        let service = makeService(coreRepo: coreRepo, deleteAuthUser: deleteAuthUser)

        do {
            try await service.deleteAccount()
            XCTFail("deleteAccount should throw on HTTP 500")
        } catch let error as AppError {
            if case .sync(let msg) = error {
                XCTAssertTrue(msg.contains("HTTP 500"), "Erreur attendue contenant 'HTTP 500', reçu : \(msg)")
            } else {
                XCTFail("AppError attendu = .sync, reçu : \(error)")
            }
        } catch {
            XCTFail("AppError attendu, reçu : \(error)")
        }

        // Le softDelete a quand même été tenté (trace de sécu posée AVANT l'edge function).
        XCTAssertEqual(coreRepo.deletedProfiles.count, 1)
    }

    // MARK: - Erreur softDelete : ne doit PAS appeler deleteAuthUser

    func testDeleteAccountThrowsOnSoftDeleteFailure() async {
        let coreRepo = MockCoreProfileRepository()
        coreRepo.stubbedProfile = SageCoreProfile(id: UUID())
        coreRepo.softDeleteShouldThrow = true

        var deleteAuthCalled = false
        let deleteAuthUser: @Sendable () async throws -> Void = {
            deleteAuthCalled = true
        }

        let service = makeService(coreRepo: coreRepo, deleteAuthUser: deleteAuthUser)

        do {
            try await service.deleteAccount()
            XCTFail("deleteAccount should throw on softDelete failure")
        } catch let error as AppError {
            // P1.2 : vérifier le type AppError propagé tel quel.
            if case .network = error {} else {
                XCTFail("AppError attendu = .network (URLError), reçu : \(error)")
            }
        } catch {
            XCTFail("AppError attendu, reçu : \(error)")
        }

        XCTAssertFalse(deleteAuthCalled, "deleteAuthUser ne doit PAS être appelé après échec softDelete")
        XCTAssertTrue(coreRepo.deletedProfiles.isEmpty, "Aucun profil ne doit avoir été flaggé soft-deleted")
    }

    // MARK: - Idempotence (retry après succès partiel)
    // Scénario du spec Task 7.2 ligne 101 : "softDelete réussi mais signOut KO → retry réussit".
    // signOut a été extrait du service (cf. P1.3 review) → côté service, l'idempotence revient à :
    // 1er appel succès complet → 2nd appel sans profil local (déjà soft-deleted) succès aussi.

    func testDeleteAccountIdempotentOnRetry() async throws {
        let coreRepo = MockCoreProfileRepository()
        let profile = SageCoreProfile(id: UUID())
        coreRepo.stubbedProfile = profile

        var deleteAuthCallCount = 0
        let deleteAuthUser: @Sendable () async throws -> Void = {
            await MainActor.run { deleteAuthCallCount += 1 }
        }

        let service = makeService(coreRepo: coreRepo, deleteAuthUser: deleteAuthUser)

        // Appel 1 : succès complet (softDelete + deleteAuthUser).
        try await service.deleteAccount()
        XCTAssertEqual(coreRepo.deletedProfiles.count, 1)
        XCTAssertEqual(deleteAuthCallCount, 1)
        // Le mock a mis stubbedProfile à nil (P1.4 : reflète la réalité métier post-softDelete).
        XCTAssertNil(coreRepo.stubbedProfile)
        XCTAssertTrue(profile.isSoftDeleted)

        // Appel 2 : pas de profil local → skip softDelete, mais deleteAuthUser rejoué.
        // Edge function réelle retournerait 200 (idempotence "user not found", cf. index.ts).
        try await service.deleteAccount()
        XCTAssertEqual(coreRepo.deletedProfiles.count, 1, "Pas de nouveau softDelete (profil déjà supprimé)")
        XCTAssertEqual(deleteAuthCallCount, 2, "deleteAuthUser rejoué côté serveur (idempotent)")
    }
}
