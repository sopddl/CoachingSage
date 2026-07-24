// CoachingSageTests/Services/DefaultHealthKitServiceTests.swift
// Story 2.1 — couvre uniquement le guard IS_UI_TESTING (review P1.3).
// Story 3.9.0 — ajoute la sémantique du flag `progressAuthorizationRequestedAt` + flow re-prompt.
// HealthKit lui-même n'est pas mockable côté unit — la vraie validation se fait via Story 2.2 sur device.
import XCTest

final class DefaultHealthKitServiceTests: XCTestCase {

    private static let authorizationRequestedKey = "healthkit.authorization.requested"
    private static let progressAuthorizationRequestedAtKey = "healthkit.progress.authorization.requested.at"

    private var suiteName: String = ""
    private var defaults: UserDefaults!

    override func setUp() {
        super.setUp()
        suiteName = "HK-tests-\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)
        defaults.removeObject(forKey: Self.authorizationRequestedKey)
        defaults.removeObject(forKey: Self.progressAuthorizationRequestedAtKey)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        defaults = nil
        super.tearDown()
    }

    func testDefaultServiceReturnsEmptyProfileUnderUITesting() async throws {
        setenv("IS_UI_TESTING", "1", 1)
        defer { unsetenv("IS_UI_TESTING") }

        let service = DefaultHealthKitService(userDefaults: defaults)
        let profile = await service.fetchProfileData()

        XCTAssertEqual(
            profile,
            HealthKitProfileData(biologicalSex: nil, dateOfBirth: nil, bodyMassKg: nil, heightCm: nil)
        )
        XCTAssertFalse(service.hasRequestedAuthorization)
        XCTAssertFalse(service.hasRequestedProgressAuthorization)

        // requestProfileAuthorization no-op : ne throw pas, ne marque pas hasRequested.
        try await service.requestProfileAuthorization()
        XCTAssertFalse(service.hasRequestedAuthorization)
        XCTAssertFalse(service.hasRequestedProgressAuthorization)

        // requestProgressAuthorizationIfNeeded no-op : ne throw pas, ne marque pas le flag.
        try await service.requestProgressAuthorizationIfNeeded()
        XCTAssertFalse(service.hasRequestedProgressAuthorization)
    }

    /// Story 3.9.0 — un utilisateur post-Story 2.1 sans permissions étendues est détecté
    /// via `hasRequestedProgressAuthorization == false`, ce qui déclenche le re-prompt sur l'onglet Progrès.
    func testHasRequestedProgressAuthorizationReturnsFalseWhenFlagAbsent() {
        let service = DefaultHealthKitService(userDefaults: defaults)
        XCTAssertFalse(service.hasRequestedProgressAuthorization)
    }

    /// Story 3.9.0 — une fois la date stockée dans UserDefaults, le service ne re-prompte plus.
    func testHasRequestedProgressAuthorizationReturnsTrueWhenFlagIsDate() {
        defaults.set(Date(), forKey: Self.progressAuthorizationRequestedAtKey)
        let service = DefaultHealthKitService(userDefaults: defaults)
        XCTAssertTrue(service.hasRequestedProgressAuthorization)
    }

    /// Story 3.9.0 — défense en profondeur : si la valeur stockée n'est pas un Date (corruption / migration),
    /// le flag est considéré comme non-set et le re-prompt sera déclenché (préférable à un re-prompt loop silencieux).
    func testHasRequestedProgressAuthorizationReturnsFalseWhenFlagIsNotDate() {
        defaults.set("garbage", forKey: Self.progressAuthorizationRequestedAtKey)
        let service = DefaultHealthKitService(userDefaults: defaults)
        XCTAssertFalse(service.hasRequestedProgressAuthorization)
    }
}

/// Verrou weeksBack défaut `fetchWorkoutSummary()` (backlog pédagogie 05-11, item HK swim/onboarding).
final class HealthKitServiceProtocolDefaultsTests: XCTestCase {

    func testFetchWorkoutSummaryDefaultUsesTwelveWeeks() async {
        let mock = MockHealthKitService()
        _ = await mock.fetchWorkoutSummary()
        XCTAssertEqual(mock.receivedWorkoutSummaryWeeksBack, 12,
                       "le défaut protocole doit rester à 12 semaines (bump 8→12, chantier onboarding non-sync)")
    }
}

/// Story 3.9.0 — tests sur le mock pour vérifier la sémantique « ne re-prompte pas en boucle ».
final class MockHealthKitServiceProgressAuthorizationTests: XCTestCase {

    func testRequestProgressAuthorizationMarksFlag() async throws {
        let mock = MockHealthKitService()
        XCTAssertFalse(mock.hasRequestedProgressAuthorization)

        try await mock.requestProgressAuthorizationIfNeeded()

        XCTAssertTrue(mock.hasRequestedProgressAuthorization)
        XCTAssertEqual(mock.requestProgressAuthorizationCallCount, 1)
    }

    func testRequestProgressAuthorizationIsIdempotent() async throws {
        let mock = MockHealthKitService()
        try await mock.requestProgressAuthorizationIfNeeded()
        try await mock.requestProgressAuthorizationIfNeeded()
        try await mock.requestProgressAuthorizationIfNeeded()

        XCTAssertEqual(mock.requestProgressAuthorizationCallCount, 1,
                       "le flow doit être no-op après la première demande")
        XCTAssertTrue(mock.hasRequestedProgressAuthorization)
    }

    func testProfileAuthorizationAlsoMarksProgressFlag() async throws {
        let mock = MockHealthKitService()
        try await mock.requestProfileAuthorization()

        XCTAssertTrue(mock.hasRequestedAuthorization)
        XCTAssertTrue(mock.hasRequestedProgressAuthorization,
                      "un nouvel utilisateur onboardé post-3.9.0 ne doit pas voir le re-prompt Progrès")
    }

    func testRequestProgressAuthorizationPropagatesThrow() async {
        let mock = MockHealthKitService()
        mock.requestProgressAuthorizationShouldThrow = HealthKitError.notAvailable

        do {
            try await mock.requestProgressAuthorizationIfNeeded()
            XCTFail("doit propager l'erreur HK")
        } catch let HealthKitError.notAvailable {
            XCTAssertFalse(mock.hasRequestedProgressAuthorization,
                          "le flag ne doit pas être marqué si la demande a échoué")
        } catch {
            XCTFail("erreur inattendue : \(error)")
        }
    }
}
