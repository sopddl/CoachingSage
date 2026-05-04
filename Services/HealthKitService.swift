// Services/HealthKitService.swift
// PRIMARY HealthKit impl — synchroniser GardenSage/TailorSage si port futur (voir mémoire architecture_decisions.md).
// Read-only V1 : profil (sex/DOB/poids/taille) pour onboarding (Story 2.2)
// + autoprofil (vo2Max, workouts récents) pour Story Autoprofil HealthKit (Epic 3 Phase 2 #4).
// Hub universel (écriture sessions, HR streaming) reporté Epic 7.
import Foundation
import HealthKit
import os

// MARK: - Result structs

struct HealthKitProfileData: Equatable, Sendable {
    let biologicalSex: HKBiologicalSex?
    let dateOfBirth: Date?
    let bodyMassKg: Double?
    let heightCm: Double?
}

struct HealthKitVO2MaxSample: Equatable, Sendable {
    let value: Double // mL/(kg·min)
    let date: Date
    let sourceName: String?
}

struct HealthKitWorkoutSummary: Equatable, Sendable {
    let totalCount: Int
    let weeklyAverage: Double
    /// Le sport dominant sur la fenêtre (par count). nil si vide.
    let dominantActivityRawValue: UInt?
    /// `true` si au moins un workout est sourcé par un appareil watchOS (productType "Watch...").
    let appleWatchDetected: Bool

    static let empty = HealthKitWorkoutSummary(
        totalCount: 0,
        weeklyAverage: 0,
        dominantActivityRawValue: nil,
        appleWatchDetected: false
    )
}

// MARK: - Errors

enum HealthKitError: LocalizedError {
    case notAvailable

    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "HealthKit n'est pas disponible sur cet appareil."
        }
    }
}

// MARK: - Protocol

protocol HealthKitServiceProtocol: Sendable {
    /// `false` sur Mac et iPad < iPadOS 17. Raccourci UI conditionnelle pour Story 2.2 — pas un prérequis fonctionnel.
    var isHealthDataAvailable: Bool { get }

    /// `true` si `requestProfileAuthorization()` a déjà été appelé avec succès au moins une fois sur ce device.
    /// Permet à Story 2.2 de différencier « première fois → afficher CTA » vs « déjà demandé → ne pas re-prompter ».
    var hasRequestedAuthorization: Bool { get }

    /// Demande l'autorisation pour les types READ : profil (sex, DOB, bodyMass, height) + autoprofil (vo2Max, workouts, heartRate).
    /// Aucun WRITE V1. Une seule pop-up système groupée.
    /// Throw uniquement si HealthKit est indisponible (iPad incompatible) ou erreur HKError critique.
    /// Apple ne révèle pas le refus côté READ — la sémantique « refusé » se mesure via nil dans les fetch.
    func requestProfileAuthorization() async throws

    /// Lit les 4 caractéristiques profil. Ne throw jamais : un champ nil = donnée non disponible / refusée silencieusement.
    func fetchProfileData() async -> HealthKitProfileData

    /// Sample VO2max le plus récent dans la fenêtre `monthsBack` (défaut 6 mois). nil si refus/absence.
    func fetchVO2MaxRecent(monthsBack: Int) async -> HealthKitVO2MaxSample?

    /// Résumé des workouts sur la fenêtre `weeksBack` (défaut 8 semaines). Struct vide si refus/absence.
    func fetchWorkoutSummary(weeksBack: Int) async -> HealthKitWorkoutSummary
}

extension HealthKitServiceProtocol {
    func fetchVO2MaxRecent() async -> HealthKitVO2MaxSample? {
        await fetchVO2MaxRecent(monthsBack: 6)
    }

    func fetchWorkoutSummary() async -> HealthKitWorkoutSummary {
        await fetchWorkoutSummary(weeksBack: 8)
    }
}

// MARK: - Default impl

final class DefaultHealthKitService: HealthKitServiceProtocol, @unchecked Sendable {
    private static let logger = Logger(subsystem: "com.sopddl.coachingsage", category: "service")
    private static let authorizationRequestedKey = "healthkit.authorization.requested"

    private let healthStore = HKHealthStore()
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    var isHealthDataAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    var hasRequestedAuthorization: Bool {
        guard !Self.isUITesting else { return false }
        return userDefaults.bool(forKey: Self.authorizationRequestedKey)
    }

    func requestProfileAuthorization() async throws {
        guard !Self.isUITesting else { return }
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HealthKitError.notAvailable
        }

        var typesToRead: Set<HKObjectType> = [HKObjectType.workoutType()]
        if let sex = HKCharacteristicType.characteristicType(forIdentifier: .biologicalSex) {
            typesToRead.insert(sex)
        }
        if let dob = HKCharacteristicType.characteristicType(forIdentifier: .dateOfBirth) {
            typesToRead.insert(dob)
        }
        if let mass = HKQuantityType.quantityType(forIdentifier: .bodyMass) {
            typesToRead.insert(mass)
        }
        if let height = HKQuantityType.quantityType(forIdentifier: .height) {
            typesToRead.insert(height)
        }
        if let vo2 = HKQuantityType.quantityType(forIdentifier: .vo2Max) {
            typesToRead.insert(vo2)
        }
        if let hr = HKQuantityType.quantityType(forIdentifier: .heartRate) {
            typesToRead.insert(hr)
        }

        try await healthStore.requestAuthorization(toShare: [], read: typesToRead)
        userDefaults.set(true, forKey: Self.authorizationRequestedKey)
    }

    func fetchProfileData() async -> HealthKitProfileData {
        guard !Self.isUITesting else {
            return HealthKitProfileData(biologicalSex: nil, dateOfBirth: nil, bodyMassKg: nil, heightCm: nil)
        }
        guard HKHealthStore.isHealthDataAvailable() else {
            return HealthKitProfileData(biologicalSex: nil, dateOfBirth: nil, bodyMassKg: nil, heightCm: nil)
        }

        let sex = readBiologicalSex()
        let dob = readDateOfBirth()
        let bodyMass = await readLatestQuantity(identifier: .bodyMass, unit: .gramUnit(with: .kilo))
        let height = await readLatestQuantity(identifier: .height, unit: .meterUnit(with: .centi))

        return HealthKitProfileData(
            biologicalSex: sex,
            dateOfBirth: dob,
            bodyMassKg: bodyMass,
            heightCm: height
        )
    }

    func fetchVO2MaxRecent(monthsBack: Int) async -> HealthKitVO2MaxSample? {
        guard !Self.isUITesting else { return nil }
        guard HKHealthStore.isHealthDataAvailable() else { return nil }
        guard let type = HKQuantityType.quantityType(forIdentifier: .vo2Max) else { return nil }

        let startDate = Calendar(identifier: .gregorian).date(byAdding: .month, value: -monthsBack, to: Date()) ?? Date()
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: nil, options: [])
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)

        return await withCheckedContinuation { (continuation: CheckedContinuation<HealthKitVO2MaxSample?, Never>) in
            let query = HKSampleQuery(
                sampleType: type,
                predicate: predicate,
                limit: 1,
                sortDescriptors: [sortDescriptor]
            ) { _, results, error in
                #if DEBUG
                if let error {
                    Self.logger.debug("vo2Max query error: \(error.localizedDescription)")
                }
                #endif
                guard let sample = (results as? [HKQuantitySample])?.first else {
                    continuation.resume(returning: nil)
                    return
                }
                let unit = HKUnit(from: "ml/kg*min")
                let value = sample.quantity.doubleValue(for: unit)
                continuation.resume(returning: HealthKitVO2MaxSample(
                    value: value,
                    date: sample.endDate,
                    sourceName: sample.sourceRevision.source.name
                ))
            }
            healthStore.execute(query)
        }
    }

    func fetchWorkoutSummary(weeksBack: Int) async -> HealthKitWorkoutSummary {
        guard !Self.isUITesting else { return .empty }
        guard HKHealthStore.isHealthDataAvailable() else { return .empty }

        let now = Date()
        guard let startDate = Calendar(identifier: .gregorian).date(byAdding: .weekOfYear, value: -weeksBack, to: now) else {
            return .empty
        }
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: [])
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)

        let workouts: [HKWorkout] = await withCheckedContinuation { (continuation: CheckedContinuation<[HKWorkout], Never>) in
            let query = HKSampleQuery(
                sampleType: HKObjectType.workoutType(),
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sortDescriptor]
            ) { _, results, error in
                #if DEBUG
                if let error {
                    Self.logger.debug("workout query error: \(error.localizedDescription)")
                }
                #endif
                continuation.resume(returning: (results as? [HKWorkout]) ?? [])
            }
            healthStore.execute(query)
        }

        guard !workouts.isEmpty else { return .empty }

        let weeklyAverage = Double(workouts.count) / Double(max(weeksBack, 1))

        var counts: [UInt: Int] = [:]
        for workout in workouts {
            counts[workout.workoutActivityType.rawValue, default: 0] += 1
        }
        let dominant = counts.max(by: { $0.value < $1.value })?.key

        let appleWatchDetected = workouts.contains { workout in
            let productType = workout.sourceRevision.productType ?? ""
            return productType.lowercased().hasPrefix("watch")
        }

        return HealthKitWorkoutSummary(
            totalCount: workouts.count,
            weeklyAverage: weeklyAverage,
            dominantActivityRawValue: dominant,
            appleWatchDetected: appleWatchDetected
        )
    }

    // MARK: - Private — caractéristiques

    private func readBiologicalSex() -> HKBiologicalSex? {
        do {
            let value = try healthStore.biologicalSex().biologicalSex
            return value == .notSet ? nil : value
        } catch {
            #if DEBUG
            Self.logger.debug("biologicalSex throw — auth requested? hasRequestedAuthorization=\(self.hasRequestedAuthorization)")
            #endif
            return nil
        }
    }

    private func readDateOfBirth() -> Date? {
        do {
            let components = try healthStore.dateOfBirthComponents()
            return Calendar(identifier: .gregorian).date(from: components)
        } catch {
            #if DEBUG
            Self.logger.debug("dateOfBirth throw — auth requested? hasRequestedAuthorization=\(self.hasRequestedAuthorization)")
            #endif
            return nil
        }
    }

    // MARK: - Private — quantités

    private func readLatestQuantity(identifier: HKQuantityTypeIdentifier, unit: HKUnit) async -> Double? {
        guard let type = HKQuantityType.quantityType(forIdentifier: identifier) else { return nil }
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)

        return await withCheckedContinuation { (continuation: CheckedContinuation<Double?, Never>) in
            let query = HKSampleQuery(
                sampleType: type,
                predicate: nil,
                limit: 1,
                sortDescriptors: [sortDescriptor]
            ) { _, results, error in
                #if DEBUG
                if let error {
                    Self.logger.debug("\(identifier.rawValue) query error: \(error.localizedDescription)")
                }
                #endif
                let sample = (results as? [HKQuantitySample])?.first
                continuation.resume(returning: sample?.quantity.doubleValue(for: unit))
            }
            healthStore.execute(query)
        }
    }

    // MARK: - UI testing guard

    private static var isUITesting: Bool {
        ProcessInfo.processInfo.environment["IS_UI_TESTING"] != nil
    }
}
