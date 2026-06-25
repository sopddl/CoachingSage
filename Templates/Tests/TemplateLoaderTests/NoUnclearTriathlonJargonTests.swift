import XCTest
@testable import TemplateLoader
import TemplateModel

/// Filet de régression — chantier compréhensibilité triathlon (2026-06-25, décisions Sophie).
///
/// Verrouille, sur le texte AFFICHÉ **FR** des séances triathlon (name / warmup / cooldown /
/// notes / alternatives, variantes incluses) :
///  1. Citations retirées : « Swim Smooth » (méthode/org), « Mjølsnes 2004 » (+ « le plus
///     validé scientifiquement »).
///  2. Allégations médicales (EU MDR) reformulées : « asymétrie = blessure » → équilibre,
///     « (risque épaule) » → sollicite les épaules, « Préventif épaule du nageur » /
///     « prévention des ischios » → renforcement.
///
/// EXCLUS / GARDÉS : vocabulaire (T1/T2, brick, FTP, FCmax, VO2max, CSS, RPE, allure seuil,
/// % FTP, offsets) rendus tappables ; « casque/bidon/repérage obligatoire » (matériel/sécurité) ;
/// % de dose ; `progression_logic`/`safety_notes` (non affichés). EN/ES : citations enchâssées
/// + reformulation MDR = suivi (ce chantier traite le FR, locale primaire).
final class NoUnclearTriathlonJargonTests: XCTestCase {

    private static let pattern = try! NSRegularExpression(
        pattern: [#"Swim Smooth"#, #"Mjølsnes"#, #"asymétrie = blessure"#, #"risque épaule"#,
                  #"Préventif épaule du nageur"#, #"prévention des ischios"#].joined(separator: "|"),
        options: [.caseInsensitive])

    private func hit(_ text: String?) -> Bool {
        guard let text else { return false }
        return Self.pattern.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) != nil
    }

    func testNoCitationsOrMDRInTriathlonDisplayedFR() async throws {
        let templates = try await TemplateLoader.loadAll()
        guard templates.count >= 30 else { throw XCTSkip("bundle non peuplé (\(templates.count))") }
        let triathlon = templates.filter { $0.sport == .triathlon }
        XCTAssertFalse(triathlon.isEmpty, "aucun template triathlon chargé")

        var failures: [String] = []
        func scan(_ field: String, _ value: String?, _ id: String) {
            if hit(value) { failures.append("[\(id)] \(field): « \((value ?? "").prefix(80))… »") }
        }
        for t in triathlon {
            for w in t.weeks {
                for s in w.sessions {
                    scan("session.name", s.name.fr, t.id)
                    scan("session.warmup", s.warmup?.fr, t.id)
                    scan("session.cooldown", s.cooldown?.fr, t.id)
                    var exos = s.exercises
                    for v in s.variants ?? [] {
                        scan("variant.name", v.name.fr, t.id)
                        scan("variant.warmup", v.warmup?.fr, t.id)
                        scan("variant.cooldown", v.cooldown?.fr, t.id)
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
            "Citation/MDR triathlon (FR) non corrigé dans \(failures.count) champ(s) :\n"
                + failures.prefix(40).joined(separator: "\n"))
    }
}
