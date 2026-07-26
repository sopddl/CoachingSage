// CoachingSageTests/Services/StoreKitServiceTests.swift
// Léon+ — teste la logique de synchronisation de tier qui ne dépend pas d'une
// vraie transaction StoreKit (applyQuotaTier / resetForSignOut). Le flow
// purchase()/restorePurchases()/refreshSubscriptionStatus() nécessite un vrai
// contexte StoreKit (fichier `.storekit` + simulateur) — cf `LeonProducts.storekit`,
// testé manuellement (voir plan Léon+).
import XCTest
@testable import CoachingSage

@MainActor
final class StoreKitServiceTests: XCTestCase {

    override func tearDown() async throws {
        // Le singleton persiste entre les tests (jamais désalloué) — on remet à
        // "free" pour ne pas fuiter d'état entre tests.
        StoreKitService.shared.resetForSignOut()
        try await super.tearDown()
    }

    func testApplyQuotaTierUpdatesCurrentTierAndPersists() {
        StoreKitService.shared.applyQuotaTier("plus")

        XCTAssertEqual(StoreKitService.shared.currentTier, "plus")
        XCTAssertEqual(UserDefaults.standard.string(forKey: "leon_subscription_tier"), "plus")
    }

    func testApplyQuotaTierBackToFreeClearsPersistedKey() {
        StoreKitService.shared.applyQuotaTier("plus")
        StoreKitService.shared.applyQuotaTier("free")

        XCTAssertEqual(StoreKitService.shared.currentTier, "free")
        XCTAssertNil(UserDefaults.standard.string(forKey: "leon_subscription_tier"))
    }

    func testResetForSignOutClearsTierAndExpiry() {
        StoreKitService.shared.applyQuotaTier("plus")

        StoreKitService.shared.resetForSignOut()

        XCTAssertEqual(StoreKitService.shared.currentTier, "free")
        XCTAssertNil(StoreKitService.shared.subscriptionExpiresAt)
        XCTAssertNil(UserDefaults.standard.string(forKey: "leon_subscription_tier"))
    }

    func testLeonProductIDTierMapping() {
        XCTAssertEqual(LeonProductID.plusMonthly.tier, "plus")
        XCTAssertTrue(LeonProductID.plusMonthly.isSubscription)
        XCTAssertEqual(LeonProductID(rawValue: "leon.plus.monthly"), .plusMonthly)
        XCTAssertNil(LeonProductID(rawValue: "unknown.product"))
    }
}
