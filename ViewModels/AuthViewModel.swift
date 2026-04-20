// ViewModels/AuthViewModel.swift
// [COPIE IDENTIQUE] — synchroniser avec GardenSage et TailorSage.
import Foundation
import AuthenticationServices
import CryptoKit
import os
import Supabase
import SageCore

@Observable
final class AuthViewModel {
    private static let logger = Logger(subsystem: "com.sopddl.coachingsage", category: "viewmodel")
    var authState: ViewState<Supabase.User> = .idle
    var isAuthenticated: Bool = false
    var resetPasswordSent: Bool = false
    var resetPasswordError: String?

    private(set) var currentNonce: String?
    private(set) var isAppleSignInInProgress = false

    private let authService: any AuthServiceProtocol
    private let coreProfileRepository: any CoreProfileRepository

    init(authService: any AuthServiceProtocol,
         coreProfileRepository: any CoreProfileRepository) {
        self.authService = authService
        self.coreProfileRepository = coreProfileRepository
    }

    // MARK: - Nonce Apple Sign In

    func generateAppleSignInNonce() -> String {
        if isAppleSignInInProgress, let existing = currentNonce {
            return sha256(existing)
        }
        let raw = generateRawNonce()
        currentNonce = raw
        isAppleSignInInProgress = true
        return sha256(raw)
    }

    // MARK: - Apple Sign In

    @MainActor
    func handleAppleSignIn(result: Result<ASAuthorization, Error>) async {
        defer { isAppleSignInInProgress = false }
        authState = .loading
        do {
            guard case .success(let authorization) = result,
                  let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
                  let tokenData = credential.identityToken,
                  let idToken = String(data: tokenData, encoding: .utf8),
                  let rawNonce = currentNonce
            else {
                authState = .error(.auth(String(localized: "auth.error.appleInfo")))
                return
            }
            let user = try await authService.signInWithApple(idToken: idToken, nonce: rawNonce)
            currentNonce = nil
            await createOrUpdateCoreProfile(userId: user.id)
            isAuthenticated = true
            authState = .success(user)
        } catch let error as AppError {
            currentNonce = nil
            authState = .error(error)
        } catch {
            currentNonce = nil
            authState = .error(.auth(String(localized: "auth.error.appleSignIn")))
        }
    }

    // MARK: - Email Sign In

    @MainActor
    func signIn(email: String, password: String) async {
        authState = .loading
        do {
            let user = try await authService.signIn(email: email, password: password)
            await createOrUpdateCoreProfile(userId: user.id)
            isAuthenticated = true
            authState = .success(user)
        } catch let error as AppError {
            authState = .error(error)
        } catch {
            authState = .error(.auth(String(localized: "auth.error.invalidCredentials")))
        }
    }

    // MARK: - Email Sign Up

    @MainActor
    func signUp(email: String, password: String) async {
        authState = .loading
        do {
            let user = try await authService.signUp(email: email, password: password)
            await createOrUpdateCoreProfile(userId: user.id)
            isAuthenticated = true
            authState = .success(user)
        } catch let error as AppError {
            authState = .error(error)
        } catch {
            authState = .error(.auth(String(localized: "auth.error.signUpFailed")))
        }
    }

    // MARK: - Reset Password

    @MainActor
    func resetPassword(email: String) async {
        resetPasswordSent = false
        resetPasswordError = nil
        do {
            try await authService.resetPasswordForEmail(email)
            resetPasswordSent = true
        } catch {
            resetPasswordError = error.localizedDescription
        }
    }

    // MARK: - Sign Out

    @MainActor
    func signOut() async {
        do {
            try await authService.signOut()
        } catch {
            Self.logger.warning("signOut server error (forcing local signOut): \(error)")
        }
        isAuthenticated = false
        authState = .idle
    }

    // MARK: - Private

    private func createOrUpdateCoreProfile(userId: UUID) async {
        guard (try? await coreProfileRepository.fetchCurrentProfile()) == nil else { return }
        let profile = SageCoreProfile(
            id: userId,
            language: Locale.current.language.languageCode?.identifier ?? "fr",
            region: ""
        )
        try? await coreProfileRepository.save(profile)
    }

    private func generateRawNonce() -> String {
        var randomBytes = [UInt8](repeating: 0, count: 32)
        _ = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        return randomBytes.map { String(format: "%02x", $0) }.joined()
    }

    private func sha256(_ input: String) -> String {
        let digest = SHA256.hash(data: Data(input.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
