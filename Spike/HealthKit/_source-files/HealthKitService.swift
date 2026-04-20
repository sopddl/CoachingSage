import Foundation
import Combine
import HealthKit

/// Minimal HealthKit service for the CoachingSage Spike 0.2.
///
/// Goal of the spike : validate the architectural assumption that HealthKit can serve as a
/// "universal hub" for fitness data, regardless of the source (iPhone alone, Apple Watch,
/// or 3rd party hardware that writes through HealthKit like Garmin Connect, Fitbit, Strava).
///
/// Production version of this service will live in `Services/HealthKit/HealthKitService.swift`
/// and be a protocol-based dependency injection target.
@MainActor
final class HealthKitService: ObservableObject {

    // MARK: - State

    @Published private(set) var status: HealthKitStatus = .unknown
    @Published private(set) var lastError: String?

    @Published var stepsToday: Int?
    @Published var stepsYesterday: Int?
    @Published var latestHeartRate: Double?
    @Published var heartRateSamples: [HeartRateSample] = []
    @Published var workoutsLast30Days: [WorkoutSummary] = []
    @Published var lastWrittenWorkoutId: UUID?

    enum HealthKitStatus: Equatable {
        case unknown
        case unavailable           // device doesn't support HealthKit
        case notAuthorized         // user hasn't granted permissions yet
        case partiallyAuthorized   // user granted some, denied others
        case authorized
    }

    struct HeartRateSample: Identifiable {
        let id = UUID()
        let bpm: Double
        let date: Date
        let sourceName: String
    }

    struct WorkoutSummary: Identifiable {
        let id: UUID
        let activityType: String
        let startDate: Date
        let endDate: Date
        let duration: TimeInterval
        let totalDistance: Double?     // meters
        let totalEnergyBurned: Double? // kcal
        let sourceName: String
    }

    // MARK: - Internals

    private let healthStore = HKHealthStore()

    /// Types we want to READ from HealthKit. The spike validates the "universal hub" claim
    /// by reading data that can come from any source.
    private var typesToRead: Set<HKObjectType> {
        var types: Set<HKObjectType> = []

        // Steps — works on iPhone alone (no Watch needed)
        if let stepCount = HKQuantityType.quantityType(forIdentifier: .stepCount) {
            types.insert(stepCount)
        }
        // Heart rate — typically Apple Watch, but any HealthKit-compatible HR monitor
        if let hr = HKQuantityType.quantityType(forIdentifier: .heartRate) {
            types.insert(hr)
        }
        // Active energy burned
        if let energy = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) {
            types.insert(energy)
        }
        // Distance walking/running
        if let dist = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) {
            types.insert(dist)
        }
        // Workouts (the magic key for "any source") — Garmin/Fitbit/Strava export to here
        types.insert(HKObjectType.workoutType())

        return types
    }

    /// Types we want to WRITE to HealthKit. We need to write workouts so the user's
    /// CoachingSage sessions show up in Apple Health and can be re-exported to Strava.
    private var typesToWrite: Set<HKSampleType> {
        var types: Set<HKSampleType> = [HKObjectType.workoutType()]
        if let energy = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) {
            types.insert(energy)
        }
        if let dist = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) {
            types.insert(dist)
        }
        return types
    }

    // MARK: - Public API

    /// Check whether HealthKit is even available on this device (it isn't on iPad before iPadOS 17,
    /// and it never is on macOS).
    func checkAvailability() {
        if HKHealthStore.isHealthDataAvailable() {
            // We don't know yet if user authorized — that requires the request flow
            status = .notAuthorized
        } else {
            status = .unavailable
            lastError = "HealthKit n'est pas disponible sur cet appareil."
        }
    }

    /// Request authorization. Apple's API never tells us if the user denied — for privacy reasons,
    /// we always get "success" regardless. We have to *infer* from later read attempts whether
    /// the user actually granted access.
    func requestAuthorization() async {
        guard HKHealthStore.isHealthDataAvailable() else {
            status = .unavailable
            return
        }

        do {
            try await healthStore.requestAuthorization(toShare: typesToWrite, read: typesToRead)
            // Apple won't tell us read auth status (privacy by design), only write auth status
            status = .authorized
            lastError = nil
        } catch {
            lastError = "Erreur autorisation : \(error.localizedDescription)"
            status = .notAuthorized
        }
    }

    // MARK: - Read : Steps

    /// Reads step count for today and yesterday. Works on iPhone alone (no Watch needed).
    /// In the iOS Simulator with no data, returns 0 — that's normal, not a bug.
    func readSteps() async {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }

        let today = await querySumQuantity(
            type: stepType,
            from: Calendar.current.startOfDay(for: Date()),
            to: Date(),
            unit: .count()
        )
        let startOfYesterday = Calendar.current.date(
            byAdding: .day, value: -1,
            to: Calendar.current.startOfDay(for: Date())
        )!
        let yesterday = await querySumQuantity(
            type: stepType,
            from: startOfYesterday,
            to: Calendar.current.startOfDay(for: Date()),
            unit: .count()
        )

        await MainActor.run {
            self.stepsToday = today.map { Int($0) }
            self.stepsYesterday = yesterday.map { Int($0) }
        }
    }

    // MARK: - Read : Heart Rate

    /// Reads the most recent heart rate samples. On simulator without data, returns nothing.
    /// On a real device with Apple Watch, should return frequent samples.
    func readRecentHeartRate(limit: Int = 10) async {
        guard let hrType = HKQuantityType.quantityType(forIdentifier: .heartRate) else { return }

        let predicate = HKQuery.predicateForSamples(
            withStart: Calendar.current.date(byAdding: .day, value: -7, to: Date()),
            end: Date(),
            options: .strictStartDate
        )
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

        let samples = await withCheckedContinuation { (continuation: CheckedContinuation<[HKQuantitySample], Never>) in
            let query = HKSampleQuery(
                sampleType: hrType,
                predicate: predicate,
                limit: limit,
                sortDescriptors: [sortDescriptor]
            ) { _, results, error in
                if let error = error {
                    print("[HealthKit] HR query error: \(error.localizedDescription)")
                }
                continuation.resume(returning: (results as? [HKQuantitySample]) ?? [])
            }
            healthStore.execute(query)
        }

        let unit = HKUnit.count().unitDivided(by: .minute()) // BPM
        let parsed = samples.map { sample in
            HeartRateSample(
                bpm: sample.quantity.doubleValue(for: unit),
                date: sample.startDate,
                sourceName: sample.sourceRevision.source.name
            )
        }

        await MainActor.run {
            self.heartRateSamples = parsed
            self.latestHeartRate = parsed.first?.bpm
        }
    }

    // MARK: - Read : Workouts (the crucial test for "universal hub")

    /// Reads recent workouts from HealthKit, regardless of source.
    /// This is the test that validates whether Garmin/Fitbit/Strava workouts that have been
    /// exported to HealthKit are actually visible to us.
    ///
    /// IMPORTANT : on the iOS Simulator, you must manually add a workout via the Health app
    /// or via this very spike (writeFakeRunningWorkout) to see anything.
    func readRecentWorkouts(daysBack: Int = 30) async {
        let calendar = Calendar.current
        let start = calendar.date(byAdding: .day, value: -daysBack, to: Date())!
        let predicate = HKQuery.predicateForSamples(
            withStart: start, end: Date(), options: .strictStartDate
        )
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

        let workouts = await withCheckedContinuation { (continuation: CheckedContinuation<[HKWorkout], Never>) in
            let query = HKSampleQuery(
                sampleType: .workoutType(),
                predicate: predicate,
                limit: 100,
                sortDescriptors: [sortDescriptor]
            ) { _, results, error in
                if let error = error {
                    print("[HealthKit] workouts query error: \(error.localizedDescription)")
                }
                continuation.resume(returning: (results as? [HKWorkout]) ?? [])
            }
            healthStore.execute(query)
        }

        let summaries: [WorkoutSummary] = workouts.map { workout in
            WorkoutSummary(
                id: workout.uuid,
                activityType: activityName(workout.workoutActivityType),
                startDate: workout.startDate,
                endDate: workout.endDate,
                duration: workout.duration,
                totalDistance: workout.totalDistance?.doubleValue(for: .meter()),
                totalEnergyBurned: workout.totalEnergyBurned?.doubleValue(for: .kilocalorie()),
                sourceName: workout.sourceRevision.source.name
            )
        }

        await MainActor.run {
            self.workoutsLast30Days = summaries
        }
    }

    // MARK: - Write : Fake Running Workout

    /// Writes a fake 30-minute running workout (5 km, 250 kcal) into HealthKit.
    /// Use this to validate that we can write workouts AND that they appear in the Health app.
    func writeFakeRunningWorkout() async {
        let now = Date()
        let start = Calendar.current.date(byAdding: .minute, value: -30, to: now)!
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .running
        configuration.locationType = .outdoor

        // Modern API (iOS 17+) : HKWorkoutBuilder
        let builder = HKWorkoutBuilder(healthStore: healthStore, configuration: configuration, device: .local())

        do {
            try await builder.beginCollection(at: start)

            // Add distance + energy as samples
            var samples: [HKSample] = []
            if let distType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) {
                let distQty = HKQuantity(unit: .meter(), doubleValue: 5000)
                samples.append(HKQuantitySample(type: distType, quantity: distQty, start: start, end: now))
            }
            if let energyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) {
                let energyQty = HKQuantity(unit: .kilocalorie(), doubleValue: 250)
                samples.append(HKQuantitySample(type: energyType, quantity: energyQty, start: start, end: now))
            }

            if !samples.isEmpty {
                try await builder.addSamples(samples)
            }

            try await builder.endCollection(at: now)
            let workout = try await builder.finishWorkout()

            await MainActor.run {
                self.lastWrittenWorkoutId = workout?.uuid
                self.lastError = nil
            }
        } catch {
            await MainActor.run {
                self.lastError = "Erreur écriture workout : \(error.localizedDescription)"
            }
        }
    }

    // MARK: - Helpers

    private func querySumQuantity(
        type: HKQuantityType,
        from: Date,
        to: Date,
        unit: HKUnit
    ) async -> Double? {
        let predicate = HKQuery.predicateForSamples(withStart: from, end: to, options: .strictStartDate)
        return await withCheckedContinuation { (continuation: CheckedContinuation<Double?, Never>) in
            let query = HKStatisticsQuery(
                quantityType: type,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, error in
                if let error = error {
                    print("[HealthKit] sum query error: \(error.localizedDescription)")
                    continuation.resume(returning: nil)
                    return
                }
                let value = result?.sumQuantity()?.doubleValue(for: unit)
                continuation.resume(returning: value)
            }
            healthStore.execute(query)
        }
    }

    private func activityName(_ type: HKWorkoutActivityType) -> String {
        switch type {
        case .running: return "Course"
        case .cycling: return "Vélo"
        case .swimming: return "Natation"
        case .walking: return "Marche"
        case .hiking: return "Randonnée"
        case .yoga: return "Yoga"
        case .traditionalStrengthTraining: return "Musculation"
        case .functionalStrengthTraining: return "Renforcement"
        case .highIntensityIntervalTraining: return "HIIT"
        case .tennis: return "Tennis"
        case .other: return "Autre"
        @unknown default: return "Inconnu (\(type.rawValue))"
        }
    }
}
