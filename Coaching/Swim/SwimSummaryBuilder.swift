// Coaching/Swim/SwimSummaryBuilder.swift
// Story 3.16 Phase 2.A — transforme les `HealthKitSwimWorkoutDetail` bruts en
// agrégats exploitables (`SwimSummary`). Logique pure et déterministe : pas
// d'accès HealthKit ni SwiftData → testable avec des fixtures.
import Foundation

enum SwimSummaryBuilder {

    /// Repos au mur (s) >= ce seuil = frontière de série. En-deçà (virages,
    /// micro-pauses) = même série. 10 s : sur données réelles, les longueurs
    /// continues ont 0-5 s d'écart, les vraies coupures de série 15-35 s.
    static let restBreakThresholdSeconds: TimeInterval = 10

    // MARK: - Agrégat fenêtre

    static func build(from details: [HealthKitSwimWorkoutDetail], windowWeeks: Int) -> SwimSummary {
        guard !details.isEmpty, windowWeeks > 0 else { return .empty }

        let sessions = details
            .map(summarizeSession)
            // Tri stable : à date égale, départage par id pour un ordre déterministe.
            .sorted { a, b in a.date != b.date ? a.date > b.date : a.id.uuidString > b.id.uuidString }

        let totalDistance = sessions.compactMap { $0.totalDistanceMeters }.reduce(0, +)

        // Pace moyenne pondérée par distance (longueurs nagées).
        var weightedPaceNumerator = 0.0
        var weightedPaceDenominator = 0.0
        for s in sessions {
            guard let pace = s.avgPaceSecondsPer100m, let dist = s.totalDistanceMeters, dist > 0 else { continue }
            weightedPaceNumerator += pace * dist
            weightedPaceDenominator += dist
        }
        let avgPace = weightedPaceDenominator > 0 ? weightedPaceNumerator / weightedPaceDenominator : nil

        let bestPace = sessions.compactMap { $0.bestLapPaceSecondsPer100m }.min()

        var distribution: [SwimStrokeStyle: Int] = [:]
        for s in sessions {
            for (style, count) in s.strokeDistribution {
                distribution[style, default: 0] += count
            }
        }

        return SwimSummary(
            sessionCount: sessions.count,
            windowWeeks: windowWeeks,
            totalDistanceMeters: totalDistance,
            weeklyAverageDistanceMeters: totalDistance / Double(windowWeeks),
            weeklyAverageSessions: Double(sessions.count) / Double(windowWeeks),
            avgPaceSecondsPer100m: avgPace,
            bestPaceSecondsPer100m: bestPace,
            strokeDistribution: distribution,
            longestSessionDistanceMeters: sessions.compactMap { $0.totalDistanceMeters }.max(),
            sessions: sessions
        )
    }

    // MARK: - Résumé d'une séance

    static func summarizeSession(_ d: HealthKitSwimWorkoutDetail) -> SwimSessionSummary {
        let laps = d.laps

        let avgPace = weightedSwumPace(laps)
        let bestPace = bestSwumPace(laps, poolLength: d.poolLengthMeters)

        var distribution: [SwimStrokeStyle: Int] = [:]
        for lap in laps {
            guard let style = lap.strokeStyle else { continue }
            distribution[style, default: 0] += 1
        }
        let dominant = dominantStroke(distribution)

        let swolfs = laps.compactMap { $0.swolfScore }
        let avgSwolf = swolfs.isEmpty ? nil : Int((Double(swolfs.reduce(0, +)) / Double(swolfs.count)).rounded())

        return SwimSessionSummary(
            id: d.id,
            date: d.startDate,
            durationSeconds: d.durationSeconds,
            totalDistanceMeters: d.totalDistanceMeters,
            lapCount: laps.count,
            avgPaceSecondsPer100m: avgPace,
            bestLapPaceSecondsPer100m: bestPace,
            dominantStroke: dominant,
            strokeDistribution: distribution,
            avgSwolf: avgSwolf,
            averageHeartRateBpm: d.averageHeartRateBpm,
            activeEnergyKcal: d.activeEnergyKcal,
            sets: detectSets(laps: laps, restThreshold: restBreakThresholdSeconds),
            poolLengthMeters: d.poolLengthMeters
        )
    }

    // MARK: - Détection de séries (repos au mur)

    /// Regroupe les longueurs consécutives en séries. Une série se ferme quand
    /// `restAfterSeconds >= restThreshold` (repos au mur) ou en fin de séance.
    static func detectSets(laps: [HealthKitSwimLap], restThreshold: TimeInterval) -> [SwimSet] {
        guard !laps.isEmpty else { return [] }

        var sets: [SwimSet] = []
        var current: [HealthKitSwimLap] = []

        func closeSet(restAfter: TimeInterval?) {
            guard !current.isEmpty else { return }
            sets.append(makeSet(id: sets.count + 1, laps: current, restAfter: restAfter))
            current.removeAll(keepingCapacity: true)
        }

        for lap in laps {
            current.append(lap)
            if let rest = lap.restAfterSeconds, rest >= restThreshold {
                closeSet(restAfter: rest)
            }
        }
        // Dernière série (pas de repos de fermeture).
        closeSet(restAfter: nil)
        return sets
    }

    private static func makeSet(id: Int, laps: [HealthKitSwimLap], restAfter: TimeInterval?) -> SwimSet {
        let distances = laps.compactMap { $0.distanceMeters }
        let distance = distances.isEmpty ? nil : distances.reduce(0, +)

        var distribution: [SwimStrokeStyle: Int] = [:]
        for lap in laps {
            guard let style = lap.strokeStyle else { continue }
            distribution[style, default: 0] += 1
        }

        let swolfs = laps.compactMap { $0.swolfScore }
        let avgSwolf = swolfs.isEmpty ? nil : Int((Double(swolfs.reduce(0, +)) / Double(swolfs.count)).rounded())

        return SwimSet(
            id: id,
            lapCount: laps.count,
            distanceMeters: distance,
            dominantStroke: dominantStroke(distribution),
            avgPaceSecondsPer100m: weightedSwumPace(laps),
            avgSwolf: avgSwolf,
            restAfterSeconds: restAfter
        )
    }

    // MARK: - Helpers pace / stroke

    /// Pace agrégée pondérée par la distance des longueurs NAGÉES (hors kick/unknown).
    /// Équivaut à (temps nagé total / distance nagée totale × 100) — la vraie pace
    /// d'ensemble, cohérente entre niveau lap / série / séance / fenêtre. nil si aucune.
    private static func weightedSwumPace(_ laps: [HealthKitSwimLap]) -> Double? {
        var numerator = 0.0
        var denominator = 0.0
        for lap in laps where (lap.strokeStyle ?? .unknown).isSwumStroke {
            guard let pace = lap.paceSecondsPer100m, let dist = lap.distanceMeters, dist > 0 else { continue }
            numerator += pace * dist
            denominator += dist
        }
        return denominator > 0 ? numerator / denominator : nil
    }

    /// Meilleure (plus rapide) pace de longueur nagée, en écartant les longueurs
    /// partielles (push-off compté seul, lap tronqué) via un plancher de distance
    /// = 90 % de la longueur de bassin. Sans pool length connu, pas de filtre.
    private static func bestSwumPace(_ laps: [HealthKitSwimLap], poolLength: Double?) -> Double? {
        let minValidDistance = poolLength.map { $0 * 0.9 }
        return laps
            .filter { ($0.strokeStyle ?? .unknown).isSwumStroke }
            .filter { lap in
                guard let floor = minValidDistance else { return true }
                guard let dist = lap.distanceMeters else { return false }
                return dist >= floor
            }
            .compactMap { $0.paceSecondsPer100m }
            .min()
    }

    /// Style dominant : le plus fréquent en EXCLUANT `.unknown` (bruit). À count
    /// égal, départage par rawValue croissant pour un résultat déterministe.
    private static func dominantStroke(_ distribution: [SwimStrokeStyle: Int]) -> SwimStrokeStyle? {
        distribution
            .filter { $0.key != .unknown }
            .max { a, b in
                a.value != b.value ? a.value < b.value : a.key.rawValue > b.key.rawValue
            }?
            .key
    }
}
