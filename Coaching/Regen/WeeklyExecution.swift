// Coaching/Regen/WeeklyExecution.swift
// Story 3.4 Phase A.1 — algo deterministic pour évaluer l'exécution d'une semaine
// de programme via HealthKit. Pur Swift testable, 0 dépendance HK live.
//
// Pipeline V1 :
//   1. WorkoutMatcher.match : pour chaque session planifiée, cherche dans les
//      WorkoutSnapshots HK le candidat le plus proche (sport + date ±2j),
//      résolution globalement optimale (distance croissante, pas greedy par
//      ordre de session).
//   2. ExecutionScore.compute : score 0-100 par match basé sur volume + intensité
//      HR vs target zone, pondéré par le type de session (endurance → volume
//      prime, interval → intensité prime).
//
// Réutilisé par 3.4.A.2 (WeeklyExecutionAnalyzer) qui agrège les scores
// par semaine et calibre la régen S+1.
//
// Doctrine intensité (HR zones en % HRmax) :
//   - Daniels-E (Easy)      = 65-79%
//   - Daniels-M (Marathon)  = 80-85%
//   - Daniels-T (Threshold) = 86-92%
//   - Daniels-I (Intervals) = 95-100%
//   - Daniels-R (Reps)      = pace-driven dans la doctrine ; HR fallback >98%
//     ici car HK fournit averageHR pas pace de référence (zone élargie pour
//     attraper le travail à pleine vitesse, sans cap réaliste hors élite).
//   - Z1                    = <60%
//   - Z2 (aerobic base)     = 60-70%
//   - Z3 (aerobic threshold)= 70-80%
//   - Z4 (lactate threshold)= 80-90%
//   - Z5 (VO2max)           = 90-100%
//
// Sources : Daniels' Running Formula (3e éd.) + ACSM Guidelines (11e éd.).
// Bandes %HRmax Daniels alignées sur la convention publique sourcée :
// articles.sweatelite.co/understand-the-jack-daniels-running-formula-in-15mins/
// coachray.nz/2023/05/03/jack-daniels-running-intensity/
import Foundation
import TemplateModel

// MARK: - HRZone

/// Plage de HR en pourcentage de HRmax (low/high ∈ 0...1).
/// Used to compare planned intensity (target zone string) vs actual (HR avg).
public struct HRZone: Equatable, Sendable {
    public let lowPercent: Double
    public let highPercent: Double

    /// Distance max (en % HRmax) au-delà de laquelle `proximity` renvoie 0.
    /// Exposée pour tuning post-prod : si la régen S+1 sous-pénalise / sur-pénalise
    /// le sous-pacing sur data réelles, on baisse (12%) ou monte (18%) ici sans
    /// toucher au reste de l'algo. 15% HRmax ≈ 30 BPM pour HRmax 200 — assez
    /// sévère pour pénaliser un Daniels-T fait à allure d'endurance, assez souple
    /// pour ne pas écraser un débutant qui rate la zone de 10 BPM.
    public static let maxProximityDistancePercent: Double = 0.15

    public init(lowPercent: Double, highPercent: Double) {
        // Defensive : tout le mapper respecte low < high mais un dev pourrait
        // construire une zone à la main. precondition fail-fast en debug.
        precondition(lowPercent <= highPercent,
                     "HRZone : lowPercent (\(lowPercent)) > highPercent (\(highPercent))")
        self.lowPercent = lowPercent
        self.highPercent = highPercent
    }

    public var midpointPercent: Double { (lowPercent + highPercent) / 2 }

    /// Convertit en BPM pour un HRmax donné (ex: 200 BPM).
    public func bpmRange(hrMax: Int) -> (low: Int, high: Int) {
        (Int(Double(hrMax) * lowPercent), Int(Double(hrMax) * highPercent))
    }

    /// Évalue à quel point un HR avg donné est dans la zone cible (1.0 = pile,
    /// 0.0 = très loin). Si dans la zone → 1.0 ; sinon pénalité linéaire à la
    /// distance au plus proche bord, max distance = `maxProximityDistancePercent`
    /// (15% HRmax par défaut).
    ///
    /// Garde-fou `hrMax > 0` : un Watch fraîchement appairé sans encore de
    /// mesure peut renvoyer 0. Retourne 0 (= "hors cible total") plutôt que
    /// crasher en `+Inf` / `NaN` sur la division.
    public func proximity(to hrAvg: Int, hrMax: Int) -> Double {
        guard hrMax > 0 else { return 0.0 }
        let bpm = bpmRange(hrMax: hrMax)
        if hrAvg >= bpm.low && hrAvg <= bpm.high { return 1.0 }
        let distance = hrAvg < bpm.low ? Double(bpm.low - hrAvg) : Double(hrAvg - bpm.high)
        let maxDistance = Double(hrMax) * Self.maxProximityDistancePercent
        return max(0.0, 1.0 - distance / maxDistance)
    }
}

// MARK: - HRZoneMapper

/// Convertit une chaîne `targetZone` (telle que stockée dans `AdaptedExercise.targetZone`)
/// en `HRZone`. Tolérant : retourne nil si la chaîne n'est pas reconnue.
///
/// Zones composées (ex: "Daniels-E/T") non gérées V1 — retourne nil.
public enum HRZoneMapper {
    public static func zone(for targetZone: String?) -> HRZone? {
        guard let raw = targetZone?.trimmingCharacters(in: .whitespacesAndNewlines),
              !raw.isEmpty else { return nil }
        let normalized = raw.lowercased()
            .replacingOccurrences(of: "_", with: "-")
            .replacingOccurrences(of: " ", with: "-")
        switch normalized {
        case "daniels-e", "easy":               return HRZone(lowPercent: 0.65, highPercent: 0.79)
        case "daniels-m", "marathon":            return HRZone(lowPercent: 0.80, highPercent: 0.85)
        case "daniels-t", "threshold", "tempo":  return HRZone(lowPercent: 0.86, highPercent: 0.92)
        case "daniels-i", "intervals", "vo2":    return HRZone(lowPercent: 0.95, highPercent: 1.00)
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
/// exécutée. `executionScore` nil si le matching n'a pas trouvé de candidat
/// (session non réalisée).
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
public struct ExecutionScore: Equatable, Sendable {
    /// 0-150% — borné pour ne pas exploser sur over-execution (volume raw).
    public let volumePercent: Double

    /// 0-100% — proximity à la target zone. nil si pas de HR HK ou pas de target zone.
    public let intensityPercent: Double?

    /// Score composite 0-100. Pondéré par type de session via `Self.weights(for:)`.
    /// Volume capped à 100% dans le score (pas de bonus over-training).
    public let overallScore: Double

    public init(volumePercent: Double, intensityPercent: Double?, overallScore: Double) {
        self.volumePercent = volumePercent
        self.intensityPercent = intensityPercent
        self.overallScore = overallScore
    }

    /// Flag dérivé : la session a été sur-réalisée (volume > 110% du planifié).
    /// L'analyzer A.2 doit lire ce flag séparément pour signaler "tu pousses trop fort"
    /// dans la régen S+1 (le `overallScore` ne le reflète pas car capped à 100).
    public var isOverExecuted: Bool { volumePercent > 110 }

    /// Pondération volume/intensité par type de session (somme = 1.0).
    /// Doctrine sport : intervals et threshold pénalisent fort le sous-pacing
    /// d'intensité (rater la zone = manquer l'adaptation cardio visée). Endurance
    /// long et strength pénalisent surtout le sous-volume. Mixed = neutre.
    public static func weights(for type: SessionType) -> (volume: Double, intensity: Double) {
        switch type {
        case .interval:                                   return (0.40, 0.60)
        case .endurance:                                  return (0.70, 0.30)
        case .strength, .technique, .mobility:            return (0.75, 0.25)
        case .mixed:                                      return (0.50, 0.50)
        case .rest, .other:                               return (0.60, 0.40)
        }
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

        // 2. Intensity : proximity HR avg vs session target zone (si dispo)
        var intensityPct: Double?
        if let hrMax,
           let targetZone = HRZoneMapper.sessionTargetZone(session),
           let hrAvg = workout.averageHeartRateBpm {
            intensityPct = targetZone.proximity(to: hrAvg, hrMax: hrMax) * 100.0
        }

        // 3. Score composite pondéré par type. Volume capped à 100% dans le
        // composite (pas de bonus over-training). Le flag `isOverExecuted`
        // expose séparément le volume > 110%.
        let cappedVolume = min(100.0, volumePct)
        let weights = Self.weights(for: session.type)
        let overall: Double
        if let intensityPct {
            overall = cappedVolume * weights.volume + intensityPct * weights.intensity
        } else {
            // Pas de HR → fallback volume seul (pas de pénalité conjecturale)
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
    /// planifiée. 2 jours pour absorber un report user (séance lundi → finie mardi).
    public static let dateToleranceDays: Int = 2

    /// Match `sessions` ↔ `workouts` pour une semaine cible.
    ///
    /// **Résolution globalement optimale** : on évite le greedy par ordre de
    /// session (qui pouvait laisser une session à distance 0 sans match si
    /// une autre session avec distance 1 consommait le workout en premier).
    /// On trie tous les couples candidats par distance croissante, puis on
    /// assigne greedy sur cette liste triée.
    public static func match(
        sessions: [PersistedSession],
        sportCode: String,
        workouts: [HealthSummary.WorkoutSnapshot],
        weekStartDate: Date,
        hrMax: Int?,
        now: Date = Date()
    ) -> [WorkoutMatch] {
        // Garde sportCode vide : éviterait de matcher silencieusement tous les
        // workouts dont sportCode est nil ou "" en cas de bug appelant. Préfère
        // retourner toutes les sessions non-matchées plutôt qu'un faux match.
        guard !sportCode.isEmpty else {
            return sessions.map { WorkoutMatch(session: $0, workout: nil, executionScore: nil) }
        }
        // 1. Pré-calculer la date planifiée de chaque session
        let plannedDates: [Date] = sessions.map { session in
            session.plannedDate ?? defaultDate(for: session, weekStartDate: weekStartDate)
        }

        // 2. Générer tous les couples candidats (sessionIdx, workoutIdx, distance)
        //    filtrés par sport + tolerance.
        struct Candidate {
            let sessionIdx: Int
            let workoutIdx: Int
            let distance: Int
        }
        var candidates: [Candidate] = []
        for (wIdx, workout) in workouts.enumerated() {
            guard workout.sportCode == sportCode else { continue }
            let workoutDate = absoluteDate(daysAgo: workout.daysAgo, now: now)
            for (sIdx, plannedDate) in plannedDates.enumerated() {
                let diff = abs(daysBetween(plannedDate, workoutDate))
                guard diff <= dateToleranceDays else { continue }
                candidates.append(Candidate(sessionIdx: sIdx, workoutIdx: wIdx, distance: diff))
            }
        }

        // 3. Trier par distance croissante. Tie-breaker : sessionIdx puis workoutIdx
        //    (deterministic pour les tests).
        candidates.sort { lhs, rhs in
            if lhs.distance != rhs.distance { return lhs.distance < rhs.distance }
            if lhs.sessionIdx != rhs.sessionIdx { return lhs.sessionIdx < rhs.sessionIdx }
            return lhs.workoutIdx < rhs.workoutIdx
        }

        // 4. Greedy assign : pour chaque candidat trié, assigner si session ET
        //    workout pas encore consommés.
        var sessionAssigned = Array(repeating: false, count: sessions.count)
        var workoutConsumed = Array(repeating: false, count: workouts.count)
        var matchedWorkoutIdx: [Int?] = Array(repeating: nil, count: sessions.count)
        for candidate in candidates {
            guard !sessionAssigned[candidate.sessionIdx],
                  !workoutConsumed[candidate.workoutIdx] else { continue }
            sessionAssigned[candidate.sessionIdx] = true
            workoutConsumed[candidate.workoutIdx] = true
            matchedWorkoutIdx[candidate.sessionIdx] = candidate.workoutIdx
        }

        // 5. Reconstruire le résultat dans l'ordre des sessions
        return sessions.enumerated().map { idx, session in
            if let wIdx = matchedWorkoutIdx[idx] {
                let workout = workouts[wIdx]
                let score = ExecutionScore.compute(session: session, workout: workout, hrMax: hrMax)
                return WorkoutMatch(session: session, workout: workout, executionScore: score)
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

    // MARK: - Helpers

    static func absoluteDate(daysAgo: Int, now: Date) -> Date {
        Calendar.current.date(byAdding: .day, value: -daysAgo, to: now) ?? now
    }

    static func daysBetween(_ a: Date, _ b: Date) -> Int {
        // Fallback Int.max (= jamais matcher) plutôt que 0 (= match parfait
        // accidentel) si Calendar échoue — quasi impossible mais préférable
        // d'être pessimiste : on rate un match plutôt que d'en inventer un.
        Calendar.current.dateComponents([.day], from: startOfDay(a), to: startOfDay(b)).day ?? .max
    }

    private static func startOfDay(_ date: Date) -> Date {
        Calendar.current.startOfDay(for: date)
    }
}
