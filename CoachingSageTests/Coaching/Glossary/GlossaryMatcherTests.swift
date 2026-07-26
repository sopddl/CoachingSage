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

    // MARK: - Revue comité 2026-06-06 — jargon échauffement (glutes / band / mobilité / récup)

    func testGlutesMatch() {
        XCTAssertEqual(Glossary.matches(in: "activation glutes").first?.entry.id, "glutes")
        XCTAssertEqual(Glossary.matches(in: "activation des fessiers").first?.entry.id, "glutes")
    }

    // Chantier compréhensibilité running 2026-06-25 — jargon orphelin rendu tappable.
    func testRunningJargonNowMatches() {
        XCTAssertEqual(Glossary.matches(in: "Séries de 600 m (allure VMA)").first?.entry.id, "vma")
        XCTAssertTrue(Glossary.matches(in: "Bloc tempo au seuil 20 min").contains { $0.entry.id == "seuil" })
        XCTAssertEqual(Glossary.matches(in: "Plusieurs seuils dans la semaine").first?.entry.id, "seuil")
        XCTAssertEqual(Glossary.matches(in: "Phase d'affûtage avant la course").first?.entry.id, "affutage")
        XCTAssertEqual(Glossary.matches(in: "construit ta base aérobie").first?.entry.id, "aerobie")
        XCTAssertEqual(Glossary.matches(in: "Mollets excentriques sur une marche").first?.entry.id, "excentrique")
    }

    // Chantier compréhensibilité cycling 2026-06-25 — FCmax rendue tappable (FTP/VO2max déjà glosés).
    func testCyclingFCmaxNowMatches() {
        XCTAssertTrue(Glossary.matches(in: "Allure soutenue (88-94 % FTP, 92-97 % FCmax, RPE 3-4)")
            .contains { $0.entry.id == "fcmax" })
        XCTAssertEqual(Glossary.matches(in: "reste sous 75 % FC max").first?.entry.id, "fcmax")
        XCTAssertEqual(Glossary.matches(in: "stay under 90-95% max HR").first?.entry.id, "fcmax")
    }

    func testBandMatch() {
        XCTAssertEqual(Glossary.matches(in: "activation glutes (band)").last?.entry.id, "band")
        XCTAssertEqual(Glossary.matches(in: "avec un élastique").first?.entry.id, "band")
    }

    func testMobiliteMatch() {
        XCTAssertEqual(Glossary.matches(in: "mobilité épaules").first?.entry.id, "mobility")
    }

    func testRecupMatch() {
        XCTAssertEqual(Glossary.matches(in: "récup active 90s").first?.entry.id, "recovery")
    }

    // Longest-first : les patterns spécifiques existants gardent la priorité.
    func testMobiliteThoraciqueStillThoracic() {
        XCTAssertEqual(Glossary.matches(in: "mobilité thoracique").first?.entry.id, "thoracic")
    }

    func testBandPullApartStillWins() {
        XCTAssertEqual(Glossary.matches(in: "band pull apart x15").first?.entry.id, "bandpullapart")
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

        // Best-of-5 (min) plutôt qu'un seul sample : la CI/simu partage le CPU avec
        // d'autres process, un cold-start ou une contention transitoire peut faire
        // gonfler UN sample x2-3 sans refléter une vraie régression algorithmique
        // (vécu 2026-07-26 : 64ms puis 151ms sur 2 runs successifs, patterns list
        // identique). Le min filtre le bruit tout en gardant le test sensible à une
        // vraie dégradation de l'algo.
        var best = Double.greatestFiniteMagnitude
        var matches: [GlossaryMatch] = []
        for _ in 0..<5 {
            let start = Date()
            matches = Glossary.matches(in: big)
            best = min(best, Date().timeIntervalSince(start))
        }
        XCTAssertFalse(matches.isEmpty)
        // Seuil élargi (était 50ms) : ~183 patterns aujourd'hui vs ~50 à l'origine du
        // test (croissance légitime au fil des passes qualité contenu par sport).
        // 100ms reste largement imperceptible pour un rendu one-shot de notes séance.
        XCTAssertLessThan(best, 0.100, "Matching trop lent : \(best * 1000) ms pour 800 chars (best-of-5)")
    }

    // MARK: - Rétrocompat API `entry(forZone:)`

    func testLegacyEntryForZoneStillWorks() {
        XCTAssertEqual(Glossary.entry(forZone: "Daniels-T")?.id, "daniels.t")
        XCTAssertEqual(Glossary.entry(forZone: "Z2")?.id, "zones")
        XCTAssertEqual(Glossary.entry(forZone: nil)?.id, nil)
        XCTAssertEqual(Glossary.entry(forZone: "")?.id, nil)
    }

    // MARK: - Story 3.24a — 10 termes strength + mobilité (test simu Sophie 2026-05-24)

    func testTMMatches() {
        XCTAssertEqual(Glossary.matches(in: "Front squat 5x5 @65% TM").last?.entry.id, "tm")
        XCTAssertEqual(Glossary.matches(in: "5,3,1+: 5 @85% TM → 3 @92% TM").last?.entry.id, "tm")
    }

    func testTMDoesNotMatchInsideWord() {
        // "tm" (2 chars, boundary stricte) ne doit pas matcher à l'intérieur d'un mot réel.
        XCTAssertTrue(Glossary.matches(in: "postmodern").isEmpty)
        XCTAssertTrue(Glossary.matches(in: "atm").isEmpty)
    }

    func testFiveThreeOneMatches() {
        XCTAssertEqual(Glossary.matches(in: "Schéma 5/3/1 W2 : 3x3 puis série au max.").first?.entry.id, "531")
        // "+" en boundary valide (schéma peak "5/3/1+").
        XCTAssertEqual(Glossary.matches(in: "5/3/1+ @95% TM").first?.entry.id, "531")
    }

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

    // MARK: - Story 3.26 Phase A — 27 termes sport-spécifiques

    func testAll27Phase3_26EntriesExistInGlossary() {
        let expectedIds = [
            // Yoga (8)
            "yoga.asana", "yoga.vinyasa", "yoga.pranayama", "yoga.mudra",
            "yoga.savasana", "yoga.drishti", "yoga.bandha", "yoga.suryanamaskar",
            // Tennis (5)
            "tennis.slice", "tennis.topspin", "tennis.kickserve",
            "tennis.footwork", "tennis.splitstep",
            // Football (4)
            "football.sprintrepete", "football.unetouche",
            "football.transition", "football.rsa",
            // Hiking (4)
            "hiking.denivele", "hiking.elevation",
            "hiking.switchback", "hiking.terrainpace",
            // Triathlon (3)
            "triathlon.t1", "triathlon.t2", "triathlon.brick",
            // HIIT (3)
            "hiit.workrest", "hiit.epoc", "hiit.microinterval",
        ]
        for id in expectedIds {
            XCTAssertNotNil(
                Glossary.entries.first(where: { $0.id == id }),
                "Entry manquante pour id '\(id)' (Story 3.26 Phase A)"
            )
        }
    }

    // MARK: - Yoga

    func testYogaAsanaMatches() {
        XCTAssertEqual(Glossary.matches(in: "Tenir l'asana 5 respirations").first?.entry.id, "yoga.asana")
        XCTAssertEqual(Glossary.matches(in: "3 asanas debout").first?.entry.id, "yoga.asana")
    }

    func testYogaVinyasaMatches() {
        XCTAssertEqual(Glossary.matches(in: "Flow vinyasa 30 min").first?.entry.id, "yoga.vinyasa")
    }

    func testYogaSavasanaAndShavasanaMatch() {
        XCTAssertEqual(Glossary.matches(in: "Finir en savasana 5 min").first?.entry.id, "yoga.savasana")
        XCTAssertEqual(Glossary.matches(in: "Shavasana 8 min").first?.entry.id, "yoga.savasana")
    }

    func testYogaSunSalutationMultiwordMatch() {
        // Multi-mot longest-first : "salutation au soleil" doit matcher en un, pas en plusieurs.
        let matches = Glossary.matches(in: "5 salutations au soleil")
        XCTAssertEqual(matches.count, 0, "'salutations' (pluriel) ne doit pas matcher 'salutation au soleil'")

        let matches2 = Glossary.matches(in: "5 salutation au soleil")
        XCTAssertEqual(matches2.first?.entry.id, "yoga.suryanamaskar")
    }

    func testYogaSunSalutationEnglishMatches() {
        XCTAssertEqual(Glossary.matches(in: "5 sun salutation").first?.entry.id, "yoga.suryanamaskar")
        XCTAssertEqual(Glossary.matches(in: "surya namaskar A").first?.entry.id, "yoga.suryanamaskar")
    }

    func testYogaPranayamaMatches() {
        XCTAssertEqual(Glossary.matches(in: "3 min de pranayama").first?.entry.id, "yoga.pranayama")
    }

    func testYogaMudraAndBandhaAndDrishtiMatch() {
        XCTAssertEqual(Glossary.matches(in: "Mudra d'ancrage").first?.entry.id, "yoga.mudra")
        XCTAssertEqual(Glossary.matches(in: "Engager mula bandha").first?.entry.id, "yoga.bandha")
        XCTAssertEqual(Glossary.matches(in: "Drishti vers le ciel").first?.entry.id, "yoga.drishti")
    }

    // MARK: - Tennis

    func testTennisSliceTopspinKickserveMatch() {
        XCTAssertEqual(Glossary.matches(in: "Travail du slice revers").first?.entry.id, "tennis.slice")
        XCTAssertEqual(Glossary.matches(in: "Coup topspin lourd").first?.entry.id, "tennis.topspin")
        XCTAssertEqual(Glossary.matches(in: "Kick serve 1ère balle").first?.entry.id, "tennis.kickserve")
    }

    func testTennisFootworkVariantsMatch() {
        XCTAssertEqual(Glossary.matches(in: "Footwork ladder 5 min").first?.entry.id, "tennis.footwork")
        XCTAssertEqual(Glossary.matches(in: "Jeu de jambes en losange").first?.entry.id, "tennis.footwork")
    }

    func testTennisSplitstepMatch() {
        XCTAssertEqual(Glossary.matches(in: "Split-step avant chaque frappe").first?.entry.id, "tennis.splitstep")
        XCTAssertEqual(Glossary.matches(in: "Split step rythmé").first?.entry.id, "tennis.splitstep")
    }

    // MARK: - Football

    func testFootballRepeatedSprintsAndRSAMatch() {
        XCTAssertEqual(Glossary.matches(in: "Sprints répétés 6×30m").first?.entry.id, "football.sprintrepete")
        XCTAssertEqual(Glossary.matches(in: "Capacité RSA").first?.entry.id, "football.rsa")
    }

    func testFootballOneTouchMatch() {
        XCTAssertEqual(Glossary.matches(in: "Jeu à une touche").first?.entry.id, "football.unetouche")
        XCTAssertEqual(Glossary.matches(in: "One-touch passes").first?.entry.id, "football.unetouche")
    }

    func testFootballTransitionMatch() {
        XCTAssertEqual(Glossary.matches(in: "Transition défense → attaque").first?.entry.id, "football.transition")
    }

    // MARK: - Hiking

    func testHikingDeniveleVariantsMatch() {
        XCTAssertEqual(Glossary.matches(in: "Dénivelé positif 800m").first?.entry.id, "hiking.denivele")
        XCTAssertEqual(Glossary.matches(in: "Dénivelé total 1200m").first?.entry.id, "hiking.denivele")
        XCTAssertEqual(Glossary.matches(in: "Total ascent 1000m").first?.entry.id, "hiking.denivele")
    }

    func testHikingElevationMatch() {
        XCTAssertEqual(Glossary.matches(in: "Elevation gain 500m").first?.entry.id, "hiking.elevation")
        XCTAssertEqual(Glossary.matches(in: "Élévation 600m sur 5km").first?.entry.id, "hiking.elevation")
    }

    func testHikingSwitchbackAndLacetMatch() {
        XCTAssertEqual(Glossary.matches(in: "Suivre les switchbacks").first?.entry.id, "hiking.switchback")
        XCTAssertEqual(Glossary.matches(in: "Monter en lacets serrés").first?.entry.id, "hiking.switchback")
    }

    func testHikingTerrainPaceMatch() {
        XCTAssertEqual(Glossary.matches(in: "Allure terrain souple").first?.entry.id, "hiking.terrainpace")
        XCTAssertEqual(Glossary.matches(in: "Terrain pace adaptée").first?.entry.id, "hiking.terrainpace")
    }

    // MARK: - Triathlon

    func testTriathlonT1T2BrickMatch() {
        XCTAssertEqual(Glossary.matches(in: "T1 rapide < 1 min").first?.entry.id, "triathlon.t1")
        XCTAssertEqual(Glossary.matches(in: "T2 fluide").first?.entry.id, "triathlon.t2")
        XCTAssertEqual(Glossary.matches(in: "Brick vélo+run").first?.entry.id, "triathlon.brick")
        XCTAssertEqual(Glossary.matches(in: "Brick session 90 min").first?.entry.id, "triathlon.brick")
    }

    func testTriathlonT1DoesNotMatchInsideWord() {
        // T1 ne doit pas matcher dans "t100" ou "t1d2".
        XCTAssertTrue(Glossary.matches(in: "t100m").filter { $0.entry.id == "triathlon.t1" }.isEmpty)
        XCTAssertTrue(Glossary.matches(in: "T1D2").filter { $0.entry.id == "triathlon.t1" }.isEmpty)
    }

    // MARK: - HIIT

    func testHIITWorkRestRatioMatch() {
        XCTAssertEqual(Glossary.matches(in: "Work-rest 30/30").first?.entry.id, "hiit.workrest")
        XCTAssertEqual(Glossary.matches(in: "work rest court").first?.entry.id, "hiit.workrest")
    }

    func testHIITEPOCMatch() {
        XCTAssertEqual(Glossary.matches(in: "Effet EPOC marqué").first?.entry.id, "hiit.epoc")
    }

    func testHIITMicroIntervalMatch() {
        XCTAssertEqual(Glossary.matches(in: "Micro-intervalles 10s").first?.entry.id, "hiit.microinterval")
        XCTAssertEqual(Glossary.matches(in: "Micro-interval 20s/40s").first?.entry.id, "hiit.microinterval")
    }

    // MARK: - Non-overlap multi-sport

    func testMultiTermsAcrossSportsInSameText() {
        let text = "Vinyasa flow puis savasana 5 min."
        let matches = Glossary.matches(in: text)
        let ids = Set(matches.map { $0.entry.id })
        XCTAssertTrue(ids.contains("yoga.vinyasa"))
        XCTAssertTrue(ids.contains("yoga.savasana"))
    }
}
