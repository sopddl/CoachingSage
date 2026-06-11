// CoachingSageTests/Adapter/ProgramAdapterTests.swift
// Story 3.3a — tests d'intégration de la cascade complète sur des cas concrets.
// Vérifie l'ordre des règles et le wiring `requiresAIAssist`.
import XCTest
import TemplateModel

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
        let plyoSession = adapted.weeks[0].sessions.first(where: { $0.name.fr == "Plyo intervals" })!
        XCTAssertEqual(plyoSession.exercises.first?.name, "Marche nordique 20 min")
        XCTAssertTrue(plyoSession.exercises.first?.wasSubstituted == true)
        XCTAssertEqual(plyoSession.exercises.first?.substitutionReason, "constraint:knee-injury")

        // Sortie longue (pas de constraint match) inchangée.
        let longSession = adapted.weeks[0].sessions.first(where: { $0.name.fr == "Sortie longue" })!
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
        XCTAssertFalse(adapted.weeks[0].sessions.contains { $0.name.fr == "Mobility" })

        // Medical clearance : Intervals → endurance, Daniels-I → Daniels-E.
        let intervalsSession = adapted.weeks[0].sessions.first(where: { $0.name.fr == "Intervals" })!
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
        // Template ≥ 4 sem (= minWeeks resolver) pour que le resize deadlineFixed
        // soit un no-op. Sinon le clamp minWeeks gonflerait artificiellement le count.
        let template = AdapterTestFixtures.makeRunningTemplate(sessionsPerWeek: 3, durationWeeks: 6)
        let adapter = ProgramAdapter()
        let now = Date(timeIntervalSince1970: 1_700_000_000)

        // Story sœur — pour que la durée matche template (resize no-op), passe deadlineFixed
        // avec targetDate = now + template.durationWeeks * 7j.
        let target = Calendar.current.date(byAdding: .weekOfYear, value: template.durationWeeks, to: now)!
        let adapted = adapter.adapt(
            template: template,
            sportProfile: AdapterTestFixtures.sportProfile(
                equipment: ["running-shoes", "track"],  // tout est là
                frequencyPerWeek: 3,                    // matche template
                durationMode: .deadlineFixed,
                targetDate: target
            ),
            coachingProfile: AdapterTestFixtures.coachingProfile(requiresMedicalClearance: false),
            now: now
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

    // MARK: - L1 indoor/outdoor vélo (2026-06-11) — adaptSession adapte la variante

    /// La variante ALTERNATE hérite des substitutions par-exercice (fin de la limite
    /// passthrough) : un exercice de renfo incompatible est remplacé par son alternative.
    func testAdaptSessionSubstitutesVariantExerciseOnConstraint() {
        let variant = SessionVariant(
            environment: .indoor,
            name: "Home-trainer 45 min + renfo",
            durationMinutes: 45,
            warmup: "10 min Z1",
            exercises: [
                TemplateExercise(name: "Pédalage continu Z2", targetZone: "Z2"),
                TemplateExercise(
                    name: "Gainage planche 3×40s",
                    incompatibleConstraints: ["lower-back-pain"],
                    alternatives: ["Gainage genoux 3×30s"]
                )
            ],
            cooldown: "5 min retour au calme"
        )

        let adapted = ProgramAdapter().adaptSession(
            variant: variant,
            day: 5,
            type: .strength,
            weekNumber: 1,
            sport: .cycling,
            level: .beginner,
            templateId: "cycling-beginner-reprise-6sem",
            sportProfile: AdapterTestFixtures.sportProfile(constraints: ["lower-back-pain"], equipment: []),
            coachingProfile: AdapterTestFixtures.coachingProfile()
        )

        // Métadonnées de la variante préservées.
        XCTAssertEqual(adapted.name.canonical, "Home-trainer 45 min + renfo")
        XCTAssertEqual(adapted.durationMinutes, 45)
        // Exercice incompatible → substitué par son alternative.
        let plank = adapted.exercises.first(where: { $0.originalName == "Gainage planche 3×40s" })
        XCTAssertNotNil(plank)
        XCTAssertTrue(plank?.wasSubstituted == true)
        XCTAssertEqual(plank?.name.canonical, "Gainage genoux 3×30s")
        // Exercice sans contrainte → inchangé.
        XCTAssertEqual(adapted.exercises.first?.name.canonical, "Pédalage continu Z2")
        XCTAssertEqual(adapted.exercises.first?.wasSubstituted, false)
    }

    /// Sans contrainte/équipement manquant, adaptSession est un no-op fidèle (passthrough).
    func testAdaptSessionNoOpWithoutConstraints() {
        let variant = SessionVariant(
            environment: .indoor,
            name: "Home-trainer 40 min",
            durationMinutes: 40,
            warmup: nil,
            exercises: [TemplateExercise(name: "Pédalage continu Z2", targetZone: "Z2")],
            cooldown: nil
        )
        let adapted = ProgramAdapter().adaptSession(
            variant: variant, day: 2, type: .endurance, weekNumber: 1,
            sport: .cycling, level: .beginner, templateId: "cycling-beginner-reprise-6sem",
            sportProfile: AdapterTestFixtures.sportProfile(equipment: []),
            coachingProfile: AdapterTestFixtures.coachingProfile()
        )
        XCTAssertEqual(adapted.exercises.count, 1)
        XCTAssertEqual(adapted.exercises.first?.wasSubstituted, false)
    }
}
