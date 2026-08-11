// CoachingSageTests/Coaching/Session/YogaVoiceScriptsTests.swift
// POC yoga (party 2026-06-05, D2/D3) — table statique sanskrit→script de placement.
// Verrouille : 5 postures témoins couvertes en FR, détection par mots-clés sanskrit
// ET vulgarisés, FR seul (EN/ES → nil = silence), posture non couverte → nil.
import XCTest

final class YogaVoiceScriptsTests: XCTestCase {

    // MARK: - Couverture des 5 témoins (FR)

    func test_savasana_couvert() {
        XCTAssertNotNil(YogaVoiceScripts.script(forName: "Savasana", language: "fr"))
        XCTAssertNotNil(YogaVoiceScripts.script(forName: "Relaxation finale", language: "fr"))
    }

    func test_sukhasana_couvert() {
        XCTAssertNotNil(YogaVoiceScripts.script(forName: "Sukhasana", language: "fr"))
        XCTAssertNotNil(YogaVoiceScripts.script(forName: "Assise en tailleur", language: "fr"))
    }

    func test_guerrier_couvert() {
        XCTAssertNotNil(YogaVoiceScripts.script(forName: "Virabhadrasana I", language: "fr"))
        XCTAssertNotNil(YogaVoiceScripts.script(forName: "Guerrier II", language: "fr"))
    }

    func test_enfant_couvert() {
        XCTAssertNotNil(YogaVoiceScripts.script(forName: "Balasana", language: "fr"))
        XCTAssertNotNil(YogaVoiceScripts.script(forName: "Posture de l'enfant", language: "fr"))
    }

    func test_chienTeteEnBas_couvert() {
        XCTAssertNotNil(YogaVoiceScripts.script(forName: "Adho Mukha Svanasana", language: "fr"))
        XCTAssertNotNil(YogaVoiceScripts.script(forName: "Chien tête en bas", language: "fr"))
    }

    // MARK: - Le script PLACE le corps (impératif), pas une description de bienfaits

    func test_script_estUnPlacementCorporel() {
        let script = YogaVoiceScripts.script(forName: "Savasana", language: "fr")
        XCTAssertEqual(script?.contains("Allonge-toi"), true)
    }

    // MARK: - FR seul (D2) : EN/ES → nil (silence, pas de mauvaise prononciation)

    func test_langueNonFR_renvoieNil() {
        XCTAssertNil(YogaVoiceScripts.script(forName: "Savasana", language: "en"))
        XCTAssertNil(YogaVoiceScripts.script(forName: "Savasana", language: "es"))
    }

    func test_prefixeFR_accepte() {
        // "fr-FR" comme "fr" doivent matcher.
        XCTAssertNotNil(YogaVoiceScripts.script(forName: "Savasana", language: "fr-FR"))
    }

    // MARK: - Non couvert / nil

    func test_postureNonCouverte_renvoieNil() {
        XCTAssertNil(YogaVoiceScripts.script(forName: "Kapotasana", language: "fr"))
    }

    func test_nomNil_renvoieNil() {
        XCTAssertNil(YogaVoiceScripts.script(forName: nil, language: "fr"))
    }

    // MARK: - Chantier yoga débutant (2026-08-11) — chat-vache dédié (retour Sophie 08-08)

    func test_chatVache_couvert() {
        XCTAssertNotNil(YogaVoiceScripts.script(forName: "Marjaryasana-Bitilasana", language: "fr"))
        XCTAssertNotNil(YogaVoiceScripts.script(forName: "Chat-vache", language: "fr"))
    }

    func test_chatVache_decritLeMouvementDynamique() {
        let script = YogaVoiceScripts.script(forName: "Chat-vache", language: "fr")
        XCTAssertEqual(script?.contains("quatre pattes"), true)
    }

    // MARK: - Fallback générique par orientation (couvre les postures non scriptées)

    func test_genericPlacement_lying() {
        let s = YogaVoiceScripts.genericPlacement(forName: "Setu Bandha Sarvangasana", language: "fr")
        XCTAssertEqual(s?.contains("Allonge-toi"), true)
    }

    func test_genericPlacement_seated() {
        let s = YogaVoiceScripts.genericPlacement(forName: "Paschimottanasana", language: "fr")
        XCTAssertEqual(s?.contains("Assieds-toi"), true)
    }

    func test_genericPlacement_standing_defaut() {
        // Trikonasana n'est ni lying ni seated → défaut debout.
        let s = YogaVoiceScripts.genericPlacement(forName: "Trikonasana", language: "fr")
        XCTAssertEqual(s?.contains("debout"), true)
    }

    func test_genericPlacement_allFours() {
        let s = YogaVoiceScripts.genericPlacement(forName: "Table top hold", language: "fr")
        XCTAssertEqual(s?.contains("quatre pattes"), true)
    }

    func test_genericPlacement_noFalsePositiveOnGenericSanskritSuffixes() {
        // Bug trouvé en test (2026-08-11) : "konasana"/"dandasana" bruts sont des
        // suffixes sanskrit génériques, pas des marqueurs de position assise —
        // Trikonasana et Chaturanga Dandasana sont DEBOUT, pas assis.
        XCTAssertEqual(YogaVoiceScripts.genericPlacement(forName: "Trikonasana", language: "fr")?.contains("debout"), true)
        XCTAssertEqual(YogaVoiceScripts.genericPlacement(forName: "Utthita Parsvakonasana", language: "fr")?.contains("debout"), true)
        XCTAssertEqual(YogaVoiceScripts.genericPlacement(forName: "Chaturanga Dandasana", language: "fr")?.contains("Assieds-toi"), false)
    }

    func test_genericPlacement_januSirsasana_pasExcluCommeLeSirsasana() {
        // "Janu Sirsasana" (flexion avant assise, tête au genou) ne doit PAS être
        // silencieuse comme "Sirsasana" (poirier) malgré le suffixe partagé.
        XCTAssertNotNil(YogaVoiceScripts.genericPlacement(forName: "Janu Sirsasana", language: "fr"))
        XCTAssertNil(YogaVoiceScripts.genericPlacement(forName: "Sirsasana", language: "fr"))
    }

    func test_genericPlacement_posturesAvanceesExclues_silence() {
        // Équilibre bras / inversion : une instruction générique fausse serait
        // pire que le silence — comportement actuel préservé.
        for name in ["Sirsasana", "Pincha Mayurasana", "Adho Mukha Vrksasana", "Bakasana"] {
            XCTAssertNil(YogaVoiceScripts.genericPlacement(forName: name, language: "fr"),
                        "\(name) devrait rester silencieux (posture avancée exclue)")
        }
    }

    func test_genericPlacement_langueNonFR_renvoieNil() {
        XCTAssertNil(YogaVoiceScripts.genericPlacement(forName: "Trikonasana", language: "en"))
        XCTAssertNil(YogaVoiceScripts.genericPlacement(forName: "Trikonasana", language: "es"))
    }

    func test_genericPlacement_nomNil_renvoieNil() {
        XCTAssertNil(YogaVoiceScripts.genericPlacement(forName: nil, language: "fr"))
    }

    // MARK: - Garde-fou EU MDR (absent jusqu'ici — YogaVoiceScripts n'est pas un
    // template chargé par TemplateLoader, donc hors du filet NoUnclearYogaJargonTests)

    private static let bannedPatterns = try! NSRegularExpression(
        pattern: [#"\bTummee\b"#, #"\bPubMed\b"#, #"drainage lymphatique"#,
                  #"système nerveux"#, #"vasoconstric"#, #"prévent"#].joined(separator: "|"),
        options: [.caseInsensitive])

    private func hasBannedJargon(_ text: String) -> Bool {
        Self.bannedPatterns.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) != nil
    }

    func test_noBannedJargonInAnyScript() {
        // Couvre les 6 scripts dédiés (5 témoins + chat-vache) ET les 4 gabarits
        // génériques — toute string user-facing produite par ce fichier.
        let dedicatedNames = ["Savasana", "Balasana", "Adho Mukha Svanasana",
                               "Virabhadrasana I", "Sukhasana", "Chat-vache"]
        let generic = ["Setu Bandha", "Paschimottanasana", "Trikonasana", "Table top"]

        var offenders: [String] = []
        for name in dedicatedNames {
            if let s = YogaVoiceScripts.script(forName: name, language: "fr"), hasBannedJargon(s) {
                offenders.append("script(\(name))")
            }
        }
        for name in generic {
            if let s = YogaVoiceScripts.genericPlacement(forName: name, language: "fr"), hasBannedJargon(s) {
                offenders.append("genericPlacement(\(name))")
            }
        }
        XCTAssertTrue(offenders.isEmpty, "Jargon interdit (EU MDR) dans : \(offenders)")
    }
}
