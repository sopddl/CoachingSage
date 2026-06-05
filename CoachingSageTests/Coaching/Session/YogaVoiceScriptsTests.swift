// CoachingSageTests/Coaching/Session/YogaVoiceScriptsTests.swift
// POC yoga (party 2026-06-05, D2/D3) — table statique sanskrit→script de placement.
// Verrouille : 5 postures témoins couvertes en FR, détection par mots-clés sanskrit
// ET vulgarisés, FR seul (EN/ES → nil = silence), posture non couverte → nil.
import XCTest
@testable import CoachingSage

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
}
