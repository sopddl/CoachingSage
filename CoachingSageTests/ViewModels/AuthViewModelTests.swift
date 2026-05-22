// CoachingSageTests/ViewModels/AuthViewModelTests.swift
import XCTest
import SageCore

@MainActor
final class AuthViewModelTests: XCTestCase {

    // MARK: - Email Sign In

    func testSignInEmailSuccess() async throws {
        let mockAuth = MockAuthService()
        let vm = makeViewModel(auth: mockAuth)

        await vm.signIn(email: "test@coachingsage.app", password: "password123")

        XCTAssertTrue(vm.isAuthenticated)
        if case .success = vm.authState {} else {
            XCTFail("authState devrait être .success après un sign in réussi")
        }
    }

    func testSignInEmailNetworkError() async {
        let mockAuth = MockAuthService()
        mockAuth.shouldThrow = true
        let vm = makeViewModel(auth: mockAuth)

        await vm.signIn(email: "test@coachingsage.app", password: "mauvais")

        XCTAssertFalse(vm.isAuthenticated)
        if case .error(let error) = vm.authState {
            if case .auth(let message) = error {
                XCTAssertFalse(message.isEmpty, "Le message d'erreur ne doit pas être vide")
            } else {
                XCTFail("L'erreur doit être un AppError.auth")
            }
        } else {
            XCTFail("authState devrait être .error après un échec réseau")
        }
    }

    // MARK: - Email Sign Up

    func testSignUpEmailSuccess() async throws {
        let mockAuth = MockAuthService()
        let vm = makeViewModel(auth: mockAuth)

        await vm.signUp(email: "nouveau@coachingsage.app", password: "password123")

        XCTAssertTrue(vm.isAuthenticated)
        if case .success = vm.authState {} else {
            XCTFail("authState devrait être .success après un sign up réussi")
        }
    }

    func testSignUpEmailError() async {
        let mockAuth = MockAuthService()
        mockAuth.shouldThrow = true
        let vm = makeViewModel(auth: mockAuth)

        await vm.signUp(email: "existant@coachingsage.app", password: "password123")

        XCTAssertFalse(vm.isAuthenticated)
        if case .error = vm.authState {} else {
            XCTFail("authState devrait être .error")
        }
    }

    // MARK: - createOrUpdateCoreProfile — profil créé à la connexion

    func testSignUpCreatesCoreProfileWithAuthUserId() async throws {
        let mockAuth = MockAuthService()
        let mockCoreRepo = MockCoreProfileRepository()
        let vm = AuthViewModel(authService: mockAuth, coreProfileRepository: mockCoreRepo)

        await vm.signUp(email: "nouveau@coachingsage.app", password: "password123")

        XCTAssertEqual(mockCoreRepo.savedProfiles.count, 1, "Un SageCoreProfile doit être sauvegardé à l'inscription")
        XCTAssertEqual(mockCoreRepo.savedProfiles.first?.id, mockAuth.stubbedUserId,
                       "L'id du profil doit correspondre à auth.users.id")
    }

    func testSignInDoesNotDuplicateExistingProfile() async throws {
        let mockAuth = MockAuthService()
        let mockCoreRepo = MockCoreProfileRepository()
        // Profil existant — ne doit pas en créer un second
        mockCoreRepo.stubbedProfile = SageCoreProfile(id: mockAuth.stubbedUserId)
        let vm = AuthViewModel(authService: mockAuth, coreProfileRepository: mockCoreRepo)

        await vm.signIn(email: "existant@coachingsage.app", password: "password123")

        XCTAssertEqual(mockCoreRepo.savedProfiles.count, 0, "Aucun profil ne doit être créé si un profil existe déjà")
    }

    // MARK: - Sign Out

    func testSignOutCallsServiceAndResetsState() async {
        let mockAuth = MockAuthService()
        let vm = makeViewModel(auth: mockAuth)
        vm.isAuthenticated = true

        await vm.signOut()

        XCTAssertTrue(mockAuth.signOutCalled)
        XCTAssertFalse(vm.isAuthenticated)
        if case .idle = vm.authState {} else {
            XCTFail("authState devrait être .idle après sign out")
        }
    }

    func testSignOutErrorDoesNotCrash() async {
        let mockAuth = MockAuthService()
        mockAuth.shouldThrow = true
        let vm = makeViewModel(auth: mockAuth)
        vm.isAuthenticated = true

        await vm.signOut()

        // Le signOut local est forcé même si le serveur échoue (fix session expirée 401)
        XCTAssertFalse(vm.isAuthenticated, "isAuthenticated doit être false même si le serveur échoue")
        if case .idle = vm.authState {} else {
            XCTFail("authState doit être .idle (signOut local forcé), got: \(vm.authState)")
        }
    }

    // MARK: - Apple Sign In Nonce

    func testGenerateAppleSignInNonceStoresRawNonce() {
        let vm = makeViewModel(auth: MockAuthService())

        let hashedNonce = vm.generateAppleSignInNonce()

        XCTAssertNotNil(vm.currentNonce, "Le nonce brut doit être stocké")
        XCTAssertFalse(hashedNonce.isEmpty, "Le hash SHA256 ne doit pas être vide")
        XCTAssertNotEqual(hashedNonce, vm.currentNonce, "Le hash ne doit pas être identique au nonce brut")
    }

    func testSecondGenerateCallReturnsSameNonceWhileInFlight() {
        let vm = makeViewModel(auth: MockAuthService())

        let nonce1 = vm.generateAppleSignInNonce()
        let nonce2 = vm.generateAppleSignInNonce()

        XCTAssertEqual(nonce1, nonce2, "Le 2ème appel doit retourner le même nonce tant que la requête Apple est en vol")
        XCTAssertTrue(vm.isAppleSignInInProgress, "Le flag doit être true après génération")
    }

    // MARK: - Helpers

    private func makeViewModel(auth: MockAuthService) -> AuthViewModel {
        AuthViewModel(
            authService: auth,
            coreProfileRepository: MockCoreProfileRepository()
        )
    }
}
