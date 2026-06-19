import XCTest
@testable import TemplateLoader
import TemplateModel

/// Filet de régression — sous-chantier « anglais résiduel FR : safety_notes » (2026-06-18).
///
/// Verrouille l'invariant : aucun **anglais résiduel non voulu** ne subsiste dans le
/// champ `safety_notes.fr`. Ce champ n'est PAS rendu verbatim dans l'UI — il part dans
/// le `template_json` envoyé à l'edge function Léon (input LLM, influence le contexte
/// FR de l'adaptation). Décision Sophie (2026-06-18) : le franciser quand même, traduire
/// AU MAX (règle 2), ne garder que les noms canoniques / protocoles / marques.
///
/// La passe (10 agents/sport) a francisé ~150 occurrences sur 33/40 templates :
/// single-leg→unilatéral, cross-training→entraînement croisé, RDL→soulevé de terre
/// roumain, OHP→développé épaules, saddle sores→douleurs de selle, hot foot→pieds qui
/// chauffent, overreaching→surmenage, bike→vélo, calf→mollet, pace→allure, glute→
/// fessier, bridge→pont, patterns→schémas, build→montée en charge, etc.
///
/// Périmètre = `safety_notes.fr` UNIQUEMENT (les champs RENDUS sont couverts par
/// `NoResidualEnglishInDisplayedFRTests`). La blocklist est volontairement alignée sur
/// celle des champs rendus + les termes S&C propres à `safety_notes` traités ici. Les
/// termes de salle non ciblés par la politique établie (reps/sets/drills/core/rowing/
/// plyo) restent tolérés ici aussi, par cohérence avec le filet des champs rendus.
///
/// Anglicismes GARDÉS (règle 1) → whitelist `allowed` (bike fit, Uphill Athlete…).
final class NoResidualEnglishInSafetyNotesFRTests: XCTestCase {

    /// Termes anglais résiduels INTERDITS dans `safety_notes.fr` (mots bornés, insensible casse).
    /// = blocklist des champs rendus + termes S&C francisés par ce sous-chantier.
    private static let forbidden = try! NSRegularExpression(
        pattern: [
            // — alignée sur NoResidualEnglishInDisplayedFRTests —
            #"\bglutes?\b"#, #"\bseated\b"#, #"\bcalf\b"#, #"\bcalves\b"#, #"\bbanded\b"#,
            #"\bswim\b"#, #"\bbike\b"#, #"\bpace\b"#, #"\bpacing\b"#, #"\bpatterns?\b"#,
            #"\bbuild\b"#, #"\bupper\b"#, #"\blower\b"#, #"\bworking\b"#, #"\bback-off\b"#,
            #"\bfull-load\b"#, #"\bstretch(es)?\b"#, #"\bfoam\b"#, #"\bshadow\b"#, #"\bholds?\b"#,
            #"\bday hikes?\b"#, #"\btaper\w*\b"#, #"\bbridges?\b"#, #"\bforehand\b"#,
            #"\bbackhand\b"#, #"\bhigh volume\b"#,
            // — termes S&C propres à safety_notes (traités ce sous-chantier) —
            #"\bcross-training\b"#, #"\bsaddle sores?\b"#, #"\boverreaching\b"#,
            #"\bsingle-leg\b"#, #"\bRDL\b"#, #"\bOHP\b"#, #"\bhot foot\b"#,
            // — passe « traduire tout » 2026-06-19 —
            #"\breps?\b"#, #"\bsets?\b"#, #"\browing\b"#, #"\bdrills?\b"#, #"\bplyo\b"#,
            #"\bcore\b"#, #"\bcool-?down\b"#,
        ].joined(separator: "|"), options: [.caseInsensitive])

    /// Phrases tolérées : noms canoniques d'exos / méthodes / matériel / marques (règle 1)
    /// qui contiennent un terme interdit en sous-chaîne. Comparées en minuscules.
    private static let allowed: [String] = [
        "split-step", "swim-smooth", "swim smooth", "bike fit", "assault bike",
        "world's greatest stretch", "couch stretch", "sleeper stretch", "thread the needle",
        "glute-ham", "glute ham", "uphill athlete", "aerobic threshold", "long swim",
        "balle de set", "balles de set",
    ]

    /// Matches de `forbidden` dans `text`, SAUF ceux couverts par une phrase `allowed`.
    private func residualHits(_ text: String) -> [String] {
        let lower = text.lowercased()
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

    func testNoResidualEnglishInSafetyNotesFR() async throws {
        let templates = try await TemplateLoader.loadAll()
        guard templates.count >= 30 else { throw XCTSkip("bundle non peuplé (\(templates.count))") }

        var failures: [String] = []
        for t in templates {
            let hits = residualHits(t.safetyNotes.fr)
            if !hits.isEmpty {
                failures.append("[\(t.id)] safety_notes.fr: \(Set(hits).sorted())")
            }
        }
        XCTAssertTrue(
            failures.isEmpty,
            "Anglais résiduel dans \(failures.count) safety_notes.fr :\n"
                + failures.prefix(40).joined(separator: "\n"))
    }
}
