// CoachingSageTests/Mocks/MockHealthKitService.swift
// Story 2.1 — mock pour les tests Story 2.2 (onboarding HealthKit pré-fill).
import Foundation
import HealthKit
@testable import CoachingSage

final class MockHealthKitService: HealthKitServiceProtocol, @unchecked Sendable {
    var isHealthDataAvailable: Bool = true
    var hasRequestedAuthorization: Bool = false

    var stubbedProfile: HealthKitProfileData = HealthKitProfileData(
        biologicalSex: nil,
        dateOfBirth: nil,
        bodyMassKg: nil,
        heightCm: nil
    )

    var stubbedVO2MaxSample: HealthKitVO2MaxSample?
    var stubbedWorkoutSummary: HealthKitWorkoutSummary = .empty

    var requestAuthorizationCallCount: Int = 0
    var requestAuthorizationShouldThrow: Error?

    func requestProfileAuthorization() async throws {
        requestAuthorizationCallCount += 1
        if let error = requestAuthorizationShouldThrow {
            throw error
        }
        hasRequestedAuthorization = true
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
}
