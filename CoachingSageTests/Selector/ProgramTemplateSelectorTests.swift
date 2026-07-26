// CoachingSageTests/Selector/ProgramTemplateSelectorTests.swift
// Story 3.2 — vérifie que le selector retourne un template valide pour TOUTE
// combinaison (SportCode × Level), avec la library bundlée v2 (40 templates).
// Couvre aussi : mapping strengthTraining ↔ strength_training, fallback level,
// fallback sport non-couvert, deterministic tie-break par id.
import XCTest
import TemplateLoader
import TemplateModel

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
                // triathlon+competitive exclu : garde-fou Half-Ironman (2026-07-26) retombe
                // sur `regular` sans confirmation des prérequis — couvert par les tests dédiés
                // `testTriathlonCompetitiveFallsBackToRegular...` / `...WhenPrereqConfirmed`.
                if code == "triathlon", level == "competitive" { continue }

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

    // MARK: - Garde-fou Half-Ironman (décision Sophie 2026-07-26, audit triathlon)

    /// Verrou : triathlon n'a qu'1 template par level → sans confirmation explicite des
    /// prérequis Half-Ironman (Olympique bouclé + vélo TT/capteur + 8-10h/sem), le
    /// selector NE DOIT JAMAIS assigner le plan competitive 20 sem. Il retombe sur
    /// `regular` (distance-m 16 sem.).
    func testTriathlonCompetitiveFallsBackToRegularWithoutPrereqConfirmation() async throws {
        let library = try await bundledLibrary()
        let selector = ProgramTemplateSelector(library: library)

        let profile = makeProfile(sportCode: "triathlon", level: "competitive")
        let template = selector.select(profile: profile)

        XCTAssertEqual(template.level, .regular, "Half-Ironman assigné sans garde-fou → \(template.id)")
    }

    /// Verrou symétrique : une fois les prérequis confirmés (réponse "yes" à
    /// `q_half_ironman_prereq` dans l'historique), le plan competitive doit être assigné.
    func testTriathlonCompetitiveAssignsHalfIronmanWhenPrereqConfirmed() async throws {
        let library = try await bundledLibrary()
        let selector = ProgramTemplateSelector(library: library)

        let confirmedEntry = ConversationEntry(
            questionId: "q_half_ironman_prereq",
            questionTextKey: "questionnaire.triathlon.q_half_ironman_prereq.text",
            answer: .single("yes"),
            askedAt: Date()
        )
        let profile = CoachingSportProfile(
            userId: UUID(),
            sportCode: "triathlon",
            level: "competitive",
            goals: GoalsPayload(primary: "half-ironman"),
            equipment: [],
            constraints: [],
            frequencyPerWeek: 3,
            frequencyLabel: "3",
            conversationHistory: [confirmedEntry],
            medicalClearanceAcknowledged: false,
            questionnaireVersion: "v1"
        )
        let template = selector.select(profile: profile)

        XCTAssertEqual(template.level, .competitive, "Half-Ironman non assigné malgré prérequis confirmés → \(template.id)")
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

    // MARK: - selectTopN — Story 3.8 mode vide

    func testSelectTopNReturnsExactMatchesForEachDeclaredSport() async throws {
        let library = try await bundledLibrary()
        let selector = ProgramTemplateSelector(library: library)

        let profile = TopNSelectionProfile(
            level: "beginner",
            sportCodes: ["running", "cycling", "swimming"]
        )
        let suggestions = selector.selectTopN(profile: profile, n: 3)

        XCTAssertEqual(suggestions.count, 3)
        XCTAssertEqual(Set(suggestions.map(\.sport)), [.running, .cycling, .swimming])
        XCTAssertTrue(suggestions.allSatisfy { $0.level == .beginner })
    }

    func testSelectTopNFallsBackToNearestLevelWhenDeclaredSportsExhausted() {
        // 1 sport déclaré (running) × 2 levels disponibles (beginner, regular).
        // Profile = beginner, n=3 → tier 1: 1 template, tier 2: 1 template, tier 3: 1 autre sport au level beginner.
        let runningBeginner = makeMinimalTemplate(id: "running-beginner-x", sport: .running, level: .beginner)
        let runningRegular = makeMinimalTemplate(id: "running-regular-x", sport: .running, level: .regular)
        let cyclingBeginner = makeMinimalTemplate(id: "cycling-beginner-x", sport: .cycling, level: .beginner)
        let library = ProgramTemplateLibrary(templates: [runningBeginner, runningRegular, cyclingBeginner])
        let selector = ProgramTemplateSelector(library: library)

        let profile = TopNSelectionProfile(level: "beginner", sportCodes: ["running"])
        let suggestions = selector.selectTopN(profile: profile, n: 3)

        XCTAssertEqual(suggestions.count, 3)
        XCTAssertEqual(suggestions[0].id, "running-beginner-x")  // tier 1
        XCTAssertEqual(suggestions[1].id, "running-regular-x")   // tier 2 (sport déclaré, level proche)
        XCTAssertEqual(suggestions[2].id, "cycling-beginner-x")  // tier 3 (autre sport, level exact)
    }

    func testSelectTopNFallsBackToAnySportAtLevelWhenNoSportsDeclared() {
        let runningBeginner = makeMinimalTemplate(id: "running-beginner-x", sport: .running, level: .beginner)
        let cyclingBeginner = makeMinimalTemplate(id: "cycling-beginner-x", sport: .cycling, level: .beginner)
        let yogaRegular = makeMinimalTemplate(id: "yoga-regular-x", sport: .yoga, level: .regular)
        let library = ProgramTemplateLibrary(templates: [yogaRegular, runningBeginner, cyclingBeginner])
        let selector = ProgramTemplateSelector(library: library)

        let profile = TopNSelectionProfile(level: "beginner", sportCodes: [])
        let suggestions = selector.selectTopN(profile: profile, n: 3)

        XCTAssertEqual(suggestions.count, 3)
        // Tier 3 d'abord (level exact), trié par id : cycling- < running- ; tier 4 ensuite avec yoga.
        XCTAssertEqual(suggestions.map(\.id), ["cycling-beginner-x", "running-beginner-x", "yoga-regular-x"])
    }

    func testSelectTopNTieBreakAlphabeticByTemplateId() {
        let aaa = makeMinimalTemplate(id: "running-beginner-aaa", sport: .running, level: .beginner)
        let bbb = makeMinimalTemplate(id: "running-beginner-bbb", sport: .running, level: .beginner)
        let ccc = makeMinimalTemplate(id: "running-beginner-ccc", sport: .running, level: .beginner)
        let library = ProgramTemplateLibrary(templates: [ccc, bbb, aaa]) // ordre inverse
        let selector = ProgramTemplateSelector(library: library)

        let profile = TopNSelectionProfile(level: "beginner", sportCodes: ["running"])
        let suggestions = selector.selectTopN(profile: profile, n: 2)

        XCTAssertEqual(suggestions.map(\.id), ["running-beginner-aaa", "running-beginner-bbb"])
    }

    func testSelectTopNReturnsEmptyWhenNIsZeroOrNegative() async throws {
        let library = try await bundledLibrary()
        let selector = ProgramTemplateSelector(library: library)
        let profile = TopNSelectionProfile(level: "beginner", sportCodes: ["running"])

        XCTAssertEqual(selector.selectTopN(profile: profile, n: 0), [])
        XCTAssertEqual(selector.selectTopN(profile: profile, n: -1), [])
    }

    func testSelectTopNCapsAtLibrarySizeWithoutDuplicates() {
        let only = makeMinimalTemplate(id: "running-beginner-x", sport: .running, level: .beginner)
        let library = ProgramTemplateLibrary(templates: [only])
        let selector = ProgramTemplateSelector(library: library)

        let profile = TopNSelectionProfile(level: "beginner", sportCodes: ["running"])
        let suggestions = selector.selectTopN(profile: profile, n: 5)

        XCTAssertEqual(suggestions.count, 1)
        XCTAssertEqual(suggestions.first?.id, "running-beginner-x")
    }

    func testSelectTopNIsDeterministic() async throws {
        let library = try await bundledLibrary()
        let selector = ProgramTemplateSelector(library: library)
        let profile = TopNSelectionProfile(
            level: "regular",
            sportCodes: ["running", "cycling", "swimming", "triathlon"]
        )

        let first = selector.selectTopN(profile: profile, n: 3)
        let second = selector.selectTopN(profile: profile, n: 3)
        XCTAssertEqual(first.map(\.id), second.map(\.id))
    }

    func testSelectTopNMapsStrengthTrainingSportCode() async throws {
        let library = try await bundledLibrary()
        let selector = ProgramTemplateSelector(library: library)

        let profile = TopNSelectionProfile(
            level: "beginner",
            sportCodes: ["strengthTraining"]
        )
        let suggestions = selector.selectTopN(profile: profile, n: 1)
        XCTAssertEqual(suggestions.count, 1)
        XCTAssertEqual(suggestions.first?.sport, .strengthTraining)
        XCTAssertEqual(suggestions.first?.level, .beginner)
    }

    // MARK: - Library minimale fixture

    private func makeMinimalTemplate(id: String, sport: Sport, level: Level) -> ProgramTemplate {
        ProgramTemplate(
            id: id,
            schemaVersion: 1,
            sport: sport,
            level: level,
            name: LocalizedText(fr: id),
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
