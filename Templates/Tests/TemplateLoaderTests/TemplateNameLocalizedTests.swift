import XCTest
@testable import TemplateLoader
import TemplateModel

/// Garde-fou pérenne — chantier i18n « localisation des noms de templates »
/// (2026-06-21). Les 40 noms étaient `{"fr":..}` fr-only → s'affichaient en FR
/// sous EN/ES (LocalizedText.resolved fallback) + paliers anglais résiduels.
///
/// Invariant verrouillé : chaque `name` de template a une traduction `en` ET `es`
/// non vide (sinon un futur template fr-only re-fuirait en FR sous EN/ES, sans test
/// pour l'attraper). Complète NoResidualEnglishInDisplayedFR (qui vérifie l'absence
/// d'anglais dans le FR, pas la présence des traductions).
final class TemplateNameLocalizedTests: XCTestCase {

    func testEveryTemplateNameHasEnAndEs() async throws {
        let templates = try await TemplateLoader.loadAll()
        guard templates.count >= 30 else { throw XCTSkip("bundle non peuplé (\(templates.count))") }

        var missing: [String] = []
        for t in templates {
            let en = t.name.en?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let es = t.name.es?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if en.isEmpty { missing.append("\(t.id): name.en manquant") }
            if es.isEmpty { missing.append("\(t.id): name.es manquant") }
        }
        XCTAssertTrue(
            missing.isEmpty,
            "Nom(s) de template non localisé(s) (s'afficheraient en FR sous EN/ES) :\n"
                + missing.joined(separator: "\n"))
    }
}
