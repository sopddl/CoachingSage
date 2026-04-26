// CoachingSageTests/Mocks/MockAuthService.swift
// [COPIE IDENTIQUE] — synchroniser avec GardenSage et TailorSage.
import Foundation
@testable import CoachingSage
import Supabase
import SageCore

final class MockAuthService: AuthServiceProtocol {
    var shouldThrow: Bool = false
    var signOutCalled: Bool = false
    var signInEmailCalled: Bool = false
    var signUpEmailCalled: Bool = false
    var signInAppleCalled: Bool = false
    var resetPasswordCalled: Bool = false

    /// Hook appelé au début de signOut (Story 1.4 tests : vérifier l'ordre).
    var signOutHook: (() -> Void)? = nil

    /// UUID fixe retourné par makeMockUser() — utilisé pour vérifier SageCoreProfile.id dans les tests
    let stubbedUserId = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!

    var currentUserId: UUID? { stubbedUserId }

    func signInWithApple(idToken: String, nonce: String) async throws -> Supabase.User {
        signInAppleCalled = true
        if shouldThrow { throw AppError.auth("Erreur réseau simulée") }
        return makeMockUser()
    }

    func signIn(email: String, password: String) async throws -> Supabase.User {
        signInEmailCalled = true
        if shouldThrow { throw AppError.auth("Identifiants invalides") }
        return makeMockUser()
    }

    func signUp(email: String, password: String) async throws -> Supabase.User {
        signUpEmailCalled = true
        if shouldThrow { throw AppError.auth("Email déjà utilisé") }
        return makeMockUser()
    }

    func signOut() async throws {
        signOutHook?()
        signOutCalled = true
        if shouldThrow { throw AppError.auth("Déconnexion impossible") }
    }

    func resetPasswordForEmail(_ email: String) async throws {
        resetPasswordCalled = true
        if shouldThrow { throw AppError.auth("Reset impossible") }
    }

    var updatePasswordCalled = false
    func updatePassword(_ newPassword: String) async throws {
        updatePasswordCalled = true
        if shouldThrow { throw AppError.auth("Update impossible") }
    }

    var handleSessionCalled = false
    func handleSessionFromURL(_ url: URL) async throws {
        handleSessionCalled = true
        if shouldThrow { throw AppError.auth("Session invalide") }
    }

    // MARK: - Helper

    private func makeMockUser() -> Supabase.User {
        let json = """
        {
            "id": "00000000-0000-0000-0000-000000000001",
            "aud": "authenticated",
            "email": "test@coachingsage.app",
            "app_metadata": {},
            "user_metadata": {},
            "is_anonymous": false,
            "created_at": "2026-01-01T00:00:00.000000Z",
            "updated_at": "2026-01-01T00:00:00.000000Z"
        }
        """.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let str = try container.decode(String.self)
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = formatter.date(from: str) { return date }
            formatter.formatOptions = [.withInternetDateTime]
            if let date = formatter.date(from: str) { return date }
            throw DecodingError.dataCorrupted(
                .init(codingPath: decoder.codingPath, debugDescription: "Date invalide: \(str)")
            )
        }
        return try! decoder.decode(Supabase.User.self, from: json)
    }
}
