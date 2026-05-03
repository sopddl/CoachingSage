// CoachingSageTests/Adapter/AdapterRuleTests.swift
// Story 3.3a — tests unitaires des 5 règles deterministic en isolation.
import XCTest
import TemplateModel
@testable import CoachingSage

final class AdapterRuleTests: XCTestCase {

    // MARK: - Helpers

    private func liftToAdapted(_ template: ProgramTemplate) -> [AdaptedWeek] {
        template.weeks.map { week in
            AdaptedWeek(
                weekNumber: week.weekNumber,
                theme: week.theme,
                goal: week.goal,
                sessions: week.sessions.map { session in
                    AdaptedSession(
                        day: session.day,
                        name: session.name,
                        durationMinutes: session.durationMinutes,
                        type: session.type,
                        warmup: session.warmup,
                        exercises: session.exercises.map { AdaptedExercise.passthrough($0) },
                        cooldown: session.cooldown
                    )
                }
            )
        }
    }

    // MARK: - ConstraintSubstitutionRule

    func testConstraintRuleSubstitutesWhenAlternativeExists() {
        let template = AdapterTestFixtures.makeRunningTemplate()
        let weeks = liftToAdapted(template)
        let rule = ConstraintSubstitutionRule()

        let result = rule.apply(
            weeks: weeks,
            template: template,
            sport: template.sport,
            level: template.level,
            sportProfile: AdapterTestFixtures.sportProfile(constraints: ["knee-injury"]),
            coachingProfile: AdapterTestFixtures.coachingProfile()
        )

        // Plyo (knee-injury incompatible, alternative = Marche nordique 20 min) substitué.
        let plyoSession = result.weeks[0].sessions.first(where: { $0.name == "Plyo intervals" })!
        XCTAssertEqual(plyoSession.exercises.first?.name, "Marche nordique 20 min")
        XCTAssertTrue(plyoSession.exercises.first?.wasSubstituted == true)
        XCTAssertEqual(plyoSession.exercises.first?.substitutionReason, "constraint:knee-injury")

        // Log applique correspondant.
        XCTAssertEqual(result.appliedRules.count, 2)  // 2 semaines × 1 plyo chacune
        XCTAssertEqual(result.appliedRules.first?.outcome, .substituted)
        XCTAssertFalse(result.triggeredAIAssist)
    }

    func testConstraintRuleTriggersAIAssistWithoutAlternative() {
        // Template sur-mesure : exercice avec contrainte mais alternatives vide.
        let template = ProgramTemplate(
            id: "test", schemaVersion: 2,
            sport: .running, level: .beginner,
            name: "test", durationWeeks: 1, sessionsPerWeek: 1,
            defaultObjective: "test", assumedProfile: "test", summary: "test",
            weeks: [TemplateWeek(weekNumber: 1, theme: "t", goal: "g", sessions: [
                TemplateSession(day: 1, name: "s", durationMinutes: 30,
                                type: .interval, warmup: nil,
                                exercises: [
                                    TemplateExercise(
                                        name: "Niche-exo",
                                        incompatibleConstraints: ["knee-injury"],
                                        alternatives: []  // explicite vide
                                    )
                                ],
                                cooldown: nil)
            ])],
            safetyNotes: "t", progressionLogic: "t"
        )
        let weeks = liftToAdapted(template)

        let result = ConstraintSubstitutionRule().apply(
            weeks: weeks, template: template,
            sport: .running, level: .beginner,
            sportProfile: AdapterTestFixtures.sportProfile(constraints: ["knee-injury"]),
            coachingProfile: AdapterTestFixtures.coachingProfile()
        )

        XCTAssertTrue(result.triggeredAIAssist)
        XCTAssertEqual(result.appliedRules.first?.outcome, .requiresAI)
        // L'exercice reste en place (UI peut afficher banner Léon).
        XCTAssertEqual(result.weeks[0].sessions.first?.exercises.first?.name, "Niche-exo")
    }

    func testConstraintRuleTreatsNoneAsEmpty() {
        let template = AdapterTestFixtures.makeRunningTemplate()
        let weeks = liftToAdapted(template)

        let result = ConstraintSubstitutionRule().apply(
            weeks: weeks, template: template,
            sport: .running, level: .beginner,
            sportProfile: AdapterTestFixtures.sportProfile(constraints: ["none"]),
            coachingProfile: AdapterTestFixtures.coachingProfile()
        )

        XCTAssertEqual(result.appliedRules.count, 0)
    }

    // MARK: - EquipmentSubstitutionRule

    func testEquipmentRuleSubstitutesWhenEquipmentMissing() {
        let template = AdapterTestFixtures.makeRunningTemplate()
        let weeks = liftToAdapted(template)

        let result = EquipmentSubstitutionRule().apply(
            weeks: weeks, template: template,
            sport: .running, level: .beginner,
            sportProfile: AdapterTestFixtures.sportProfile(equipment: []),  // pas de track
            coachingProfile: AdapterTestFixtures.coachingProfile()
        )

        // Plyo a required_equipment = ["track"] → manquant → substitution.
        let plyoSession = result.weeks[0].sessions.first(where: { $0.name == "Plyo intervals" })!
        XCTAssertEqual(plyoSession.exercises.first?.name, "Marche nordique 20 min")
        XCTAssertEqual(plyoSession.exercises.first?.substitutionReason, "equipment:track")
    }

    func testEquipmentRuleSkipsAlreadySubstituted() {
        let template = AdapterTestFixtures.makeRunningTemplate()
        // Pré-substitué par règle constraint
        let alreadySubbed = AdaptedExercise(
            name: "Marche nordique 20 min",
            originalName: "Bondissements 6×30s",
            wasSubstituted: true,
            substitutionReason: "constraint:knee-injury"
        )
        let weeks: [AdaptedWeek] = [
            AdaptedWeek(weekNumber: 1, theme: "t", goal: "g", sessions: [
                AdaptedSession(day: 1, name: "Plyo intervals", durationMinutes: 30,
                               type: .interval, warmup: nil,
                               exercises: [alreadySubbed], cooldown: nil)
            ])
        ]

        let result = EquipmentSubstitutionRule().apply(
            weeks: weeks, template: template,
            sport: .running, level: .beginner,
            sportProfile: AdapterTestFixtures.sportProfile(equipment: []),
            coachingProfile: AdapterTestFixtures.coachingProfile()
        )

        XCTAssertEqual(result.appliedRules.count, 0)
        XCTAssertEqual(result.weeks[0].sessions[0].exercises[0].name, "Marche nordique 20 min")
    }

    // MARK: - VolumeModulationRule

    func testVolumeRuleDropsLowestPrioritySession() {
        let template = AdapterTestFixtures.makeFourSessionTemplate()
        let weeks = liftToAdapted(template)

        let result = VolumeModulationRule().apply(
            weeks: weeks, template: template,
            sport: .running, level: .recreational,
            sportProfile: AdapterTestFixtures.sportProfile(frequencyPerWeek: 3),
            coachingProfile: AdapterTestFixtures.coachingProfile()
        )

        // Mobility doit sauter (priorité de drop la plus haute).
        let kept = result.weeks[0].sessions.map(\.name)
        XCTAssertFalse(kept.contains("Mobility"))
        XCTAssertTrue(kept.contains("Easy"))
        XCTAssertTrue(kept.contains("Intervals"))
        XCTAssertTrue(kept.contains("Long run"))
        XCTAssertEqual(result.appliedRules.first?.outcome, .removed)
    }

    func testVolumeRuleNoOpWhenFrequencyMatchesOrExceeds() {
        let template = AdapterTestFixtures.makeRunningTemplate()  // 3 sessions/sem
        let weeks = liftToAdapted(template)

        let result = VolumeModulationRule().apply(
            weeks: weeks, template: template,
            sport: .running, level: .beginner,
            sportProfile: AdapterTestFixtures.sportProfile(frequencyPerWeek: 4),  // > template
            coachingProfile: AdapterTestFixtures.coachingProfile()
        )

        XCTAssertEqual(result.appliedRules.count, 0)
        XCTAssertEqual(result.weeks[0].sessions.count, 3)
    }

    // MARK: - LevelPacingRule (stub jusqu'à Story 3.1.5)

    func testLevelPacingRuleIsNoOpForNow() {
        let template = AdapterTestFixtures.makeRunningTemplate()
        let weeks = liftToAdapted(template)

        let result = LevelPacingRule().apply(
            weeks: weeks, template: template,
            sport: .running, level: .beginner,
            sportProfile: AdapterTestFixtures.sportProfile(),
            coachingProfile: AdapterTestFixtures.coachingProfile()
        )

        XCTAssertEqual(result.appliedRules.count, 0)
        XCTAssertEqual(result.weeks, weeks)
    }

    // MARK: - MedicalClearanceRule

    func testMedicalClearanceDowngradesIntervalsAndZones() {
        let template = AdapterTestFixtures.makeRunningTemplate()
        let weeks = liftToAdapted(template)

        let result = MedicalClearanceRule().apply(
            weeks: weeks, template: template,
            sport: .running, level: .beginner,
            sportProfile: AdapterTestFixtures.sportProfile(),
            coachingProfile: AdapterTestFixtures.coachingProfile(requiresMedicalClearance: true)
        )

        // SessionType interval → endurance pour la session "Plyo intervals".
        let plyoSession = result.weeks[0].sessions.first(where: { $0.name == "Plyo intervals" })!
        XCTAssertEqual(plyoSession.type, .endurance)

        // target_zone Daniels-R → Daniels-E pour l'exercice plyo.
        XCTAssertEqual(plyoSession.exercises.first?.targetZone, "Daniels-E")

        // target_zone Daniels-T → Daniels-E pour la session tempo.
        let tempoSession = result.weeks[0].sessions.first(where: { $0.name == "Tempo continu" })!
        XCTAssertEqual(tempoSession.exercises.first?.targetZone, "Daniels-E")

        // Sortie longue (Daniels-E) inchangée.
        let longSession = result.weeks[0].sessions.first(where: { $0.name == "Sortie longue" })!
        XCTAssertEqual(longSession.exercises.first?.targetZone, "Daniels-E")

        // Au moins 1 log d'outcome=downgraded.
        XCTAssertTrue(result.appliedRules.contains { $0.outcome == .downgraded })
    }

    func testMedicalClearanceNoOpWhenFlagFalse() {
        let template = AdapterTestFixtures.makeRunningTemplate()
        let weeks = liftToAdapted(template)

        let result = MedicalClearanceRule().apply(
            weeks: weeks, template: template,
            sport: .running, level: .beginner,
            sportProfile: AdapterTestFixtures.sportProfile(),
            coachingProfile: AdapterTestFixtures.coachingProfile(requiresMedicalClearance: false)
        )

        XCTAssertEqual(result.appliedRules.count, 0)
        XCTAssertEqual(result.weeks, weeks)
    }
}
