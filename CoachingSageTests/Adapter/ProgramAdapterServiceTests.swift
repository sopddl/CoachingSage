// CoachingSageTests/Adapter/ProgramAdapterServiceTests.swift
// Story 3.3a — vérifie le wiring SwiftData → adapter façades + un appel end-to-end
// de `ProgramAdapterService.adapt(template:sportProfile:coachingProfile:)`.
import XCTest
import TemplateModel
@testable import CoachingSage

@MainActor
final class ProgramAdapterServiceTests: XCTestCase {

    // Pas de ModelContainer : `CoachingSportProfile` et `CoachingProfile` sont
    // instanciables via leur init() même sans context. Les bridges
    // `adapterFacade` ne lisent que les stored properties, ne déclenchent
    // pas de fetch / save SwiftData.

    func testBridgesMapSwiftDataModelsToFacades() {
        let sport = CoachingSportProfile(
            userId: UUID(),
            sportCode: "running",
            level: "beginner",
            goals: GoalsPayload(primary: "5K"),
            equipment: ["running-shoes"],
            constraints: ["knee-injury"],
            frequencyPerWeek: 3,
            frequencyLabel: "3",
            sessionDurationMinutes: 45,
            conversationHistory: [],
            medicalClearanceAcknowledged: false,
            questionnaireVersion: "running_v1"
        )
        let coaching = CoachingProfile(id: UUID())
        coaching.requiresMedicalClearance = true

        XCTAssertEqual(sport.adapterFacade.constraints, ["knee-injury"])
        // `running` ajoute mat implicit + dédup running-shoes déjà présent.
        XCTAssertEqual(sport.adapterFacade.equipment, ["running-shoes", "mat"])
        XCTAssertEqual(sport.adapterFacade.frequencyPerWeek, 3)
        XCTAssertEqual(sport.adapterFacade.sessionDurationMinutes, 45)
        XCTAssertTrue(coaching.adapterFacade.requiresMedicalClearance)
    }

    // MARK: - Bridge mapping (fix bug "tapis" 2026-05-04)

    /// Codes Q4 RunningQuestionnaire (knee/back/ankle/shin) → codes templates (kebab-case).
    /// Sans ce mapping, ConstraintSubstitutionRule ne match jamais et les exercices
    /// contraignants ne sont pas substitués.
    func testConstraintCodesAppMappedToTemplateCodes() {
        let sport = makeSport(constraints: ["knee", "back", "ankle", "shin"])
        XCTAssertEqual(sport.adapterFacade.constraints, [
            "knee-injury", "lower-back-pain", "ankle-injury", "shin-splints"
        ])
    }

    /// Le code `none` (signal "pas de contrainte") est préservé tel quel — la règle
    /// ConstraintSubstitutionRule le filtre côté apply.
    func testConstraintNoneCodePreserved() {
        let sport = makeSport(constraints: ["none"])
        XCTAssertEqual(sport.adapterFacade.constraints, ["none"])
    }

    /// Codes inconnus passent en pass-through (compat templates qui pourraient déjà
    /// utiliser des codes alignés via story autoprofil future).
    func testUnknownConstraintCodePassthrough() {
        let sport = makeSport(constraints: ["acl-history"])
        XCTAssertEqual(sport.adapterFacade.constraints, ["acl-history"])
    }

    /// Codes Q5 RunningQuestionnaire (gps_watch, heart_rate_monitor) → codes templates.
    /// Bug 2026-05-04 : underscore vs dash → user qui coche « j'ai une montre GPS » se
    /// faisait sub ses exos vers leur alternative « tapis ».
    func testEquipmentCodesAppMappedToTemplateCodes() {
        let sport = makeSport(equipment: ["gps_watch", "heart_rate_monitor"])
        // running implicit mat + running-shoes ajoutés.
        XCTAssertEqual(sport.adapterFacade.equipment, [
            "gps-watch", "heart-rate-monitor", "running-shoes", "mat"
        ])
    }

    /// Sport running ajoute mat + running-shoes implicit (assumé acquis), même si
    /// l'utilisateur a coché `none` côté équipement Q5.
    func testRunningSportAddsImplicitEquipment() {
        let sport = makeSport(sportCode: "running", equipment: ["none"])
        XCTAssertEqual(sport.adapterFacade.equipment, ["none", "running-shoes", "mat"])
    }

    /// Sport non-supporté V1 : pas d'implicit équipement (les autres sports n'ont pas
    /// encore leur catalogue d'implicits — les templates sont là mais le mapping
    /// arrivera avec leurs questionnaires Story 3.4+).
    func testNonRunningSportDoesNotAddImplicits() {
        let sport = makeSport(sportCode: "cycling", equipment: ["gps_watch"])
        XCTAssertEqual(sport.adapterFacade.equipment, ["gps-watch"])
    }

    // MARK: - Helpers

    private func makeSport(
        sportCode: String = "running",
        equipment: [String] = [],
        constraints: [String] = []
    ) -> CoachingSportProfile {
        CoachingSportProfile(
            userId: UUID(),
            sportCode: sportCode,
            level: "beginner",
            goals: GoalsPayload(primary: "5K"),
            equipment: equipment,
            constraints: constraints,
            frequencyPerWeek: 3,
            frequencyLabel: "3",
            sessionDurationMinutes: 45,
            conversationHistory: [],
            medicalClearanceAcknowledged: false,
            questionnaireVersion: "running_v1"
        )
    }

    func testServiceRunsAdapterEndToEnd() {
        let template = AdapterTestFixtures.makeRunningTemplate()
        let sport = CoachingSportProfile(
            userId: UUID(),
            sportCode: "running",
            level: "beginner",
            goals: GoalsPayload(primary: "5K"),
            equipment: ["running-shoes"],
            constraints: ["knee-injury"],
            frequencyPerWeek: 3,
            frequencyLabel: "3",
            conversationHistory: [],
            medicalClearanceAcknowledged: false,
            questionnaireVersion: "running_v1"
        )
        let coaching = CoachingProfile(id: UUID())

        let service = ProgramAdapterService()
        let adapted = service.adapt(
            template: template,
            sportProfile: sport,
            coachingProfile: coaching
        )

        // Plyo session : exercice substitué par l'alternative connue du fixture.
        let plyoSession = adapted.weeks[0].sessions.first(where: { $0.name == "Plyo intervals" })!
        XCTAssertEqual(plyoSession.exercises.first?.name, "Marche nordique 20 min")
        XCTAssertTrue(plyoSession.exercises.first?.wasSubstituted == true)
    }
}
