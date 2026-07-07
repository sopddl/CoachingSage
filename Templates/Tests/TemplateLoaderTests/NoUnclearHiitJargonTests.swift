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

    // FR + EN + ES (passe EN/ES 2026-06-25). Tokens d'auteurs/orgs communs aux 3 langues +
    // cadrages MDR propres à chaque langue.
    private static let pattern = try! NSRegularExpression(
        pattern: [#"\bNSCA\b"#, #"\bMujika\b"#, #"\bGibala\b"#, #"\bPetersen\b"#, #"\bBJSM\b"#,
                  #"True Sports"#, #"170 ?% VO2má?x"#, #"fractionné 20/10 1996"#, #"20/10 \(1996\)"#,
                  #"[Pp]révention conflit"#, #"prévention valgus"#, #"Prévention coiffe"#,
                  #"\bimpingement\b"#, #"pinzamiento"#, #"subacromial"#,
                  #"prévent"#, #"prevent"#, #"prevenc"#, #"preventi"#,
                  #"Obligatoire (HIIT|chez le débutant HIIT)"#, #"Mandatory for the HIIT"#,
                  #"Obligatorio para el principiante de HIIT"#].joined(separator: "|"),
        options: [.caseInsensitive])

    private func hit(_ loc: LocalizedText?) -> Bool {
        guard let loc else { return false }
        for v in [loc.fr, loc.en, loc.es] {
            guard let v else { continue }
            if Self.pattern.firstMatch(in: v, range: NSRange(v.startIndex..., in: v)) != nil { return true }
        }
        return false
    }

    func testNoCitationsOrMDRInHiitDisplayedFR() async throws {
        let templates = try await TemplateLoader.loadAll()
        guard templates.count >= 30 else { throw XCTSkip("bundle non peuplé (\(templates.count))") }
        let hiit = templates.filter { $0.sport == .hiit }
        XCTAssertFalse(hiit.isEmpty, "aucun template HIIT chargé")

        var failures: [String] = []
        func scan(_ field: String, _ loc: LocalizedText?, _ id: String) {
            if hit(loc) { failures.append("[\(id)] \(field): « \((loc?.fr ?? "").prefix(80))… »") }
        }
        for t in hiit {
            for w in t.weeks {
                for s in w.sessions {
                    scan("session.name", s.name, t.id)
                    scan("session.warmup", s.warmup, t.id)
                    scan("session.cooldown", s.cooldown, t.id)
                    var exos = s.exercises
                    for v in s.variants ?? [] {
                        scan("variant.name", v.name, t.id)
                        scan("variant.warmup", v.warmup, t.id)
                        scan("variant.cooldown", v.cooldown, t.id)
                        exos += v.exercises
                    }
                    for e in exos {
                        scan("exo.name", e.name, t.id)
                        scan("exo.notes", e.notes, t.id)
                        for alt in e.alternatives { scan("alternative", alt, t.id) }
                    }
                }
            }
        }
        XCTAssertTrue(failures.isEmpty,
            "Citation/MDR HIIT (FR) non corrigé dans \(failures.count) champ(s) :\n"
                + failures.prefix(40).joined(separator: "\n"))
    }
}
