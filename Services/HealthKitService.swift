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

/// Story 3.16 (DEBUG) — résultat du diagnostic de fetch natation. Sert à
/// distinguer, dans l'écran d'inspection, un « vrai 0 séance » d'un souci
/// d'autorisation / sync / erreur HK silencieuse.
struct SwimFetchDiagnostics: Equatable, Sendable {
    let healthDataAvailable: Bool
    let hasRequestedSwimAuthorization: Bool
    /// Statut d'autorisation (PARTAGE) pour `workoutType()` — indicatif :
    /// `.notDetermined` = jamais demandé, `.sharingDenied`/`.sharingAuthorized`
    /// concernent l'écriture (HK ne révèle pas le statut de lecture).
    let workoutAuthStatus: String
    /// Nombre de workouts TOUS sports dans la fenêtre (requête témoin sans predicate natation).
    let allWorkoutsCount: Int
    /// Nombre de workouts natation (même predicate que le fetch réel).
    let swimWorkoutsCount: Int
    /// Activity types distincts trouvés (rawValue → count) sur la requête témoin.
    let activityTypeCounts: [UInt: Int]
    /// Description de l'erreur de la requête natation, si la requête a échoué.
    let swimQueryError: String?
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

    /// Story 3.16 — `true` si l'extension natation (distanceSwimming + swimmingStrokeCount)
    /// a déjà été demandée via `requestSwimAuthorizationIfNeeded()`. Permet de ne pas
    /// re-prompter en boucle. **Délibérément séparé** du batch `requestProfileAuthorization()`
    /// (privacy UX : un user "running only" ne doit pas voir la popup HK swim au onboarding).
    var hasRequestedSwimAuthorization: Bool { get }

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

    /// Story 3.16 — demande l'extension natation (distanceSwimming + swimmingStrokeCount)
    /// uniquement si elle n'a jamais été demandée. Déclenchée conditionnellement à la
    /// présence d'un profil sport natation actif (hook dashboard refresh + finalize onboarding).
    /// No-op si déjà demandé, si HealthKit indisponible, ou en UI testing. Le refus utilisateur
    /// reste silencieux côté READ — la sémantique se mesure via tableau vide dans `fetchRecentSwimWorkoutDetails`.
    func requestSwimAuthorizationIfNeeded() async throws

    /// Story 3.16 (DEBUG) — demande **ungated** de l'autorisation complète natation
    /// (workouts + distance + strokes + HR + énergie). Contrairement à
    /// `requestSwimAuthorizationIfNeeded()`, ignore le garde `hasRequestedSwimAuthorization`
    /// pour pouvoir accorder `workoutType` même après une demande partielle (cas Dev Login).
    /// Utilisé par l'écran d'inspection. Throw uniquement si HealthKit indisponible.
    func requestSwimInspectionAuthorization() async throws

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

    /// Story 3.16 — derniers `limit` workouts natation dans la fenêtre `weeksBack`,
    /// ordre antichronologique. Lit la décomposition lap-by-lap (stroke style, pace,
    /// HR par lap) quand disponible. Tableau vide si refus/absence/aucun workout swim.
    /// Jamais throw.
    func fetchRecentSwimWorkoutDetails(limit: Int, weeksBack: Int) async -> [HealthKitSwimWorkoutDetail]

    /// Story 3.16 (DEBUG) — diagnostic du fetch natation : distingue « 0 séance vraie »
    /// d'un problème d'autorisation/sync/erreur silencieuse. Jamais throw.
    func diagnoseSwimFetch(weeksBack: Int) async -> SwimFetchDiagnostics
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

    func fetchRecentSwimWorkoutDetails() async -> [HealthKitSwimWorkoutDetail] {
        await fetchRecentSwimWorkoutDetails(limit: 12, weeksBack: 12)
    }
}

// MARK: - Default impl

final class DefaultHealthKitService: HealthKitServiceProtocol, @unchecked Sendable {
    private static let logger = Logger(subsystem: "com.sopddl.coachingsage", category: "service")
    private static let authorizationRequestedKey = "healthkit.authorization.requested"
    private static let progressAuthorizationRequestedAtKey = "healthkit.progress.authorization.requested.at"
    private static let swimAuthorizationRequestedAtKey = "healthkit.swim.authorization.requested.at"

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

    var hasRequestedSwimAuthorization: Bool {
        guard !Self.isUITesting else { return false }
        return userDefaults.object(forKey: Self.swimAuthorizationRequestedAtKey) is Date
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

    func requestSwimAuthorizationIfNeeded() async throws {
        guard !Self.isUITesting else { return }
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HealthKitError.notAvailable
        }
        guard !hasRequestedSwimAuthorization else { return }

        let typesToRead = Self.swimReadTypes()
        try await healthStore.requestAuthorization(toShare: [], read: typesToRead)
        userDefaults.set(Date(), forKey: Self.swimAuthorizationRequestedAtKey)
    }

    func requestSwimInspectionAuthorization() async throws {
        guard !Self.isUITesting else { return }
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HealthKitError.notAvailable
        }
        // Ungated (≠ requestSwimAuthorizationIfNeeded) : l'écran d'inspection DEBUG
        // doit garantir l'autorisation complète (workouts + natation + HR + énergie)
        // même si une demande natation partielle a déjà eu lieu. HealthKit ne
        // re-présente la feuille que pour les types `notDetermined` — sans danger.
        try await healthStore.requestAuthorization(toShare: [], read: Self.swimReadTypes())
        userDefaults.set(Date(), forKey: Self.swimAuthorizationRequestedAtKey)
    }

    /// Story 3.16 — types HK que la lecture natation + l'inspection consomment.
    /// Inclut **`HKObjectType.workoutType()`** : on ne peut PAS supposer qu'il a été
    /// accordé via `requestProfileAuthorization` (court-circuité en Dev Login) — sinon
    /// la requête workout échoue avec "Authorization not determined". On ajoute aussi
    /// HR + énergie (active/basale) lus par la capture exhaustive lap-by-lap.
    private static func swimReadTypes() -> Set<HKObjectType> {
        var types: Set<HKObjectType> = [HKObjectType.workoutType()]
        if let distance = HKQuantityType.quantityType(forIdentifier: .distanceSwimming) {
            types.insert(distance)
        }
        if let strokes = HKQuantityType.quantityType(forIdentifier: .swimmingStrokeCount) {
            types.insert(strokes)
        }
        if let hr = HKQuantityType.quantityType(forIdentifier: .heartRate) {
            types.insert(hr)
        }
        if let active = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) {
            types.insert(active)
        }
        if let basal = HKQuantityType.quantityType(forIdentifier: .basalEnergyBurned) {
            types.insert(basal)
        }
        return types
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
            let (avgHR, _, maxHR) = await readHeartRateStatsWindow(start: workout.startDate, end: workout.endDate)
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

    func fetchRecentSwimWorkoutDetails(limit: Int, weeksBack: Int) async -> [HealthKitSwimWorkoutDetail] {
        #if DEBUG
        // Seed simulateur : `SWIM_SEED=1` court-circuite HK (qui n'a aucune
        // donnée natation sur simu). Placé AVANT la garde UI testing pour
        // cohabiter avec `IS_UI_TESTING=1` (bypass auth/onboarding).
        if let seeded = SwimSeedFixtures.fixturesIfEnabled(limit: limit, weeksBack: weeksBack) {
            return seeded
        }
        #endif
        guard !Self.isUITesting else { return [] }
        guard HKHealthStore.isHealthDataAvailable() else { return [] }

        let now = Date()
        guard let startDate = Calendar(identifier: .gregorian).date(byAdding: .weekOfYear, value: -weeksBack, to: now) else {
            return []
        }
        let datePredicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: [])
        let swimPredicate = HKQuery.predicateForWorkouts(with: .swimming)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [datePredicate, swimPredicate])
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
                    Self.logger.debug("swim workout query error: \(error.localizedDescription)")
                }
                #endif
                continuation.resume(returning: (results as? [HKWorkout]) ?? [])
            }
            healthStore.execute(query)
        }

        var details: [HealthKitSwimWorkoutDetail] = []
        details.reserveCapacity(workouts.count)
        for workout in workouts {
            details.append(await buildSwimWorkoutDetail(workout))
        }
        return details
    }

    func diagnoseSwimFetch(weeksBack: Int) async -> SwimFetchDiagnostics {
        let available = HKHealthStore.isHealthDataAvailable()
        let authStatus = healthStore.authorizationStatus(for: HKObjectType.workoutType())
        let authString: String
        switch authStatus {
        case .notDetermined: authString = "notDetermined"
        case .sharingDenied: authString = "sharingDenied (lecture non révélée)"
        case .sharingAuthorized: authString = "sharingAuthorized"
        @unknown default: authString = "status(\(authStatus.rawValue))"
        }

        guard available else {
            return SwimFetchDiagnostics(
                healthDataAvailable: false,
                hasRequestedSwimAuthorization: hasRequestedSwimAuthorization,
                workoutAuthStatus: authString,
                allWorkoutsCount: 0,
                swimWorkoutsCount: 0,
                activityTypeCounts: [:],
                swimQueryError: nil
            )
        }

        let now = Date()
        let startDate = Calendar(identifier: .gregorian)
            .date(byAdding: .weekOfYear, value: -weeksBack, to: now) ?? now
        let datePredicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: [])

        // Requête témoin : TOUS les workouts (aucun predicate sport).
        let (allWorkouts, _) = await runWorkoutQuery(predicate: datePredicate, limit: 200)
        var typeCounts: [UInt: Int] = [:]
        for w in allWorkouts {
            typeCounts[w.workoutActivityType.rawValue, default: 0] += 1
        }

        // Requête natation (identique au fetch réel).
        let swimPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            datePredicate,
            HKQuery.predicateForWorkouts(with: .swimming)
        ])
        let (swimWorkouts, swimError) = await runWorkoutQuery(predicate: swimPredicate, limit: 200)

        return SwimFetchDiagnostics(
            healthDataAvailable: true,
            hasRequestedSwimAuthorization: hasRequestedSwimAuthorization,
            workoutAuthStatus: authString,
            allWorkoutsCount: allWorkouts.count,
            swimWorkoutsCount: swimWorkouts.count,
            activityTypeCounts: typeCounts,
            swimQueryError: swimError?.localizedDescription
        )
    }

    /// Exécute une requête workout et remonte (résultats, erreur éventuelle).
    private func runWorkoutQuery(predicate: NSPredicate, limit: Int) async -> ([HKWorkout], Error?) {
        await withCheckedContinuation { (continuation: CheckedContinuation<([HKWorkout], Error?), Never>) in
            let query = HKSampleQuery(
                sampleType: HKObjectType.workoutType(),
                predicate: predicate,
                limit: limit,
                sortDescriptors: nil
            ) { _, results, error in
                continuation.resume(returning: ((results as? [HKWorkout]) ?? [], error))
            }
            healthStore.execute(query)
        }
    }

    private func buildSwimWorkoutDetail(_ workout: HKWorkout) async -> HealthKitSwimWorkoutDetail {
        // Distance et strokes via `allStatistics` (iOS 16+) — `totalDistance` et
        // `totalSwimmingStrokeCount` sont deprecated iOS 18.
        var totalDistanceMeters: Double?
        if let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceSwimming),
           let sum = workout.allStatistics[distanceType]?.sumQuantity() {
            totalDistanceMeters = sum.doubleValue(for: .meter())
        }

        var totalStrokes: Int?
        if let strokeType = HKQuantityType.quantityType(forIdentifier: .swimmingStrokeCount),
           let sum = workout.allStatistics[strokeType]?.sumQuantity() {
            totalStrokes = Int(sum.doubleValue(for: HKUnit.count()))
        }

        // Énergie active + totale (kcal). `.activeEnergyBurned` = effort ;
        // + `.basalEnergyBurned` si présent = total.
        var activeEnergyKcal: Double?
        var basalEnergyKcal: Double?
        if let activeType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned),
           let sum = workout.allStatistics[activeType]?.sumQuantity() {
            activeEnergyKcal = sum.doubleValue(for: .kilocalorie())
        }
        if let basalType = HKQuantityType.quantityType(forIdentifier: .basalEnergyBurned),
           let sum = workout.allStatistics[basalType]?.sumQuantity() {
            basalEnergyKcal = sum.doubleValue(for: .kilocalorie())
        }
        let totalEnergyKcal: Double? = {
            switch (activeEnergyKcal, basalEnergyKcal) {
            case let (a?, b?): return a + b
            case let (a?, nil): return a
            case let (nil, b?): return b
            default: return nil
            }
        }()

        // METs moyens (`HKMetadataKeyAverageMETs`) — HKQuantity en kcal/(kg·hr).
        var averageMETs: Double?
        let metUnit = HKUnit(from: "kcal/kg*hr")
        if let q = workout.metadata?[HKMetadataKeyAverageMETs] as? HKQuantity, q.is(compatibleWith: metUnit) {
            averageMETs = q.doubleValue(for: metUnit)
        }

        let (avgHR, minHR, maxHR) = await readHeartRateStatsWindow(start: workout.startDate, end: workout.endDate)

        let poolLengthMeters = (workout.metadata?[HKMetadataKeyLapLength] as? HKQuantity)?
            .doubleValue(for: .meter())

        var swimLocationType: SwimLocationType?
        if let raw = workout.metadata?[HKMetadataKeySwimmingLocationType] as? Int {
            swimLocationType = SwimLocationType(rawValueSafe: raw)
        }

        let productType = workout.sourceRevision.productType
        let appleWatchDetected = (productType ?? "").lowercased().hasPrefix("watch")

        let isIndoor = workout.metadata?[HKMetadataKeyIndoorWorkout] as? Bool
        let timeZoneIdentifier = workout.metadata?[HKMetadataKeyTimeZone] as? String

        let laps = await extractSwimLaps(workout: workout, poolLengthMeters: poolLengthMeters)

        return HealthKitSwimWorkoutDetail(
            id: workout.uuid,
            startDate: workout.startDate,
            endDate: workout.endDate,
            durationSeconds: workout.duration,
            totalDistanceMeters: totalDistanceMeters,
            totalStrokes: totalStrokes,
            averageHeartRateBpm: avgHR.map { Int($0.rounded()) },
            maxHeartRateBpm: maxHR.map { Int($0.rounded()) },
            minHeartRateBpm: minHR.map { Int($0.rounded()) },
            activeEnergyKcal: activeEnergyKcal,
            totalEnergyKcal: totalEnergyKcal,
            averageMETs: averageMETs,
            poolLengthMeters: poolLengthMeters,
            swimLocationType: swimLocationType,
            sourceProductType: productType,
            appleWatchDetected: appleWatchDetected,
            deviceDescription: Self.describeDevice(workout.device),
            sourceDescription: Self.describeSource(workout.sourceRevision),
            isIndoorWorkout: isIndoor,
            timeZoneIdentifier: timeZoneIdentifier,
            eventCounts: Self.summarizeEvents(workout.workoutEvents),
            laps: laps,
            rawMetadata: Self.dumpMetadata(workout.metadata),
            rawStatistics: Self.dumpStatistics(workout.allStatistics)
        )
    }

    /// Story 3.16 AC7 — extraction lap-by-lap.
    /// Path 1 : `workout.workoutActivities` non vide (watchOS 9+) → on itère
    /// les activities et filtre les `.lap` events par fenêtre temporelle.
    /// Path 2 : `workoutActivities` vide (Watch legacy ou app tierce) → on
    /// itère directement `workout.workoutEvents` filtrés `.lap`.
    /// Path 3 : aucun lap event → `[]`.
    /// Borne max 200 laps pour éviter UI ingérable.
    private func extractSwimLaps(workout: HKWorkout, poolLengthMeters: Double?) async -> [HealthKitSwimLap] {
        let activities = workout.workoutActivities

        let lapEvents: [HKWorkoutEvent]
        if !activities.isEmpty {
            // Path 1 : récupère les lap events de tous les workoutActivities en
            // filtrant ceux dont la fenêtre temporelle tombe dans une activity.
            let activityWindows = activities.map { $0.startDate...($0.endDate ?? workout.endDate) }
            lapEvents = (workout.workoutEvents ?? []).filter { event in
                event.type == .lap && activityWindows.contains { $0.contains(event.dateInterval.start) }
            }
        } else {
            // Path 2 : fallback workout legacy sans activities.
            #if DEBUG
            Self.logger.debug("swim laps: fallback legacy workout sans activities (uuid=\(workout.uuid))")
            #endif
            lapEvents = (workout.workoutEvents ?? []).filter { $0.type == .lap }
        }

        guard !lapEvents.isEmpty else { return [] }

        let boundedEvents = Array(lapEvents.prefix(200))

        var laps: [HealthKitSwimLap] = []
        laps.reserveCapacity(boundedEvents.count)
        for (offset, event) in boundedEvents.enumerated() {
            // Repos au mur = écart entre la fin de ce lap et le début du suivant.
            let nextStart = offset + 1 < boundedEvents.count
                ? boundedEvents[offset + 1].dateInterval.start
                : nil
            let lap = await buildSwimLap(
                event: event,
                index: offset + 1,
                poolLengthMeters: poolLengthMeters,
                nextLapStart: nextStart
            )
            laps.append(lap)
        }
        return laps
    }

    private func buildSwimLap(
        event: HKWorkoutEvent,
        index: Int,
        poolLengthMeters: Double?,
        nextLapStart: Date?
    ) async -> HealthKitSwimLap {
        let interval = event.dateInterval
        let duration = interval.duration
        let distance = poolLengthMeters
        let pace = HealthKitSwimLap.computePaceSecondsPer100m(
            durationSeconds: duration,
            distanceMeters: distance
        )

        var strokeStyle: SwimStrokeStyle?
        if let raw = event.metadata?[HKMetadataKeySwimmingStrokeStyle] as? Int {
            strokeStyle = SwimStrokeStyle(rawValueSafe: raw)
        }

        let (avgHR, minHR, maxHR) = await readHeartRateStatsWindow(start: interval.start, end: interval.end)
        let strokeCount = await readSwimStrokeCount(start: interval.start, end: interval.end)
        let swolf = HealthKitSwimLap.computeSwolf(durationSeconds: duration, strokeCount: strokeCount)

        let rest: TimeInterval? = nextLapStart.map { max(0, $0.timeIntervalSince(interval.end)) }

        return HealthKitSwimLap(
            index: index,
            startDate: interval.start,
            durationSeconds: duration,
            distanceMeters: distance,
            strokeStyle: strokeStyle,
            paceSecondsPer100m: pace,
            averageHeartRateBpm: avgHR.map { Int($0.rounded()) },
            strokeCount: strokeCount,
            minHeartRateBpm: minHR.map { Int($0.rounded()) },
            maxHeartRateBpm: maxHR.map { Int($0.rounded()) },
            swolfScore: swolf,
            restAfterSeconds: rest
        )
    }

    /// Somme `swimmingStrokeCount` sur une fenêtre temporelle (utilisé par lap).
    /// `.strictStartDate` : un échantillon n'est compté que si son `startDate` tombe
    /// dans la fenêtre — sinon un sample à cheval sur deux longueurs serait compté
    /// dans les deux (double comptage observé : Σ laps 942 > total séance 776).
    private func readSwimStrokeCount(start: Date, end: Date) async -> Int? {
        guard let type = HKQuantityType.quantityType(forIdentifier: .swimmingStrokeCount) else {
            return nil
        }
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: [.strictStartDate])
        return await withCheckedContinuation { (continuation: CheckedContinuation<Int?, Never>) in
            let query = HKStatisticsQuery(
                quantityType: type,
                quantitySamplePredicate: predicate,
                options: [.cumulativeSum]
            ) { _, statistics, _ in
                guard let sum = statistics?.sumQuantity() else {
                    continuation.resume(returning: nil)
                    return
                }
                continuation.resume(returning: Int(sum.doubleValue(for: .count()).rounded()))
            }
            healthStore.execute(query)
        }
    }

    /// HR moyenne / min / max sur une fenêtre temporelle.
    private func readHeartRateStatsWindow(start: Date, end: Date) async -> (average: Double?, min: Double?, max: Double?) {
        guard let hrType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            return (nil, nil, nil)
        }
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: [])

        return await withCheckedContinuation { (continuation: CheckedContinuation<(Double?, Double?, Double?), Never>) in
            let query = HKStatisticsQuery(
                quantityType: hrType,
                quantitySamplePredicate: predicate,
                options: [.discreteAverage, .discreteMin, .discreteMax]
            ) { _, statistics, _ in
                let unit = HKUnit.count().unitDivided(by: .minute())
                let avg = statistics?.averageQuantity()?.doubleValue(for: unit)
                let minVal = statistics?.minimumQuantity()?.doubleValue(for: unit)
                let maxVal = statistics?.maximumQuantity()?.doubleValue(for: unit)
                continuation.resume(returning: (avg, minVal, maxVal))
            }
            healthStore.execute(query)
        }
    }

    // MARK: - Private — dump brut natation (inspection DEBUG)

    /// Stringifie une valeur de metadata HK (HKQuantity / Bool / Date / NSNumber / String).
    private static func stringifyMetadataValue(_ value: Any) -> String {
        switch value {
        case let q as HKQuantity: return q.description
        case let d as Date: return ISO8601DateFormatter().string(from: d)
        case let n as NSNumber:
            // NSNumber(1) bridge vers Bool → "true" à tort. On ne traite comme
            // booléen QUE les vrais CFBoolean (ex: HKIndoorWorkout), pas les Int.
            if CFGetTypeID(n) == CFBooleanGetTypeID() {
                return n.boolValue ? "true" : "false"
            }
            return n.stringValue
        case let b as Bool: return b ? "true" : "false"
        case let s as String: return s
        default: return String(describing: value)
        }
    }

    private static func dumpMetadata(_ metadata: [String: Any]?) -> [HealthKitRawEntry] {
        guard let metadata else { return [] }
        return metadata
            .map { HealthKitRawEntry(key: $0.key, value: stringifyMetadataValue($0.value)) }
            .sorted { $0.key < $1.key }
    }

    private static func dumpStatistics(_ stats: [HKQuantityType: HKStatistics]) -> [HealthKitRawEntry] {
        let bpm = HKUnit.count().unitDivided(by: .minute())
        return stats
            .map { type, stat -> HealthKitRawEntry in
                // HR : afficher en bpm plutôt que l'unité canonique count/s.
                let isHR = type.identifier == HKQuantityTypeIdentifier.heartRate.rawValue
                func fmt(_ q: HKQuantity?) -> String? {
                    guard let q else { return nil }
                    return isHR ? String(format: "%.0f bpm", q.doubleValue(for: bpm)) : q.description
                }
                // On affiche la somme si dispo (cumulatif), sinon moy/min/max (discret).
                let parts: [String] = [
                    fmt(stat.sumQuantity()).map { "Σ \($0)" },
                    fmt(stat.averageQuantity()).map { "x̄ \($0)" },
                    fmt(stat.minimumQuantity()).map { "min \($0)" },
                    fmt(stat.maximumQuantity()).map { "max \($0)" }
                ].compactMap { $0 }
                let value = parts.isEmpty ? "—" : parts.joined(separator: " · ")
                return HealthKitRawEntry(key: type.identifier, value: value)
            }
            .sorted { $0.key < $1.key }
    }

    private static func summarizeEvents(_ events: [HKWorkoutEvent]?) -> [String: Int] {
        guard let events else { return [:] }
        var counts: [String: Int] = [:]
        for event in events {
            counts[eventTypeName(event.type), default: 0] += 1
        }
        return counts
    }

    private static func eventTypeName(_ type: HKWorkoutEventType) -> String {
        switch type {
        case .pause: return "pause"
        case .resume: return "resume"
        case .lap: return "lap"
        case .marker: return "marker"
        case .motionPaused: return "motionPaused"
        case .motionResumed: return "motionResumed"
        case .segment: return "segment"
        case .pauseOrResumeRequest: return "pauseOrResumeRequest"
        @unknown default: return "type(\(type.rawValue))"
        }
    }

    private static func describeDevice(_ device: HKDevice?) -> String? {
        guard let device else { return nil }
        let parts = [
            device.name,
            device.model,
            device.hardwareVersion.map { "hw \($0)" },
            device.softwareVersion.map { "sw \($0)" }
        ].compactMap { $0 }
        return parts.isEmpty ? nil : parts.joined(separator: " · ")
    }

    private static func describeSource(_ revision: HKSourceRevision) -> String? {
        var parts = [revision.source.name]
        if let v = revision.version { parts.append("v\(v)") }
        let os = revision.operatingSystemVersion
        if os.majorVersion > 0 {
            parts.append("OS \(os.majorVersion).\(os.minorVersion).\(os.patchVersion)")
        }
        return parts.joined(separator: " · ")
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
