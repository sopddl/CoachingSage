import XCTest
@testable import TemplateLoader
import TemplateModel

/// Filet de régression — chantier compréhensibilité natation (2026-06-24, device-test Sophie).
///
/// Verrouille les vulgarisations validées (audit multi-agents coach+novice) : certains termes
/// de jargon natation NE DOIVENT PLUS apparaître dans le texte AFFICHÉ FR des exos de natation
/// (name / notes / alternatives) — ils ont été reformulés :
///   - « éducatif » → « exercice technique »
///   - « prise d'eau » (faux-ami anxiogène = « prendre l'eau ») → « appui sur l'eau »
///   - « au mur » → « au bord du bassin »
///   - « allure seuil » brut → « allure soutenue (seuil) » (sensation d'abord)
///
/// Périmètre VOLONTAIRE = name + notes + alternatives en FR. EXCLUS :
///   - `dose.free_text` : prescription terse, « allure seuil » y reste (verrouillé à
///     `LegacyDoseMigration` — cf. NoFreeTextFRInDoseTests / LegacyDoseMigrationTests) ;
///   - `match_key` : clé interne d'appariement adapter, non affichée ;
///   - EN/ES : « drill »/« catch-up » etc. y sont des termes légitimes.
final class NoUnclearSwimmingJargonTests: XCTestCase {

    private static let pattern = try! NSRegularExpression(
        pattern: [
            #"\béducatif"#,        // éducatif/éducatifs/éducative
            #"prise d['’]eau"#,
            #"\bau mur\b"#,
            #"\ballure seuil\b"#,   // forme glosée « allure soutenue (seuil) » ne matche pas
        ].joined(separator: "|"),
        options: [.caseInsensitive]
    )

    private func offenders(in text: String) -> [String] {
        let range = NSRange(text.startIndex..., in: text)
        return Self.pattern.matches(in: text, range: range).compactMap {
            Range($0.range, in: text).map { String(text[$0]) }
        }
    }

    func testNoUnclearJargonInSwimmingDisplayedFR() async throws {
        let templates = try await TemplateLoader.loadAll()
        guard templates.count >= 30 else { throw XCTSkip("bundle non peuplé (\(templates.count))") }
        let swimming = templates.filter { $0.sport == .swimming }
        XCTAssertFalse(swimming.isEmpty, "aucun template natation chargé")

        var failures: [String] = []
        for t in swimming {
            for w in t.weeks {
                for s in w.sessions {
                    let exos = s.exercises + (s.variants ?? []).flatMap { $0.exercises }
                    for e in exos {
                        var fields: [(String, String?)] = [("name", e.name.fr), ("notes", e.notes?.fr)]
                        for alt in e.alternatives { fields.append(("alternative", alt.fr)) }
                        for (field, value) in fields {
                            guard let value else { continue }
                            let hits = offenders(in: value)
                            if !hits.isEmpty {
                                failures.append("[\(t.id)] \(field): \(Set(hits).sorted()) — « \(value.prefix(70))… »")
                            }
                        }
                    }
                }
            }
        }
        XCTAssertTrue(
            failures.isEmpty,
            "Jargon natation non vulgarisé dans \(failures.count) champ(s) FR affiché(s) :\n" + failures.prefix(40).joined(separator: "\n")
        )
    }
}
