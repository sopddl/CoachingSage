import XCTest
@testable import TemplateLoader
import TemplateModel

/// Filet de régression — chantier compréhensibilité tennis (2026-06-25, décisions Sophie).
///
/// Tennis n'avait pas de citations d'auteurs/orgs : tout le travail est MDR. Verrouille,
/// sur le texte AFFICHÉ **FR** des séances tennis (name / warmup / cooldown / notes /
/// alternatives, variantes incluses), l'absence du cadrage « prévention / préventif »
/// (gêne coude, inconfort épaule, coiffe des rotateurs) — reformulé en « renforcement »
/// neutre, l'anatomie (coude, épaule, coiffe) restant comme cible d'entraînement.
///
/// EXCLUS / GARDÉS : vocabulaire (slice, topspin/lifté, kick serve, split-step, footwork,
/// drill) ; % de dose/perf (volume -33 %, % réussite, % FCmax) ; « échelle d'agilité
/// obligatoire (en option) » (matériel) ; `progression_logic`/`safety_notes` (non affichés).
/// EN/ES : reformulation MDR = suivi (ce chantier traite le FR, locale primaire).
final class NoUnclearTennisJargonTests: XCTestCase {

    private static let pattern = try! NSRegularExpression(
        pattern: #"prévention|préventif|préventive"#,
        options: [.caseInsensitive])

    private func hit(_ text: String?) -> Bool {
        guard let text else { return false }
        return Self.pattern.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) != nil
    }

    func testNoMDRFramingInTennisDisplayedFR() async throws {
        let templates = try await TemplateLoader.loadAll()
        guard templates.count >= 30 else { throw XCTSkip("bundle non peuplé (\(templates.count))") }
        let tennis = templates.filter { $0.sport == .tennis }
        XCTAssertFalse(tennis.isEmpty, "aucun template tennis chargé")

        var failures: [String] = []
        func scan(_ field: String, _ value: String?, _ id: String) {
            if hit(value) { failures.append("[\(id)] \(field): « \((value ?? "").prefix(80))… »") }
        }
        for t in tennis {
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
            "Cadrage MDR « prévention » tennis (FR) non corrigé dans \(failures.count) champ(s) :\n"
                + failures.prefix(40).joined(separator: "\n"))
    }
}
