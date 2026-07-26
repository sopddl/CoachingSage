import XCTest
@testable import TemplateLoader
import TemplateModel

/// Filet de régression — chantier « doublons FR » (2026-06-17).
///
/// Verrouille l'invariant : aucun mot consécutif dupliqué (« allure allure seuil »,
/// « ritmo ritmo umbral », « série série », « pace pace », « tempo tempo »,
/// « côté côté », « en en el umbral »…) dans un champ AFFICHÉ, dans les 3 langues.
///
/// Origine : séquelle de la passe vulgarisation/trio (substitution mécanique
/// `set→série`, `pace→allure`…) appliquée sur un texte où le mot cible était déjà
/// adjacent → doublon non rattrapé par le patch D (qui ne ciblait que des doublons
/// connus). 193 occurrences corrigées / 23 templates.
///
/// Périmètre = champs RENDUS (cf. `NoForeignLanguageInDisplayedTextTests`).
/// Le détecteur exclut nativement les faux positifs « composé composé » à trait
/// d'union ou flèche (`Low-step step-up`, `Single-leg leg`, `swim→bike bike-to-run`,
/// `MULTI-DAY DAY`, `one one-sided`) via les lookarounds `(?<![\w-])…(?![\w-])`.
///
/// Durci 2026-07-26 (audit running) : un second motif attrape les doublons de GROUPE
/// de 2 mots (« allure marathon allure marathon »), invisibles au motif mot-unique
/// (la backreference `\1` ne portait que sur un seul token) — même origine mécanique
/// (find-replace de vulgarisation appliqué sur un texte où la cible était déjà là).
final class NoDuplicatedWordsInDisplayedTextTests: XCTestCase {

    /// `mot mot` consécutif (≥2 lettres), anti-mots-composés (trait d'union/flèche).
    /// Backreference `\1` + caseInsensitive → attrape « Allure allure » (casse mixte).
    private static let duplicate = try! NSRegularExpression(
        pattern: #"(?<![\w\-])(\w{2,})\s+\1(?![\w\-])"#,
        options: [.caseInsensitive])

    /// `mot1 mot2 mot1 mot2` consécutif (chaque mot ≥2 lettres) — doublon de groupe de
    /// 2 mots, ex. « allure marathon allure marathon ».
    private static let duplicatePhrase = try! NSRegularExpression(
        pattern: #"(?<![\w\-])(\w{2,}\s+\w{2,})\s+\1(?![\w\-])"#,
        options: [.caseInsensitive])

    /// Mots dont la répétition consécutive est tolérée (rare, légitime) — s'applique
    /// UNIQUEMENT au détecteur mot-unique (`duplicate`). Bug trouvé 2026-07-26 (review) :
    /// appliqué aussi à `duplicatePhrase`, il blanchissait à tort tout doublon de groupe
    /// commençant par un mot whitelisté (« très facile très facile » raté car « très »
    /// est whitelisté comme intensificateur mot-unique légitime « très très »).
    private static let whitelist: Set<String> = ["non", "oui", "tres", "plus"]

    private func hits(_ re: NSRegularExpression, _ text: String, applyWhitelist: Bool = false) -> [String] {
        let r = NSRange(text.startIndex..., in: text)
        let matches = re.matches(in: text, range: r).compactMap {
            Range($0.range, in: text).map { String(text[$0]) }
        }
        guard applyWhitelist else { return matches }
        return matches.filter { m in
            let first = m.split(whereSeparator: { $0.isWhitespace }).first.map(String.init) ?? m
            return !Self.whitelist.contains(first.folding(options: .diacriticInsensitive, locale: nil).lowercased())
        }
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
            for alt in e.alternatives { out.append(("exercise.alternative", alt)) }
        }
    }

    func testNoDuplicatedWordsInDisplayedText() async throws {
        let templates = try await TemplateLoader.loadAll()
        guard templates.count >= 30 else { throw XCTSkip("bundle non peuplé (\(templates.count))") }

        var failures: [String] = []
        for t in templates {
            for (field, lt) in displayedTexts(t) {
                for (lang, value) in [("fr", lt.fr as String?), ("en", lt.en), ("es", lt.es)] {
                    guard let value else { continue }
                    let h = hits(Self.duplicate, value, applyWhitelist: true) + hits(Self.duplicatePhrase, value)
                    if !h.isEmpty {
                        failures.append("[\(t.id)] \(field).\(lang): \(Set(h).sorted()) — « …\(value.prefix(70))… »")
                    }
                }
            }
        }
        XCTAssertTrue(
            failures.isEmpty,
            "Mot dupliqué dans \(failures.count) champ(s) affiché(s) :\n" + failures.prefix(40).joined(separator: "\n"))
    }
}
