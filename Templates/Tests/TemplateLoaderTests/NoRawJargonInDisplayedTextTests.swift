import XCTest
@testable import TemplateLoader
import TemplateModel

/// Filet de régression revue qualité #3 (vulgarisation jargon, 2026-06-16).
///
/// Politique (validée Sophie) : le jargon anglais d'entraînement ne doit pas
/// subsister dans le texte AFFICHÉ en FR/ES — on vulgarise dans la langue cible
/// (« cutback »/« deload » → « semaine allégée »/« semana ligera » ; « Down Dog »
/// → « Chien tête en bas »). L'EN n'est PAS vérifié : ces termes y sont légitimes.
///
/// Périmètre = STRICTEMENT les champs rendus à l'écran (cf. re-scope #3) :
/// `name` programme (nav title), `week.theme`/`week.goal` (AdaptedProgramView),
/// `session`/`variant` name/warmup/cooldown, `exercise` name/notes/duration,
/// `alternative` name/notes. Volontairement HORS périmètre (non rendus —
/// `ProgramAdapter` les vide, cf NoRawZoneCodesTests) : `safetyNotes`, `summary`,
/// `defaultObjective`, `assumedProfile`, `progressionLogic`. Le jargon doctrinal
/// (EMOM/Tabata/myélinisation…) y reste et c'est intentionnel.
///
/// Conservés volontairement (NON interdits ici) : noms de poses sanskrit (avec
/// glose FR), formats d'intervalle « 30/60 », « VO2max » (labels concis décidés
/// gardés), « AMRAP » (glosé « max de reps » mais le terme reste).
final class NoRawJargonInDisplayedTextTests: XCTestCase {

    /// Jargon anglais interdit dans le texte affiché FR/ES.
    private static let pattern = try! NSRegularExpression(
        pattern: [
            #"\bcutback\b"#,
            #"\bdeload\b"#,
            #"Down\s?Dog"#,
            #"Downward Dog"#,
        ].joined(separator: "|"),
        options: [.caseInsensitive]
    )

    private func offenders(in text: String) -> [String] {
        let range = NSRange(text.startIndex..., in: text)
        return Self.pattern.matches(in: text, range: range).compactMap {
            Range($0.range, in: text).map { String(text[$0]) }
        }
    }

    /// Champs AFFICHÉS (incl. variantes de séance indoor/outdoor).
    private func displayedTexts(_ t: ProgramTemplate) -> [(field: String, text: LocalizedText)] {
        var out: [(String, LocalizedText)] = [("name", t.name)]
        for w in t.weeks {
            out.append(("week.theme", w.theme))
            out.append(("week.goal", w.goal))
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
            if let d = e.duration { out.append(("exercise.duration", LocalizedText(fr: d))) }
            for alt in e.alternatives { out.append(("exercise.alternative", alt)) }
        }
    }

    func testNoRawJargonInDisplayedFRandES() async throws {
        let templates = try await TemplateLoader.loadAll()
        guard templates.count >= 30 else { throw XCTSkip("bundle non peuplé (\(templates.count))") }

        var failures: [String] = []
        for t in templates {
            for (field, lt) in displayedTexts(t) {
                // EN volontairement exclu : jargon anglais légitime dans la version EN.
                for (lang, value) in [("fr", lt.fr), ("es", lt.es)] {
                    guard let value else { continue }
                    let hits = offenders(in: value)
                    if !hits.isEmpty {
                        failures.append("[\(t.id)] \(field).\(lang): \(Set(hits).sorted()) — « \(value.prefix(80))… »")
                    }
                }
            }
        }
        XCTAssertTrue(
            failures.isEmpty,
            "Jargon anglais résiduel dans \(failures.count) champ(s) affiché(s) FR/ES :\n" + failures.prefix(40).joined(separator: "\n")
        )
    }
}
