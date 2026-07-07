import XCTest
@testable import TemplateLoader
import TemplateModel

/// Filet de régression — chantier « Vélo L2 / dé-lieu-isation » (2026-06-19 titres,
/// 2026-06-20 contenu).
///
/// Décision Sophie : sur les programmes VÉLO, le lieu (🏠 home-trainer / 🛣️ dehors)
/// vit dans la PUCE de lieu, pas dans le texte. Deux passes :
///  1. TITRES (option A « strip symétrique ») : `session.name` + `variant.name` nettoyés
///     de « Home-trainer »/« Indoor »/« Rodillo » et « Sortie »/« Salida »/« Tirada »/
///     « ride ». Ex. « Sortie longue — 45 km » → « Longue — 45 km ».
///  2. CONTENU (option C, scope max) : noms d'exos, alternatives, notes, échauffements
///     et retours au calme dé-lieu-isés en préservant grammaire + sens coaching (via
///     workflow 12 agents → règles {old→new} → applier byte-exact). Ex. « Sortie
///     tranquille » → « Pédalage tranquille » ; « … sur home-trainer » retiré ;
///     « Sur home-trainer, X » → « X » ; « post-sortie » → « après l'effort ».
///
/// GARDES-FOUS (termes qui CONTIENNENT un marqueur mais ne désignent PAS le lieu —
/// volontairement conservés) : « sortie de selle » (danseuse), « rodillo de masaje »
/// (rouleau de massage), « pelotón de salida » (départ de course), « out of the
/// saddle », « fuera del sillín ».
final class NoLocationWordInCyclingSessionNamesTests: XCTestCase {

    /// Marqueurs de lieu interdits N'IMPORTE OÙ (mot entier) : purement du lieu.
    private static let anywhere = try! NSRegularExpression(
        pattern: [
            #"\bhome-?trainer\b"#, #"\bindoor\b"#, #"\brodillo\b"#, #"\bride\b"#,
        ].joined(separator: "|"), options: [.caseInsensitive])

    /// Mots « sortie/extérieur » interdits en TÊTE de titre seulement (mid-titre peut
    /// être légitime : « salida de marcha » = départ de course).
    private static let leading = try! NSRegularExpression(
        pattern: #"^\s*(sortie|salida|tirada)\b"#, options: [.caseInsensitive])

    /// Marqueurs interdits dans le CONTENU (prose incluse), mot entier. « sortie » et
    /// « salida » inclus : dé-lieu-isés partout sauf gardes-fous (scrubés avant test).
    private static let content = try! NSRegularExpression(
        pattern: [
            #"\bhome-?trainer\b"#, #"\bindoor\b"#, #"\brodillo\b"#, #"\btirada\b"#,
            #"\bride\b"#, #"\bsortie\b"#, #"\bsalida\b"#,
        ].joined(separator: "|"), options: [.caseInsensitive])

    /// Phrases légitimes (lowercased) retirées AVANT le scan contenu : elles contiennent
    /// un marqueur mais ne désignent pas le lieu.
    private static let guards = [
        "sortie de selle", "rodillo de masaje", "pelotón de salida", "peloton de salida",
        "out of the saddle", "fuera del sillín",
    ]

    private func hits(_ re: NSRegularExpression, _ text: String) -> [String] {
        let r = NSRange(text.startIndex..., in: text)
        return re.matches(in: text, range: r).compactMap { Range($0.range, in: text).map { String(text[$0]) } }
    }

    private func sessionNames(_ t: ProgramTemplate) -> [(String, LocalizedText)] {
        var out: [(String, LocalizedText)] = []
        for w in t.weeks {
            for s in w.sessions {
                out.append(("session.name", s.name))
                for v in s.variants ?? [] { out.append(("variant.name", v.name)) }
            }
        }
        return out
    }

    /// Tous les champs user-facing de CONTENU (hors titres) des séances + variantes.
    private func contentTexts(_ t: ProgramTemplate) -> [(String, LocalizedText)] {
        var out: [(String, LocalizedText)] = []
        func add(warmup: LocalizedText?, cooldown: LocalizedText?, exercises: [TemplateExercise]) {
            if let warmup { out.append(("warmup", warmup)) }
            if let cooldown { out.append(("cooldown", cooldown)) }
            for e in exercises {
                out.append(("exercise.name", e.name))
                if let n = e.notes { out.append(("exercise.notes", n)) }
                for a in e.alternatives { out.append(("exercise.alt", a)) }
            }
        }
        for w in t.weeks {
            for s in w.sessions {
                add(warmup: s.warmup, cooldown: s.cooldown, exercises: s.exercises)
                for v in s.variants ?? [] {
                    add(warmup: v.warmup, cooldown: v.cooldown, exercises: v.exercises)
                }
            }
        }
        return out
    }

    func testNoLocationWordInCyclingSessionNames() async throws {
        let templates = try await TemplateLoader.loadAll()
        guard templates.count >= 30 else { throw XCTSkip("bundle non peuplé (\(templates.count))") }

        var failures: [String] = []
        for t in templates where t.id.hasPrefix("cycling-") {
            for (field, lt) in sessionNames(t) {
                for (lang, value) in [("fr", lt.fr), ("en", lt.en), ("es", lt.es)] {
                    guard let value else { continue }
                    let h = hits(Self.anywhere, value) + hits(Self.leading, value)
                    if !h.isEmpty {
                        failures.append("[\(t.id)] \(field).\(lang) lieu: \(Set(h.map { $0.lowercased() }).sorted()) — « \(value) »")
                    }
                }
            }
        }
        XCTAssertTrue(
            failures.isEmpty,
            "Marqueur de lieu dans \(failures.count) titre(s) de séance vélo (dé-lieu-isation L2) :\n"
                + failures.prefix(40).joined(separator: "\n"))
    }

    func testNoLocationWordInCyclingExerciseContent() async throws {
        let templates = try await TemplateLoader.loadAll()
        guard templates.count >= 30 else { throw XCTSkip("bundle non peuplé (\(templates.count))") }

        var failures: [String] = []
        for t in templates where t.id.hasPrefix("cycling-") {
            for (field, lt) in contentTexts(t) {
                for (lang, value) in [("fr", lt.fr), ("en", lt.en), ("es", lt.es)] {
                    guard let value else { continue }
                    // Retire les phrases légitimes avant de chercher un marqueur résiduel.
                    var scrubbed = value.lowercased()
                    for g in Self.guards { scrubbed = scrubbed.replacingOccurrences(of: g, with: " ") }
                    let h = hits(Self.content, scrubbed)
                    if !h.isEmpty {
                        failures.append("[\(t.id)] \(field).\(lang) lieu: \(Set(h.map { $0.lowercased() }).sorted()) — « \(value.prefix(80))… »")
                    }
                }
            }
        }
        XCTAssertTrue(
            failures.isEmpty,
            "Marqueur de lieu dans \(failures.count) champ(s) de contenu vélo (dé-lieu-isation L2 scope C) :\n"
                + failures.prefix(40).joined(separator: "\n"))
    }
}
