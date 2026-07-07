// CoachingSageTests/Mocks/MockHealthKitService.swift
// Story 2.1 — mock pour les tests Story 2.2 (onboarding HealthKit pré-fill).
import Foundation
import HealthKit

final class MockHealthKitService: HealthKitServiceProtocol, @unchecked Sendable {
    var isHealthDataAvailable: Bool = true
    var hasRequestedAuthorization: Bool = false
    var hasRequestedProgressAuthorization: Bool = false
    var hasRequestedSwimAuthorization: Bool = false

    var stubbedProfile: HealthKitProfileData = HealthKitProfileData(
        biologicalSex: nil,
        dateOfBirth: nil,
        bodyMassKg: nil,
        heightCm: nil
    )

    var stubbedVO2MaxSample: HealthKitVO2MaxSample?
    var stubbedWorkoutSummary: HealthKitWorkoutSummary = .empty
    var stubbedRestingHeartRateAverage: Double?
    var stubbedHRVAverage: Double?
    var stubbedSleepAverageMinutes: Double?
    var stubbedWorkoutVolumeByActivityType: [UInt: TimeInterval] = [:]
    var stubbedRecentWorkoutDetails: [HealthKitWorkoutDetail] = []
    var stubbedSwimWorkoutDetails: [HealthKitSwimWorkoutDetail] = []

    var requestAuthorizationCallCount: Int = 0
    var requestAuthorizationShouldThrow: Error?

    var requestProgressAuthorizationCallCount: Int = 0
    var requestProgressAuthorizationShouldThrow: Error?

    var requestSwimAuthorizationCallCount: Int = 0
    var requestSwimAuthorizationShouldThrow: Error?

    func requestProfileAuthorization() async throws {
        requestAuthorizationCallCount += 1
        if let error = requestAuthorizationShouldThrow {
            throw error
        }
        hasRequestedAuthorization = true
        hasRequestedProgressAuthorization = true
    }

    var requestWorkoutAndFitnessAuthorizationCallCount: Int = 0

    func requestWorkoutAndFitnessAuthorization() async throws {
        requestWorkoutAndFitnessAuthorizationCallCount += 1
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

    var requestSwimInspectionAuthorizationCallCount: Int = 0

    func requestSwimInspectionAuthorization() async throws {
        requestSwimInspectionAuthorizationCallCount += 1
        if let error = requestSwimAuthorizationShouldThrow {
            throw error
        }
        hasRequestedSwimAuthorization = true
    }

    func requestSwimAuthorizationIfNeeded() async throws {
        if hasRequestedSwimAuthorization { return }
        requestSwimAuthorizationCallCount += 1
        if let error = requestSwimAuthorizationShouldThrow {
            throw error
        }
        hasRequestedSwimAuthorization = true
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

    func fetchRestingHeartRateAverage(daysBack: Int, endingAt: Date) async -> Double? {
        stubbedRestingHeartRateAverage
    }

    func fetchHRVAverage(daysBack: Int, endingAt: Date) async -> Double? {
        stubbedHRVAverage
    }

    func fetchSleepAverageMinutes(daysBack: Int, endingAt: Date) async -> Double? {
        stubbedSleepAverageMinutes
    }

    func fetchWorkoutVolumeByActivityType(daysBack: Int) async -> [UInt: TimeInterval] {
        stubbedWorkoutVolumeByActivityType
    }

    func fetchRecentWorkoutDetails(limit: Int, weeksBack: Int) async -> [HealthKitWorkoutDetail] {
        stubbedRecentWorkoutDetails
    }

    func fetchRecentSwimWorkoutDetails(limit: Int, weeksBack: Int) async -> [HealthKitSwimWorkoutDetail] {
        stubbedSwimWorkoutDetails
    }

    var stubbedSwimFetchDiagnostics = SwimFetchDiagnostics(
        healthDataAvailable: true,
        hasRequestedSwimAuthorization: false,
        workoutAuthStatus: "notDetermined",
        allWorkoutsCount: 0,
        swimWorkoutsCount: 0,
        activityTypeCounts: [:],
        swimQueryError: nil
    )

    func diagnoseSwimFetch(weeksBack: Int) async -> SwimFetchDiagnostics {
        stubbedSwimFetchDiagnostics
    }
}
