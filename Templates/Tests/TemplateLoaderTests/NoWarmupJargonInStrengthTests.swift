import XCTest
@testable import TemplateLoader
import TemplateModel

/// Filet de régression — passe warmups muscu jargon EN → FR didactique (2026-07-24),
/// `warmup-jargon-glossaire-PROPOSAL-2026-06-08.md` option 2 (décision Sophie : « didactique »,
/// cf `chantier_revue_images_muscu_2026_06_08.md`).
///
/// Scope STRICT : uniquement `session.warmup` / `session.cooldown` / `variant.warmup` /
/// `variant.cooldown` en FR (texte narratif affiché tel quel, où le jargon doit être traduit).
/// Volontairement PAS `exo.name` / `exo.notes` / `alternatives` (des noms d'exercice canoniques
/// comme « Face pull », « Wall slides » sont des anglicismes de salle whitelistés, cf CLAUDE.md
/// « politique nommage exos ») ni les locales `en`/`es` (jargon EN légitime dans ces champs).
final class NoWarmupJargonInStrengthTests: XCTestCase {

    private static let pattern = try! NSRegularExpression(
        pattern: [#"\bCARs\b"#, #"\bramping\b"#, #"sleeper stretch"#, #"band pull-apart"#,
                  #"world's greatest stretch"#, #"band dislocate"#, #"knee-to-wall"#,
                  #"hip flexor lunge"#, #"scapular push"#, #"scapular pull"#, #"wall slides"#,
                  #"deep squat hold"#, #"band lateral walks"#, #"\bface pull"#].joined(separator: "|"),
        options: [.caseInsensitive])

    private func hit(_ text: String?) -> Bool {
        guard let text else { return false }
        return Self.pattern.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) != nil
    }

    func testNoEnglishJargonInStrengthWarmupOrCooldownFR() async throws {
        let templates = try await TemplateLoader.loadAll()
        guard templates.count >= 30 else { throw XCTSkip("bundle non peuplé (\(templates.count))") }
        let strength = templates.filter { $0.sport == .strengthTraining }
        XCTAssertFalse(strength.isEmpty, "aucun template strength chargé")

        var failures: [String] = []
        func scan(_ field: String, _ loc: LocalizedText?, _ id: String) {
            guard let fr = loc?.fr, hit(fr) else { return }
            failures.append("[\(id)] \(field): « \(fr.prefix(80))… »")
        }
        for t in strength {
            for w in t.weeks {
                for s in w.sessions {
                    scan("session.warmup", s.warmup, t.id)
                    scan("session.cooldown", s.cooldown, t.id)
                    for v in s.variants ?? [] {
                        scan("variant.warmup", v.warmup, t.id)
                        scan("variant.cooldown", v.cooldown, t.id)
                    }
                }
            }
        }
        XCTAssertTrue(failures.isEmpty,
            "Jargon warmup EN non traduit dans \(failures.count) champ(s) :\n"
                + failures.prefix(40).joined(separator: "\n"))
    }
}
