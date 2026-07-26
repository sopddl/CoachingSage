import XCTest
@testable import TemplateLoader
import TemplateModel

/// Filet de régression — chantier compréhensibilité tennis (2026-06-25, décisions Sophie).
///
/// Tennis n'avait pas de citations d'auteurs/orgs : tout le travail est MDR. Verrouille,
/// sur le texte AFFICHÉ **FR** des séances tennis (name / warmup / cooldown / notes /
/// alternatives, variantes incluses), l'absence du cadrage « prévention / préventif »
/// (gêne coude, inconfort épaule, coiffe des rotateurs) — reformulé en « renforcement »
/// neutre, l'anatomie (coude, épaule, coiffe) restant comme cible d'entraînement.
///
/// EXCLUS / GARDÉS : vocabulaire (slice, topspin/lifté, kick serve, split-step, footwork,
/// drill) ; % de dose/perf (volume -33 %, % réussite, % FCmax) ; « échelle d'agilité
/// obligatoire (en option) » (matériel) ; `progression_logic`/`safety_notes` (non affichés).
/// EN/ES : reformulation MDR = suivi (ce chantier traite le FR, locale primaire).
final class NoUnclearTennisJargonTests: XCTestCase {

    // FR + EN + ES (la passe EN/ES 2026-06-25 a aussi reformulé le cadrage « prévention »).
    private static let pattern = try! NSRegularExpression(
        pattern: #"prévention|préventif|préventive|prevention|preventive|prevención|preventiv|\bMujika\b"#,
        options: [.caseInsensitive])

    private func hit(_ loc: LocalizedText?) -> Bool {
        guard let loc else { return false }
        for v in [loc.fr, loc.en, loc.es] {
            guard let v else { continue }
            if Self.pattern.firstMatch(in: v, range: NSRange(v.startIndex..., in: v)) != nil { return true }
        }
        return false
    }

    func testNoMDRFramingInTennisDisplayedFR() async throws {
        let templates = try await TemplateLoader.loadAll()
        guard templates.count >= 30 else { throw XCTSkip("bundle non peuplé (\(templates.count))") }
        let tennis = templates.filter { $0.sport == .tennis }
        XCTAssertFalse(tennis.isEmpty, "aucun template tennis chargé")

        var failures: [String] = []
        func scan(_ field: String, _ loc: LocalizedText?, _ id: String) {
            if hit(loc) { failures.append("[\(id)] \(field): « \((loc?.fr ?? "").prefix(80))… »") }
        }
        for t in tennis {
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
        XCTAssertTrue(failures.isEmpty,
            "Cadrage MDR « prévention » tennis (FR) non corrigé dans \(failures.count) champ(s) :\n"
                + failures.prefix(40).joined(separator: "\n"))
    }

    // MARK: - Audit contenu tennis (2026-07-26)

    /// P1 : "icky shuffle" (drill agilité canonique, anglicisme gardé — comme split-step/
    /// kick serve) doit toujours porter sa glose FR/ES (« pas chassés latéraux »/« pasos
    /// laterales ») quand il apparaît en texte affiché, pas juste dans `name` de l'exercice.
    /// Avant fix : glosé dans `name` mais laissé nu dans `notes` (dès le niveau beginner).
    func testIckyShuffleAlwaysGlossedInFRAndES() async throws {
        let templates = try await TemplateLoader.loadAll()
        guard templates.count >= 30 else { throw XCTSkip("bundle non peuplé (\(templates.count))") }
        let tennis = templates.filter { $0.sport == .tennis }
        XCTAssertFalse(tennis.isEmpty, "aucun template tennis chargé")

        func isGlossed(_ text: String) -> Bool {
            let low = text.lowercased()
            return low.contains("pas chass") || low.contains("pas latér")
                || low.contains("pasos latera") || low.contains("paso latera")
        }

        var failures: [String] = []
        func scan(_ field: String, _ loc: LocalizedText?, _ id: String) {
            guard let loc else { return }
            for (lang, value) in [("fr", loc.fr), ("es", loc.es)] {
                guard let value, value.lowercased().contains("icky") else { continue }
                if !isGlossed(value) {
                    failures.append("[\(id)] \(field).\(lang): « \(value.prefix(100))… »")
                }
            }
        }

        for t in tennis {
            for w in t.weeks {
                for s in w.sessions {
                    scan("session.name", s.name, t.id)
                    var exos = s.exercises
                    for v in s.variants ?? [] {
                        scan("variant.name", v.name, t.id)
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
        XCTAssertTrue(failures.isEmpty,
            "« icky shuffle »/« icky » non glosé (FR/ES) dans \(failures.count) champ(s) :\n"
                + failures.prefix(40).joined(separator: "\n"))
    }

    /// P2 : une seule graphie correcte pour « médecine-ball » en FR (accentuée,
    /// tiret) — 3 graphies coexistaient (medecine-ball / Medecine-ball / médecine-ball).
    func testMedecineBallSingleCorrectSpellingInFR() async throws {
        let templates = try await TemplateLoader.loadAll()
        guard templates.count >= 30 else { throw XCTSkip("bundle non peuplé (\(templates.count))") }
        let tennis = templates.filter { $0.sport == .tennis }
        XCTAssertFalse(tennis.isEmpty, "aucun template tennis chargé")

        let badSpelling = try! NSRegularExpression(
            pattern: #"\bmedecine[- ]ball\b|\bmédecine ball\b"#, options: [.caseInsensitive])

        func hasBadSpelling(_ text: String) -> Bool {
            badSpelling.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) != nil
        }

        var failures: [String] = []
        func scan(_ field: String, _ loc: LocalizedText?, _ id: String) {
            guard let loc, hasBadSpelling(loc.fr) else { return }
            failures.append("[\(id)] \(field).fr: « \(loc.fr.prefix(100))… »")
        }

        for t in tennis {
            for w in t.weeks {
                for s in w.sessions {
                    scan("session.name", s.name, t.id)
                    var exos = s.exercises
                    for v in s.variants ?? [] {
                        scan("variant.name", v.name, t.id)
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
        XCTAssertTrue(failures.isEmpty,
            "Graphie « medecine-ball » (sans accent) non corrigée dans \(failures.count) champ(s) :\n"
                + failures.prefix(40).joined(separator: "\n"))
    }

    /// P1 : `tennis-regular-match-prep-12sem` déclare dans son propre `safety_notes`
    /// (« INTENSITÉ ») « Maximum 1 séance / sem en RPE 8-9 dès W5 ». Le contenu réel
    /// contredisait cette règle W5/W6/W9 (séance tactique jour 3 + finisher cardio
    /// jour 6 tous deux à RPE 8-9). Fix : finisher jour 6 redescendu à RPE 7-8 (aligné
    /// sur le pattern déjà présent W7/W10 — circuit Kovacs en RPE 7-8 les semaines où
    /// le jour 3 porte déjà le quota RPE 8-9). Scope volontairement limité à
    /// `regular` : `competitive` n'a pas cette règle « max 1/sem » dans sa doctrine
    /// (fréquence haute intensité plus élevée assumée à ce niveau).
    func testRegularNeverExceedsOneRPE89SessionPerWeekFromW5() async throws {
        let templates = try await TemplateLoader.loadAll()
        guard templates.count >= 30 else { throw XCTSkip("bundle non peuplé (\(templates.count))") }
        guard let template = templates.first(where: { $0.id == "tennis-regular-match-prep-12sem" }) else {
            throw XCTSkip("template tennis-regular-match-prep-12sem absent du bundle")
        }

        var failures: [String] = []
        for w in template.weeks where w.weekNumber >= 5 {
            var daysWithRPE89: Set<Int> = []
            for s in w.sessions {
                let exos = s.exercises + (s.variants ?? []).flatMap { $0.exercises }
                if exos.contains(where: { $0.targetZone?.contains("RPE 8-9") == true }) {
                    daysWithRPE89.insert(s.day)
                }
            }
            if daysWithRPE89.count > 1 {
                failures.append("semaine \(w.weekNumber) : \(daysWithRPE89.count) séances RPE 8-9 (jours \(daysWithRPE89.sorted())), garde-fou = max 1/sem")
            }
        }
        XCTAssertTrue(failures.isEmpty,
            "Garde-fou « max 1 séance RPE 8-9/sem » (dès W5) non respecté :\n" + failures.joined(separator: "\n"))
    }
}
