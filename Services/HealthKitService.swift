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

/// Story 3.3b — détail d'un workout pour `HealthSummaryBuilder`. Volontairement
/// minimal et anonymisé : pas de coordonnées GPS, pas de date absolue (uniquement
/// `daysAgo` relatif), pas d'identifiants. Léon n'a besoin que de calibrer
/// l'intensité réelle vs prescrite.
struct HealthKitWorkoutDetail: Equatable, Sendable {
    let activityTypeRawValue: UInt
    let durationMinutes: Int
    /// HR moyenne en BPM si disponible (refus auth ou Watch absente → nil).
    let averageHeartRateBpm: Int?
    /// HR max observée pendant le workout en BPM si disponible.
    let maxHeartRateBpm: Int?
    /// Jours écoulés depuis la fin du workout (0 = aujourd'hui).
    let daysAgo: Int
    /// `true` si workout sourcé par un appareil watchOS.
    let fromAppleWatch: Bool
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

    /// Story 3.9.0 — `true` si l'extension Progrès (RHR / HRV SDNN / Sleep Analysis) a déjà été demandée via
    /// `requestProgressAuthorizationIfNeeded()` ou implicitement via `requestProfileAuthorization()` post-Story 3.9.0.
    /// Permet à l'onglet Progrès de ne pas re-prompter en boucle (HK ne distingue pas refus historique vs jamais demandé).
    var hasRequestedProgressAuthorization: Bool { get }

    /// Demande l'autorisation pour les types READ : profil (sex, DOB, bodyMass, height) + autoprofil (vo2Max, workouts, heartRate)
    /// + Progrès Story 3.9.0 (restingHeartRate, heartRateVariabilitySDNN, sleepAnalysis).
    /// Aucun WRITE V1. Une seule pop-up système groupée.
    /// Throw uniquement si HealthKit est indisponible (iPad incompatible) ou erreur HKError critique.
    /// Apple ne révèle pas le refus côté READ — la sémantique « refusé » se mesure via nil dans les fetch.
    func requestProfileAuthorization() async throws

    /// Story 3.9.0 — demande l'extension Progrès uniquement si elle n'a jamais été demandée
    /// (utilisateurs existants post-Story 2.1 dont l'onboarding n'a pas couvert RHR / HRV / Sleep).
    /// Invoquée au premier `onAppear` de l'onglet Progrès. No-op si déjà demandé ou si HealthKit indisponible.
    /// Throw uniquement si HealthKit est indisponible. Le refus utilisateur reste silencieux côté READ.
    func requestProgressAuthorizationIfNeeded() async throws

    /// Lit les 4 caractéristiques profil. Ne throw jamais : un champ nil = donnée non disponible / refusée silencieusement.
    func fetchProfileData() async -> HealthKitProfileData

    /// Sample VO2max le plus récent dans la fenêtre `monthsBack` (défaut 6 mois). nil si refus/absence.
    func fetchVO2MaxRecent(monthsBack: Int) async -> HealthKitVO2MaxSample?

    /// Résumé des workouts sur la fenêtre `weeksBack` (défaut 8 semaines). Struct vide si refus/absence.
    func fetchWorkoutSummary(weeksBack: Int) async -> HealthKitWorkoutSummary

    /// Story 3.3b — moyenne du resting heart rate sur la fenêtre [endingAt - daysBack, endingAt].
    /// nil si refus/absence/échantillons insuffisants. Utilisé par `HealthSummaryBuilder`
    /// pour donner à Léon une mesure objective de récupération/forme du jour.
    /// Story 3.9 ajoute `endingAt` pour permettre le calcul delta vs fenêtre précédente.
    func fetchRestingHeartRateAverage(daysBack: Int, endingAt: Date) async -> Double?

    /// Story 3.9 — moyenne HRV SDNN (ms) sur la fenêtre [endingAt - daysBack, endingAt].
    /// nil si refus/absence. Affichage neutre uniquement (garde-fou EU MDR : aucune
    /// interprétation "fatigue/récupération" côté UI).
    func fetchHRVAverage(daysBack: Int, endingAt: Date) async -> Double?

    /// Story 3.9 — durée moyenne de sommeil (minutes par nuit) sur la fenêtre
    /// [endingAt - daysBack, endingAt]. Agrège tous les `HKCategoryValueSleepAnalysis.asleep*`
    /// groupés par jour calendaire de fin de sample. nil si refus/absence.
    func fetchSleepAverageMinutes(daysBack: Int, endingAt: Date) async -> Double?

    /// Story 3.9 — volume HK par `HKWorkoutActivityType.rawValue` sur la fenêtre `daysBack`.
    /// Somme des `workout.duration` (secondes) par activityType. Dictionnaire vide si refus/absence.
    /// Source pour le bloc « Volume par sport » de l'onglet Progrès.
    func fetchWorkoutVolumeByActivityType(daysBack: Int) async -> [UInt: TimeInterval]

    /// Story 3.3b — derniers `limit` workouts dans la fenêtre `weeksBack`, ordre antichronologique.
    /// Inclut HR moyenne + max si watchOS présent. Tableau vide si refus/absence.
    func fetchRecentWorkoutDetails(limit: Int, weeksBack: Int) async -> [HealthKitWorkoutDetail]
}

extension HealthKitServiceProtocol {
    func fetchVO2MaxRecent() async -> HealthKitVO2MaxSample? {
        await fetchVO2MaxRecent(monthsBack: 6)
    }

    func fetchWorkoutSummary() async -> HealthKitWorkoutSummary {
        await fetchWorkoutSummary(weeksBack: 8)
    }

    func fetchRestingHeartRateAverage() async -> Double? {
        await fetchRestingHeartRateAverage(daysBack: 30, endingAt: Date())
    }

    func fetchRestingHeartRateAverage(daysBack: Int) async -> Double? {
        await fetchRestingHeartRateAverage(daysBack: daysBack, endingAt: Date())
    }

    func fetchHRVAverage(daysBack: Int) async -> Double? {
        await fetchHRVAverage(daysBack: daysBack, endingAt: Date())
    }

    func fetchSleepAverageMinutes(daysBack: Int) async -> Double? {
        await fetchSleepAverageMinutes(daysBack: daysBack, endingAt: Date())
    }

    func fetchRecentWorkoutDetails() async -> [HealthKitWorkoutDetail] {
        await fetchRecentWorkoutDetails(limit: 4, weeksBack: 4)
    }
}

// MARK: - Default impl

final class DefaultHealthKitService: HealthKitServiceProtocol, @unchecked Sendable {
    private static let logger = Logger(subsystem: "com.sopddl.coachingsage", category: "service")
    private static let authorizationRequestedKey = "healthkit.authorization.requested"
    private static let progressAuthorizationRequestedAtKey = "healthkit.progress.authorization.requested.at"

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

    var hasRequestedProgressAuthorization: Bool {
        guard !Self.isUITesting else { return false }
        return userDefaults.object(forKey: Self.progressAuthorizationRequestedAtKey) is Date
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
        if let restingHR = HKQuantityType.quantityType(forIdentifier: .restingHeartRate) {
            typesToRead.insert(restingHR)
        }
        for type in Self.progressReadTypes() {
            typesToRead.insert(type)
        }

        try await healthStore.requestAuthorization(toShare: [], read: typesToRead)
        userDefaults.set(true, forKey: Self.authorizationRequestedKey)
        userDefaults.set(Date(), forKey: Self.progressAuthorizationRequestedAtKey)
    }

    func requestProgressAuthorizationIfNeeded() async throws {
        guard !Self.isUITesting else { return }
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HealthKitError.notAvailable
        }
        guard !hasRequestedProgressAuthorization else { return }

        let typesToRead = Self.progressReadTypes()
        try await healthStore.requestAuthorization(toShare: [], read: typesToRead)
        userDefaults.set(Date(), forKey: Self.progressAuthorizationRequestedAtKey)
    }

    /// Story 3.9.0 — types HK ajoutés pour le bloc Forme physique de l'onglet Progrès.
    /// Sleep Analysis est un `HKCategoryType`, les deux autres sont `HKQuantityType`.
    private static func progressReadTypes() -> Set<HKObjectType> {
        var types: Set<HKObjectType> = []
        if let rhr = HKQuantityType.quantityType(forIdentifier: .restingHeartRate) {
            types.insert(rhr)
        }
        if let hrv = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN) {
            types.insert(hrv)
        }
        if let sleep = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis) {
            types.insert(sleep)
        }
        return types
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

    func fetchRestingHeartRateAverage(daysBack: Int, endingAt: Date) async -> Double? {
        guard !Self.isUITesting else { return nil }
        guard HKHealthStore.isHealthDataAvailable() else { return nil }
        guard let type = HKQuantityType.quantityType(forIdentifier: .restingHeartRate) else { return nil }

        guard let startDate = Calendar(identifier: .gregorian).date(byAdding: .day, value: -daysBack, to: endingAt) else {
            return nil
        }
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endingAt, options: [])

        return await withCheckedContinuation { (continuation: CheckedContinuation<Double?, Never>) in
            let query = HKStatisticsQuery(
                quantityType: type,
                quantitySamplePredicate: predicate,
                options: .discreteAverage
            ) { _, statistics, error in
                #if DEBUG
                if let error {
                    Self.logger.debug("restingHeartRate query error: \(error.localizedDescription)")
                }
                #endif
                let unit = HKUnit.count().unitDivided(by: .minute())
                let avg = statistics?.averageQuantity()?.doubleValue(for: unit)
                continuation.resume(returning: avg)
            }
            healthStore.execute(query)
        }
    }

    func fetchHRVAverage(daysBack: Int, endingAt: Date) async -> Double? {
        guard !Self.isUITesting else { return nil }
        guard HKHealthStore.isHealthDataAvailable() else { return nil }
        guard let type = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN) else { return nil }

        guard let startDate = Calendar(identifier: .gregorian).date(byAdding: .day, value: -daysBack, to: endingAt) else {
            return nil
        }
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endingAt, options: [])

        return await withCheckedContinuation { (continuation: CheckedContinuation<Double?, Never>) in
            let query = HKStatisticsQuery(
                quantityType: type,
                quantitySamplePredicate: predicate,
                options: .discreteAverage
            ) { _, statistics, error in
                #if DEBUG
                if let error {
                    Self.logger.debug("HRV SDNN query error: \(error.localizedDescription)")
                }
                #endif
                let unit = HKUnit.secondUnit(with: .milli)
                let avg = statistics?.averageQuantity()?.doubleValue(for: unit)
                continuation.resume(returning: avg)
            }
            healthStore.execute(query)
        }
    }

    func fetchSleepAverageMinutes(daysBack: Int, endingAt: Date) async -> Double? {
        guard !Self.isUITesting else { return nil }
        guard HKHealthStore.isHealthDataAvailable() else { return nil }
        guard let type = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis) else { return nil }

        let calendar = Calendar(identifier: .gregorian)
        guard let startDate = calendar.date(byAdding: .day, value: -daysBack, to: endingAt) else {
            return nil
        }
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endingAt, options: [])

        let samples: [HKCategorySample] = await withCheckedContinuation { (continuation: CheckedContinuation<[HKCategorySample], Never>) in
            let query = HKSampleQuery(
                sampleType: type,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
            ) { _, results, error in
                #if DEBUG
                if let error {
                    Self.logger.debug("sleep query error: \(error.localizedDescription)")
                }
                #endif
                continuation.resume(returning: (results as? [HKCategorySample]) ?? [])
            }
            healthStore.execute(query)
        }

        guard !samples.isEmpty else { return nil }

        // Garde uniquement les segments « asleep* » (asleepUnspecified, asleepCore,
        // asleepDeep, asleepREM). On rejette `inBed` (utilisateur au lit mais éveillé)
        // et `awake`. iOS 16+ : asleepUnspecified == ancien .asleep deprecated.
        let asleepValues: Set<Int> = [
            HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue,
            HKCategoryValueSleepAnalysis.asleepCore.rawValue,
            HKCategoryValueSleepAnalysis.asleepDeep.rawValue,
            HKCategoryValueSleepAnalysis.asleepREM.rawValue
        ]

        // Groupe par jour calendaire de la fin du sample = nuit qui se termine ce
        // jour-là. Permet de moyenner sur le nombre de nuits réellement enregistrées
        // dans la fenêtre (pas sur `daysBack` brut — un user qui ne porte pas la Watch
        // 3 nuits/7 doit voir la moyenne des 4 nuits, pas une moyenne tirée vers 0).
        var minutesPerNight: [Date: Double] = [:]
        for sample in samples where asleepValues.contains(sample.value) {
            let dayKey = calendar.startOfDay(for: sample.endDate)
            let durationMin = sample.endDate.timeIntervalSince(sample.startDate) / 60.0
            minutesPerNight[dayKey, default: 0] += durationMin
        }

        guard !minutesPerNight.isEmpty else { return nil }
        let total = minutesPerNight.values.reduce(0, +)
        return total / Double(minutesPerNight.count)
    }

    func fetchWorkoutVolumeByActivityType(daysBack: Int) async -> [UInt: TimeInterval] {
        guard !Self.isUITesting else { return [:] }
        guard HKHealthStore.isHealthDataAvailable() else { return [:] }

        let now = Date()
        guard let startDate = Calendar(identifier: .gregorian).date(byAdding: .day, value: -daysBack, to: now) else {
            return [:]
        }
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: [])

        let workouts: [HKWorkout] = await withCheckedContinuation { (continuation: CheckedContinuation<[HKWorkout], Never>) in
            let query = HKSampleQuery(
                sampleType: HKObjectType.workoutType(),
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
            ) { _, results, error in
                #if DEBUG
                if let error {
                    Self.logger.debug("workout volume query error: \(error.localizedDescription)")
                }
                #endif
                continuation.resume(returning: (results as? [HKWorkout]) ?? [])
            }
            healthStore.execute(query)
        }

        var byType: [UInt: TimeInterval] = [:]
        for workout in workouts {
            byType[workout.workoutActivityType.rawValue, default: 0] += workout.duration
        }
        return byType
    }

    func fetchRecentWorkoutDetails(limit: Int, weeksBack: Int) async -> [HealthKitWorkoutDetail] {
        guard !Self.isUITesting else { return [] }
        guard HKHealthStore.isHealthDataAvailable() else { return [] }

        let now = Date()
        guard let startDate = Calendar(identifier: .gregorian).date(byAdding: .weekOfYear, value: -weeksBack, to: now) else {
            return []
        }
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: [])
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)

        let workouts: [HKWorkout] = await withCheckedContinuation { (continuation: CheckedContinuation<[HKWorkout], Never>) in
            let query = HKSampleQuery(
                sampleType: HKObjectType.workoutType(),
                predicate: predicate,
                limit: limit,
                sortDescriptors: [sortDescriptor]
            ) { _, results, error in
                #if DEBUG
                if let error {
                    Self.logger.debug("workout details query error: \(error.localizedDescription)")
                }
                #endif
                continuation.resume(returning: (results as? [HKWorkout]) ?? [])
            }
            healthStore.execute(query)
        }

        var details: [HealthKitWorkoutDetail] = []
        details.reserveCapacity(workouts.count)
        for workout in workouts {
            let (avgHR, maxHR) = await readHeartRateStats(for: workout)
            let durationMinutes = Int((workout.duration / 60.0).rounded())
            let daysAgo = Calendar(identifier: .gregorian).dateComponents([.day], from: workout.endDate, to: now).day ?? 0
            let productType = workout.sourceRevision.productType ?? ""
            let fromAppleWatch = productType.lowercased().hasPrefix("watch")

            details.append(HealthKitWorkoutDetail(
                activityTypeRawValue: workout.workoutActivityType.rawValue,
                durationMinutes: durationMinutes,
                averageHeartRateBpm: avgHR.map { Int($0.rounded()) },
                maxHeartRateBpm: maxHR.map { Int($0.rounded()) },
                daysAgo: max(0, daysAgo),
                fromAppleWatch: fromAppleWatch
            ))
        }
        return details
    }

    private func readHeartRateStats(for workout: HKWorkout) async -> (average: Double?, max: Double?) {
        guard let hrType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            return (nil, nil)
        }
        let predicate = HKQuery.predicateForSamples(withStart: workout.startDate, end: workout.endDate, options: [])

        return await withCheckedContinuation { (continuation: CheckedContinuation<(Double?, Double?), Never>) in
            let query = HKStatisticsQuery(
                quantityType: hrType,
                quantitySamplePredicate: predicate,
                options: [.discreteAverage, .discreteMax]
            ) { _, statistics, _ in
                let unit = HKUnit.count().unitDivided(by: .minute())
                let avg = statistics?.averageQuantity()?.doubleValue(for: unit)
                let maxVal = statistics?.maximumQuantity()?.doubleValue(for: unit)
                continuation.resume(returning: (avg, maxVal))
            }
            healthStore.execute(query)
        }
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
