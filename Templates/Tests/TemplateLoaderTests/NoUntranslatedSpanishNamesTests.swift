import XCTest
@testable import TemplateLoader
import TemplateModel

/// Filet de régression passe qualité #2c ES (2026-06-13). Vérifie le CHEMIN DE
/// RENDU réel : `LocalizedText.resolved(Locale)` — la même fonction que les vues
/// appellent pour afficher un nom d'exercice dans la langue de l'app.
///
/// Trois garanties :
///  1. `testSpanishResolvesToSpanish` — pour CHAQUE nom d'exo/alternative/séance,
///     la résolution en `es` ne renvoie PAS la valeur anglaise (`es == en`),
///     hors anglicismes dominants whitelistés. C'est l'invariant de #2c.
///  2. `testGoldenSpanishNames` — ancres « golden » : une poignée de traductions
///     clés sont figées (Dead bug → Bicho muerto…) pour attraper une dérive de
///     contenu future (re-génération, ré-import) qui les casserait silencieusement.
///  3. `testFallbackToFrenchWhenSpanishMissing` — quand `es` est absent (titres
///     top-level fr-only), la résolution `es` retombe bien sur `fr` (pas de vide).
///
/// Hors périmètre : `notes`/`goal` (textes longs ; RPE/RIR/FTP/tempo = vocabulaire
/// volontaire présent dans les 3 langues, ≠ anglais résiduel — cf #2c).
final class NoUntranslatedSpanishNamesTests: XCTestCase {

    private static let es = Locale(identifier: "es")
    private static let en = Locale(identifier: "en")
    private static let fr = Locale(identifier: "fr")

    /// Anglicismes dominants en salle ES : `es == en` y est volontaire.
    /// (StairMaster = nom de machine ; "resistencia" = fragment déjà ES mistaggé.)
    private static let allowedAnglicisms = [
        "push press", "hip thrust", "good morning", "sculling", "catch-up",
        "z-press", "stairmaster", "yin yoga", "resistencia",
        // #2d : anglicismes dominants en salle ES, gardés volontairement (lead anglais).
        "back squat", "front squat", "hack squat", "step-up", "hollow",
        "glute-ham", "face pull", "superman glide", "kettlebell",
    ]

    private func isAllowed(_ s: String) -> Bool {
        let lower = s.lowercased()
        return Self.allowedAnglicisms.contains { lower.contains($0) }
    }

    /// Tous les `LocalizedText` « nom » (exercice, alternative, séance, variante).
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

    private func loadTemplates() async throws -> [ProgramTemplate] {
        let templates = try await TemplateLoader.loadAll()
        guard templates.count >= 30 else { throw XCTSkip("bundle non peuplé (\(templates.count))") }
        return templates
    }

    /// (1) Invariant #2c, via la résolution de rendu réelle.
    func testSpanishResolvesToSpanish() async throws {
        var seen = Set<String>()
        var failures: [String] = []
        for t in try await loadTemplates() {
            for (field, lt) in nameTexts(t) {
                let esVal = lt.resolved(Self.es)
                let enVal = lt.resolved(Self.en)
                let frVal = lt.resolved(Self.fr)
                // anglais non traduit ET fr bien francisé ET pas un anglicisme voulu
                guard esVal == enVal, frVal != enVal, !isAllowed(esVal) else { continue }
                if seen.insert(esVal).inserted {
                    failures.append("[\(t.id)] \(field) → es « \(esVal) » (fr « \(frVal.prefix(40)) »)")
                }
            }
        }
        XCTAssertTrue(
            failures.isEmpty,
            "Noms d'exos résolus en anglais sous locale ES (\(failures.count) uniques) :\n"
                + failures.prefix(40).joined(separator: "\n")
        )
    }

    /// (2) Ancres golden : traductions clés figées contre la dérive de contenu.
    func testGoldenSpanishNames() async throws {
        // Ancres choisies UNIQUEMENT parmi les canonicals dont l'ES est stable
        // partout (1 seule valeur dans tout le bundle). NB : « Gainage croisé au
        // sol » (Dead bug) / « Pointeur » (Bird-dog) sont volontairement EXCLUS :
        // ils ont encore des variantes anglais-en-tête non traduites (résidu #2d,
        // cf incohérence documentée) → mauvaises ancres tant que #2d n'est pas fait.
        let golden: [String: String] = [   // fr (canonical) → es attendu
            "Squat gobelet": "Sentadilla goblet",
            "Tirage barre en T 4×10": "Remo en T 4×10",
            "Tirage seal 4×8": "Remo seal 4×8",
            "Gainage croisé au sol + pointeur": "Bicho muerto + perro-pájaro",
            "Soulevé de terre roumain 3x6 @60% TM": "Peso muerto rumano 3x6 @60% TM",
        ]
        var found = Set<String>()
        var mismatches: [String] = []
        for t in try await loadTemplates() {
            for (_, lt) in nameTexts(t) {
                guard let expectedES = golden[lt.canonical] else { continue }
                found.insert(lt.canonical)
                let esVal = lt.resolved(Self.es)
                if esVal != expectedES {
                    mismatches.append("« \(lt.canonical) » → es « \(esVal) » (attendu « \(expectedES) »)")
                }
            }
        }
        XCTAssertTrue(mismatches.isEmpty, "Traductions golden cassées :\n" + mismatches.joined(separator: "\n"))
        // garde-fou : si une ancre disparaît du bundle, le test ne doit pas devenir vide-vrai
        let missing = Set(golden.keys).subtracting(found)
        XCTAssertTrue(missing.isEmpty, "Ancres golden absentes du bundle (à mettre à jour) : \(missing.sorted())")
    }

    /// (2-bis) « Screenshot swift » : fige la liste EXACTE des noms d'exos rendus
    /// en ES pour une vraie séance (PPL semaine 1, Push A), telle que l'utilisateur
    /// la verrait — et vérifie qu'ils diffèrent du rendu EN (= traduction appliquée,
    /// pas un passthrough anglais). Équivalent déterministe d'une capture d'écran.
    func testRealSessionRendersInSpanish() async throws {
        let templates = try await loadTemplates()
        guard let ppl = templates.first(where: { $0.id == "strength-training-regular-ppl-12sem" }),
              let session = ppl.weeks.first?.sessions.first else {
            throw XCTSkip("template PPL ou séance 1 absente")
        }
        let renderedES = session.exercises.map { $0.name.resolved(Self.es) }
        let expectedES = [
            "Press de banca con barra — series tope pesadas",
            "Press militar con barra de pie",
            "Press de banca inclinado con mancuernas a 30° (empuje horizontal (hipertrofia))",
            "Elevaciones laterales con mancuernas (deltoides lateral aislamiento)",
            "Extensión de tríceps en polea (cuerda)",
            "Pallof press (core antirrotación — AL FINAL)",
        ]
        XCTAssertEqual(renderedES, expectedES, "Le rendu ES de la séance PPL Push A a changé (golden à mettre à jour si intentionnel).")
        // chaque nom rendu en ES diffère du rendu EN → la traduction est bien appliquée
        for ex in session.exercises {
            XCTAssertNotEqual(ex.name.resolved(Self.es), ex.name.resolved(Self.en),
                              "« \(ex.name.resolved(Self.es)) » identique en ES et EN (non traduit)")
        }
    }

    /// (3) Fallback FR quand l'ES manque (ne jamais afficher vide).
    func testFallbackToFrenchWhenSpanishMissing() {
        let frOnly = LocalizedText(fr: "Vélo reprise — Retrouver le plaisir")
        XCTAssertEqual(frOnly.resolved(Self.es), "Vélo reprise — Retrouver le plaisir")
        XCTAssertEqual(frOnly.resolved(Self.en), "Vélo reprise — Retrouver le plaisir")
    }
}
