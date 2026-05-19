// CoachingSageTests/Adapter/SecondaryGoalOverlayTests.swift
// Story 3.13 Phase C (AC21) — overlay secondary goals selon stratégie par sport.
// Couvre les 4 stratégies + garde-fou EU MDR AC17 + cas dégradés (vide, frequency=1).
import Testing
import Foundation
import TemplateModel
@testable import CoachingSage

@Suite("SecondaryGoalOverlay")
struct SecondaryGoalOverlayTests {

    // MARK: - Helpers

    /// Fabrique des semaines adaptées factices : N weeks × sessions configurables.
    private func makeWeeks(
        weekCount: Int = 2,
        sessionsPerWeek: [(day: Int, name: String, durationMinutes: Int, type: SessionType)] = [
            (1, "Intervalles", 30, .interval),
            (3, "Tempo", 40, .endurance),
            (5, "Sortie longue", 60, .endurance)
        ]
    ) -> [AdaptedWeek] {
        (1...weekCount).map { wn in
            AdaptedWeek(
                weekNumber: wn,
                theme: "S\(wn)",
                goal: "G\(wn)",
                sessions: sessionsPerWeek.map {
                    AdaptedSession(
                        day: $0.day,
                        name: $0.name,
                        durationMinutes: $0.durationMinutes,
                        type: $0.type,
                        warmup: nil,
                        exercises: [
                            AdaptedExercise(name: "Exo \(wn)-\($0.day)", originalName: "Exo \(wn)-\($0.day)")
                        ],
                        cooldown: nil
                    )
                }
            )
        }
    }

    private func anyTemplate() -> ProgramTemplate {
        AdapterTestFixtures.makeRunningTemplate()
    }

    // MARK: - Noop cases

    @Test
    func emptySecondary_returnsUnchanged() {
        let weeks = makeWeeks()
        let result = SecondaryGoalOverlay.apply(
            weeks: weeks,
            template: anyTemplate(),
            primary: "10k",
            secondary: [],
            frequency: 3,
            sportCode: "running",
            strategy: .dedicatedSession
        )
        #expect(result.weeks == weeks)
        #expect(result.appliedOverlays.isEmpty)
    }

    @Test
    func notApplicableStrategy_returnsUnchanged() {
        let weeks = makeWeeks()
        let result = SecondaryGoalOverlay.apply(
            weeks: weeks,
            template: anyTemplate(),
            primary: "strength-5x5",
            secondary: ["ppl"],
            frequency: 3,
            sportCode: "strengthTraining",
            strategy: .notApplicable
        )
        #expect(result.weeks == weeks)
        #expect(result.appliedOverlays.isEmpty)
    }

    @Test
    func dedicatedSession_frequencyOne_noop() {
        // Pas la place pour une séance dédiée si freq < 2.
        let weeks = makeWeeks(sessionsPerWeek: [(1, "Easy", 30, .endurance)])
        let result = SecondaryGoalOverlay.apply(
            weeks: weeks,
            template: anyTemplate(),
            primary: "10k",
            secondary: ["5k"],
            frequency: 1,
            sportCode: "running",
            strategy: .dedicatedSession
        )
        #expect(result.weeks == weeks)
        #expect(result.appliedOverlays.isEmpty)
    }

    // MARK: - dedicatedSession

    @Test
    func dedicatedSession_running_replacesLowestPrioritySession() {
        // Sessions = [interval, endurance, endurance] → la plus droppable = endurance (les 2 sont endurance,
        // donc la première rencontrée. dropPriority préfère endurance APRÈS technique/strength/etc).
        // Avec ce template, autre/mobility/technique/strength/mixed absents → endurance est droppée
        // (firstIndex .endurance = day 3 "Tempo").
        let weeks = makeWeeks(weekCount: 1)
        let result = SecondaryGoalOverlay.apply(
            weeks: weeks,
            template: anyTemplate(),
            primary: "10k",
            secondary: ["5k"],
            frequency: 3,
            sportCode: "running",
            strategy: .dedicatedSession
        )
        #expect(result.appliedOverlays.count == 1)
        let touched = result.appliedOverlays[0]
        #expect(touched.secondaryGoal == "5k")
        #expect(touched.strategy == .dedicatedSession)
        #expect(touched.weekNumber == 1)
        #expect(touched.originalSessionName == "Tempo")

        // La session ciblée a été remplacée par une séance secondary
        let newSession = result.weeks[0].sessions[1]
        #expect(newSession.day == 3)
        #expect(newSession.name != "Tempo")
        #expect(!newSession.exercises.isEmpty)
        // type doit refléter le secondary "5k" → SessionType.interval
        #expect(newSession.type == .interval)
    }

    @Test
    func dedicatedSession_preservesUntouchedSessions() {
        let weeks = makeWeeks(weekCount: 1)
        let result = SecondaryGoalOverlay.apply(
            weeks: weeks,
            template: anyTemplate(),
            primary: "10k",
            secondary: ["5k"],
            frequency: 3,
            sportCode: "running",
            strategy: .dedicatedSession
        )
        // Interval (day 1) et Long run (day 5) inchangés
        #expect(result.weeks[0].sessions[0].name == "Intervalles")
        #expect(result.weeks[0].sessions[2].name == "Sortie longue")
    }

    @Test
    func dedicatedSession_rotatesAcrossWeeks() {
        // 2 secondary goals × 4 weeks → rotation alternée. Cap performance désactivé
        // via config (sinon running 100% perf cap à 1 — testé séparément).
        let weeks = makeWeeks(weekCount: 4)
        let result = SecondaryGoalOverlay.apply(
            weeks: weeks,
            template: anyTemplate(),
            primary: "marathon",
            secondary: ["10k", "5k"],
            frequency: 3,
            sportCode: "running",
            strategy: .dedicatedSession,
            config: OverlayConfig(performanceSecondaryCap: 5)
        )
        #expect(result.appliedOverlays.count == 4)
        #expect(result.appliedOverlays[0].secondaryGoal == "10k")
        #expect(result.appliedOverlays[1].secondaryGoal == "5k")
        #expect(result.appliedOverlays[2].secondaryGoal == "10k")
        #expect(result.appliedOverlays[3].secondaryGoal == "5k")
    }

    @Test
    func dedicatedSession_singleSessionWeek_skipped() {
        // Si la semaine n'a qu'1 session active, on ne touche pas (préserve la cadence).
        let weeks = makeWeeks(weekCount: 1, sessionsPerWeek: [
            (1, "Solo", 30, .endurance)
        ])
        let result = SecondaryGoalOverlay.apply(
            weeks: weeks,
            template: anyTemplate(),
            primary: "10k",
            secondary: ["5k"],
            frequency: 2,
            sportCode: "running",
            strategy: .dedicatedSession
        )
        #expect(result.weeks == weeks)
        #expect(result.appliedOverlays.isEmpty)
    }

    // MARK: - mixInSession

    @Test
    func mixInSession_swimming_prependsDrillToEachSession() {
        let weeks = makeWeeks(weekCount: 1, sessionsPerWeek: [
            (1, "Main set", 60, .endurance),
            (3, "Easy", 40, .endurance)
        ])
        let result = SecondaryGoalOverlay.apply(
            weeks: weeks,
            template: anyTemplate(),
            primary: "endurance",
            secondary: ["technique"],
            frequency: 2,
            sportCode: "swimming",
            strategy: .mixInSession
        )
        #expect(result.appliedOverlays.count == 2)

        // Session 1 : drill prepended
        let s1 = result.weeks[0].sessions[0]
        #expect(s1.exercises.count == 2)  // drill + originale
        #expect(s1.exercises[0].name.contains("Éducatifs"))
        // Durée drill = clamp(15% × 60) = 9 min → mais min 5, max 15 → 9 OK
        #expect(s1.exercises[0].duration == "9 min")

        // Session 2
        let s2 = result.weeks[0].sessions[1]
        #expect(s2.exercises.count == 2)
        #expect(s2.exercises[0].duration == "6 min")  // clamp(15% × 40) = 6
    }

    @Test
    func mixInSession_clampsToMin5Minutes() {
        // Session courte 20 min → 15% × 20 = 3 → clamped à 5
        let weeks = makeWeeks(weekCount: 1, sessionsPerWeek: [
            (1, "Short", 20, .endurance)
        ])
        let result = SecondaryGoalOverlay.apply(
            weeks: weeks,
            template: anyTemplate(),
            primary: "endurance",
            secondary: ["technique"],
            frequency: 2,
            sportCode: "swimming",
            strategy: .mixInSession
        )
        #expect(result.weeks[0].sessions[0].exercises[0].duration == "5 min")
    }

    @Test
    func mixInSession_clampsToMax15Minutes() {
        // Session 120 min → 15% × 120 = 18 → clamped à 15
        let weeks = makeWeeks(weekCount: 1, sessionsPerWeek: [
            (1, "Long", 120, .endurance)
        ])
        let result = SecondaryGoalOverlay.apply(
            weeks: weeks,
            template: anyTemplate(),
            primary: "endurance",
            secondary: ["technique"],
            frequency: 2,
            sportCode: "swimming",
            strategy: .mixInSession
        )
        #expect(result.weeks[0].sessions[0].exercises[0].duration == "15 min")
    }

    @Test
    func mixInSession_skipsRestSessions() {
        let weeks = makeWeeks(weekCount: 1, sessionsPerWeek: [
            (1, "Repos", 0, .rest),
            (3, "Active", 60, .endurance)
        ])
        let result = SecondaryGoalOverlay.apply(
            weeks: weeks,
            template: anyTemplate(),
            primary: "endurance",
            secondary: ["technique"],
            frequency: 2,
            sportCode: "swimming",
            strategy: .mixInSession
        )
        // Rest inchangée, active augmentée
        #expect(result.weeks[0].sessions[0].exercises.count == 1)
        #expect(result.weeks[0].sessions[1].exercises.count == 2)
        #expect(result.appliedOverlays.count == 1)
    }

    // MARK: - hybrid

    @Test
    func hybrid_frequencyThreeOrMore_usesDedicatedSession() {
        let weeks = makeWeeks(weekCount: 1)
        let result = SecondaryGoalOverlay.apply(
            weeks: weeks,
            template: anyTemplate(),
            primary: "tournoi-prep",
            secondary: ["regularite"],
            frequency: 3,
            sportCode: "tennis",
            strategy: .hybrid
        )
        #expect(result.appliedOverlays.count == 1)
        #expect(result.appliedOverlays[0].strategy == .dedicatedSession)
    }

    @Test
    func hybrid_frequencyTwo_fallsBackToMixIn() {
        let weeks = makeWeeks(weekCount: 1, sessionsPerWeek: [
            (1, "Match", 60, .endurance),
            (3, "Fitness", 45, .endurance)
        ])
        let result = SecondaryGoalOverlay.apply(
            weeks: weeks,
            template: anyTemplate(),
            primary: "tournoi-prep",
            secondary: ["regularite"],
            frequency: 2,
            sportCode: "tennis",
            strategy: .hybrid
        )
        // mixIn → 1 drill prepended sur chaque session → 2 overlays
        #expect(result.appliedOverlays.count == 2)
        #expect(result.appliedOverlays.allSatisfy { $0.strategy == .mixInSession })
    }

    // MARK: - AC17 garde-fou EU MDR (performance cap)

    @Test
    func performanceCap_allPerformanceGoals_capsToOne() {
        // running primary=10k + secondary=[5k, half_marathon] → tous "performance" → cap à 1
        let weeks = makeWeeks(weekCount: 1)
        let result = SecondaryGoalOverlay.apply(
            weeks: weeks,
            template: anyTemplate(),
            primary: "10k",
            secondary: ["5k", "half_marathon"],
            frequency: 3,
            sportCode: "running",
            strategy: .dedicatedSession
        )
        // Cap appliqué → 1 seul secondary effectivement utilisé
        #expect(result.appliedOverlays.count == 1)
        #expect(result.appliedOverlays[0].secondaryGoal == "5k")
    }

    @Test
    func performanceCap_explicitlyTunable() {
        // Config cap=2 → secondary garde 2 entrées dans rotation
        let weeks = makeWeeks(weekCount: 2)
        let result = SecondaryGoalOverlay.apply(
            weeks: weeks,
            template: anyTemplate(),
            primary: "10k",
            secondary: ["5k", "half_marathon"],
            frequency: 3,
            sportCode: "running",
            strategy: .dedicatedSession,
            config: OverlayConfig(performanceSecondaryCap: 2)
        )
        #expect(result.appliedOverlays.count == 2)
        #expect(Set(result.appliedOverlays.map { $0.secondaryGoal }) == Set(["5k", "half_marathon"]))
    }

    // MARK: - Catalogue fallback

    @Test
    func unknownSportGoal_fallsBackToGenericDrill() {
        // 1 session active pour clarifier l'assertion sur le nombre d'overlays
        let weeks = makeWeeks(weekCount: 1, sessionsPerWeek: [
            (1, "Solo", 60, .endurance)
        ])
        let result = SecondaryGoalOverlay.apply(
            weeks: weeks,
            template: anyTemplate(),
            primary: "endurance",
            secondary: ["esoteric-goal"],
            frequency: 2,
            sportCode: "swimming",
            strategy: .mixInSession
        )
        #expect(result.appliedOverlays.count == 1)
        let drill = result.weeks[0].sessions[0].exercises[0]
        #expect(drill.name.contains("esoteric-goal"))
    }

    // MARK: - overlayStrategy(for:) wiring

    @Test
    func overlayStrategy_perSport() {
        #expect(GoalCompatibilityMatrix.overlayStrategy(for: "running") == .dedicatedSession)
        #expect(GoalCompatibilityMatrix.overlayStrategy(for: "cycling") == .dedicatedSession)
        #expect(GoalCompatibilityMatrix.overlayStrategy(for: "swimming") == .mixInSession)
        #expect(GoalCompatibilityMatrix.overlayStrategy(for: "yoga") == .mixInSession)
        #expect(GoalCompatibilityMatrix.overlayStrategy(for: "tennis") == .hybrid)
        #expect(GoalCompatibilityMatrix.overlayStrategy(for: "strengthTraining") == .notApplicable)
        #expect(GoalCompatibilityMatrix.overlayStrategy(for: "triathlon") == .notApplicable)
        #expect(GoalCompatibilityMatrix.overlayStrategy(for: "kitesurfing") == .notApplicable)
    }
}
