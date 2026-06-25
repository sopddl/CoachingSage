import XCTest
@testable import TemplateLoader
import TemplateModel

/// Filet de régression — chantier compréhensibilité yoga (2026-06-25, décisions Sophie).
///
/// Verrouille, sur le texte AFFICHÉ **FR** des séances yoga (name / warmup / cooldown /
/// notes / alternatives, variantes incluses) :
///  1. Citations / sources retirées : « Tummee » (plateforme), référence « PubMed ».
///  2. Allégations physiologiques (EU MDR) reformulées en intention de pratique neutre :
///     « drainage lymphatique », « (régulation du) système nerveux (autonome) »,
///     « vasoconstriction ».
///
/// EXCLUS / GARDÉS : sanskrit + lignées/textes fondateurs (asana, vinyasa, Ujjayi,
/// Pattabhi Jois, Iyengar, Patanjali) = vocabulaire ; « obligatoire » de séquençage/sécurité
/// de pratique (contre-posture, pré-séquence, échauffement poignets) ; deltas de VOLUME ;
/// `progression_logic`/`safety_notes` (non affichés). La DENSITÉ des notes = autre chantier.
final class NoUnclearYogaJargonTests: XCTestCase {

    private static let pattern = try! NSRegularExpression(
        pattern: [#"\bTummee\b"#, #"\bPubMed\b"#, #"drainage lymphatique"#,
                  #"système nerveux"#, #"vasoconstriction"#].joined(separator: "|"),
        options: [.caseInsensitive])

    private func hit(_ text: String?) -> Bool {
        guard let text else { return false }
        return Self.pattern.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) != nil
    }

    func testNoCitationsOrMDRInYogaDisplayedFR() async throws {
        let templates = try await TemplateLoader.loadAll()
        guard templates.count >= 30 else { throw XCTSkip("bundle non peuplé (\(templates.count))") }
        let yoga = templates.filter { $0.sport == .yoga }
        XCTAssertFalse(yoga.isEmpty, "aucun template yoga chargé")

        var failures: [String] = []
        func scan(_ field: String, _ value: String?, _ id: String) {
            if hit(value) { failures.append("[\(id)] \(field): « \((value ?? "").prefix(80))… »") }
        }
        for t in yoga {
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
            "Citation/MDR yoga (FR) non corrigé dans \(failures.count) champ(s) :\n"
                + failures.prefix(40).joined(separator: "\n"))
    }
}
