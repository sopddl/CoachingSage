// Coaching/Regen/WeeklyExecution.swift
// Story 3.4 Phase A.1 — algo deterministic pour évaluer l'exécution d'une semaine
// de programme via HealthKit. Pur Swift testable, 0 dépendance HK live.
//
// Pipeline V1 :
//   1. WorkoutMatcher.match : pour chaque session planifiée, cherche dans les
//      WorkoutSnapshots HK le candidat le plus proche (sport + date ±2j).
//   2. ExecutionScore.compute : score 0-100 par match basé sur volume (0.6) +
//      intensité HR vs target zone (0.4).
//
// Réutilisé par 3.4.A.2 (WeeklyExecutionAnalyzer) qui agrège les scores
// par semaine et calibre la régen S+1.
//
// Doctrine intensité (HR zones en % HRmax) :
//   - Daniels-E (Easy)      = 60-75%
//   - Daniels-M (Marathon)  = 75-82%
//   - Daniels-T (Threshold) = 82-88%
//   - Daniels-I (Intervals) = 92-98%
//   - Daniels-R (Reps)      = >98%
//   - Z1                    = <60%
//   - Z2 (aerobic base)     = 60-70%
//   - Z3 (aerobic threshold)= 70-80%
//   - Z4 (lactate threshold)= 80-90%
//   - Z5 (VO2max)           = 90-100%
//
// Sources : Daniels' Running Formula (3e éd.) + ACSM Guidelines (10e éd.).
import Foundation
import TemplateModel

// MARK: - HRZone

/// Plage de HR en pourcentage de HRmax (low/high ∈ 0...1).
/// Used to compare planned intensity (target zone string) vs actual (HR avg).
public struct HRZone: Equatable, Sendable {
    public let lowPercent: Double
    public let highPercent: Double

    public init(lowPercent: Double, highPercent: Double) {
        self.lowPercent = lowPercent
        self.highPercent = highPercent
    }

    public var midpointPercent: Double { (lowPercent + highPercent) / 2 }

    /// Convertit en BPM si HRmax est connu (ex: 190 BPM). Retourne nil si HRmax nil.
    public func bpmRange(hrMax: Int?) -> (low: Int, high: Int)? {
        guard let hrMax else { return nil }
        return (Int(Double(hrMax) * lowPercent), Int(Double(hrMax) * highPercent))
    }

    /// Évalue à quel point un HR avg donné est dans la zone cible (1.0 = pile,
    /// 0.0 = très loin). Méthode robuste : si dans la zone → 1.0 ; sinon
    /// pénalité linéaire à la distance au plus proche bord, max distance = 30% HRmax.
    public func proximity(to hrAvg: Int, hrMax: Int) -> Double {
        guard let bpm = bpmRange(hrMax: hrMax) else { return 0.5 }
        if hrAvg >= bpm.low && hrAvg <= bpm.high { return 1.0 }
        let distance = hrAvg < bpm.low ? Double(bpm.low - hrAvg) : Double(hrAvg - bpm.high)
        let maxDistance = Double(hrMax) * 0.30
        let normalized = max(0.0, 1.0 - distance / maxDistance)
        return normalized
    }
}

// MARK: - HRZoneMapper

/// Convertit une chaîne `targetZone` (telle que stockée dans `AdaptedExercise.targetZone`)
/// en `HRZone`. Tolérant : retourne nil si la chaîne n'est pas reconnue.
public enum HRZoneMapper {
    public static func zone(for targetZone: String?) -> HRZone? {
        guard let raw = targetZone?.trimmingCharacters(in: .whitespacesAndNewlines),
              !raw.isEmpty else { return nil }
        // Normalisation : casse + séparateurs (Daniels-E, daniels_e, "Daniels E").
        let normalized = raw.lowercased()
            .replacingOccurrences(of: "_", with: "-")
            .replacingOccurrences(of: " ", with: "-")
        switch normalized {
        case "daniels-e", "easy":               return HRZone(lowPercent: 0.60, highPercent: 0.75)
        case "daniels-m", "marathon":            return HRZone(lowPercent: 0.75, highPercent: 0.82)
        case "daniels-t", "threshold", "tempo":  return HRZone(lowPercent: 0.82, highPercent: 0.88)
        case "daniels-i", "intervals", "vo2":    return HRZone(lowPercent: 0.92, highPercent: 0.98)
        case "daniels-r", "reps":                return HRZone(lowPercent: 0.98, highPercent: 1.05)
        case "z1":                                return HRZone(lowPercent: 0.50, highPercent: 0.60)
        case "z2":                                return HRZone(lowPercent: 0.60, highPercent: 0.70)
        case "z3":                                return HRZone(lowPercent: 0.70, highPercent: 0.80)
        case "z4":                                return HRZone(lowPercent: 0.80, highPercent: 0.90)
        case "z5":                                return HRZone(lowPercent: 0.90, highPercent: 1.00)
        default: return nil
        }
    }

    /// Zone "haute" attendue d'une session — agrège les target zones de ses
    /// exercices et retourne la zone la plus intense (= heuristique : on évalue
    /// la session par son pic d'intensité, pas par sa moyenne).
    public static func sessionTargetZone(_ session: PersistedSession) -> HRZone? {
        let zones = session.exercises.compactMap { zone(for: $0.targetZone) }
        guard !zones.isEmpty else { return nil }
        return zones.max(by: { $0.midpointPercent < $1.midpointPercent })
    }
}

// MARK: - WorkoutMatch

/// Lien entre une session planifiée et un workout HK qui l'a probablement
/// exécutée. `executionScore` peut être nil si le matching n'a pas trouvé de
/// candidat (session non réalisée).
public struct WorkoutMatch: Equatable, Sendable {
    public let session: PersistedSession
    public let workout: HealthSummary.WorkoutSnapshot?
    public let executionScore: ExecutionScore?

    public init(
        session: PersistedSession,
        workout: HealthSummary.WorkoutSnapshot?,
        executionScore: ExecutionScore?
    ) {
        self.session = session
        self.workout = workout
        self.executionScore = executionScore
    }

    /// True si la session a un workout HK matchant (peu importe la qualité).
    public var isDone: Bool { workout != nil }
}

// MARK: - ExecutionScore

/// Évaluation 0-100 de l'exécution d'une session.
/// `volumePercent` et `intensityPercent` peuvent être nil si non calculables
/// (pas de durée planifiée, pas de target zone, pas de HR HK).
public struct ExecutionScore: Equatable, Sendable {
    /// 0-150% — borné pour ne pas exploser sur over-execution (l'user qui fait
    /// 60 min au lieu de 30 → 200% ne donne pas 200/100 mais reste 150%).
    public let volumePercent: Double

    /// 0-100% — proximity à la target zone. nil si pas de HR HK ou pas de target zone.
    public let intensityPercent: Double?

    /// Score composite 0-100. Volume pondéré 0.6, intensity 0.4 si dispo, sinon
    /// volume seul.
    public let overallScore: Double

    public init(volumePercent: Double, intensityPercent: Double?, overallScore: Double) {
        self.volumePercent = volumePercent
        self.intensityPercent = intensityPercent
        self.overallScore = overallScore
    }

    /// Calcule un ExecutionScore pour un (session, workout) match.
    /// - Parameter hrMax : HRmax estimé du user. Si nil → intensity skipped.
    public static func compute(
        session: PersistedSession,
        workout: HealthSummary.WorkoutSnapshot,
        hrMax: Int?
    ) -> ExecutionScore {
        // 1. Volume : durée réelle vs planifiée, clampé 0...150%
        let plannedMin = max(1, session.durationMinutes) // évite div/0
        let actualMin = max(0, workout.durationMinutes)
        let volumePct = min(150.0, Double(actualMin) / Double(plannedMin) * 100.0)

        // 2. Intensity : proximity HR avg vs session target zone
        var intensityPct: Double?
        if let hrMax,
           let targetZone = HRZoneMapper.sessionTargetZone(session),
           let hrAvg = workout.averageHeartRateBpm {
            intensityPct = targetZone.proximity(to: hrAvg, hrMax: hrMax) * 100.0
        }

        // 3. Score composite. Volume "à 100%" vaut 100, dépasser au-delà ne bonus pas
        // (on n'encourage pas l'over-training : >100% volume = même score que pile).
        let cappedVolume = min(100.0, volumePct)
        let overall: Double
        if let intensityPct {
            overall = cappedVolume * 0.6 + intensityPct * 0.4
        } else {
            overall = cappedVolume
        }

        return ExecutionScore(
            volumePercent: volumePct,
            intensityPercent: intensityPct,
            overallScore: overall
        )
    }
}

// MARK: - WorkoutMatcher

/// Algo deterministic qui pour une liste de sessions planifiées + une liste de
/// workouts HK, produit la liste des `WorkoutMatch` (1 par session, workout
/// éventuellement nil si pas réalisée).
public enum WorkoutMatcher {

    /// Tolérance ±N jours pour considérer qu'un workout HK exécute une session
    /// planifiée à une certaine date. 2 jours pour absorber un report user
    /// (séance lundi → finie mardi soir).
    public static let dateToleranceDays: Int = 2

    /// Match `sessions` ↔ `workouts` pour une semaine cible.
    /// - Parameters:
    ///   - sessions: sessions planifiées de la semaine (`PersistedSession`).
    ///   - workouts: snapshots HK des 7-14 derniers jours.
    ///   - weekStartDate: lundi 00:00 de la semaine cible (référence pour les dates par défaut).
    ///   - hrMax: HRmax estimé du user (ex: 220-age).
    ///   - now: date courante (pour calcul date absolue depuis `daysAgo`).
    public static func match(
        sessions: [PersistedSession],
        workouts: [HealthSummary.WorkoutSnapshot],
        weekStartDate: Date,
        hrMax: Int?,
        now: Date = Date()
    ) -> [WorkoutMatch] {
        var availableWorkouts = workouts.enumerated().map { (index: $0.offset, snapshot: $0.element) }

        return sessions.map { session in
            let plannedDate = session.plannedDate
                ?? defaultDate(for: session, weekStartDate: weekStartDate)

            // Cherche le workout candidat : même sport + date dans la tolérance,
            // minimisant la distance temporelle.
            let candidate = availableWorkouts
                .compactMap { entry -> (index: Int, snapshot: HealthSummary.WorkoutSnapshot, distance: Int)? in
                    guard let sport = entry.snapshot.sportCode,
                          sport == programSportCode(for: session) else { return nil }
                    let workoutDate = absoluteDate(daysAgo: entry.snapshot.daysAgo, now: now)
                    let diff = abs(daysBetween(plannedDate, workoutDate))
                    guard diff <= dateToleranceDays else { return nil }
                    return (entry.index, entry.snapshot, diff)
                }
                .min(by: { $0.distance < $1.distance })

            if let candidate {
                // Consomme le workout pour ne pas le re-matcher sur une autre session.
                availableWorkouts.removeAll { $0.index == candidate.index }
                let score = ExecutionScore.compute(
                    session: session,
                    workout: candidate.snapshot,
                    hrMax: hrMax
                )
                return WorkoutMatch(session: session, workout: candidate.snapshot, executionScore: score)
            } else {
                return WorkoutMatch(session: session, workout: nil, executionScore: nil)
            }
        }
    }

    /// Date par défaut d'une session = weekStart + (day-1) jours. Utilisée quand
    /// l'user n'a pas modifié `plannedDate` via drag&drop.
    static func defaultDate(for session: PersistedSession, weekStartDate: Date) -> Date {
        Calendar.current.date(byAdding: .day, value: session.day - 1, to: weekStartDate) ?? weekStartDate
    }

    /// `Sport.rawValue` du programme — passé à travers `PersistedSession`. La
    /// session ne porte pas le sport explicitement, mais on récupère via le
    /// premier exercice... actuellement on n'a pas cette info. Pour V1.A.1 on
    /// passe par le caller (3.4.A.2 connaît le programme.sportCode). Cf
    /// extension `match(sessions:sportCode:...)` ci-dessous.
    private static func programSportCode(for session: PersistedSession) -> String {
        // Hack V1 : on stocke implicitement le sport via le type de session ?
        // Non — on accepte le défaut, le caller passe le sportCode. Cf overload.
        return ""
    }

    /// Overload qui prend explicitement le sportCode du programme. C'est le
    /// point d'entrée principal (l'autre version sans sportCode renverra des
    /// matchs vides car sport ne sera jamais "").
    public static func match(
        sessions: [PersistedSession],
        sportCode: String,
        workouts: [HealthSummary.WorkoutSnapshot],
        weekStartDate: Date,
        hrMax: Int?,
        now: Date = Date()
    ) -> [WorkoutMatch] {
        var availableWorkouts = workouts.enumerated().map { (index: $0.offset, snapshot: $0.element) }

        return sessions.map { session in
            let plannedDate = session.plannedDate
                ?? defaultDate(for: session, weekStartDate: weekStartDate)

            let candidate = availableWorkouts
                .compactMap { entry -> (index: Int, snapshot: HealthSummary.WorkoutSnapshot, distance: Int)? in
                    guard let sport = entry.snapshot.sportCode, sport == sportCode else { return nil }
                    let workoutDate = absoluteDate(daysAgo: entry.snapshot.daysAgo, now: now)
                    let diff = abs(daysBetween(plannedDate, workoutDate))
                    guard diff <= dateToleranceDays else { return nil }
                    return (entry.index, entry.snapshot, diff)
                }
                .min(by: { $0.distance < $1.distance })

            if let candidate {
                availableWorkouts.removeAll { $0.index == candidate.index }
                let score = ExecutionScore.compute(
                    session: session,
                    workout: candidate.snapshot,
                    hrMax: hrMax
                )
                return WorkoutMatch(session: session, workout: candidate.snapshot, executionScore: score)
            } else {
                return WorkoutMatch(session: session, workout: nil, executionScore: nil)
            }
        }
    }

    // MARK: - Helpers

    static func absoluteDate(daysAgo: Int, now: Date) -> Date {
        Calendar.current.date(byAdding: .day, value: -daysAgo, to: now) ?? now
    }

    static func daysBetween(_ a: Date, _ b: Date) -> Int {
        Calendar.current.dateComponents([.day], from: a.startOfDay(), to: b.startOfDay()).day ?? 0
    }
}

// MARK: - Date helper

private extension Date {
    func startOfDay() -> Date {
        Calendar.current.startOfDay(for: self)
    }
}
