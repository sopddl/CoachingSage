import XCTest
@testable import TemplateLoader
import TemplateModel

/// Filet de régression — chantier « Vélo L2 / dé-lieu-isation des titres » (2026-06-19).
///
/// Décision Sophie (option A « strip symétrique ») : sur les programmes VÉLO, le lieu
/// (🏠 home-trainer / 🛣️ dehors) vit dans la PUCE de lieu, pas dans le titre de la
/// séance. On a donc retiré des `name` (séance native + variantes) tout marqueur de
/// lieu : « Home-trainer »/« Indoor trainer »/« Rodillo » (intérieur) et le mot
/// « Sortie »/« Salida »/« Tirada »/« ride » (sortie/extérieur). Ex. « Sortie longue —
/// 45 km » + variante « Home-trainer longue — 80 min » → « Longue — 45 km » /
/// « Longue — 80 min ».
///
/// Périmètre = `session.name` + `variant.name` des templates `cycling-*` UNIQUEMENT.
/// On ne touche PAS aux instructions (warmup/exos), où « home-trainer » reste légitime
/// (« règle la résistance du home-trainer »). « Sortie/Salida/Tirada » ne sont bannis
/// qu'en TÊTE de titre (le ES « salida de marcha » = départ de course, légitime
/// mid-titre).
final class NoLocationWordInCyclingSessionNamesTests: XCTestCase {

    /// Marqueurs de lieu interdits N'IMPORTE OÙ dans un titre (mot entier) : purement
    /// du lieu, jamais légitimes dans un titre de séance.
    private static let anywhere = try! NSRegularExpression(
        pattern: [
            #"\bhome-?trainer\b"#, #"\bindoor\b"#, #"\brodillo\b"#, #"\bride\b"#,
        ].joined(separator: "|"), options: [.caseInsensitive])

    /// Mots « sortie/extérieur » interdits en TÊTE de titre seulement (mid-titre peut
    /// être légitime : « salida de marcha » = départ de course).
    private static let leading = try! NSRegularExpression(
        pattern: #"^\s*(sortie|salida|tirada)\b"#, options: [.caseInsensitive])

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
}
