import XCTest
@testable import TemplateLoader
import TemplateModel

/// Filet de régression revue qualité #1bis (2026-06-13) : aucun code coach brut
/// (zone/intensité/allure) ne doit subsister dans les champs USER-FACING des
/// templates bundlés. Les codes sont remplacés par une sensation FR/EN/ES
/// (cohérent avec `DosageFormatting.sensationLabel`, thème #1).
///
/// Hors périmètre (volontairement NON vérifiés ici) :
/// - `safetyNotes`, `summary`, `defaultObjective`, `assumedProfile`,
///   `progressionLogic` : non rendus à l'utilisateur (métadonnées / déjà nettoyés).
/// - métriques précises `%1RM`, `FCmax`, `VO2max`, `VMA`, `PMA` : différées au pass #3.
final class NoRawZoneCodesTests: XCTestCase {

    /// Codes coach bruts interdits dans le texte affiché.
    private static let pattern: NSRegularExpression = {
        let p = [
            #"FTP[-\s]?Z[1-7]"#,                 // FTP-Z1..7
            #"(?<![A-Za-z])Z\s?[1-7]\b"#,        // Z1..7 nu (pas EZ-bar)
            #"\bDaniels[-\s]?[EMTIR]\b"#,         // Daniels-E/M/T/I/R
            #"\bEN[1-3]\b"#,                     // natation EN1..3
            #"\bSP[1-3]\b"#,                     // natation SP1..3
            #"\bCSS\+?\b"#,                      // natation CSS / CSS+
            #"Sweet[-\s]?Spot"#,                 // vélo Sweet-Spot
            #"@\s?(?:HMP|CSS|MP|5K|10K|FTP)\b"#, // allures @…
            #"\bREC\b"#,                          // natation REC
        ].joined(separator: "|")
        return try! NSRegularExpression(pattern: p)
    }()

    private func offenders(in text: String) -> [String] {
        let range = NSRange(text.startIndex..., in: text)
        return Self.pattern.matches(in: text, range: range).compactMap {
            Range($0.range, in: text).map { String(text[$0]) }
        }
    }

    /// Champs USER-FACING d'un template (incl. variantes de séance indoor/outdoor).
    private func userFacingTexts(_ t: ProgramTemplate) -> [(field: String, text: LocalizedText)] {
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

    func testNoRawZoneCodesInUserFacingFields() async throws {
        let templates = try await TemplateLoader.loadAll()
        guard templates.count >= 30 else { throw XCTSkip("bundle non peuplé (\(templates.count))") }

        var failures: [String] = []
        for t in templates {
            for (field, lt) in userFacingTexts(t) {
                for (lang, value) in [("fr", lt.fr), ("en", lt.en), ("es", lt.es)] {
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
            "Codes zone bruts résiduels dans \(failures.count) champ(s) user-facing :\n" + failures.prefix(40).joined(separator: "\n")
        )
    }
}
