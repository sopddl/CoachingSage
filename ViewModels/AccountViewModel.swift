// ViewModels/AccountViewModel.swift
// Story 1.4 — orchestre la suppression de compte côté UI : transitions ViewState pour DeleteAccountView.
// .success est posé AVANT signOut pour éviter la race authStateChanges → démontage VM (cf. P1.3 review).
// signOut local = best-effort : l'user est déjà supprimé côté serveur, le client perdra sa session
// au prochain refresh JWT (401) si signOut local échoue.
import Foundation
import os
import SageCore

@Observable
final class AccountViewModel {
    private static let logger = Logger(subsystem: "com.sopddl.coachingsage", category: "AccountViewModel")
    var deleteAccountState: ViewState<Void> = .idle

    private let accountService: any AccountServiceProtocol
    private let authService: any AuthServiceProtocol

    init(
        accountService: any AccountServiceProtocol,
        authService: any AuthServiceProtocol
    ) {
        self.accountService = accountService
        self.authService = authService
    }

    @MainActor
    func deleteAccount() async {
        deleteAccountState = .loading
        do {
            try await accountService.deleteAccount()
            deleteAccountState = .success(())
            // Best-effort signOut local — l'user est déjà supprimé côté serveur.
            // CoachingSageApp observe authStateChanges (.signedOut / .userDeleted) → bascule sur AuthView.
            try? await authService.signOut()
        } catch {
            Self.logger.error("deleteAccount failed: \(error)")
            deleteAccountState = .error(error as? AppError ?? .sync(error.localizedDescription))
        }
    }
}
