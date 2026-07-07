import XCTest
@testable import TemplateLoader
import TemplateModel

/// Filet de régression — chantier compréhensibilité running (2026-06-25, décisions Sophie).
///
/// Verrouille les corrections de l'audit multi-agents (coach + novice) : ces motifs NE
/// DOIVENT PLUS apparaître dans le texte AFFICHÉ FR des séances running (name / notes /
/// alternatives des exos + name / warmup / cooldown de la séance, variantes incluses).
///
/// Trois familles :
///  1. Artefacts d'injection sensation-first (passe FR antérieure → français cassé) :
///       « Allure très dur (intervalles) » → « allure intervalles (très dur) »
///       « allure marathon (soutenu) »     → « allure marathon (soutenue) »
///       « allure à allure … », « à au seuil », « facile (tu peux parler) facile »
///  2. Data coach-science retirée (décision Sophie « retirer partout ») :
///       VDOT, lactatémie « mmol », « polarisé (LIT) », citations d'études (Mjolsnes,
///       Pfitzinger), « seuil lactique 1 », « base mitochondriale », « zone grise ».
///  3. Claims MDR + jargon cryptique :
///       « syndrome fémoro-patellaire (PFPS) », « razor curl », « skipping A-march »,
///       « bipodal ».
///
/// EXCLUS (volontaire) : `dose.free_text` (prescription terse, hors champ rédigé),
/// `match_key` (clé interne d'appariement adapter, non affichée), EN/ES (« track »,
/// « VDOT » y restent des termes/segments légitimes ou hors périmètre de ce chantier).
/// VMA / seuil / affûtage / aérobie / excentrique = GARDÉS (vocabulaire coureur rendu
/// tappable via le glossaire) — donc NON interdits ici.
final class NoUnclearRunningJargonTests: XCTestCase {

    private static let pattern = try! NSRegularExpression(
        pattern: [
            #"très dur \(intervalles\)"#,        // ordre cassé (la bonne forme « intervalles (très dur) » ne matche pas)
            #"marathon \(soutenu\)"#,            // « soutenue) » (la bonne forme) ne matche pas
            #"allure à allure"#,
            #"à au seuil"#,
            #"facile \(tu peux parler\) facile"#,
            #"\bVDOT\b"#,
            #"mmol"#,
            #"\(LIT\)"#,
            #"Mjolsnes"#,
            #"Pfitzinger"#,
            #"\bPFPS\b"#,
            #"fémoro-patellaire"#,
            #"seuil lactique 1"#,
            #"base mitochondriale"#,
            #"zone grise"#,
            #"razor curl"#,
            #"skipping A-march"#,
            #"\bbipodal"#,
        ].joined(separator: "|"),
        options: [.caseInsensitive]
    )

    private func offenders(in text: String) -> [String] {
        let range = NSRange(text.startIndex..., in: text)
        return Self.pattern.matches(in: text, range: range).compactMap {
            Range($0.range, in: text).map { String(text[$0]) }
        }
    }

    func testNoUnclearJargonInRunningDisplayedFR() async throws {
        let templates = try await TemplateLoader.loadAll()
        guard templates.count >= 30 else { throw XCTSkip("bundle non peuplé (\(templates.count))") }
        let running = templates.filter { $0.sport == .running }
        XCTAssertFalse(running.isEmpty, "aucun template running chargé")

        var failures: [String] = []
        func scan(_ field: String, _ value: String?, _ id: String) {
            guard let value else { return }
            let hits = offenders(in: value)
            if !hits.isEmpty {
                failures.append("[\(id)] \(field): \(Set(hits).sorted()) — « \(value.prefix(70))… »")
            }
        }

        for t in running {
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
            "Jargon/artefact running non corrigé dans \(failures.count) champ(s) FR affiché(s) :\n"
                + failures.prefix(40).joined(separator: "\n")
        )
    }
}
