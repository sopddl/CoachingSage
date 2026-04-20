// Services/AuthService.swift
// [COPIE IDENTIQUE] — synchroniser avec GardenSage et TailorSage.
import Foundation
import Supabase
import SageCore

// MARK: - Protocol

protocol AuthServiceProtocol {
    var currentUserId: UUID? { get }
    func signInWithApple(idToken: String, nonce: String) async throws -> Supabase.User
    func signIn(email: String, password: String) async throws -> Supabase.User
    func signUp(email: String, password: String) async throws -> Supabase.User
    func signOut() async throws
    func resetPasswordForEmail(_ email: String) async throws
    func updatePassword(_ newPassword: String) async throws
    func handleSessionFromURL(_ url: URL) async throws
}

// MARK: - Implémentation concrète

final class AuthService: AuthServiceProtocol {
    private var auth: AuthClient { SupabaseService.shared.client.auth }

    var currentUserId: UUID? {
        auth.currentUser?.id
    }

    func signInWithApple(idToken: String, nonce: String) async throws -> Supabase.User {
        do {
            let session = try await auth.signInWithIdToken(
                credentials: .init(provider: .apple, idToken: idToken, nonce: nonce)
            )
            return session.user
        } catch {
            throw AppError.auth(error.localizedDescription)
        }
    }

    func signIn(email: String, password: String) async throws -> Supabase.User {
        do {
            let session = try await auth.signIn(email: email, password: password)
            return session.user
        } catch {
            throw AppError.auth(error.localizedDescription)
        }
    }

    func signUp(email: String, password: String) async throws -> Supabase.User {
        do {
            let response = try await auth.signUp(email: email, password: password)
            return response.user
        } catch {
            throw AppError.auth(error.localizedDescription)
        }
    }

    func signOut() async throws {
        do {
            try await auth.signOut()
        } catch {
            throw AppError.auth(error.localizedDescription)
        }
    }

    func resetPasswordForEmail(_ email: String) async throws {
        do {
            try await auth.resetPasswordForEmail(
                email,
                redirectTo: URL(string: "https://sopddl.github.io/auth/callback")
            )
        } catch {
            throw AppError.auth(error.localizedDescription)
        }
    }

    func updatePassword(_ newPassword: String) async throws {
        do {
            try await auth.update(user: UserAttributes(password: newPassword))
        } catch {
            throw AppError.auth(error.localizedDescription)
        }
    }

    func handleSessionFromURL(_ url: URL) async throws {
        do {
            try await auth.session(from: url)
        } catch {
            throw AppError.auth(error.localizedDescription)
        }
    }
}
