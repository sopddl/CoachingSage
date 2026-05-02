// CoachingSageTests/Adapter/ProgramAdapterServiceTests.swift
// Story 3.3a — vérifie le wiring SwiftData → adapter façades + un appel end-to-end
// de `ProgramAdapterService.adapt(template:sportProfile:coachingProfile:)`.
import XCTest
import SwiftData
import TemplateModel
@testable import CoachingSage

@MainActor
final class ProgramAdapterServiceTests: XCTestCase {

    private var context: ModelContext!

    override func setUpWithError() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Schema(versionedSchema: SchemaV3.self), configurations: config)
        context = container.mainContext
    }

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
        XCTAssertEqual(sport.adapterFacade.equipment, ["running-shoes"])
        XCTAssertEqual(sport.adapterFacade.frequencyPerWeek, 3)
        XCTAssertEqual(sport.adapterFacade.sessionDurationMinutes, 45)
        XCTAssertTrue(coaching.adapterFacade.requiresMedicalClearance)
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
