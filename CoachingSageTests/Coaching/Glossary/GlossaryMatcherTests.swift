// CoachingSageTests/Coaching/Glossary/GlossaryMatcherTests.swift
// Story 3.17 Phase 1 — couvre `Glossary.matches(in:)` (moteur multi-match inline).
import XCTest

final class GlossaryMatcherTests: XCTestCase {

    // MARK: - Cas vides / no-match

    func testEmptyStringReturnsNoMatches() {
        XCTAssertTrue(Glossary.matches(in: "").isEmpty)
    }

    func testNoTechnicalTermReturnsNoMatches() {
        let text = "Une jolie balade tranquille à la campagne."
        XCTAssertTrue(Glossary.matches(in: text).isEmpty)
    }

    // MARK: - Match unique

    func testSingleRPEMatch() {
        let text = "RPE 7-8 pendant 10 minutes."
        let matches = Glossary.matches(in: text)
        XCTAssertEqual(matches.count, 1)
        XCTAssertEqual(matches.first?.entry.id, "rpe")
        XCTAssertEqual(matches.first?.matchedSubstring, "RPE")
    }

    func testSingleTempoMatch() {
        let text = "Travail au tempo pendant 30 minutes."
        let matches = Glossary.matches(in: text)
        XCTAssertEqual(matches.count, 1)
        XCTAssertEqual(matches.first?.entry.id, "tempo")
    }

    // MARK: - Matches multiples ordonnés

    func testMultipleMatchesOrderedByPosition() {
        let text = "Travail au tempo en Z2 puis intervals à Daniels-T."
        let matches = Glossary.matches(in: text)
        XCTAssertEqual(matches.count, 4)
        XCTAssertEqual(matches.map { $0.entry.id }, ["tempo", "zones", "intervals", "daniels.t"])
    }

    func testThreeNewTerms() {
        let text = "Fartlek 30 min avec cadence haute et strides 6×80m."
        let matches = Glossary.matches(in: text)
        XCTAssertEqual(matches.count, 3)
        let ids = Set(matches.map { $0.entry.id })
        XCTAssertEqual(ids, Set(["fartlek", "cadence", "strides"]))
    }

    // MARK: - Case-insensitive + casse préservée

    func testCaseInsensitiveMatching() {
        XCTAssertEqual(Glossary.matches(in: "rpe 7").first?.entry.id, "rpe")
        XCTAssertEqual(Glossary.matches(in: "RPE 7").first?.entry.id, "rpe")
        XCTAssertEqual(Glossary.matches(in: "Rpe 7").first?.entry.id, "rpe")
    }

    func testOriginalCasePreservedInMatchedSubstring() {
        let matches = Glossary.matches(in: "RPE et tempo")
        XCTAssertEqual(matches.first(where: { $0.entry.id == "rpe" })?.matchedSubstring, "RPE")
        XCTAssertEqual(matches.first(where: { $0.entry.id == "tempo" })?.matchedSubstring, "tempo")
    }

    // MARK: - Word boundaries

    func testRPEDoesNotMatchInsideWord() {
        XCTAssertTrue(Glossary.matches(in: "scrapped").isEmpty)
        XCTAssertTrue(Glossary.matches(in: "supercrepe").isEmpty)
    }

    func testTempoDoesNotMatchInsideWord() {
        XCTAssertTrue(Glossary.matches(in: "atempérament").isEmpty)
    }

    func testCadenceMatchesAtBoundaries() {
        XCTAssertEqual(Glossary.matches(in: "Cadence haute").first?.entry.id, "cadence")
        XCTAssertEqual(Glossary.matches(in: "la cadence").first?.entry.id, "cadence")
        XCTAssertEqual(Glossary.matches(in: "cadence.").first?.entry.id, "cadence")
        XCTAssertEqual(Glossary.matches(in: "cadence,").first?.entry.id, "cadence")
    }

    // MARK: - Longest-first priority

    func testDanielsTBeatsTempoStandalone() {
        let text = "Allure Daniels-T pendant 4×10 min."
        let matches = Glossary.matches(in: text)
        XCTAssertEqual(matches.count, 1)
        XCTAssertEqual(matches.first?.entry.id, "daniels.t")
    }

    func testPlyometricBeatsPlyo() {
        // "plyometric" est plus long que "plyo" — devrait gagner sur l'overlap.
        let text = "Plyometric 3 sets."
        let matches = Glossary.matches(in: text)
        XCTAssertEqual(matches.count, 1)
        XCTAssertEqual(matches.first?.entry.id, "plyometric")
        XCTAssertEqual(matches.first?.matchedSubstring, "Plyometric")
    }

    func testPlyoAloneStillMatchesPlyometric() {
        let matches = Glossary.matches(in: "Plyo en option.")
        XCTAssertEqual(matches.count, 1)
        XCTAssertEqual(matches.first?.entry.id, "plyometric")
    }

    // MARK: - Acronymes zones (Z1-Z5, EN1-EN3)

    func testZoneAcronymsMatch() {
        XCTAssertEqual(Glossary.matches(in: "Z2 facile").first?.entry.id, "zones")
        XCTAssertEqual(Glossary.matches(in: "footing Z3").first?.entry.id, "zones")
    }

    func testZNotFollowedByDigitDoesNotMatch() {
        XCTAssertTrue(Glossary.matches(in: "ZZ top").isEmpty)
        XCTAssertTrue(Glossary.matches(in: "zigzag").isEmpty)
    }

    func testENAcronymsMatch() {
        XCTAssertEqual(Glossary.matches(in: "EN1 800m").first?.entry.id, "en")
        XCTAssertEqual(Glossary.matches(in: "Travail EN2 calme").first?.entry.id, "en")
        XCTAssertEqual(Glossary.matches(in: "EN3 jusqu'au seuil").first?.entry.id, "en")
    }

    func testENWithoutDigitDoesNotMatch() {
        // "en" mot français basique ne doit PAS matcher comme EN swim zone.
        XCTAssertTrue(Glossary.matches(in: "marche en montée").filter { $0.entry.id == "en" }.isEmpty)
    }

    // MARK: - Termes Phase 1 (11 nouveaux)

    func testAllPhase1TermsDetectable() {
        let cases: [(input: String, expectedId: String)] = [
            ("cadence haute", "cadence"),
            ("au tempo", "tempo"),
            ("le threshold", "threshold"),
            ("VO2max ciblé", "vo2max"),
            ("vo2 max développé", "vo2max"),
            ("intervals 5×3min", "intervals"),
            ("strides post-warmup", "strides"),
            ("fartlek 30 min", "fartlek"),
            ("plyometric explosif", "plyometric"),
            ("hypertrophy 4×10", "hypertrophy"),
            ("le lactate s'accumule", "lactate"),
            ("push-off au mur", "pushoff"),
            ("push off natation", "pushoff"),
        ]
        for testCase in cases {
            let matches = Glossary.matches(in: testCase.input)
            XCTAssertEqual(matches.first?.entry.id, testCase.expectedId,
                           "Expected '\(testCase.expectedId)' for input '\(testCase.input)' — got \(matches.map { $0.entry.id })")
        }
    }

    // MARK: - Non-overlap

    func testOverlapResolvedByLongest() {
        // Phrase contenant "VO2max" et "VO2 max" séparés. Pas d'overlap, 2 matches.
        let text = "Travail VO2max et VO2 max séparément."
        let matches = Glossary.matches(in: text)
        XCTAssertEqual(matches.count, 2)
        XCTAssertTrue(matches.allSatisfy { $0.entry.id == "vo2max" })
    }

    func testCSSMatchesAsAcronym() {
        XCTAssertEqual(Glossary.matches(in: "CSS test 400m").first?.entry.id, "css")
        // "discussion" ne doit pas matcher css (boundary).
        XCTAssertTrue(Glossary.matches(in: "discussion").isEmpty)
    }

    // MARK: - Performance smoke test

    func testPerformanceOn500CharText() {
        let chunk = "Footing tranquille en Z2 puis intervals 5×3min à Daniels-T " +
                    "avec cadence haute. RPE 7-8 cible, push-off bien fait au mur " +
                    "et CSS test 400m. Strides 6×80m après warmup et threshold. "
        let big = String(repeating: chunk, count: 4) // ~800 chars
        let start = Date()
        let matches = Glossary.matches(in: big)
        let elapsed = Date().timeIntervalSince(start)
        XCTAssertFalse(matches.isEmpty)
        XCTAssertLessThan(elapsed, 0.050, "Matching trop lent : \(elapsed * 1000) ms pour 800 chars")
    }

    // MARK: - Rétrocompat API `entry(forZone:)`

    func testLegacyEntryForZoneStillWorks() {
        XCTAssertEqual(Glossary.entry(forZone: "Daniels-T")?.id, "daniels.t")
        XCTAssertEqual(Glossary.entry(forZone: "Z2")?.id, "zones")
        XCTAssertEqual(Glossary.entry(forZone: nil)?.id, nil)
        XCTAssertEqual(Glossary.entry(forZone: "")?.id, nil)
    }
}
