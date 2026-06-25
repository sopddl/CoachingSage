import XCTest
@testable import TemplateLoader
import TemplateModel

/// Filet de régression — chantier compréhensibilité hiking (2026-06-25, décisions Sophie).
///
/// Verrouille les corrections de l'audit (coach + novice) : ces motifs NE DOIVENT PLUS
/// apparaître dans le texte AFFICHÉ FR/EN/ES des séances hiking (name / notes / alternatives
/// des exos + name / warmup / cooldown de la séance, variantes incluses).
///
/// Une famille :
///  1. Citation de marque/méthode retirée (décision D2 « data coach-science retirée partout »,
///     identique running/cycling) : « Uphill Athlete » (House-Johnston, Training for the
///     Uphill Athlete) — la justification d'entraînement référencée à la marque. On garde le
///     terme physiologique (« seuil aérobie » / « Aerobic Threshold » / « umbral aeróbico »).
///
/// EXCLUS (volontaire) :
///  - `progression_logic` / `safety_notes` : champs coach/LLM NON affichés (non itérés ici,
///    comme les filets running/cycling) → ils gardent leur doctrine (Uphill Athlete, etc.).
///  - Les pourcentages « 65-78 % FCmax » : GARDÉS (décision Sophie — FCmax rendue tappable
///    via le glossaire, pas retirée). Donc NON interdits ici.
///  - `dose.free_text`, `match_key` : hors champ rédigé / clé interne.
///
/// NB : scan multi-langues (la marque est un nom propre identique FR/EN/ES).
final class NoUnclearHikingJargonTests: XCTestCase {

    private static let pattern = try! NSRegularExpression(
        pattern: #"Uphill Athlete"#,
        options: [.caseInsensitive]
    )

    private func hasOffender(_ text: String?) -> Bool {
        guard let text else { return false }
        let range = NSRange(text.startIndex..., in: text)
        return Self.pattern.firstMatch(in: text, range: range) != nil
    }

    func testNoBrandCitationInHikingDisplayedText() async throws {
        let templates = try await TemplateLoader.loadAll()
        guard templates.count >= 30 else { throw XCTSkip("bundle non peuplé (\(templates.count))") }
        let hiking = templates.filter { $0.sport == .hiking }
        XCTAssertFalse(hiking.isEmpty, "aucun template hiking chargé")

        var failures: [String] = []
        func scan(_ field: String, _ loc: LocalizedText?, _ id: String) {
            guard let loc else { return }
            for (lang, value) in [("fr", loc.fr), ("en", loc.en), ("es", loc.es)] {
                if hasOffender(value) {
                    failures.append("[\(id)] \(field).\(lang): « \((value ?? "").prefix(80))… »")
                }
            }
        }

        for t in hiking {
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
        XCTAssertTrue(
            failures.isEmpty,
            "Citation marque « Uphill Athlete » non retirée dans \(failures.count) champ(s) affiché(s) :\n"
                + failures.prefix(40).joined(separator: "\n")
        )
    }
}
