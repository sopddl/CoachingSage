import XCTest
@testable import TemplateLoader
import TemplateModel

/// Filet de régression — chantier compréhensibilité HIIT (2026-06-25, décisions Sophie).
///
/// Verrouille, sur le texte AFFICHÉ **FR** des séances HIIT (name / warmup / cooldown /
/// notes / alternatives, variantes incluses) :
///  1. Citations coach-science retirées : NSCA, Mujika, Gibala, Petersen, BJSM,
///     True Sports PT, et les données labo rattachées (« 170 % VO2max », « fractionné
///     20/10 1996 », « 20/10 (1996) »).
///  2. Allégations médicales (EU MDR) reformulées : « Prévention conflit sous-acromial »,
///     « prévention valgus », « Prévention coiffe rotateurs », « Obligatoire HIIT/débutant ».
///
/// EXCLUS : `progression_logic`/`safety_notes` (non affichés) ; % de DOSE (-10/-25 % vs Wx) ;
/// vocabulaire gardé (fractionné 20/10, AMRAP/EMOM, Tabata, kettlebell, burpees, RPE,
/// VO2max/FCmax rendus tappables). EN/ES : citations enchâssées en prose = suivi (ce chantier
/// traite le FR, locale primaire — cf. running/cycling/hiking).
final class NoUnclearHiitJargonTests: XCTestCase {

    private static let pattern = try! NSRegularExpression(
        pattern: [#"\bNSCA\b"#, #"\bMujika\b"#, #"\bGibala\b"#, #"\bPetersen\b"#, #"\bBJSM\b"#,
                  #"True Sports"#, #"170 ?% VO2max"#, #"fractionné 20/10 1996"#, #"20/10 \(1996\)"#,
                  #"[Pp]révention conflit"#, #"prévention valgus"#, #"Prévention coiffe"#,
                  #"Obligatoire HIIT"#, #"Obligatoire chez le débutant HIIT"#].joined(separator: "|"),
        options: [])

    private func hit(_ text: String?) -> Bool {
        guard let text else { return false }
        return Self.pattern.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) != nil
    }

    func testNoCitationsOrMDRInHiitDisplayedFR() async throws {
        let templates = try await TemplateLoader.loadAll()
        guard templates.count >= 30 else { throw XCTSkip("bundle non peuplé (\(templates.count))") }
        let hiit = templates.filter { $0.sport == .hiit }
        XCTAssertFalse(hiit.isEmpty, "aucun template HIIT chargé")

        var failures: [String] = []
        func scan(_ field: String, _ value: String?, _ id: String) {
            if hit(value) { failures.append("[\(id)] \(field): « \((value ?? "").prefix(80))… »") }
        }
        for t in hiit {
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
            "Citation/MDR HIIT (FR) non corrigé dans \(failures.count) champ(s) :\n"
                + failures.prefix(40).joined(separator: "\n"))
    }
}
