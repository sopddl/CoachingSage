// Services/DTOs/HealthKitSwimWorkoutDetail.swift
// Story 3.16 (Phase 1, read-only) — DTOs pour l'inspection lap-by-lap des
// workouts natation lus depuis HealthKit. Pas de wiring algo en Phase 1 :
// ces structs alimentent uniquement `SwimHealthKitInspectorView` (écran DEBUG).
//
// 2026-06-02 — extension « tout capter » (demande Sophie) : on remonte
// l'intégralité de ce que HealthKit expose pour une séance natation (énergie,
// METs, SWOLF, strokes par lap, repos au mur, device/source, + dump brut de
// metadata / allStatistics / events) pour que le test iPhone soit décisionnel
// avant d'arbitrer la Phase 2.
import Foundation

/// Style de nage par lap. Miroir EXACT des rawValues `HKSwimmingStrokeStyle`
/// iOS 16+ : 0 unknown / 1 mixed / 2 freestyle / 3 backstroke / 4 breaststroke /
/// 5 butterfly / 6 kickboard. Tout rawValue non reconnu → `.unknown`.
enum SwimStrokeStyle: Int, Equatable, Sendable {
    case unknown = 0
    case mixed = 1
    case freestyle = 2
    case backstroke = 3
    case breaststroke = 4
    case butterfly = 5
    case kickboard = 6

    init(rawValueSafe: Int) {
        self = SwimStrokeStyle(rawValue: rawValueSafe) ?? .unknown
    }
}

/// Type de plan d'eau extrait de `HKMetadataKeySwimmingLocationType` (pool /
/// openWater / unknown). Miroir simplifié de `HKWorkoutSwimmingLocationType`.
enum SwimLocationType: Int, Equatable, Sendable {
    case unknown = 0
    case pool = 1
    case openWater = 2

    init(rawValueSafe: Int) {
        self = SwimLocationType(rawValue: rawValueSafe) ?? .unknown
    }
}

/// Une paire clé→valeur déjà stringifiée pour l'affichage brut. `Identifiable`
/// pour itérer proprement dans le `ForEach` de l'inspector.
struct HealthKitRawEntry: Equatable, Sendable, Identifiable {
    let key: String
    let value: String
    var id: String { key }
}

/// Détail d'un lap natation. Distance par lap dérivée du `poolLengthMeters`
/// du workout parent (un lap = une longueur en pool tracking Apple). `nil`
/// si pool length absente (open water, app tierce). HR récupérée via
/// `HKStatisticsQuery` ciblée sur la fenêtre temporelle du lap.
struct HealthKitSwimLap: Equatable, Sendable {
    /// 1-based, ordre temporel.
    let index: Int
    let startDate: Date
    let durationSeconds: TimeInterval
    let distanceMeters: Double?
    let strokeStyle: SwimStrokeStyle?
    let paceSecondsPer100m: Double?
    let averageHeartRateBpm: Int?
    /// Strokes comptés sur la fenêtre temporelle du lap (somme `swimmingStrokeCount`).
    let strokeCount: Int?
    /// HR min/max sur la fenêtre du lap (complète `averageHeartRateBpm`).
    let minHeartRateBpm: Int?
    let maxHeartRateBpm: Int?
    /// SWOLF = durée du lap (s, arrondie) + nombre de strokes. `nil` si l'un
    /// des deux manque. Métrique d'efficacité de nage standard.
    let swolfScore: Int?
    /// Secondes de repos entre la fin de ce lap et le début du suivant (repos
    /// au mur). `nil` pour le dernier lap ou si pas d'écart mesurable.
    let restAfterSeconds: TimeInterval?

    /// Calcule la pace s/100m à partir de durée + distance. Retourne `nil` si
    /// distance absente ou == 0 (garde-fou division). Exposée pour les tests.
    static func computePaceSecondsPer100m(
        durationSeconds: TimeInterval,
        distanceMeters: Double?
    ) -> Double? {
        guard let distance = distanceMeters, distance > 0 else { return nil }
        return durationSeconds / distance * 100.0
    }

    /// SWOLF = durée arrondie (s) + strokes. `nil` si l'un des deux manque ou
    /// si strokes <= 0. Exposée pour les tests.
    static func computeSwolf(durationSeconds: TimeInterval, strokeCount: Int?) -> Int? {
        guard let strokes = strokeCount, strokes > 0 else { return nil }
        return Int(durationSeconds.rounded()) + strokes
    }
}

/// Détail d'un workout natation lu depuis HealthKit. `laps` peut être vide
/// (open water, app tierce, ou tracking sans lap event) — la Phase 1 ne
/// bloque jamais sur l'absence de laps : on inspecte ce qu'on a.
struct HealthKitSwimWorkoutDetail: Equatable, Sendable, Identifiable {
    let id: UUID
    let startDate: Date
    let endDate: Date
    let durationSeconds: TimeInterval
    let totalDistanceMeters: Double?
    let totalStrokes: Int?
    let averageHeartRateBpm: Int?
    let maxHeartRateBpm: Int?
    /// HR min sur toute la séance (complète moy/max).
    let minHeartRateBpm: Int?
    /// Énergie active brûlée (kcal) — proxy d'effort.
    let activeEnergyKcal: Double?
    /// Énergie totale (active + repos) brûlée (kcal).
    let totalEnergyKcal: Double?
    /// METs moyens (`HKMetadataKeyAverageMETs`) — intensité normalisée.
    let averageMETs: Double?
    let poolLengthMeters: Double?
    let swimLocationType: SwimLocationType?
    let sourceProductType: String?
    let appleWatchDetected: Bool
    /// Description du device source (HKDevice : nom + modèle + soft version).
    let deviceDescription: String?
    /// Description de la source applicative (nom app + version + OS).
    let sourceDescription: String?
    /// `HKMetadataKeyIndoorWorkout` si présent.
    let isIndoorWorkout: Bool?
    /// Fuseau horaire (`HKMetadataKeyTimeZone`).
    let timeZoneIdentifier: String?
    /// Comptage des events par type (pause, segment, marker, lap…) pour la
    /// structure de séance. Ex: ["lap": 32, "pause": 8].
    let eventCounts: [String: Int]
    let laps: [HealthKitSwimLap]
    /// Dump intégral de `workout.metadata` (clé HK → valeur stringifiée).
    let rawMetadata: [HealthKitRawEntry]
    /// Dump de `workout.allStatistics` (type quantité → somme/moy + unité).
    let rawStatistics: [HealthKitRawEntry]
}

#if DEBUG
// MARK: - Seed simulateur (DEBUG only)
//
// Le simulateur iOS n'a AUCUN workout natation HealthKit → impossible d'y
// valider visuellement le bloc Natation / la SportProfileView / l'autoprofil.
// Activé par la var d'env `SWIM_SEED=1` au launch (combinable avec
// `IS_UI_TESTING=1` pour bypasser auth+onboarding, et `UI_TEST_LANG=fr|en`).
// Injecté en tête de `DefaultHealthKitService.fetchRecentSwimWorkoutDetails`.
// JAMAIS compilé en release (`#if DEBUG`). Pur, déterministe, sans I/O.
enum SwimSeedFixtures {

    /// Actif si `SWIM_SEED` est dans l'env (lancement Xcode via scheme) OU si
    /// `swim_seed` / `-SWIM_SEED` est passé en launch arg (lancement piloté par
    /// un agent via `simctl launch`, qui ne peut pas injecter d'env var — même
    /// raison que le fallback launch-args de `resolveUITestScenario`).
    private static var isSeedEnabled: Bool {
        if ProcessInfo.processInfo.environment["SWIM_SEED"] != nil { return true }
        let args = ProcessInfo.processInfo.arguments
        return args.contains("swim_seed") || args.contains("-SWIM_SEED")
    }

    /// Retourne les fixtures si `SWIM_SEED` est dans l'env, sinon `nil` (le
    /// service réel reprend la main). Respecte `limit` et `weeksBack` comme le
    /// vrai query HK (tri end date décroissant, fenêtre glissante).
    static func fixturesIfEnabled(limit: Int, weeksBack: Int, now: Date = Date()) -> [HealthKitSwimWorkoutDetail]? {
        guard isSeedEnabled else { return nil }
        let cal = Calendar(identifier: .gregorian)
        let cutoff = cal.date(byAdding: .weekOfYear, value: -max(1, weeksBack), to: now) ?? now
        let sessions = allSessions(now: now)
            .filter { $0.endDate >= cutoff }
            .sorted { $0.endDate > $1.endDate }
        return Array(sessions.prefix(max(0, limit)))
    }

    /// 9 séances : un bloc récent (~10 dernières semaines) + un bloc ancien
    /// (~40 semaines en arrière) SÉPARÉS PAR UN TROU de ~30 semaines (arrêt).
    /// Tendance à l'amélioration (récent plus rapide + SWOLF plus bas). Sert à
    /// exercer la fenêtre 1 an (Story 3.16, Sophie 2026-06-02) :
    /// - le bloc ancien sort de la fenêtre 12 sem mais entre dans la fenêtre 52 sem
    ///   → records (plus longue séance 1500 m) puisés au-delà de 3 mois ;
    /// - les moyennes hebdo se calent sur ~9 semaines ACTIVES, pas 52 (la pause
    ///   de 30 semaines ne dilue pas le volume).
    /// Pace best ~91 → niveau estimé "regular" (cf `SwimLevelEstimator`).
    private static func allSessions(now: Date) -> [HealthKitSwimWorkoutDetail] {
        // (uuid, daysAgo, lapCount, basePace s/100m, baseSwolf)
        let specs: [(id: String, daysAgo: Int, lapCount: Int, pace: Double, swolf: Int)] = [
            // Bloc récent (amélioration)
            ("11111111-0000-0000-0000-000000000001", 2,  40, 93.0, 33),
            ("11111111-0000-0000-0000-000000000002", 9,  32, 95.0, 34),
            ("11111111-0000-0000-0000-000000000003", 16, 36, 96.0, 34),
            ("11111111-0000-0000-0000-000000000004", 30, 32, 99.0, 36),
            ("11111111-0000-0000-0000-000000000005", 44, 28, 101.0, 37),
            ("11111111-0000-0000-0000-000000000006", 72, 30, 103.0, 38),
            // ── trou ~30 semaines (arrêt) ──
            // Bloc ancien (~40 sem) : plus lent, dont une grosse séance (1500 m)
            // qui devient le record "plus longue séance" sur la fenêtre 1 an.
            ("11111111-0000-0000-0000-000000000007", 280, 60, 108.0, 39),
            ("11111111-0000-0000-0000-000000000008", 287, 44, 110.0, 40),
            ("11111111-0000-0000-0000-000000000009", 301, 40, 112.0, 41),
        ]
        return specs.map {
            makeSession(idHex: $0.id, daysAgo: $0.daysAgo, lapCount: $0.lapCount,
                        basePace: $0.pace, baseSwolf: $0.swolf, now: now)
        }
    }

    private static func makeSession(idHex: String, daysAgo: Int, lapCount: Int,
                                    basePace: Double, baseSwolf: Int, now: Date) -> HealthKitSwimWorkoutDetail {
        let pool = 25.0
        let cal = Calendar(identifier: .gregorian)
        let start = cal.date(byAdding: .day, value: -daysAgo, to: now) ?? now

        var laps: [HealthKitSwimLap] = []
        var cursor = start
        var lapEventCount = 0
        var pauseCount = 0

        for i in 0..<lapCount {
            // Majorité crawl, un peu de dos / brasse, une longueur de jambes
            // (kickboard, exclue du calcul d'allure) → exerce le % styles.
            let style: SwimStrokeStyle
            switch i % 10 {
            case 4: style = .backstroke
            case 7: style = .breaststroke
            case 9: style = .kickboard
            default: style = .freestyle
            }

            // Variation déterministe par longueur → best pace < pace moyenne.
            let variation = Double((i % 5) - 2) * 1.2 // -2.4 ... +2.4
            let kickPenalty = style == .kickboard ? 28.0 : 0.0
            let lapPace = basePace + variation + kickPenalty
            let duration = lapPace / 100.0 * pool // s pour 25 m

            // SWOLF & strokes seulement sur les longueurs nagées (pas le kick).
            let swolf: Int? = style.isSwumStroke ? baseSwolf + Int((variation / 2).rounded()) : nil
            let strokeCount: Int? = swolf.map { max(1, $0 - Int(duration.rounded())) }

            // Repos au mur : ~4 s en série, 22 s toutes les 8 longueurs
            // (frontière de série → exerce la détection de séries).
            let isLast = i == lapCount - 1
            let isSetBreak = (i + 1) % 8 == 0 && !isLast
            let rest: TimeInterval? = isLast ? nil : (isSetBreak ? 22.0 : 4.0)
            if isSetBreak { pauseCount += 1 }
            lapEventCount += 1

            laps.append(HealthKitSwimLap(
                index: i + 1,
                startDate: cursor,
                durationSeconds: duration,
                distanceMeters: pool,
                strokeStyle: style,
                paceSecondsPer100m: lapPace,
                averageHeartRateBpm: nil,
                strokeCount: strokeCount,
                minHeartRateBpm: nil,
                maxHeartRateBpm: nil,
                swolfScore: swolf,
                restAfterSeconds: rest
            ))
            cursor = cursor.addingTimeInterval(duration + (rest ?? 0))
        }

        let totalDistance = Double(lapCount) * pool
        let durationSeconds = cursor.timeIntervalSince(start)
        // HR légèrement plus basse sur les séances récentes (cosmétique).
        let avgHR = 124 + min(12, daysAgo / 6)

        return HealthKitSwimWorkoutDetail(
            id: UUID(uuidString: idHex) ?? UUID(),
            startDate: start,
            endDate: cursor,
            durationSeconds: durationSeconds,
            totalDistanceMeters: totalDistance,
            totalStrokes: laps.compactMap { $0.strokeCount }.reduce(0, +),
            averageHeartRateBpm: avgHR,
            maxHeartRateBpm: avgHR + 18,
            minHeartRateBpm: avgHR - 22,
            activeEnergyKcal: totalDistance * 0.38,
            totalEnergyKcal: totalDistance * 0.46,
            averageMETs: 8.6,
            poolLengthMeters: pool,
            swimLocationType: .pool,
            sourceProductType: "Watch6,16",
            appleWatchDetected: true,
            deviceDescription: "Apple Watch · SWIM_SEED (DEBUG)",
            sourceDescription: "CoachingSage seed",
            isIndoorWorkout: true,
            timeZoneIdentifier: "Europe/Paris",
            eventCounts: ["lap": lapEventCount, "pause": pauseCount],
            laps: laps,
            rawMetadata: [],
            rawStatistics: []
        )
    }
}
#endif
