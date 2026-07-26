import XCTest
@testable import TemplateLoader
import TemplateModel

/// Filet de régression — audit yoga (2026-07-26) : `yoga-competitive-advanced`
/// avait des titres de séance jusqu'à 159 caractères (pranayama listant 4
/// techniques glosées), tronqués sans ellipsis visible sur `NextSessionTeaser`
/// (`.lineLimit(2)` sans `fixedSize`). Titres condensés (max observé après
/// passe : 80 car.) — ce test verrouille l'invariant contre la régression
/// future (nouveau template, édition) plutôt qu'un check ponctuel jetable.
///
/// SCOPE = yoga uniquement (les 4 templates audités aujourd'hui) : un scan
/// large a révélé le même problème sur `hiit-competitive-athletique` (jusqu'à
/// 137 car.) — dette pré-existante, hors périmètre de cet audit, non touchée
/// ici. Ne pas élargir ce test à tout le catalogue sans traiter ce cas d'abord.
///
/// EXCLUS : seul `session.name` est plafonné (c'est LUI qui s'affiche sur la
/// carte compacte à 2 lignes). `warmup`/`cooldown`/`notes` peuvent légitimement
/// être plus longs ailleurs (cf `NoVerboseNotesTests`, plafond séparé).
final class NoVerboseSessionNamesTests: XCTestCase {

    /// Plafond dur (caractères) pour un titre de séance affiché, toutes langues.
    /// Un titre "catégorie [— qualifier court]" tient largement dessous. Avant
    /// la passe 2026-07-26 : jusqu'à 159 car. sur yoga-competitive-advanced.
    private static let cap = 100

    func testNoVerboseYogaSessionNames() async throws {
        let templates = try await TemplateLoader.loadAll()
        guard templates.count >= 30 else { throw XCTSkip("bundle non peuplé (\(templates.count))") }

        var failures: [String] = []
        func check(_ lang: String, _ value: String?, _ id: String, _ week: Int, _ day: Int) {
            guard let value, value.count > Self.cap else { return }
            failures.append("[\(id)] S\(week) J\(day) name.\(lang): \(value.count) car. (> \(Self.cap)) — « \(value.prefix(80))… »")
        }

        for t in templates where t.sport == .yoga {
            for w in t.weeks {
                for s in w.sessions {
                    check("fr", s.name.fr, t.id, w.weekNumber, s.day)
                    check("en", s.name.en, t.id, w.weekNumber, s.day)
                    check("es", s.name.es, t.id, w.weekNumber, s.day)
                }
            }
        }
        XCTAssertTrue(
            failures.isEmpty,
            "Titre(s) de séance yoga trop long(s) (> \(Self.cap) car., risque de troncature NextSessionTeaser) dans \(failures.count) champ(s) :\n"
                + failures.prefix(50).joined(separator: "\n")
        )
    }
}
