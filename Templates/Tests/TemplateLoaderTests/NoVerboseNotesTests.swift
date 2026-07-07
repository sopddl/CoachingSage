import XCTest
@testable import TemplateLoader
import TemplateModel

/// Filet de régression — chantier ÉPURATION DENSITÉ (2026-06-26, décision Sophie).
///
/// Invariant verrouillé : aucune note d'exo AFFICHÉE ne doit redevenir un pavé.
/// La passe a réduit la densité (geste + sensation + 1 repère ; gros blocs
/// structurels condensés en puces). Le garde-fou = un PLAFOND DUR de caractères
/// sur `exercise.notes` (FR/EN/ES) dans tout le contenu rendu en séance.
///
/// Pourquoi un plafond plutôt qu'un motif : la densité n'est pas une faute
/// lexicale repérable par regex — c'est du volume. Un plafond protège contre la
/// régression future (édition, nouveau template) là où aucun check ponctuel ne
/// laisse de trace. Cf CLAUDE.md « passe qualité contenu → filet swift obligatoire ».
///
/// EXCLUS : seules les `notes` d'exo sont plafonnées (champ rédigé le plus dense).
/// Les `warmup`/`cooldown` de séance peuvent légitimement énumérer plusieurs
/// mouvements ; `progression_logic`/`safety_notes` ne sont pas affichés (input LLM).
final class NoVerboseNotesTests: XCTestCase {

    /// Plafond dur (caractères) pour une note d'exo affichée, toutes langues.
    /// Un cue épuré tient largement dessous (moyenne post-passe ≈ 150 car.) ; un
    /// gros bloc structurel condensé en puces (checklist, stratégie course) reste
    /// sous ce plafond. Avant la passe : jusqu'à 2951 car.
    private static let cap = 500

    func testNoVerboseExerciseNotes() async throws {
        let templates = try await TemplateLoader.loadAll()
        guard templates.count >= 30 else { throw XCTSkip("bundle non peuplé (\(templates.count))") }

        var failures: [String] = []
        func check(_ lang: String, _ value: String?, _ id: String, _ exo: String) {
            guard let value, value.count > Self.cap else { return }
            failures.append("[\(id)] \(exo) notes.\(lang): \(value.count) car. (> \(Self.cap)) — « \(value.prefix(80))… »")
        }

        for t in templates {
            for w in t.weeks {
                for s in w.sessions {
                    var exos = s.exercises
                    for v in s.variants ?? [] { exos += v.exercises }
                    for e in exos {
                        check("fr", e.notes?.fr, t.id, e.name.fr)
                        check("en", e.notes?.en, t.id, e.name.fr)
                        check("es", e.notes?.es, t.id, e.name.fr)
                    }
                }
            }
        }
        XCTAssertTrue(
            failures.isEmpty,
            "Notes d'exo trop denses (> \(Self.cap) car.) dans \(failures.count) champ(s) affiché(s) :\n"
                + failures.prefix(50).joined(separator: "\n")
        )
    }
}
