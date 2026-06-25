import XCTest
@testable import TemplateLoader
import TemplateModel

/// Filet de régression — chantier compréhensibilité musculation (2026-06-25, décisions Sophie).
///
/// Verrouille, sur le texte AFFICHÉ **FR** des séances strength (name / warmup / cooldown /
/// notes / alternatives, variantes incluses) :
///  1. Citations coach-science retirées : NSCA, ACSM, Texas Method, Madcow, Helms (Pyramid).
///  2. Noms de pathologie (EU MDR) retirés : « impingement », « conflit sous-acromial »
///     (reformulés en renforcement/stabilité d'épaule).
///
/// EXCLUS / GARDÉS : `5/3/1` = nom de programme canonique (vocabulaire, comme Tabata) ;
/// RPE/RIR/1RM/TM/tempo ; % de charge ; « ceinture obligatoire » / pause technique
/// (matériel/sécurité) ; `progression_logic`/`safety_notes` (non affichés). EN/ES :
/// citations enchâssées en prose = suivi (ce chantier traite le FR, locale primaire).
final class NoUnclearStrengthJargonTests: XCTestCase {

    private static let pattern = try! NSRegularExpression(
        pattern: [#"\bNSCA\b"#, #"\bACSM\b"#, #"\bMadcow\b"#, #"Texas Method"#, #"\bHelms\b"#,
                  #"\bimpingement\b"#, #"conflit sous-acromial"#].joined(separator: "|"),
        options: [.caseInsensitive])

    private func hit(_ text: String?) -> Bool {
        guard let text else { return false }
        return Self.pattern.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) != nil
    }

    func testNoCitationsOrMDRInStrengthDisplayedFR() async throws {
        let templates = try await TemplateLoader.loadAll()
        guard templates.count >= 30 else { throw XCTSkip("bundle non peuplé (\(templates.count))") }
        let strength = templates.filter { $0.sport == .strengthTraining }
        XCTAssertFalse(strength.isEmpty, "aucun template strength chargé")

        var failures: [String] = []
        func scan(_ field: String, _ value: String?, _ id: String) {
            if hit(value) { failures.append("[\(id)] \(field): « \((value ?? "").prefix(80))… »") }
        }
        for t in strength {
            for w in t.weeks {
                for s in w.sessions {
                    scan("session.name", s.name.fr, t.id)
                    scan("session.warmup", s.warmup?.fr, t.id)
                    scan("session.cooldown", s.cooldown?.fr, t.id)
                    var exos = s.exercises
                    for v in s.variants ?? [] {
                        scan("variant.name", v.name.fr, t.id)
                        exos += v.exercises
                    }
                    for e in exos {
                        scan("exo.name", e.name.fr, t.id)
                        scan("exo.notes", e.notes?.fr, t.id)
                        for alt in e.alternatives { scan("alternative", alt.fr, t.id) }
                    }
                }
            }
        }
        XCTAssertTrue(failures.isEmpty,
            "Citation/MDR strength (FR) non corrigé dans \(failures.count) champ(s) :\n"
                + failures.prefix(40).joined(separator: "\n"))
    }
}
