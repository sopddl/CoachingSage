// CoachingSageTests/Adapter/ProgramAdapterTests.swift
// Story 3.3a — tests d'intégration de la cascade complète sur des cas concrets.
// Vérifie l'ordre des règles et le wiring `requiresAIAssist`.
import XCTest
import TemplateModel
@testable import CoachingSage

final class ProgramAdapterTests: XCTestCase {

    // MARK: - AC story : running + knee-injury → plyo remplacée par low-impact

    func testRunningKneeInjuryReplacesPlyoWithLowImpact() {
        let template = AdapterTestFixtures.makeRunningTemplate()
        let adapter = ProgramAdapter()

        let adapted = adapter.adapt(
            template: template,
            sportProfile: AdapterTestFixtures.sportProfile(constraints: ["knee-injury"]),
            coachingProfile: AdapterTestFixtures.coachingProfile()
        )

        XCTAssertEqual(adapted.templateId, "running-fixture")
        XCTAssertEqual(adapted.sport, .running)
        XCTAssertFalse(adapted.requiresAIAssist)

        // Plyo session : exercice substitué par alternative (Marche nordique).
        let plyoSession = adapted.weeks[0].sessions.first(where: { $0.name == "Plyo intervals" })!
        XCTAssertEqual(plyoSession.exercises.first?.name, "Marche nordique 20 min")
        XCTAssertTrue(plyoSession.exercises.first?.wasSubstituted == true)
        XCTAssertEqual(plyoSession.exercises.first?.substitutionReason, "constraint:knee-injury")

        // Sortie longue (pas de constraint match) inchangée.
        let longSession = adapted.weeks[0].sessions.first(where: { $0.name == "Sortie longue" })!
        XCTAssertEqual(longSession.exercises.first?.name, "Long run 60 min")
        XCTAssertFalse(longSession.exercises.first?.wasSubstituted == true)
    }

    // MARK: - Cascade complète : volume + medical clearance combinés

    func testCascadeAppliesVolumeThenMedicalClearance() {
        let template = AdapterTestFixtures.makeFourSessionTemplate()
        let adapter = ProgramAdapter()

        let adapted = adapter.adapt(
            template: template,
            sportProfile: AdapterTestFixtures.sportProfile(frequencyPerWeek: 3),
            coachingProfile: AdapterTestFixtures.coachingProfile(requiresMedicalClearance: true)
        )

        // Volume : Mobility supprimé (3 sessions au lieu de 4).
        XCTAssertEqual(adapted.weeks[0].sessions.count, 3)
        XCTAssertFalse(adapted.weeks[0].sessions.contains { $0.name == "Mobility" })

        // Medical clearance : Intervals → endurance, Daniels-I → Daniels-E.
        let intervalsSession = adapted.weeks[0].sessions.first(where: { $0.name == "Intervals" })!
        XCTAssertEqual(intervalsSession.type, .endurance)
        XCTAssertEqual(intervalsSession.exercises.first?.targetZone, "Daniels-E")

        // Logs : au moins 1 volumeModulation + 1 medicalClearance.
        let ruleTypes = Set(adapted.appliedRules.map(\.ruleType))
        XCTAssertTrue(ruleTypes.contains(.volumeModulation))
        XCTAssertTrue(ruleTypes.contains(.medicalClearance))
    }

    // MARK: - requiresAIAssist propagé depuis une règle

    func testRequiresAIAssistPropagatedFromRule() {
        // Template avec exercice qui n'a pas d'alternative.
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
                                        incompatibleConstraints: ["pregnancy"],
                                        alternatives: []
                                    )
                                ],
                                cooldown: nil)
            ])],
            safetyNotes: "t", progressionLogic: "t"
        )
        let adapter = ProgramAdapter()

        let adapted = adapter.adapt(
            template: template,
            sportProfile: AdapterTestFixtures.sportProfile(constraints: ["pregnancy"]),
            coachingProfile: AdapterTestFixtures.coachingProfile()
        )

        XCTAssertTrue(adapted.requiresAIAssist)
        XCTAssertNotNil(adapted.aiAssistReason)
        XCTAssertTrue(adapted.aiAssistReason?.contains("pregnancy") == true)
    }

    // MARK: - Profil sans contrainte ni équipement manquant ni clearance

    func testHappyPathPassthrough() {
        let template = AdapterTestFixtures.makeRunningTemplate()
        let adapter = ProgramAdapter()

        let adapted = adapter.adapt(
            template: template,
            sportProfile: AdapterTestFixtures.sportProfile(
                equipment: ["running-shoes", "track"],  // tout est là
                frequencyPerWeek: 3                     // matche template
            ),
            coachingProfile: AdapterTestFixtures.coachingProfile(requiresMedicalClearance: false)
        )

        XCTAssertFalse(adapted.requiresAIAssist)
        XCTAssertEqual(adapted.appliedRules.count, 0)
        // Toutes les sessions originales conservées sans substitution.
        XCTAssertEqual(adapted.weeks.flatMap(\.sessions).count, template.weeks.flatMap(\.sessions).count)
        for week in adapted.weeks {
            for session in week.sessions {
                for ex in session.exercises {
                    XCTAssertFalse(ex.wasSubstituted, "« \(ex.name) » ne devrait pas être substitué")
                }
            }
        }
    }
}
