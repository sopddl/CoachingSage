import XCTest
@testable import TemplateLoader
import TemplateModel

/// Filet de régression — chantier structuration i18n du dosage (party 2026-06-14, Lot 1 yoga).
///
/// Invariants verrouillés :
///  1. **Couverture** : tout exercice yoga porteur d'un dosage (`duration` ou `reps`) a un
///     `dose` structuré → l'affichage (3 vues + label minuteur) ne retombe JAMAIS sur le texte
///     legacy FR (cause du bug déclencheur « 3 min (~10 cycles respiratoires) » en EN/ES).
///  2. **Zéro fuite FR** : chaque `dose` (tous sports) résolu en EN et en ES via `DoseFormatter`
///     ne contient aucun marqueur français — ni mot FR du corpus, ni diacritique FR-exclusif.
///
/// `DoseFormatter` est la source UNIQUE de rendu : tester sa sortie EN/ES = tester ce que voit
/// l'utilisateur (UI + minuteur), pas une approximation.
final class NoFreeTextFRInDoseTests: XCTestCase {

    private static let en = Locale(identifier: "en")
    private static let es = Locale(identifier: "es")

    /// Mots FR du corpus dosage qui ne doivent JAMAIS apparaître dans un rendu EN ou ES
    /// (chacun a une traduction propre : respirations→breaths/respiraciones, etc.).
    /// Volontairement ciblé sur le vocabulaire réellement produit (structuré + freeText).
    private static let frTokens: [String] = [
        "respiration", "respirations", "respiratoires", "souffle", "rythme du souffle",
        "récup", "recup", "tenue", "roulis", "séquence", "lecture", "réflexion",
        "expulsions", "rapides", "lente", "descente", "contrôlée", "chacune", "chaque",
        "par côté", "par posture", "par variante", "par tenue", "par jambe", "par bras",
        "par pied", "par épaule", "cycles respiratoires", "côté", "posture", "variante",
        // Lot 2 running — tokens FR-exclusifs (la trad propre est running/walking/pace/…).
        // On EXCLUT volontairement « progressive »/« recovery » (mots EN légitimes des rendus).
        "course", "marche", "allure", "footing", "tranquille", "rapide",
        "accélération", "récupération", "selon", "objectif",
        // Lot 3 cycling — tokens FR-exclusifs (trad : uphill/elevation/reverse plank/full day…).
        // « rpm » est universel (gardé) ; « endurance »/« tempo » sont des mots EN légitimes.
        "montée", "journée", "entière", "planche", "dorsale",
        // Lot 4 swimming — tokens FR-exclusifs (trad : glide/push-off/float/sculling/backstroke…).
        // « crawl »/« pull-buoy » sont des emprunts universels (gardés, non listés).
        "glisse", "glissé", "poussée", "flottaison", "godille", "apnée",
        "favori", "faible", "alterner", "comptage", "avancée", "séance",
        // Lot 5 hiking — tokens FR-exclusifs (trad : walk/uphill/downhill/elevation gain/grade/pack…).
        // « RPE »/« tempo »/« endurance » = vocabulaire gardé (3 langues), non listés.
        "marche", "sac", "pente", "dont", "cumulé", "plate", "remontée", "facile",
        // Lot 6 hiit — tokens FR-exclusifs (trad : front/side plank/per side/work/rest/knees…).
        // Noms d'exos gardés (dead bug, hollow, Nordic, sled, calf, tibialis…), non listés.
        "ventrale", "latérale", "repos", "bloc", "genoux", "haltères", "lecture",
        // Lot 7 muscu — tokens FR-exclusifs (trad : clean max/of each exercise/attempts/set…).
        // « AMRAP »/« max »/« RPE » = vocabulaire de salle gardé (3 langues), non listés.
        "propre", "exercice", "essai", "essais",
    ]

    /// Diacritiques FR-exclusifs (absents de l'orthographe ES : ç, ô, ê, è, à, î, ë, œ).
    /// Leur présence dans un rendu EN ou ES = fuite FR certaine.
    private static let frDiacritics = CharacterSet(charactersIn: "çôêèàîëœ")

    private func frLeak(in text: String) -> String? {
        let lower = text.lowercased()
        for tok in Self.frTokens where Self.containsWord(tok, in: lower) {
            return "token « \(tok) »"
        }
        if lower.rangeOfCharacter(from: Self.frDiacritics) != nil {
            return "diacritique FR"
        }
        return nil
    }

    /// Match par frontière de mot (lettres Unicode) : « recup » ne matche PAS l'espagnol
    /// correct « recuperación », mais matche bien l'abréviation FR « recup » isolée.
    private static func containsWord(_ token: String, in text: String) -> Bool {
        let pattern = "(?<![\\p{L}])" + NSRegularExpression.escapedPattern(for: token) + "(?![\\p{L}])"
        guard let re = try? NSRegularExpression(pattern: pattern) else { return text.contains(token) }
        return re.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) != nil
    }

    /// (chemin, dose) de tous les exercices d'un template, variantes incluses.
    private func doses(_ t: ProgramTemplate) -> [(path: String, dose: Dose)] {
        var out: [(String, Dose)] = []
        for w in t.weeks {
            for s in w.sessions {
                for e in s.exercises where e.dose != nil { out.append(("\(t.id) S\(w.weekNumber)D\(s.day) \(e.stableMatchKey)", e.dose!)) }
                for v in s.variants ?? [] {
                    for e in v.exercises where e.dose != nil { out.append(("\(t.id) variant \(e.stableMatchKey)", e.dose!)) }
                }
            }
        }
        return out
    }

    // MARK: Invariant 1 — couverture yoga

    func testEveryYogaExerciseHasDose() async throws {
        let templates = try await TemplateLoader.loadAll()
        guard templates.count >= 30 else { throw XCTSkip("bundle non peuplé (\(templates.count))") }
        let yoga = templates.filter { $0.sport == .yoga }
        XCTAssertFalse(yoga.isEmpty, "aucun template yoga chargé")

        var missing: [String] = []
        for t in yoga {
            for w in t.weeks {
                for s in w.sessions {
                    let all = s.exercises + (s.variants ?? []).flatMap { $0.exercises }
                    for e in all where (e.duration != nil || e.reps != nil) && e.dose == nil {
                        missing.append("[\(t.id)] S\(w.weekNumber)D\(s.day) « \(e.stableMatchKey) » : duration/reps sans dose")
                    }
                }
            }
        }
        XCTAssertTrue(
            missing.isEmpty,
            "Exercices yoga avec dosage legacy mais sans `dose` structuré (\(missing.count)) — fuite FR à l'affichage :\n"
                + missing.prefix(30).joined(separator: "\n")
        )
    }

    func testEveryRunningExerciseHasDose() async throws {
        try await assertEverySportExerciseHasDose(.running, name: "running")
    }

    func testEveryCyclingExerciseHasDose() async throws {
        try await assertEverySportExerciseHasDose(.cycling, name: "cycling")
    }

    func testEverySwimmingExerciseHasDose() async throws {
        try await assertEverySportExerciseHasDose(.swimming, name: "swimming")
    }

    func testEveryHikingExerciseHasDose() async throws {
        try await assertEverySportExerciseHasDose(.hiking, name: "hiking")
    }

    func testEveryHiitExerciseHasDose() async throws {
        try await assertEverySportExerciseHasDose(.hiit, name: "hiit")
    }

    func testEveryStrengthExerciseHasDose() async throws {
        try await assertEverySportExerciseHasDose(.strengthTraining, name: "strength")
    }

    private func assertEverySportExerciseHasDose(_ sport: Sport, name: String, file: StaticString = #filePath, line: UInt = #line) async throws {
        let templates = try await TemplateLoader.loadAll()
        guard templates.count >= 30 else { throw XCTSkip("bundle non peuplé (\(templates.count))") }
        let scoped = templates.filter { $0.sport == sport }
        XCTAssertFalse(scoped.isEmpty, "aucun template \(name) chargé", file: file, line: line)

        var missing: [String] = []
        for t in scoped {
            for w in t.weeks {
                for s in w.sessions {
                    let all = s.exercises + (s.variants ?? []).flatMap { $0.exercises }
                    for e in all where (e.duration != nil || e.reps != nil) && e.dose == nil {
                        missing.append("[\(t.id)] S\(w.weekNumber)D\(s.day) « \(e.stableMatchKey) » : duration/reps sans dose")
                    }
                }
            }
        }
        XCTAssertTrue(
            missing.isEmpty,
            "Exercices \(name) avec dosage legacy mais sans `dose` structuré (\(missing.count)) — fuite FR à l'affichage :\n"
                + missing.prefix(30).joined(separator: "\n"),
            file: file, line: line
        )
    }

    // MARK: Invariant 2 — zéro fuite FR dans le rendu EN/ES

    func testDoseRendersWithoutFrenchLeakInENandES() async throws {
        let templates = try await TemplateLoader.loadAll()
        guard templates.count >= 30 else { throw XCTSkip("bundle non peuplé (\(templates.count))") }

        var failures: [String] = []
        for t in templates {
            for (path, dose) in doses(t) {
                for (lang, locale) in [("en", Self.en), ("es", Self.es)] {
                    let rendered = DoseFormatter.string(dose, locale: locale)
                    if let why = frLeak(in: rendered) {
                        failures.append("[\(path)] \(lang): « \(rendered) » — \(why)")
                    }
                }
            }
        }
        XCTAssertTrue(
            failures.isEmpty,
            "Fuite FR dans \(failures.count) rendu(s) de dose EN/ES :\n" + failures.prefix(40).joined(separator: "\n")
        )
    }
}
