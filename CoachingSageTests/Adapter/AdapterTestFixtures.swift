// CoachingSageTests/Adapter/AdapterTestFixtures.swift
// Story 3.3a — helpers pour construire des ProgramTemplate / profiles in-memory
// sans charger le bundle Resources. Garde les tests rapides et déterministes.
import Foundation
import TemplateModel

enum AdapterTestFixtures {

    static func makeRunningTemplate(
        sessionsPerWeek: Int = 3,
        durationWeeks: Int = 2
    ) -> ProgramTemplate {
        ProgramTemplate(
            id: "running-fixture",
            schemaVersion: 2,
            sport: .running,
            level: .beginner,
            name: "Running fixture",
            durationWeeks: durationWeeks,
            sessionsPerWeek: sessionsPerWeek,
            defaultObjective: "test",
            assumedProfile: "test",
            summary: "test",
            weeks: (1...durationWeeks).map { wn in
                TemplateWeek(
                    weekNumber: wn,
                    theme: "Semaine \(wn)",
                    goal: "Goal \(wn)",
                    sessions: [
                        TemplateSession(
                            day: 1, name: "Plyo intervals",
                            durationMinutes: 30, type: .interval,
                            warmup: nil,
                            exercises: [
                                TemplateExercise(
                                    name: "Bondissements 6×30s",
                                    sets: 6, duration: "30s",
                                    targetZone: "Daniels-R",
                                    requiredEquipment: ["track"],
                                    incompatibleConstraints: ["knee-injury", "shin-splints"],
                                    alternatives: ["Marche nordique 20 min"],
                                    volumeAxis: .sets
                                )
                            ],
                            cooldown: nil
                        ),
                        TemplateSession(
                            day: 3, name: "Tempo continu",
                            durationMinutes: 40, type: .endurance,
                            warmup: nil,
                            exercises: [
                                TemplateExercise(
                                    name: "Tempo 20 min",
                                    duration: "20 min",
                                    targetZone: "Daniels-T",
                                    requiredEquipment: [],
                                    incompatibleConstraints: [],
                                    alternatives: [],
                                    volumeAxis: .duration
                                )
                            ],
                            cooldown: nil
                        ),
                        TemplateSession(
                            day: 5, name: "Sortie longue",
                            durationMinutes: 60, type: .endurance,
                            warmup: nil,
                            exercises: [
                                TemplateExercise(
                                    name: "Long run 60 min",
                                    duration: "60 min",
                                    targetZone: "Daniels-E",
                                    requiredEquipment: [],
                                    incompatibleConstraints: [],
                                    alternatives: [],
                                    volumeAxis: .duration
                                )
                            ],
                            cooldown: nil
                        )
                    ]
                )
            },
            safetyNotes: "test",
            progressionLogic: "test"
        )
    }

    /// Template 4 sessions/sem avec une session strength + une mobility en plus.
    /// Utilisé pour tester VolumeModulationRule.
    static func makeFourSessionTemplate() -> ProgramTemplate {
        ProgramTemplate(
            id: "running-4sessions-fixture",
            schemaVersion: 2,
            sport: .running,
            level: .recreational,
            name: "Running 4 sessions",
            durationWeeks: 1,
            sessionsPerWeek: 4,
            defaultObjective: "test",
            assumedProfile: "test",
            summary: "test",
            weeks: [
                TemplateWeek(
                    weekNumber: 1,
                    theme: "S1",
                    goal: "G1",
                    sessions: [
                        TemplateSession(day: 1, name: "Easy", durationMinutes: 40,
                                        type: .endurance, warmup: nil,
                                        exercises: [TemplateExercise(name: "Easy 40min", targetZone: "Daniels-E")],
                                        cooldown: nil),
                        TemplateSession(day: 3, name: "Intervals", durationMinutes: 45,
                                        type: .interval, warmup: nil,
                                        exercises: [TemplateExercise(name: "6×400m", targetZone: "Daniels-I")],
                                        cooldown: nil),
                        TemplateSession(day: 4, name: "Mobility", durationMinutes: 20,
                                        type: .mobility, warmup: nil,
                                        exercises: [TemplateExercise(name: "Étirements")],
                                        cooldown: nil),
                        TemplateSession(day: 6, name: "Long run", durationMinutes: 75,
                                        type: .endurance, warmup: nil,
                                        exercises: [TemplateExercise(name: "Long 75 min", targetZone: "Daniels-E")],
                                        cooldown: nil)
                    ]
                )
            ],
            safetyNotes: "test",
            progressionLogic: "test"
        )
    }

    static func sportProfile(
        constraints: [String] = [],
        equipment: [String] = ["running-shoes"],
        frequencyPerWeek: Int = 3,
        goal: String = "",
        durationMode: ProgramDurationMode = .routineCyclic,
        targetDate: Date? = nil
    ) -> AdapterSportProfile {
        AdapterSportProfile(
            constraints: constraints,
            equipment: equipment,
            frequencyPerWeek: frequencyPerWeek,
            sessionDurationMinutes: nil,
            goal: goal,
            durationMode: durationMode,
            targetDate: targetDate
        )
    }

    static func coachingProfile(requiresMedicalClearance: Bool = false) -> AdapterCoachingProfile {
        AdapterCoachingProfile(requiresMedicalClearance: requiresMedicalClearance)
    }
}
