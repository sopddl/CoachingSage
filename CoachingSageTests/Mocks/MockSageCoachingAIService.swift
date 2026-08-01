// CoachingSageTests/Mocks/MockSageCoachingAIService.swift
// Story 3.3b — mock pour tests AdaptedProgramViewModel.
import Foundation
import StoreKit

final class MockSageCoachingAIService: SageCoachingAIServiceProtocol, @unchecked Sendable {
    var stubbedResponse: AdaptRareResponse?
    var stubbedError: LeonError?
    var receivedReason: AdaptRareReason?
    var callCount = 0

    func requestAdaptRare(
        triggeredReason: AdaptRareReason,
        templateJSON: Data,
        profileJSON: Data,
        healthSummary: HealthSummary,
        adaptedProgramJSON: Data
    ) async throws -> AdaptRareResponse {
        callCount += 1
        receivedReason = triggeredReason
        if let stubbedError { throw stubbedError }
        if let stubbedResponse { return stubbedResponse }
        // Default : patch vide (Léon n'a rien à dire) avec quota libre.
        return AdaptRareResponse(
            patch: AdaptationPatch(),
            quota: .init(used: 1, limit: 10, resetsAt: Date(), tier: "free"),
            meta: nil
        )
    }
}

final class MockHealthSummaryBuilder: HealthSummaryBuilding, @unchecked Sendable {
    var stubbedSummary: HealthSummary = HealthSummary()
    var callCount = 0

    func buildSummary() async -> HealthSummary {
        callCount += 1
        return stubbedSummary
    }
}

/// Léon+ — mock pour vérifier que `AdaptedProgramViewModel` synchronise bien le
/// tier reçu dans `AdaptRareResponse.quota` après chaque appel Léon réussi.
@MainActor
final class MockStoreKitService: StoreKitServiceProtocol {
    var products: [Product] = []
    var currentTier: String = "free"
    var subscriptionExpiresAt: Date?
    var appliedTiers: [String] = []
    private(set) var resetForSignOutCallCount = 0

    func loadProducts() async {}
    func purchase(_ product: Product) async throws -> LeonPurchaseResult { .userCancelled }
    func restorePurchases() async throws {}
    func refreshSubscriptionStatus() async {}

    func applyQuotaTier(_ tier: String) {
        appliedTiers.append(tier)
        currentTier = tier
    }

    func resetForSignOut() {
        resetForSignOutCallCount += 1
        currentTier = "free"
        subscriptionExpiresAt = nil
        appliedTiers.removeAll()
    }
}
