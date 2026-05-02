import XCTest
@testable import TemplateModel

final class RoundTripTests: XCTestCase {

    func testReferenceTemplateDecodes() throws {
        let url = try fixtureURL(named: "running-beginner-5k-8sem")
        let data = try Data(contentsOf: url)
        let template = try TemplateCoding.decode(data)

        XCTAssertEqual(template.id, "running-beginner-5k-8sem")
        XCTAssertEqual(template.sport, .running)
        XCTAssertEqual(template.level, .beginner)
        XCTAssertEqual(template.durationWeeks, 8)
        XCTAssertEqual(template.sessionsPerWeek, 3)
        XCTAssertEqual(template.weeks.count, 8)
        XCTAssertEqual(template.weeks.first?.weekNumber, 1)
        XCTAssertEqual(template.weeks.last?.weekNumber, 8)
    }

    func testRoundTripEncodeDecode() throws {
        let url = try fixtureURL(named: "running-beginner-5k-8sem")
        let data = try Data(contentsOf: url)
        let original = try TemplateCoding.decode(data)

        let reEncoded = try TemplateCoding.encode(original)
        let reDecoded = try TemplateCoding.decode(reEncoded)

        XCTAssertEqual(original, reDecoded)
    }

    func testValidatorAcceptsReference() throws {
        let url = try fixtureURL(named: "running-beginner-5k-8sem")
        let data = try Data(contentsOf: url)
        let template = try TemplateCoding.decode(data)
        XCTAssertNoThrow(try TemplateValidator.validate(template))
    }

    func testValidatorRejectsSchemaVersionMismatch() throws {
        let url = try fixtureURL(named: "running-beginner-5k-8sem")
        let data = try Data(contentsOf: url)
        let original = try TemplateCoding.decode(data)
        let bumped = ProgramTemplate(
            id: original.id,
            schemaVersion: 99,
            sport: original.sport,
            level: original.level,
            name: original.name,
            durationWeeks: original.durationWeeks,
            sessionsPerWeek: original.sessionsPerWeek,
            defaultObjective: original.defaultObjective,
            assumedProfile: original.assumedProfile,
            summary: original.summary,
            weeks: original.weeks,
            safetyNotes: original.safetyNotes,
            progressionLogic: original.progressionLogic,
            validatedAt: original.validatedAt,
            validatedBy: original.validatedBy
        )
        XCTAssertThrowsError(try TemplateValidator.validate(bumped)) { err in
            XCTAssertEqual(err as? TemplateValidationError,
                           .schemaVersionMismatch(expected: 2, got: 99))
        }
    }

    func testValidatorRejectsWeekCountMismatch() throws {
        let url = try fixtureURL(named: "running-beginner-5k-8sem")
        let data = try Data(contentsOf: url)
        let original = try TemplateCoding.decode(data)
        let truncated = ProgramTemplate(
            id: original.id,
            schemaVersion: original.schemaVersion,
            sport: original.sport,
            level: original.level,
            name: original.name,
            durationWeeks: original.durationWeeks,
            sessionsPerWeek: original.sessionsPerWeek,
            defaultObjective: original.defaultObjective,
            assumedProfile: original.assumedProfile,
            summary: original.summary,
            weeks: Array(original.weeks.prefix(3)),
            safetyNotes: original.safetyNotes,
            progressionLogic: original.progressionLogic
        )
        XCTAssertThrowsError(try TemplateValidator.validate(truncated)) { err in
            XCTAssertEqual(err as? TemplateValidationError,
                           .weekCountMismatch(declared: 8, actual: 3))
        }
    }

    private func fixtureURL(named name: String) throws -> URL {
        guard let url = Bundle.module.url(forResource: name, withExtension: "json") else {
            throw XCTSkip("Fixture \(name).json introuvable dans le bundle de test")
        }
        return url
    }
}
