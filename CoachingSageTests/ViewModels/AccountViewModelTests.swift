// CoachingSageTests/ViewModels/AccountViewModelTests.swift
// Story 1.4 — transitions ViewState pour DeleteAccountView + orchestration .success → signOut.
import XCTest
import SageCore

@MainActor
final class AccountViewModelTests: XCTestCase {

    // MARK: - Helpers

    private func makeViewModel(
        accountService: any AccountServiceProtocol,
        authService: any AuthServiceProtocol = MockAuthService()
    ) -> AccountViewModel {
        AccountViewModel(accountService: accountService, authService: authService)
    }

    // MARK: - Transitions

    func testDeleteAccountSuccessTransitionsIdleLoadingSuccess() async {
        let mockService = MockAccountService()
        let mockAuth = MockAuthService()
        let vm = makeViewModel(accountService: mockService, authService: mockAuth)

        if case .idle = vm.deleteAccountState {} else {
            XCTFail("État initial doit être .idle")
        }

        await vm.deleteAccount()

        XCTAssertTrue(mockService.deleteAccountCalled)
        if case .success = vm.deleteAccountState {} else {
            XCTFail("deleteAccountState doit être .success après succès")
        }
        XCTAssertTrue(mockAuth.signOutCalled, "signOut doit être appelé après .success")
    }

    func testDeleteAccountFailureTransitionsIdleLoadingErrorAppError() async {
        let mockService = MockAccountService()
        mockService.shouldThrow = true
        mockService.thrownError = AppError.sync("delete-account HTTP 500")
        let mockAuth = MockAuthService()
        let vm = makeViewModel(accountService: mockService, authService: mockAuth)

        await vm.deleteAccount()

        XCTAssertTrue(mockService.deleteAccountCalled)
        if case .error(let error) = vm.deleteAccountState {
            if case .sync(let msg) = error {
                XCTAssertTrue(msg.contains("HTTP 500"))
            } else {
                XCTFail("AppError attendu = .sync, reçu : \(error)")
            }
        } else {
            XCTFail("deleteAccountState doit être .error après échec")
        }

        XCTAssertFalse(mockAuth.signOutCalled, "signOut ne doit PAS être appelé après échec service")
    }

    // MARK: - Ordre .success AVANT signOut (P1.3 review)

    func testDeleteAccountSetsSuccessBeforeCallingSignOut() async {
        let mockService = MockAccountService()
        let mockAuth = MockAuthService()
        let vm = makeViewModel(accountService: mockService, authService: mockAuth)

        var stateAtSignOut: ViewState<Void>?
        mockAuth.signOutHook = { [weak vm] in
            stateAtSignOut = vm?.deleteAccountState
        }

        await vm.deleteAccount()

        XCTAssertNotNil(stateAtSignOut)
        if case .success = stateAtSignOut! {} else {
            XCTFail(".success doit être posé AVANT l'appel signOut (race authStateChanges)")
        }
    }

    // MARK: - signOut KO après delete réussi : .success préservé (best-effort)

    func testDeleteAccountSucceedsEvenIfSignOutFails() async {
        let mockService = MockAccountService()
        let mockAuth = MockAuthService()
        mockAuth.shouldThrow = true
        let vm = makeViewModel(accountService: mockService, authService: mockAuth)

        await vm.deleteAccount()

        // delete réussi → .success ; signOut throw → swallow (try?) → état reste .success.
        if case .success = vm.deleteAccountState {} else {
            XCTFail("deleteAccountState doit rester .success même si signOut échoue (best-effort)")
        }
        XCTAssertTrue(mockAuth.signOutCalled)
    }

    // MARK: - Retry après signOut KO (P1.1 review : scénario du spec Task 7.2)

    func testDeleteAccountRetryAfterSignOutFailureSucceeds() async {
        let mockService = MockAccountService()
        let mockAuth = MockAuthService()
        let vm = makeViewModel(accountService: mockService, authService: mockAuth)

        // Appel 1 : delete OK + signOut KO → état .success (signOut swallow), signOut tenté.
        mockAuth.shouldThrow = true
        await vm.deleteAccount()
        if case .success = vm.deleteAccountState {} else {
            XCTFail("Appel 1 : .success attendu malgré signOut KO")
        }
        XCTAssertTrue(mockAuth.signOutCalled)

        // Appel 2 : reset signOut → succès complet.
        mockAuth.shouldThrow = false
        mockAuth.signOutCalled = false
        mockService.deleteAccountCalled = false

        await vm.deleteAccount()

        XCTAssertTrue(mockService.deleteAccountCalled, "Appel 2 : delete rejoué (idempotent côté serveur)")
        XCTAssertTrue(mockAuth.signOutCalled, "Appel 2 : signOut réussit")
        if case .success = vm.deleteAccountState {} else {
            XCTFail("Appel 2 : .success attendu après retry réussi")
        }
    }
}
