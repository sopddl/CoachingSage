import XCTest
@testable import TemplateLoader
import TemplateModel

/// Filet de régression — chantier « anglais résiduel FR » (2026-06-17).
///
/// Verrouille l'invariant : aucun **anglais résiduel non voulu** ne subsiste dans
/// un champ FR AFFICHÉ. Suite directe du chantier vulgarisation / doublons : une
/// passe a francisé ~1300 champs (`banded`→avec élastique, `seated`→assis,
/// `calf`→mollet, `pace`→allure, `pattern`→schéma de mouvement, `build`→
/// développement/montée en charge, `split Upper/Lower`→Programme Haut/Bas,
/// `work`/`rest` HIIT→effort/récup, glose `(shadow)`/`(catch)` retirée, `taper`→
/// affûtage, `bridge`→pont, `forehand`/`backhand`→coup droit/revers, `day hike`→
/// sortie à la journée, etc.). Décisions fork ratifiées Sophie (2026-06-17) :
/// build/split/shadow/catch tous francisés.
///
/// Périmètre = champs RENDUS (cf. `displayedTexts`, identique à
/// `NoForeignLanguageInDisplayedTextTests`). `safety_notes` (prose S&C dense :
/// taper/cross-training/saddle sores…) reste un sous-chantier séparé, hors filet.
///
/// Anglicismes GARDÉS (politique nommage règle 1 : noms canoniques de salle /
/// protocoles / marques sans équivalent FR dominant) → whitelist `allowed`.
final class NoResidualEnglishInDisplayedFRTests: XCTestCase {

    /// Termes anglais résiduels INTERDITS en FR affiché (mots bornés, insensible casse).
    private static let forbidden = try! NSRegularExpression(
        pattern: [
            #"\bglutes?\b"#, #"\bseated\b"#, #"\bcalf\b"#, #"\bcalves\b"#, #"\bbanded\b"#,
            #"\bswim\b"#, #"\bbike\b"#, #"\bpace\b"#, #"\bpacing\b"#, #"\bpatterns?\b"#,
            #"\bbuild\b"#, #"\bupper\b"#, #"\blower\b"#, #"\bworking\b"#, #"\bback-off\b"#,
            #"\bfull-load\b"#, #"\bstretch(es)?\b"#, #"\bfoam\b"#, #"\bshadow\b"#, #"\bholds?\b"#,
            #"\bday hikes?\b"#, #"\btaper\w*\b"#, #"\bbridges?\b"#, #"\bforehand\b"#,
            #"\bbackhand\b"#, #"\bhigh volume\b"#,
            // — passe « traduire tout » 2026-06-19 (reps→répétitions, sets→séries,
            //   rowing→tirage/rameur, drills→exercices/éducatifs, plyo→pliométrie) —
            #"\breps?\b"#, #"\bsets?\b"#, #"\browing\b"#, #"\bdrills?\b"#, #"\bplyo\b"#,
            // — passe « anglais large » 2026-06-19 (prose anglaise + exos génériques
            //   francisés ; vertical jump→saut vertical, skater jumps→sauts de
            //   patineur, race week→semaine de course, S&C→renforcement physique) —
            #"\bvertical jump\b"#, #"\bskater jumps?\b"#, #"\brace week\b"#, #"S&C"#,
            // — passe « warmup jargon EN→FR » 2026-06-21 (jargon mobilité/échauffement
            //   muscu + HIIT resté anglais : rower→rameur, wall slides→glissements au
            //   mur, lateral walks→pas latéraux, thoracic rotation→rotation thoracique,
            //   ankle→cheville, gloses (back squat)/(knee-to-wall) retirées) —
            #"\brower\b"#, #"\bwall slides\b"#, #"\blateral walks\b"#,
            #"\bthoracic rotation\b"#, #"\bdislocate\b"#, #"\bback squat\b"#,
            #"\bknee-to-wall\b"#, #"\bankle\b"#,
        ].joined(separator: "|"), options: [.caseInsensitive])

    /// Phrases tolérées : noms canoniques d'exos / méthodes / matériel / marques
    /// (règle 1) qui contiennent un terme interdit en sous-chaîne. Comparées en
    /// minuscules ; un match du `forbidden` couvert par une de ces plages est ignoré.
    private static let allowed: [String] = [
        "split-step", "swim-smooth", "swim smooth", "bike fit", "assault bike",
        "world's greatest stretch", "couch stretch", "sleeper stretch", "thread the needle",
        "glute-ham", "glute ham", "uphill athlete", "aerobic threshold", "long swim",
        "balle de set", "balles de set", // « set » = set point au tennis (manche gardée FR)
    ]

    private func displayedTexts(_ t: ProgramTemplate) -> [(String, LocalizedText)] {
        var out: [(String, LocalizedText)] = [("name", t.name)]
        for w in t.weeks {
            out.append(("week.theme", w.theme)); out.append(("week.goal", w.goal))
            for s in w.sessions {
                out.append(("session.name", s.name))
                if let wu = s.warmup { out.append(("session.warmup", wu)) }
                if let cd = s.cooldown { out.append(("session.cooldown", cd)) }
                appendExercises(s.exercises, into: &out)
                for v in s.variants ?? [] {
                    out.append(("variant.name", v.name))
                    if let wu = v.warmup { out.append(("variant.warmup", wu)) }
                    if let cd = v.cooldown { out.append(("variant.cooldown", cd)) }
                    appendExercises(v.exercises, into: &out)
                }
            }
        }
        return out
    }

    private func appendExercises(_ ex: [TemplateExercise], into out: inout [(String, LocalizedText)]) {
        for e in ex {
            out.append(("exercise.name", e.name))
            if let n = e.notes { out.append(("exercise.notes", n)) }
            for alt in e.alternatives { out.append(("exercise.alternative", alt)) }
        }
    }

    /// Matches de `forbidden` dans `text`, SAUF ceux couverts par une phrase `allowed`.
    private func residualHits(_ text: String) -> [String] {
        let lower = text.lowercased()
        // Plages (en offset UTF-16, cohérent avec NSRange) couvertes par la whitelist.
        var allowedRanges: [NSRange] = []
        for phrase in Self.allowed {
            var searchStart = lower.startIndex
            while let r = lower.range(of: phrase, range: searchStart..<lower.endIndex) {
                allowedRanges.append(NSRange(r, in: lower))
                searchStart = r.upperBound
            }
        }
        let full = NSRange(text.startIndex..., in: text)
        return Self.forbidden.matches(in: text, range: full).compactMap { m -> String? in
            if allowedRanges.contains(where: { NSIntersectionRange($0, m.range).length == m.range.length }) {
                return nil // entièrement dans une phrase tolérée
            }
            return Range(m.range, in: text).map { String(text[$0]) }
        }
    }

    func testNoResidualEnglishInDisplayedFR() async throws {
        let templates = try await TemplateLoader.loadAll()
        guard templates.count >= 30 else { throw XCTSkip("bundle non peuplé (\(templates.count))") }

        var failures: [String] = []
        for t in templates {
            for (field, lt) in displayedTexts(t) {
                let hits = residualHits(lt.fr)
                if !hits.isEmpty {
                    failures.append("[\(t.id)] \(field).fr: \(Set(hits).sorted()) — « \(lt.fr.prefix(72))… »")
                }
            }
        }
        XCTAssertTrue(
            failures.isEmpty,
            "Anglais résiduel dans \(failures.count) champ(s) FR affiché(s) :\n"
                + failures.prefix(40).joined(separator: "\n"))
    }
}
