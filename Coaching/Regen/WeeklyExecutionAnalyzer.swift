// Coaching/Regen/WeeklyExecutionAnalyzer.swift
// Story 3.4 Phase A.2 — agrège les ExecutionScores A.1 en un rapport hebdo
// que A.3 (PauseDetector + RegressionRule) et A.4 (WeeklyRegenEngine) consomment
// pour décider de la régen S+1.
//
// Pur Swift, 0 dépendance HK live (déterministe, testable). Travaille à partir
// d'un tableau de PersistedSession + un tableau de WorkoutSnapshot HK ; orchestre
// WorkoutMatcher (A.1) puis calcule completionRate + globalQuality + flags.
//
// Doctrine pondération : on pondère par `durationMinutes` plutôt que par type
// de session. Justification : la durée encode déjà l'importance relative (une
// sortie longue de 90 min compte 3× plus qu'une récup 30 min) et reste fidèle
// au template. Une session manquée pèse 0 dans la qualité — ce qui pénalise le
// completionRate, mais pas la qualité des séances réalisées.
import Foundation
import TemplateModel

// MARK: - WeeklyExecutionReport

/// Rapport agrégé de l'exécution d'une semaine de programme.
/// `globalQuality` = qualité MOYENNE des séances réalisées (0 si rien fait).
/// `completionRate` = ratio séances réalisées / séances actives planifiées.
/// Les deux sont indépendants : on peut avoir completionRate 50% et globalQuality
/// 95% (l'user a fait peu de séances, mais celles faites étaient parfaites).
public struct WeeklyExecutionReport: Equatable, Sendable {
    public let weekNumber: Int
    public let weekStartDate: Date

    /// Nombre total de sessions planifiées (toutes, y compris `.rest`).
    public let plannedSessionCount: Int

    /// Sessions planifiées « actives » : exclut `.rest`. Sert de dénominateur
    /// au completionRate (un jour de repos ne peut pas être « réalisé »).
    public let plannedActiveSessionCount: Int

    /// Sessions réellement matchées avec un workout HK.
    public let completedSessionCount: Int

    /// `completedSessionCount` / `plannedActiveSessionCount`, dans [0, 1].
    /// 0 si aucune session active planifiée (programme = full rest).
    public let completionRate: Double

    /// Moyenne pondérée par `durationMinutes` du `overallScore` des sessions
    /// complétées. 0-100. 0 si rien de complété.
    public let globalQuality: Double

    /// Nombre de sessions complétées avec volume > 110% du planifié.
    public let overExecutedCount: Int

    /// `true` si au moins la moitié des sessions complétées sont sur-réalisées.
    /// Sert à A.4 pour flag "tu pousses fort, écoute-toi" dans la régen S+1.
    public let isOverallOverExecuted: Bool

    /// Matches détaillés (1 par session planifiée, dans l'ordre d'entrée).
    /// Exposé pour drill-down UI (badge dashboard, notes overlay) et pour A.3
    /// (PauseDetector regarde lesquelles sont missed).
    public let matches: [WorkoutMatch]

    public init(
        weekNumber: Int,
        weekStartDate: Date,
        plannedSessionCount: Int,
        plannedActiveSessionCount: Int,
        completedSessionCount: Int,
        completionRate: Double,
        globalQuality: Double,
        overExecutedCount: Int,
        isOverallOverExecuted: Bool,
        matches: [WorkoutMatch]
    ) {
        self.weekNumber = weekNumber
        self.weekStartDate = weekStartDate
        self.plannedSessionCount = plannedSessionCount
        self.plannedActiveSessionCount = plannedActiveSessionCount
        self.completedSessionCount = completedSessionCount
        self.completionRate = completionRate
        self.globalQuality = globalQuality
        self.overExecutedCount = overExecutedCount
        self.isOverallOverExecuted = isOverallOverExecuted
        self.matches = matches
    }

    /// Sessions actives non réalisées, dans l'ordre d'entrée. Sert au PauseDetector
    /// (A.3) et à l'overlay "Tu as manqué X séances" en UI.
    public var missedActiveSessions: [PersistedSession] {
        matches.compactMap { match in
            guard !match.isDone, match.session.type != .rest else { return nil }
            return match.session
        }
    }

    /// Matches réellement complétés (pour drill-down qualitatif).
    public var completedMatches: [WorkoutMatch] {
        matches.filter(\.isDone)
    }
}

// MARK: - WeeklyExecutionAnalyzer

public enum WeeklyExecutionAnalyzer {

    /// Analyse une semaine de programme.
    /// - Parameters:
    ///   - weekNumber: numéro de la semaine (référence, pas utilisé pour le calcul).
    ///   - weekStartDate: lundi 00:00 de la semaine analysée.
    ///   - sessions: sessions planifiées de cette semaine (toutes, y compris .rest).
    ///   - sportCode: sport ciblé (filtre les workouts HK).
    ///   - workouts: workouts HK candidats (tous sports confondus, filtrés par
    ///     `WorkoutMatcher` sur `sportCode`).
    ///   - hrMax: HRmax estimé pour calibrer l'intensité. Si nil → score volume seul.
    ///   - now: date « maintenant » (injectable pour les tests).
    public static func analyze(
        weekNumber: Int,
        weekStartDate: Date,
        sessions: [PersistedSession],
        sportCode: String,
        workouts: [HealthSummary.WorkoutSnapshot],
        hrMax: Int?,
        now: Date = Date()
    ) -> WeeklyExecutionReport {
        let matches = WorkoutMatcher.match(
            sessions: sessions,
            sportCode: sportCode,
            workouts: workouts,
            weekStartDate: weekStartDate,
            hrMax: hrMax,
            now: now
        )
        return analyze(
            weekNumber: weekNumber,
            weekStartDate: weekStartDate,
            matches: matches
        )
    }

    /// Overload : si A.4 ou les tests ont déjà calculé les matches, on évite
    /// de re-matcher.
    public static func analyze(
        weekNumber: Int,
        weekStartDate: Date,
        matches: [WorkoutMatch]
    ) -> WeeklyExecutionReport {
        let plannedCount = matches.count
        let activeCount = matches.filter { $0.session.type != .rest }.count
        let completed = matches.filter(\.isDone)
        let completedCount = completed.count

        let completionRate: Double
        if activeCount > 0 {
            completionRate = Double(completedCount) / Double(activeCount)
        } else {
            completionRate = 0.0
        }

        // Moyenne pondérée par durée. Les sessions complétées sans ExecutionScore
        // (cas dégénéré, ne devrait pas arriver via la pipeline normale) sont
        // ignorées pour ne pas fausser la moyenne.
        var weightedSum: Double = 0
        var totalWeight: Double = 0
        var overExecuted = 0
        for match in completed {
            guard let score = match.executionScore else { continue }
            let weight = Double(max(1, match.session.durationMinutes))
            weightedSum += score.overallScore * weight
            totalWeight += weight
            if score.isOverExecuted { overExecuted += 1 }
        }
        let globalQuality: Double = totalWeight > 0 ? (weightedSum / totalWeight) : 0.0

        // Au moins la moitié des sessions complétées sur-réalisées.
        // 1 session over sur 1 réalisée → true. 0 réalisée → false.
        let isOverallOverExecuted: Bool
        if completedCount > 0 {
            isOverallOverExecuted = overExecuted * 2 >= completedCount
        } else {
            isOverallOverExecuted = false
        }

        return WeeklyExecutionReport(
            weekNumber: weekNumber,
            weekStartDate: weekStartDate,
            plannedSessionCount: plannedCount,
            plannedActiveSessionCount: activeCount,
            completedSessionCount: completedCount,
            completionRate: completionRate,
            globalQuality: globalQuality,
            overExecutedCount: overExecuted,
            isOverallOverExecuted: isOverallOverExecuted,
            matches: matches
        )
    }
}
