// CoachingSageTests/Services/DefaultHealthKitServiceTests.swift
// Story 2.1 — couvre uniquement le guard IS_UI_TESTING (review P1.3).
// HealthKit lui-même n'est pas mockable côté unit — la vraie validation se fait via Story 2.2 sur device.
import XCTest
@testable import CoachingSage

final class DefaultHealthKitServiceTests: XCTestCase {

    private static let authorizationRequestedKey = "healthkit.authorization.requested"

    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: Self.authorizationRequestedKey)
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: Self.authorizationRequestedKey)
        super.tearDown()
    }

    func testDefaultServiceReturnsEmptyProfileUnderUITesting() async throws {
        setenv("IS_UI_TESTING", "1", 1)
        defer { unsetenv("IS_UI_TESTING") }

        let service = DefaultHealthKitService()
        let profile = await service.fetchProfileData()

        XCTAssertEqual(
            profile,
            HealthKitProfileData(biologicalSex: nil, dateOfBirth: nil, bodyMassKg: nil, heightCm: nil)
        )
        XCTAssertFalse(service.hasRequestedAuthorization)

        // requestProfileAuthorization no-op : ne throw pas, ne marque pas hasRequested.
        try await service.requestProfileAuthorization()
        XCTAssertFalse(service.hasRequestedAuthorization)
    }
}
