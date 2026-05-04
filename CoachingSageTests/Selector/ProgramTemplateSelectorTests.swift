// CoachingSageTests/Selector/ProgramTemplateSelectorTests.swift
// Story 3.2 — vérifie que le selector retourne un template valide pour TOUTE
// combinaison (SportCode × Level), avec la library bundlée v2 (40 templates).
// Couvre aussi : mapping strengthTraining ↔ strength_training, fallback level,
// fallback sport non-couvert, deterministic tie-break par id.
import XCTest
import TemplateLoader
import TemplateModel
@testable import CoachingSage

@MainActor
final class ProgramTemplateSelectorTests: XCTestCase {

    // MARK: - Helpers

    private func bundledLibrary() async throws -> ProgramTemplateLibrary {
        let templates = try await TemplateLoader.loadAll()
        return ProgramTemplateLibrary(templates: templates)
    }

    private func makeProfile(
        sportCode: String,
        level: String,
        goal: String = "general"
    ) -> CoachingSportProfile {
        CoachingSportProfile(
            userId: UUID(),
            sportCode: sportCode,
            level: level,
            goals: GoalsPayload(primary: goal),
            equipment: [],
            constraints: [],
            frequencyPerWeek: 3,
            frequencyLabel: "3",
            conversationHistory: [],
            medicalClearanceAcknowledged: false,
            questionnaireVersion: "v1"
        )
    }

    // MARK: - Couverture exhaustive (10 sports × 4 levels)

    func testSelectsExactMatchForEverySportAndLevelInBundledLibrary() async throws {
        let library = try await bundledLibrary()
        let selector = ProgramTemplateSelector(library: library)

        let sportCodes: [String] = SportCode.allCases.map { $0.rawValue }
        let levels = ["beginner", "recreational", "regular", "competitive"]

        for code in sportCodes {
            for level in levels {
                let profile = makeProfile(sportCode: code, level: level)
                let template = selector.select(profile: profile)

                let expectedSport = Sport(sportCode: code)
                let expectedLevel = Level(rawValue: level)
                XCTAssertEqual(
                    template.sport, expectedSport,
                    "Mauvais sport pour (\(code), \(level)) → \(template.id)"
                )
                XCTAssertEqual(
                    template.level, expectedLevel,
                    "Mauvais level pour (\(code), \(level)) → \(template.id)"
                )
            }
        }
    }

    // MARK: - Mapping strengthTraining ↔ strength_training

    func testStrengthTrainingSportCodeMapsToStrengthTrainingTemplate() async throws {
        let library = try await bundledLibrary()
        let selector = ProgramTemplateSelector(library: library)

        let profile = makeProfile(sportCode: "strengthTraining", level: "regular")
        let template = selector.select(profile: profile)

        XCTAssertEqual(template.sport, .strengthTraining)
        XCTAssertEqual(template.sport.rawValue, "strength_training")
        XCTAssertEqual(template.level, .regular)
    }

    // MARK: - Fallback level (sport couvert, level inhabituel)

    func testFallbackToNearestLevelWhenExactLevelMissing() {
        // Library minimale : seulement running-beginner et running-competitive.
        let beginner = makeMinimalTemplate(id: "running-beginner-x", sport: .running, level: .beginner)
        let competitive = makeMinimalTemplate(id: "running-competitive-x", sport: .running, level: .competitive)
        let library = ProgramTemplateLibrary(templates: [beginner, competitive])
        let selector = ProgramTemplateSelector(library: library)

        // Profile recreational → distance = 1 vers beginner, 2 vers competitive → beginner
        let profile = makeProfile(sportCode: "running", level: "recreational")
        let chosen = selector.select(profile: profile)
        XCTAssertEqual(chosen.id, "running-beginner-x")

        // Profile regular → distance = 1 vers competitive, 2 vers beginner → competitive
        let profile2 = makeProfile(sportCode: "running", level: "regular")
        let chosen2 = selector.select(profile: profile2)
        XCTAssertEqual(chosen2.id, "running-competitive-x")
    }

    // MARK: - Fallback sport (sport non couvert)

    func testFallbackToOtherSportWhenSportMissing() {
        // Library : seulement running-beginner. Profile demande cycling-beginner.
        let beginner = makeMinimalTemplate(id: "running-beginner-x", sport: .running, level: .beginner)
        let library = ProgramTemplateLibrary(templates: [beginner])
        let selector = ProgramTemplateSelector(library: library)

        let profile = makeProfile(sportCode: "cycling", level: "beginner")
        let chosen = selector.select(profile: profile)
        // Aucun template cycling, mais running-beginner partage le level → choisi.
        XCTAssertEqual(chosen.id, "running-beginner-x")
    }

    // MARK: - Determinism tie-break

    func testTieBreakDeterministicByIdAscendingWhenMultipleSameSportLevel() {
        let a = makeMinimalTemplate(id: "running-beginner-aaa", sport: .running, level: .beginner)
        let b = makeMinimalTemplate(id: "running-beginner-bbb", sport: .running, level: .beginner)
        let library = ProgramTemplateLibrary(templates: [b, a]) // ordre inverse
        let selector = ProgramTemplateSelector(library: library)

        let profile = makeProfile(sportCode: "running", level: "beginner", goal: "")
        let chosen = selector.select(profile: profile)
        XCTAssertEqual(chosen.id, "running-beginner-aaa") // tri ascendant par id
    }

    func testTieBreakPrefersGoalSubstringMatchInId() {
        let basics = makeMinimalTemplate(id: "strength-training-beginner-home-basics-8sem", sport: .strengthTraining, level: .beginner)
        let split = makeMinimalTemplate(id: "strength-training-beginner-split-12sem", sport: .strengthTraining, level: .beginner)
        let library = ProgramTemplateLibrary(templates: [basics, split])
        let selector = ProgramTemplateSelector(library: library)

        let profile = makeProfile(sportCode: "strengthTraining", level: "beginner", goal: "split")
        let chosen = selector.select(profile: profile)
        XCTAssertEqual(chosen.id, "strength-training-beginner-split-12sem")
    }

    // MARK: - Library minimale fixture

    private func makeMinimalTemplate(id: String, sport: Sport, level: Level) -> ProgramTemplate {
        ProgramTemplate(
            id: id,
            schemaVersion: 1,
            sport: sport,
            level: level,
            name: id,
            durationWeeks: 8,
            sessionsPerWeek: 3,
            defaultObjective: "test",
            assumedProfile: "test",
            summary: "test",
            weeks: [],
            safetyNotes: "n/a",
            progressionLogic: "n/a"
        )
    }
}
