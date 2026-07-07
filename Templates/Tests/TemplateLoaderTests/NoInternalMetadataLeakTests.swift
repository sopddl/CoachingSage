import XCTest
@testable import TemplateLoader
import TemplateModel

/// Filet de régression — passe qualité "vulgarisation par niveau" (2026-07-06).
///
/// Audit sourcé sur les 10 sports (40 templates) a trouvé des fuites de
/// métadonnées de conception interne dans le texte AFFICHÉ à l'utilisateur :
/// - le slug de niveau brut (`beginner`/`recreational`/`regular`/`competitive`,
///   valeur de `ProgramTemplate.level`) utilisé comme un mot français dans une
///   phrase (ex. « refait recreational +1 charge », « plan Hatha recreational »)
///   au lieu d'être traduit (débutant/intermédiaire/confirmé/compétiteur).
/// - un nom de champ JSON interne (`safety_notes`, `default_objective`) recopié
///   tel quel dans une note affichée, parfois entre backticks Markdown qui ne
///   rendent rien en UI (« Lecture de la grille RPE en `safety_notes` »).
/// - une fuite pure de conception (référence à un prompt de génération, tag de
///   matching moteur, prénom de la développeuse) sans aucun sens pour
///   l'utilisateur (« master prompt §2.6 », « Tags : pente plate... », « selon
///   planning Sophie »).
///
/// Périmètre = STRICTEMENT les champs rendus à l'écran (même liste que
/// `NoRawJargonInDisplayedTextTests`) : `name`, `week.theme`/`week.goal`,
/// `session`/`variant` name/warmup/cooldown, `exercise` name/notes/duration,
/// `alternative` name/notes. `safetyNotes`/`summary`/`defaultObjective`/
/// `assumedProfile`/`progressionLogic` sont volontairement HORS périmètre
/// (jamais affichés — `ProgramAdapter` les vide).
final class NoInternalMetadataLeakTests: XCTestCase {

    /// Slug de niveau brut utilisé comme mot dans une phrase (pas juste la
    /// valeur du champ `level`, qui n'est jamais dans ces champs texte).
    private static let levelSlugPattern = try! NSRegularExpression(
        pattern: #"\b(beginner|recreational|regular|competitive)\b"#,
        options: [.caseInsensitive]
    )

    /// Fuites de conception interne : nom de champ JSON, référence prompt,
    /// tag de matching, prénom développeuse.
    private static let designLeakPattern = try! NSRegularExpression(
        pattern: [
            #"safety_notes"#,
            #"default_objective"#,
            #"progression_logic"#,
            #"assumed_profile"#,
            #"master prompt"#,
            #"\bTags?\s*:"#,
            #"\bSophie\b"#,
        ].joined(separator: "|"),
        options: [.caseInsensitive]
    )

    private func offenders(_ pattern: NSRegularExpression, in text: String) -> [String] {
        let range = NSRange(text.startIndex..., in: text)
        return pattern.matches(in: text, range: range).compactMap {
            Range($0.range, in: text).map { String(text[$0]) }
        }
    }

    /// Champs AFFICHÉS (incl. variantes de séance indoor/outdoor) — copie du
    /// même périmètre que `NoRawJargonInDisplayedTextTests.displayedTexts`.
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

    func testNoRawLevelSlugInDisplayedText() async throws {
        let templates = try await TemplateLoader.loadAll()
        guard templates.count >= 30 else { throw XCTSkip("bundle non peuplé (\(templates.count))") }

        // FR uniquement : en anglais "regular"/"beginner"/"competitive" sont des
        // mots légitimes (registre = question de ton, pas une fuite littérale) ;
        // en espagnol "regular" est un mot natif indépendant ("régulier") — sujet
        // à faux positifs. Le bug identifié par l'audit est spécifiquement le
        // slug NON traduit dans une phrase FR.
        var failures: [String] = []
        for t in templates {
            for (field, lt) in displayedTexts(t) {
                let value = lt.fr
                let hits = offenders(Self.levelSlugPattern, in: value)
                if !hits.isEmpty {
                    failures.append("[\(t.id)] \(field).fr: \(Set(hits).sorted()) — « \(value.prefix(90))… »")
                }
            }
        }

        XCTAssertTrue(failures.isEmpty, """
        Slug de niveau brut (beginner/recreational/regular/competitive) trouvé \
        comme mot dans un champ affiché — traduire (débutant/intermédiaire/\
        confirmé/compétiteur) au lieu de recopier l'identifiant interne :
        \(failures.joined(separator: "\n"))
        """)
    }

    func testNoDesignArtifactLeakInDisplayedText() async throws {
        let templates = try await TemplateLoader.loadAll()
        guard templates.count >= 30 else { throw XCTSkip("bundle non peuplé (\(templates.count))") }

        var failures: [String] = []
        for t in templates {
            for (field, lt) in displayedTexts(t) {
                for (lang, value) in [("fr", lt.fr), ("en", lt.en), ("es", lt.es)] {
                    guard let value else { continue }
                    let hits = offenders(Self.designLeakPattern, in: value)
                    if !hits.isEmpty {
                        failures.append("[\(t.id)] \(field).\(lang): \(Set(hits).sorted()) — « \(value.prefix(90))… »")
                    }
                }
            }
        }

        XCTAssertTrue(failures.isEmpty, """
        Fuite de métadonnée de conception interne dans un champ affiché (nom de \
        champ JSON, référence prompt, tag de matching, prénom développeuse) :
        \(failures.joined(separator: "\n"))
        """)
    }
}
