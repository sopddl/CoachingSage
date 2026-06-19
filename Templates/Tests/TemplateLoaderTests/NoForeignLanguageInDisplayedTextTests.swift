import XCTest
@testable import TemplateLoader
import TemplateModel

/// Filet de régression — chantier « fuites cross-langue » (2026-06-16, bucket A).
///
/// Verrouille l'invariant : aucun contenu d'une AUTRE langue ne fuit dans un champ
/// AFFICHÉ. Découvert après la passe #3 vulgarisation (édition main multi-langue
/// bâclée) : warmups cycling « X min muy fácil » en FR+EN, « SEMANA LIGERA » en
/// FR+EN, « Semaine allégée » (français) dans des champs `.en`, « resistencia alta »
/// en EN. Tout resynchronisé (FR « très facile »/« Semaine allégée », EN « very easy »/
/// « Easy week », ES canonique « Semana ligera »).
///
/// Périmètre = champs RENDUS (cf. `NoRawJargonInDisplayedTextTests`). Ne couvre
/// QUE l'invariant du bucket A : pas d'espagnol en FR/EN, pas du français
/// « semaine allégée »/« très facile » en EN. L'anglais résiduel en FR
/// (restorative/breath-led…) relève du chantier vulgarisation (bucket B) et n'est
/// volontairement PAS asserté ici.
final class NoForeignLanguageInDisplayedTextTests: XCTestCase {

    /// Marqueurs espagnols interdits en FR et EN affichés.
    private static let spanish = try! NSRegularExpression(
        pattern: [
            #"\bmuy fácil\b"#, #"\bresistencia (fácil|alta|sostenida)\b"#,
            #"\bsemana (ligera|suave|de descarga)\b"#, #"\bpuedes hablar\b"#,
        ].joined(separator: "|"), options: [.caseInsensitive])

    /// Marqueurs français interdits en EN affiché (fuites passe #3).
    private static let frenchInEn = try! NSRegularExpression(
        pattern: [#"\bsemaine allégée\b"#, #"\btrès facile\b"#].joined(separator: "|"),
        options: [.caseInsensitive])

    /// Anglais résiduel interdit en ES affiché (passe « traduire tout » 2026-06-19 :
    /// `Tapering`/`Taper`→afinamiento, `Flow`→secuencia).
    private static let englishInEs = try! NSRegularExpression(
        pattern: [#"\btaper\w*\b"#, #"\bflow\b"#].joined(separator: "|"),
        options: [.caseInsensitive])

    /// Jargon anglais interdit en FR affiché (chantier vulgarisation bucket B). `tempo` reste
    /// volontairement gardé (vocabulaire). Le « semaine semaine » verrouille la non-régression
    /// du doublon créé/corrigé en bucket A.
    private static let englishInFr = try! NSRegularExpression(
        pattern: [
            #"\brestorative\b"#, #"\bflow\b"#, #"\bchild\b"#, #"\bwarm-?up\b"#, #"\bcool-?down\b"#,
            #"\bknees-down\b"#, #"\bbreath-led\b"#, #"\bfeeling\b"#, #"\bwall-only\b"#,
            #"\bgrip\b"#, #"\bcore\b"#, #"\beasy\b"#, #"\bsemaine\s+semaine\b"#,
        ].joined(separator: "|"), options: [.caseInsensitive])

    private func hits(_ re: NSRegularExpression, _ text: String) -> [String] {
        let r = NSRange(text.startIndex..., in: text)
        return re.matches(in: text, range: r).compactMap { Range($0.range, in: text).map { String(text[$0]) } }
    }

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
            // `duration`/`reps` (String plates) sont des CLÉS d'injection dose, pas du texte
            // directement rendu : la vue affiche le `dose` (déjà localisé, garde-fou
            // `NoFreeTextFRInDoseTests`). On ne les contrôle donc pas ici (ex. clé yoga
            // « 9 respirations breath-led » → dose « ...au rythme du souffle » rendu).
            for alt in e.alternatives { out.append(("exercise.alternative", alt)) }
        }
    }

    func testNoForeignLanguageLeakInDisplayedText() async throws {
        let templates = try await TemplateLoader.loadAll()
        guard templates.count >= 30 else { throw XCTSkip("bundle non peuplé (\(templates.count))") }

        var failures: [String] = []
        for t in templates {
            for (field, lt) in displayedTexts(t) {
                // Espagnol interdit en FR et EN.
                for (lang, value) in [("fr", lt.fr), ("en", lt.en)] {
                    guard let value else { continue }
                    let h = hits(Self.spanish, value)
                    if !h.isEmpty {
                        failures.append("[\(t.id)] \(field).\(lang) ES: \(Set(h).sorted()) — « \(value.prefix(70))… »")
                    }
                }
                // Français « semaine allégée »/« très facile » interdit en EN.
                if let en = lt.en {
                    let h = hits(Self.frenchInEn, en)
                    if !h.isEmpty {
                        failures.append("[\(t.id)] \(field).en FR: \(Set(h).sorted()) — « \(en.prefix(70))… »")
                    }
                }
                // Jargon anglais interdit en FR affiché (bucket B vulgarisation).
                let frVal = lt.fr
                let hFr = hits(Self.englishInFr, frVal)
                if !hFr.isEmpty {
                    failures.append("[\(t.id)] \(field).fr EN: \(Set(hFr).sorted()) — « \(frVal.prefix(70))… »")
                }
                // Anglais résiduel interdit en ES affiché (passe « traduire tout »).
                if let es = lt.es {
                    let hEs = hits(Self.englishInEs, es)
                    if !hEs.isEmpty {
                        failures.append("[\(t.id)] \(field).es EN: \(Set(hEs).sorted()) — « \(es.prefix(70))… »")
                    }
                }
            }
        }
        XCTAssertTrue(
            failures.isEmpty,
            "Fuite cross-langue dans \(failures.count) champ(s) affiché(s) :\n" + failures.prefix(40).joined(separator: "\n"))
    }
}
