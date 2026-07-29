import XCTest
@testable import TemplateLoader
import TemplateModel

/// Filet de régression — chantier compréhensibilité football (2026-06-25, décisions Sophie).
///
/// Deux familles, sur le texte AFFICHÉ des séances football (name / warmup / cooldown /
/// notes / alternatives, variantes incluses) :
///  1. Citations coach-science (auteurs/orgs/méthodes) RETIRÉES dans les 3 LANGUES :
///       Bompa, Buchheit, F-MARC, méta-analyses Petersen 2016 / Thorborg 2024.
///  2. Allégations médicales (EU MDR) REFORMULÉES — vérifiées en FR (la reformulation
///     porte sur le FR, locale primaire ; cf. précédent running) :
///       « Pilier prévention … », « prévention blessures … -51 % », « préventif » (titres),
///       noms de pathologie. Reformulés en bénéfice d'entraînement neutre (« renforcement »,
///       « stabilité »).
///
/// EXCLUS : `progression_logic` / `safety_notes` / `summary` (coach/LLM, non affichés) ;
/// les % de DOSE (volume -20/-25/-30 %, % FCmax) ; vocabulaire gardé (FIFA 11+, RSA,
/// ischios nordiques, sprints répétés). EN/ES : seules les citations (noms propres) sont
/// verrouillées ; la reformulation MDR EN/ES reste un suivi (hors périmètre FR de ce
/// chantier).
///
/// Audit contenu football (2026-07-26) — « Verheijen » (nom propre expert) traînait dans
/// `week.theme`/`week.goal` de football-regular/competitive (bruit pur pour un joueur
/// amateur, contrairement au concept "micro-cycle 4 jours" qui lui est gardé). Retiré +
/// pattern étendu à Verheijen + scan étendu à theme/goal (angle mort : le scan précédent
/// ne couvrait que session/exo, pas les champs de semaine où vivent citations et concepts).
final class NoUnclearFootballJargonTests: XCTestCase {

    // Citations (noms propres) + cadrages MDR EN/ES — interdits dans les 3 langues
    // (passe EN/ES 2026-06-25 : « prevention pillar », « injury-prevention », « pilar de
    // prevención », « mobility-prevention/movilidad-prevención » reformulés en renforcement).
    private static let citationPattern = try! NSRegularExpression(
        pattern: [#"\bBompa\b"#, #"\bBuchheit\b"#, #"\bF-MARC\b"#, #"Petersen 201"#, #"Thorborg 202"#,
                  #"\bMujika\b"#, #"\bVerheijen\b"#, #"prévent"#, #"prevent"#, #"prevenc"#, #"preventi"#,
                  #"mobilité-prévention"#, #"movilidad-prevención"#].joined(separator: "|"),
        options: [.caseInsensitive])
    // Allégations MDR — vérifiées en FR.
    private static let frClaimPattern = try! NSRegularExpression(
        pattern: [#"[Pp]ilier prévention"#, #"prévention blessures"#, #"préventif"#,
                  #"prévention (de l'aine|cheville|du genou|du dos|adducteurs)"#,
                  #"conflit sous-acromial"#, #"-51 ?%"#].joined(separator: "|"),
        options: [])

    private func hits(_ re: NSRegularExpression, _ text: String?) -> Bool {
        guard let text else { return false }
        return re.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) != nil
    }

    func testNoCitationsOrMDRInFootballDisplayed() async throws {
        let templates = try await TemplateLoader.loadAll()
        guard templates.count >= 30 else { throw XCTSkip("bundle non peuplé (\(templates.count))") }
        let football = templates.filter { $0.sport == .football }
        XCTAssertFalse(football.isEmpty, "aucun template football chargé")

        var failures: [String] = []
        func scan(_ field: String, _ loc: LocalizedText?, _ id: String) {
            guard let loc else { return }
            if hits(Self.frClaimPattern, loc.fr) {
                failures.append("[\(id)] \(field).fr (MDR): « \(loc.fr.prefix(80))… »")
            }
            for (lang, value) in [("fr", loc.fr), ("en", loc.en), ("es", loc.es)] {
                if hits(Self.citationPattern, value) {
                    failures.append("[\(id)] \(field).\(lang) (citation): « \((value ?? "").prefix(80))… »")
                }
            }
        }

        for t in football {
            for w in t.weeks {
                scan("week.theme", w.theme, t.id)
                scan("week.goal", w.goal, t.id)
                for s in w.sessions {
                    scan("session.name", s.name, t.id)
                    scan("session.warmup", s.warmup, t.id)
                    scan("session.cooldown", s.cooldown, t.id)
                    var exos = s.exercises
                    for v in s.variants ?? [] {
                        scan("variant.name", v.name, t.id)
                        exos += v.exercises
                    }
                    for e in exos {
                        scan("exo.name", e.name, t.id)
                        scan("exo.notes", e.notes, t.id)
                        for alt in e.alternatives { scan("alternative", alt, t.id) }
                    }
                }
            }
        }
        XCTAssertTrue(failures.isEmpty,
            "Citation/MDR football non corrigé dans \(failures.count) champ(s) :\n"
                + failures.prefix(40).joined(separator: "\n"))
    }
}
