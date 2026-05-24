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

    // MARK: - Story 3.24a — 10 termes strength + mobilité (test simu Sophie 2026-05-24)

    func testRIRMatches() {
        XCTAssertEqual(Glossary.matches(in: "Garde RIR 2 sur la dernière série.").first?.entry.id, "rir")
        XCTAssertEqual(Glossary.matches(in: "rir 3").first?.entry.id, "rir")
    }

    func testRepsInReserveMatchesAsRIRMultiword() {
        let matches = Glossary.matches(in: "Reps in reserve 2 max.")
        XCTAssertEqual(matches.count, 1, "Multi-mot 'reps in reserve' doit matcher RIR seul, pas reps+rir séparés")
        XCTAssertEqual(matches.first?.entry.id, "rir")
    }

    func testCARsMatches() {
        XCTAssertEqual(Glossary.matches(in: "Ankle CARs 5 reps").first?.entry.id, "cars")
        XCTAssertEqual(Glossary.matches(in: "hip cars").first?.entry.id, "cars")
    }

    func testScapularCARsMatchesBothTerms() {
        let matches = Glossary.matches(in: "Scapular CARs 5 reps")
        let ids = Set(matches.map { $0.entry.id })
        XCTAssertTrue(ids.contains("scapular"), "Scapular doit matcher")
        XCTAssertTrue(ids.contains("cars"), "CARs doit matcher en plus")
        XCTAssertTrue(ids.contains("reps"), "reps doit matcher aussi")
    }

    func testThoracicMobilityMatches() {
        XCTAssertEqual(Glossary.matches(in: "Mobilité thoracique 1 min").first?.entry.id, "thoracic")
        XCTAssertEqual(Glossary.matches(in: "Thoracic mobility drill").first(where: { $0.entry.id == "thoracic" })?.entry.id, "thoracic")
        XCTAssertEqual(Glossary.matches(in: "Thoracic extension").first?.entry.id, "thoracic")
    }

    func testTSpineMatchesAsThoracic() {
        // Synonyme alias très utilisé dans les templates strength.
        XCTAssertEqual(Glossary.matches(in: "Rotations T-spine 8/côté").first?.entry.id, "thoracic")
        XCTAssertEqual(Glossary.matches(in: "T spine rotation").first?.entry.id, "thoracic")
        XCTAssertEqual(Glossary.matches(in: "Thoracic rotation 8/côté").first?.entry.id, "thoracic")
    }

    func testBandPullApartMatches() {
        let matches = Glossary.matches(in: "Band pull apart × 15")
        XCTAssertEqual(matches.first?.entry.id, "bandpullapart")
        XCTAssertEqual(matches.count, 1, "Multi-mot doit matcher en un seul, pas band+pull+apart")
    }

    func testPullApartShortMatchesBandpullapart() {
        XCTAssertEqual(Glossary.matches(in: "Pull apart pour échauffer.").first?.entry.id, "bandpullapart")
    }

    func testShoulderDislocationsMatches() {
        let matches = Glossary.matches(in: "Shoulder dislocations × 10")
        XCTAssertEqual(matches.first?.entry.id, "dislocation")
    }

    func testCatCowMatches() {
        XCTAssertEqual(Glossary.matches(in: "Cat-cow 8 reps").first?.entry.id, "catcow")
        XCTAssertEqual(Glossary.matches(in: "cat cow lent").first?.entry.id, "catcow")
    }

    func testRampUpMatches() {
        XCTAssertEqual(Glossary.matches(in: "Ramp up bench 3 séries").first?.entry.id, "rampup")
        XCTAssertEqual(Glossary.matches(in: "ramp-up progressif").first?.entry.id, "rampup")
    }

    func testBarreVideMatches() {
        XCTAssertEqual(Glossary.matches(in: "Échauffement barre vide ×5").first?.entry.id, "barrevide")
        XCTAssertEqual(Glossary.matches(in: "Warm up with empty bar").first?.entry.id, "barrevide")
    }

    func testRepsMatches() {
        XCTAssertEqual(Glossary.matches(in: "10 reps").first?.entry.id, "reps")
        XCTAssertEqual(Glossary.matches(in: "Faire 8 répétitions lentes.").first?.entry.id, "reps")
    }

    func testRepsDoesNotMatchInsideRepresent() {
        // word boundary : "represent" / "représenter" ne doit pas matcher "reps"
        XCTAssertTrue(Glossary.matches(in: "représenter").isEmpty)
        XCTAssertTrue(Glossary.matches(in: "represent").isEmpty)
    }

    func testCarsMatchesEvenInNonExerciseContext() {
        // Word boundary catche "cars" comme mot isolé, donc va matcher même hors contexte exo.
        // Note documentation : c'est ATTENDU (pattern 4 chars). Si ce devient un pain dans des
        // textes user non-glossariables, ajouter un guard contextuel ('cars' suivi d'un verbe
        // d'exo ou précédé d'une articulation). V1 : laisser, peu probable dans les notes exo.
        XCTAssertEqual(Glossary.matches(in: "Cars dans le parking").first?.entry.id, "cars")
        // Anti-régression : ne matche PAS dans "scars" ni "carstone"
        XCTAssertTrue(Glossary.matches(in: "scars").isEmpty)
        XCTAssertTrue(Glossary.matches(in: "carstone").isEmpty)
    }

    // MARK: - Smoke : tous les nouveaux termes ont des entries valides

    func testAll10NewEntriesExistInGlossary() {
        let expectedIds = ["rir", "cars", "scapular", "thoracic", "bandpullapart",
                           "dislocation", "catcow", "rampup", "barrevide", "reps"]
        for id in expectedIds {
            XCTAssertNotNil(
                Glossary.entries.first(where: { $0.id == id }),
                "Entry manquante pour id '\(id)' (Story 3.24a)"
            )
        }
    }
}
