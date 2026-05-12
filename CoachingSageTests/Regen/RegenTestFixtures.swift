// CoachingSageTests/Regen/RegenTestFixtures.swift
// Story 3.4 Phase A — helpers partagés entre tests A.1 (WeeklyExecution),
// A.2 (WeeklyExecutionAnalyzer), et à venir A.3/A.4. Évite la duplication.
import Foundation
import TemplateModel
@testable import CoachingSage

enum RegenTestFixtures {

    /// Lundi 1er juillet 2024, 00:00 local — date stable pour les tests.
    /// Choix : un lundi mid-summer évite les transitions DST (printemps/automne)
    /// qui pourraient décaler les calculs `daysBetween` d'1h en bord de zone.
    static func makeWeekStart() -> Date {
        var components = DateComponents()
        components.year = 2024
        components.month = 7
        components.day = 1
        components.hour = 0
        return Calendar.current.date(from: components)!
    }

    /// Construit une `PersistedSession` minimale pour les tests.
    /// - `targetZones` : un élément par exercice. nil = exercice sans HR target.
    ///   Si vide → session sans exercice (utile pour tester sessionTargetZone nil).
    static func makeSession(
        weekNumber: Int = 1,
        day: Int = 1,
        durationMinutes: Int = 30,
        type: SessionType = .endurance,
        targetZones: [String?] = []
    ) -> PersistedSession {
        let exercises = targetZones.map { zone in
            AdaptedExercise(
                name: "Test exercise",
                originalName: "Test exercise",
                targetZone: zone
            )
        }
        return PersistedSession(
            weekNumber: weekNumber,
            weekTheme: "test theme",
            weekGoal: "test goal",
            day: day,
            name: "Test session",
            durationMinutes: durationMinutes,
            type: type,
            warmup: nil,
            exercises: exercises,
            cooldown: nil
        )
    }

    /// Construit un `WeeklyExecutionReport` directement, pour tester les couches
    /// au-dessus de l'analyzer (PauseDetector, RegressionRule) sans avoir à
    /// orchestrer un matching complet. `matches` laissé vide par défaut — les
    /// consommateurs aval (A.3/A.4) ne lisent que les champs agrégés, pas les
    /// matches individuels.
    static func makeReport(
        weekNumber: Int = 1,
        plannedActiveSessionCount: Int = 3,
        completedSessionCount: Int = 3,
        completionRate: Double = 1.0,
        globalQuality: Double = 100.0,
        overExecutedCount: Int = 0,
        isOverallOverExecuted: Bool = false
    ) -> WeeklyExecutionReport {
        WeeklyExecutionReport(
            weekNumber: weekNumber,
            weekStartDate: makeWeekStart(),
            plannedSessionCount: plannedActiveSessionCount,
            plannedActiveSessionCount: plannedActiveSessionCount,
            completedSessionCount: completedSessionCount,
            completionRate: completionRate,
            globalQuality: globalQuality,
            overExecutedCount: overExecutedCount,
            isOverallOverExecuted: isOverallOverExecuted,
            matches: []
        )
    }
}
