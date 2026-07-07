// Coaching/Progress/ProgressViewModel.swift
// Story 3.9 — VM de l'onglet Progrès. Orchestre les 4 blocs (widget stats,
// forme physique HK, volume par sport, PR) en parallèle pour minimiser le
// time-to-first-meaningful-paint.
//
// Pattern : la View récupère `programs: [AdaptedProgramRecord]` via @Query et
// appelle `reload(programs:)`. Le VM ne touche pas SwiftData directement →
// testabilité préservée (cf. WeeklyStatsServiceTests, qui construit des records
// in-memory sans Schema).
//
// Garde-fou EU MDR : aucune interprétation médicale des valeurs HK. Le VM
// retourne uniquement chiffres + flèche delta neutre (↑/↓). Le wording UI
// affiche "Moy. 7 derniers j" ou similaire, jamais "Fatigue", "Récupération", etc.
import Foundation
import SwiftUI

// MARK: - View models internes

/// Ligne « Volume par sport » du bloc 3. Identifiable par `sportCode` brut
/// (`Sport.appSportCode` quand un programme existe, ou rawValue HK mappé sinon).
struct SportVolumeRow: Identifiable, Equatable, Sendable {
    let id: String
    let sportCode: SportCode?
    /// Label fallback quand `sportCode == nil` (workout HK qu'on ne mappe pas).
    let displayName: String
    let totalMinutes: Int
    /// Ratio 0...1 vs le sport le plus volumineux de la liste (pour la barre 6px).
    let ratio: Double

    init(
        id: String,
        sportCode: SportCode?,
        displayName: String,
        totalMinutes: Int,
        ratio: Double
    ) {
        self.id = id
        self.sportCode = sportCode
        self.displayName = displayName
        self.totalMinutes = totalMinutes
        self.ratio = ratio
    }
}

/// Bloc 2 « Forme physique HK ». Chaque valeur est `nil` si HK indisponible /
/// permission refusée / 0 sample sur la fenêtre (AC Story 3.9 : Apple ne
/// distingue pas refus vs 0 sample côté READ — comportement identique).
struct HKFitnessReadout: Equatable, Sendable {
    /// Resting Heart Rate (bpm) — valeur courante.
    let restingHR: Double?
    /// Delta vs fenêtre précédente. `+` = augmentation. nil si une des deux fenêtres est vide.
    let restingHRDelta: Double?

    /// HRV SDNN (ms) — valeur courante.
    let hrv: Double?
    let hrvDelta: Double?

    /// Sommeil (minutes par nuit) — valeur courante.
    let sleepMinutes: Double?
    let sleepDelta: Double?

    static let empty = HKFitnessReadout(
        restingHR: nil, restingHRDelta: nil,
        hrv: nil, hrvDelta: nil,
        sleepMinutes: nil, sleepDelta: nil
    )

    /// True si les 3 métriques sont nil — UI peut afficher le CTA "Activer
    /// HealthKit dans Réglages" en remplacement des trois lignes "—".
    var isFullyUnavailable: Bool {
        restingHR == nil && hrv == nil && sleepMinutes == nil
    }
}

// MARK: - ViewModel

@MainActor
@Observable
final class ProgressViewModel {
    /// État de chargement d'un bloc. `idle` avant 1er reload, `loading` pendant
    /// fetch HK (différé < 2s P90 spec), `loaded(value)` une fois résolu.
    enum BlockState<T: Equatable>: Equatable {
        case idle
        case loading
        case loaded(T)
    }

    /// Story 3.z — clé UserDefaults pour l'effet "wow" au premier launch
    /// de l'onglet Progrès : période initiale `.quarter` (3 mois) au lieu de
    /// `.week`, pour montrer l'historique HK déjà sync.
    static let firstLaunchSeenKey = "progress_first_launch_seen"

    // MARK: Inputs / state utilisateur

    /// Période sélectionnée par le picker bottom sheet (icône ⏱).
    /// Défaut `.week`, override à `.quarter` au premier launch (cf. AC4-AC7
    /// Story 3.z), flag UserDefaults `progress_first_launch_seen`.
    var period: ProgressPeriod

    // MARK: Output

    /// `true` si aucun programme actif ET aucun workout HK sur la période →
    /// état vide global (icône 📊 + "Bientôt tes progrès" + CTA retour Séances).
    /// Story sœur 3.z (2026-05-17) : prend en compte l'historique HK (Strava→Santé)
    /// pour ne pas masquer la valeur produit de la Story 3.z aux users fresh
    /// onboarding qui ont 3 mois d'activités synchronisées.
    private(set) var isEmpty: Bool = false

    /// `true` si l'utilisateur a au moins un `AdaptedProgramRecord` actif.
    /// Pilote l'affichage des blocs qui dépendent des séances trackées par l'app
    /// (widget stats hebdo + performances récentes). Les blocs HK fitness et
    /// Volume par sport s'affichent indépendamment (alimentés HK uniquement).
    private(set) var hasActivePrograms: Bool = false

    /// Bloc 1 — toujours synchrone (SwiftData local), pas de loading state.
    private(set) var stats: WeeklyStats = .empty

    /// Bloc 2 — async (HKStatisticsQuery × 6 : 3 métriques × 2 fenêtres).
    private(set) var hkFitness: BlockState<HKFitnessReadout> = .idle

    /// Bloc 3 — async (HKSampleQuery workouts).
    private(set) var volumeRows: BlockState<[SportVolumeRow]> = .idle

    /// Bloc 4 — sync (computation locale sur completionState), mais wrappé en
    /// BlockState par cohérence d'UI.
    private(set) var personalRecords: BlockState<[PRRecord]> = .idle

    /// Bloc 5 (chantier récap hebdo triathlon 2026-07-06/07) — répartition
    /// nage/vélo/course des séances complétées, programme triathlon uniquement.
    /// Sync (comme bloc 1/4) — pas de dépendance HK.
    private(set) var triathlonDisciplines: BlockState<[TriathlonDisciplineRow]> = .idle

    // MARK: Dependencies

    private let healthKit: HealthKitServiceProtocol
    private let statsService: WeeklyStatsService
    private let prEngine: PersonalRecordsEngine
    private let triathlonDisciplineStatsService: TriathlonDisciplineStatsService
    private let nowProvider: () -> Date
    private let userDefaults: UserDefaults

    init(
        healthKit: HealthKitServiceProtocol,
        statsService: WeeklyStatsService = WeeklyStatsService(),
        prEngine: PersonalRecordsEngine = PersonalRecordsEngine(),
        triathlonDisciplineStatsService: TriathlonDisciplineStatsService = TriathlonDisciplineStatsService(),
        nowProvider: @escaping () -> Date = { Date() },
        userDefaults: UserDefaults = .standard
    ) {
        self.healthKit = healthKit
        self.statsService = statsService
        self.prEngine = prEngine
        self.triathlonDisciplineStatsService = triathlonDisciplineStatsService
        self.nowProvider = nowProvider
        self.userDefaults = userDefaults
        let hasSeenFirstLaunch = userDefaults.bool(forKey: Self.firstLaunchSeenKey)
        self.period = hasSeenFirstLaunch ? .week : .quarter
    }

    /// Marque le premier launch comme vu. Idempotent. À appeler au `.task` /
    /// `.onAppear` de la View Progrès (pas seulement au switch de période),
    /// afin que l'effet wow `.quarter` ne s'enregistre qu'une fois.
    func markFirstLaunchSeen() {
        guard !userDefaults.bool(forKey: Self.firstLaunchSeenKey) else { return }
        userDefaults.set(true, forKey: Self.firstLaunchSeenKey)
    }

    // MARK: API

    /// Demande à HK la permission étendue Progrès (RHR / HRV / Sleep) si pas
    /// déjà demandée. No-op si déjà fait ou si HK indisponible. À appeler dans
    /// le `task {}` au premier `onAppear` de l'onglet Progrès.
    func ensureProgressAuthorization() async {
        try? await healthKit.requestProgressAuthorizationIfNeeded()
    }

    /// Recharge les 4 blocs pour `period` courante. Les 2 blocs HK (fitness +
    /// volume) chargent toujours, même sans programme actif — la décision
    /// "empty state" se fait après leur retour, en croisant `hasActivePrograms`
    /// et la présence de workouts HK sur la période (cf. Story sœur 3.z).
    /// Les programmes sont passés par la View (View récupère via `@Query`).
    func reload(programs: [AdaptedProgramRecord]) async {
        let now = nowProvider()
        let activePrograms = programs.filter { $0.isActive }
        hasActivePrograms = !activePrograms.isEmpty

        // Blocs 1 et 4 — dépendent des séances trackées par l'app. Sans programme
        // actif, on les met à vide (la View masque les blocs concernés).
        if hasActivePrograms {
            stats = statsService.compute(
                programs: activePrograms,
                now: now,
                period: period
            )
            let prs = prEngine.detectRecent(
                period: period,
                programs: activePrograms,
                now: now
            )
            personalRecords = .loaded(prs)
            triathlonDisciplines = .loaded(
                triathlonDisciplineStatsService.compute(programs: activePrograms, now: now, period: period)
            )
        } else {
            stats = .empty
            personalRecords = .loaded([])
            triathlonDisciplines = .loaded([])
        }

        // Blocs 2 et 3 — async HK en parallèle. Toujours chargés : permet à un
        // user fresh onboarding (0 programme) avec historique Strava→Santé de
        // voir tout de suite son volume — effet wow Story 3.z préservé.
        hkFitness = .loading
        volumeRows = .loading

        async let hkTask = loadHKFitness(period: period, now: now)
        async let volTask = loadVolumeRows(period: period, programs: activePrograms)

        let (hk, vols) = await (hkTask, volTask)
        hkFitness = .loaded(hk)
        volumeRows = .loaded(vols)

        // Empty state = aucun signal côté app (pas de programme actif) ET aucun
        // signal côté HK (pas de workout sur la période). HK fitness seul (RHR
        // sans workout) ne suffit pas — sans workout on n'a rien à raconter
        // comme « progrès » d'entraînement.
        isEmpty = !hasActivePrograms && vols.isEmpty
    }

    /// Bascule la période et recharge.
    func selectPeriod(_ newPeriod: ProgressPeriod, programs: [AdaptedProgramRecord]) async {
        guard newPeriod != period else { return }
        period = newPeriod
        await reload(programs: programs)
    }

    // MARK: Private — bloc 2 HK fitness

    private func loadHKFitness(period: ProgressPeriod, now: Date) async -> HKFitnessReadout {
        let days = period.slidingDays
        // Fenêtre précédente = même longueur, juste décalée.
        let previousEnd = Calendar(identifier: .gregorian)
            .date(byAdding: .day, value: -days, to: now) ?? now

        async let rhrCurrent = healthKit.fetchRestingHeartRateAverage(daysBack: days, endingAt: now)
        async let rhrPrev    = healthKit.fetchRestingHeartRateAverage(daysBack: days, endingAt: previousEnd)
        async let hrvCurrent = healthKit.fetchHRVAverage(daysBack: days, endingAt: now)
        async let hrvPrev    = healthKit.fetchHRVAverage(daysBack: days, endingAt: previousEnd)
        async let slpCurrent = healthKit.fetchSleepAverageMinutes(daysBack: days, endingAt: now)
        async let slpPrev    = healthKit.fetchSleepAverageMinutes(daysBack: days, endingAt: previousEnd)

        let (rc, rp, hc, hp, sc, sp) = await (rhrCurrent, rhrPrev, hrvCurrent, hrvPrev, slpCurrent, slpPrev)

        return HKFitnessReadout(
            restingHR: rc,
            restingHRDelta: delta(current: rc, previous: rp),
            hrv: hc,
            hrvDelta: delta(current: hc, previous: hp),
            sleepMinutes: sc,
            sleepDelta: delta(current: sc, previous: sp)
        )
    }

    private func delta(current: Double?, previous: Double?) -> Double? {
        guard let c = current, let p = previous else { return nil }
        return c - p
    }

    // MARK: Private — bloc 3 volume par sport

    private func loadVolumeRows(
        period: ProgressPeriod,
        programs: [AdaptedProgramRecord]
    ) async -> [SportVolumeRow] {
        let days = period.slidingDays
        let byActivityType = await healthKit.fetchWorkoutVolumeByActivityType(daysBack: days)

        // Agrège les workouts HK par SportCode mappé. Les types HK non-mappés
        // sont ignorés V1 (cf SportCodeMapper.fromHKWorkoutActivityType).
        var minutesBySport: [SportCode: Int] = [:]
        for (rawType, duration) in byActivityType {
            guard let sport = SportCodeMapper.fromHKWorkoutActivityType(rawType) else { continue }
            let minutes = Int((duration / 60).rounded())
            guard minutes > 0 else { continue }
            minutesBySport[sport, default: 0] += minutes
        }

        guard !minutesBySport.isEmpty else { return [] }

        let maxMinutes = minutesBySport.values.max() ?? 1
        return minutesBySport
            .map { sport, minutes in
                SportVolumeRow(
                    id: sport.rawValue,
                    sportCode: sport,
                    displayName: sport.rawValue, // remplacé par i18n côté View via `sport.localizationKey`
                    totalMinutes: minutes,
                    ratio: Double(minutes) / Double(maxMinutes)
                )
            }
            .sorted(by: { $0.totalMinutes > $1.totalMinutes })
    }
}
