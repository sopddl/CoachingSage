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

    // FR + EN + ES (la passe EN/ES 2026-06-25 a aussi reformulé le cadrage « prévention »).
    private static let pattern = try! NSRegularExpression(
        pattern: #"prévention|préventif|préventive|prevention|preventive|prevención|preventiv|\bMujika\b"#,
        options: [.caseInsensitive])

    private func hit(_ loc: LocalizedText?) -> Bool {
        guard let loc else { return false }
        for v in [loc.fr, loc.en, loc.es] {
            guard let v else { continue }
            if Self.pattern.firstMatch(in: v, range: NSRange(v.startIndex..., in: v)) != nil { return true }
        }
        return false
    }

    func testNoMDRFramingInTennisDisplayedFR() async throws {
        let templates = try await TemplateLoader.loadAll()
        guard templates.count >= 30 else { throw XCTSkip("bundle non peuplé (\(templates.count))") }
        let tennis = templates.filter { $0.sport == .tennis }
        XCTAssertFalse(tennis.isEmpty, "aucun template tennis chargé")

        var failures: [String] = []
        func scan(_ field: String, _ loc: LocalizedText?, _ id: String) {
            if hit(loc) { failures.append("[\(id)] \(field): « \((loc?.fr ?? "").prefix(80))… »") }
        }
        for t in tennis {
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
            "Cadrage MDR « prévention » tennis (FR) non corrigé dans \(failures.count) champ(s) :\n"
                + failures.prefix(40).joined(separator: "\n"))
    }
}
