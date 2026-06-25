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

    // FR + EN + ES (passe EN/ES 2026-06-25).
    private static let pattern = try! NSRegularExpression(
        pattern: [#"\bTummee\b"#, #"\bPubMed\b"#, #"drainage lymphatique"#, #"lymphatic drainage"#,
                  #"drenaje linfático"#, #"système nerveux"#, #"nervous-system"#,
                  #"sistema nervioso"#, #"vasoconstric"#, #"prévent"#, #"preventi"#,
                  #"prevención"#].joined(separator: "|"),
        options: [.caseInsensitive])

    private func hit(_ loc: LocalizedText?) -> Bool {
        guard let loc else { return false }
        for v in [loc.fr, loc.en, loc.es] {
            guard let v else { continue }
            if Self.pattern.firstMatch(in: v, range: NSRange(v.startIndex..., in: v)) != nil { return true }
        }
        return false
    }

    func testNoCitationsOrMDRInYogaDisplayedFR() async throws {
        let templates = try await TemplateLoader.loadAll()
        guard templates.count >= 30 else { throw XCTSkip("bundle non peuplé (\(templates.count))") }
        let yoga = templates.filter { $0.sport == .yoga }
        XCTAssertFalse(yoga.isEmpty, "aucun template yoga chargé")

        var failures: [String] = []
        func scan(_ field: String, _ loc: LocalizedText?, _ id: String) {
            if hit(loc) { failures.append("[\(id)] \(field): « \((loc?.fr ?? "").prefix(80))… »") }
        }
        for t in yoga {
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
            "Citation/MDR yoga (FR) non corrigé dans \(failures.count) champ(s) :\n"
                + failures.prefix(40).joined(separator: "\n"))
    }
}
