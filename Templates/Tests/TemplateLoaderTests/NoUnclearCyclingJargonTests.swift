import XCTest
@testable import TemplateLoader
import TemplateModel

/// Filet de régression — chantier compréhensibilité cycling (2026-06-25, décisions Sophie).
///
/// Verrouille les corrections de l'audit (coach + novice) : ces motifs NE DOIVENT PLUS
/// apparaître dans le texte AFFICHÉ FR des séances cycling (name / notes / alternatives des
/// exos + name / warmup / cooldown de la séance, variantes incluses).
///
/// Deux familles :
///  1. Citations d'auteurs / protocoles retirées (décision D2 « data coach-science retirée
///     partout », identique running) :
///       « Test d'allure 20 min (protocole Coggan) », « (Coggan/Allen) ».
///  2. Artefact d'injection sensation-first (passe FR antérieure → mot dédoublé) :
///       « très facile très facile » → « très facile ».
///
/// EXCLUS (volontaire) :
///  - `progression_logic` / `safety_notes` : champs coach/LLM NON affichés (non itérés ici,
///    comme le filet running) → ils gardent leur doctrine (Coggan, FTP-Z, etc.).
///  - Les pourcentages « 88-94 % FTP, 92-97 % FCmax » : GARDÉS (décision Sophie — rendus
///    tappables via le glossaire FTP/FCmax/VO2max, pas retirés). Donc NON interdits ici.
///  - `dose.free_text`, `match_key` : hors champ rédigé / clé interne.
final class NoUnclearCyclingJargonTests: XCTestCase {

    private static let pattern = try! NSRegularExpression(
        pattern: [
            #"\bCoggan\b"#,                  // citation auteur/protocole (toutes formes)
            #"très facile très facile"#,     // mot dédoublé (artefact injection)
        ].joined(separator: "|"),
        options: [.caseInsensitive]
    )

    private func offenders(in text: String) -> [String] {
        let range = NSRange(text.startIndex..., in: text)
        return Self.pattern.matches(in: text, range: range).compactMap {
            Range($0.range, in: text).map { String(text[$0]) }
        }
    }

    func testNoUnclearJargonInCyclingDisplayedFR() async throws {
        let templates = try await TemplateLoader.loadAll()
        guard templates.count >= 30 else { throw XCTSkip("bundle non peuplé (\(templates.count))") }
        let cycling = templates.filter { $0.sport == .cycling }
        XCTAssertFalse(cycling.isEmpty, "aucun template cycling chargé")

        var failures: [String] = []
        func scan(_ field: String, _ value: String?, _ id: String) {
            guard let value else { return }
            let hits = offenders(in: value)
            if !hits.isEmpty {
                failures.append("[\(id)] \(field): \(Set(hits).sorted()) — « \(value.prefix(70))… »")
            }
        }

        for t in cycling {
            for w in t.weeks {
                for s in w.sessions {
                    scan("session.name", s.name.fr, t.id)
                    scan("session.warmup", s.warmup?.fr, t.id)
                    scan("session.cooldown", s.cooldown?.fr, t.id)
                    var exos = s.exercises
                    for v in s.variants ?? [] {
                        scan("variant.name", v.name.fr, t.id)
                        scan("variant.warmup", v.warmup?.fr, t.id)
                        scan("variant.cooldown", v.cooldown?.fr, t.id)
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
        XCTAssertTrue(
            failures.isEmpty,
            "Jargon/artefact cycling non corrigé dans \(failures.count) champ(s) FR affiché(s) :\n"
                + failures.prefix(40).joined(separator: "\n")
        )
    }
}
