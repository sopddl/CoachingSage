// CoachingSageTests/Mocks/MockHealthKitService.swift
// Story 2.1 — mock pour les tests Story 2.2 (onboarding HealthKit pré-fill).
import Foundation
import HealthKit
@testable import CoachingSage

final class MockHealthKitService: HealthKitServiceProtocol, @unchecked Sendable {
    var isHealthDataAvailable: Bool = true
    var hasRequestedAuthorization: Bool = false
    var hasRequestedProgressAuthorization: Bool = false

    var stubbedProfile: HealthKitProfileData = HealthKitProfileData(
        biologicalSex: nil,
        dateOfBirth: nil,
        bodyMassKg: nil,
        heightCm: nil
    )

    var stubbedVO2MaxSample: HealthKitVO2MaxSample?
    var stubbedWorkoutSummary: HealthKitWorkoutSummary = .empty
    var stubbedRestingHeartRateAverage: Double?
    var stubbedRecentWorkoutDetails: [HealthKitWorkoutDetail] = []

    var requestAuthorizationCallCount: Int = 0
    var requestAuthorizationShouldThrow: Error?

    var requestProgressAuthorizationCallCount: Int = 0
    var requestProgressAuthorizationShouldThrow: Error?

    func requestProfileAuthorization() async throws {
        requestAuthorizationCallCount += 1
        if let error = requestAuthorizationShouldThrow {
            throw error
        }
        hasRequestedAuthorization = true
        hasRequestedProgressAuthorization = true
    }

    func requestProgressAuthorizationIfNeeded() async throws {
        if hasRequestedProgressAuthorization { return }
        requestProgressAuthorizationCallCount += 1
        if let error = requestProgressAuthorizationShouldThrow {
            throw error
        }
        hasRequestedProgressAuthorization = true
    }

    func fetchProfileData() async -> HealthKitProfileData {
        stubbedProfile
    }

    func fetchVO2MaxRecent(monthsBack: Int) async -> HealthKitVO2MaxSample? {
        stubbedVO2MaxSample
    }

    func fetchWorkoutSummary(weeksBack: Int) async -> HealthKitWorkoutSummary {
        stubbedWorkoutSummary
    }

    func fetchRestingHeartRateAverage(daysBack: Int) async -> Double? {
        stubbedRestingHeartRateAverage
    }

    func fetchRecentWorkoutDetails(limit: Int, weeksBack: Int) async -> [HealthKitWorkoutDetail] {
        stubbedRecentWorkoutDetails
    }
}
