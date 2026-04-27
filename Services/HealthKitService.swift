// Services/HealthKitService.swift
// PRIMARY HealthKit impl — synchroniser GardenSage/TailorSage si port futur (voir mémoire architecture_decisions.md).
// Read-only V1 : sex/DOB/poids/taille pour onboarding (Story 2.2).
// Hub universel (workouts, HR, écriture sessions) reporté Epic 7.
import Foundation
import HealthKit
import os

// MARK: - Result struct

struct HealthKitProfileData: Equatable, Sendable {
    let biologicalSex: HKBiologicalSex?
    let dateOfBirth: Date?
    let bodyMassKg: Double?
    let heightCm: Double?
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

    /// Demande l'autorisation pour 4 types READ (sex, DOB, bodyMass, height). Aucun WRITE V1.
    /// Throw uniquement si HealthKit est indisponible (iPad incompatible) ou erreur HKError critique.
    /// Apple ne révèle pas le refus côté READ — la sémantique « refusé » se mesure via nil dans `fetchProfileData()`.
    func requestProfileAuthorization() async throws

    /// Lit les 4 caractéristiques. Ne throw jamais : un champ nil = donnée non disponible / refusée silencieusement.
    func fetchProfileData() async -> HealthKitProfileData
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

        var typesToRead: Set<HKObjectType> = []
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
