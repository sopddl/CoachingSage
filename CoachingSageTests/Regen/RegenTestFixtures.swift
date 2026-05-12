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
}
