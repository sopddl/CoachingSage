// CoachingSageTests/Mocks/MockSageCoachingAIService.swift
// Story 3.3b — mock pour tests AdaptedProgramViewModel.
import Foundation
@testable import CoachingSage

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
