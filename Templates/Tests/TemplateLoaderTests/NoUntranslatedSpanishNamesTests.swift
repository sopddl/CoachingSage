import XCTest
@testable import TemplateLoader
import TemplateModel

/// Filet de régression passe qualité #2c ES (2026-06-13) : aucun nom d'exercice,
/// alternative ou titre de séance ne doit rester en anglais côté `es`
/// (c.-à-d. `es == en`). Suite de #2b (franglais→FR) propagée à l'espagnol.
///
/// Politique (validée Sophie) : espagnol naturel de salle, l'anglicisme n'est
/// gardé QUE là où c'est le terme dominant en ES → liste `allowedAnglicisms`.
/// Hors périmètre : `notes`, `goal`, `theme` (textes longs, RPE/RIR/FTP/tempo
/// sont du vocabulaire volontaire présent dans les 3 langues, pas de l'anglais
/// résiduel — cf #2c).
final class NoUntranslatedSpanishNamesTests: XCTestCase {

    /// Anglicismes dominants en salle ES : `es == en` y est volontaire.
    /// (StairMaster = nom de machine ; "resistencia alta" = fragment déjà ES
    /// mistaggé côté `en`.)
    private static let allowedAnglicisms = [
        "push press", "hip thrust", "good morning", "sculling", "catch-up",
        "z-press", "stairmaster", "yin yoga", "resistencia",
    ]

    private func isAllowed(_ s: String) -> Bool {
        let lower = s.lowercased()
        return Self.allowedAnglicisms.contains { lower.contains($0) }
    }

    /// Champs « nom » courts d'un template (exercice, alternative, séance, variante).
    private func nameTexts(_ t: ProgramTemplate) -> [(field: String, text: LocalizedText)] {
        var out: [(String, LocalizedText)] = []
        for w in t.weeks {
            for s in w.sessions {
                out.append(("session.name", s.name))
                appendExercises(s.exercises, into: &out)
                for v in s.variants ?? [] {
                    out.append(("variant.name", v.name))
                    appendExercises(v.exercises, into: &out)
                }
            }
        }
        return out
    }

    private func appendExercises(_ ex: [TemplateExercise], into out: inout [(String, LocalizedText)]) {
        for e in ex {
            out.append(("exercise.name", e.name))
            for alt in e.alternatives { out.append(("exercise.alternative", alt)) }
        }
    }

    func testNoExerciseNameLeftUntranslatedInSpanish() async throws {
        let templates = try await TemplateLoader.loadAll()
        guard templates.count >= 30 else { throw XCTSkip("bundle non peuplé (\(templates.count))") }

        var seen = Set<String>()
        var failures: [String] = []
        for t in templates {
            for (field, lt) in nameTexts(t) {
                guard let en = lt.en, let es = lt.es else { continue }
                let fr = lt.fr
                // es == en (anglais non traduit) ET fr a bien été francisé (fr != en)
                guard es == en, fr != en, !isAllowed(es) else { continue }
                if seen.insert(es).inserted {
                    failures.append("[\(t.id)] \(field).es == en : « \(es) » (fr: « \(fr.prefix(40)) »)")
                }
            }
        }
        XCTAssertTrue(
            failures.isEmpty,
            "Noms d'exos ES restés en anglais (\(failures.count) uniques) :\n" + failures.prefix(40).joined(separator: "\n")
        )
    }
}
