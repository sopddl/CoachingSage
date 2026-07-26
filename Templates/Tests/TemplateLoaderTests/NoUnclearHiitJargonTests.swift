import XCTest
@testable import TemplateLoader
import TemplateModel

/// Filet de régression — chantier compréhensibilité HIIT (2026-06-25, décisions Sophie).
///
/// Verrouille, sur le texte AFFICHÉ **FR** des séances HIIT (name / warmup / cooldown /
/// notes / alternatives, variantes incluses) :
///  1. Citations coach-science retirées : NSCA, Mujika, Gibala, Petersen, BJSM,
///     True Sports PT, et les données labo rattachées (« 170 % VO2max », « fractionné
///     20/10 1996 », « 20/10 (1996) »).
///  2. Allégations médicales (EU MDR) reformulées : « Prévention conflit sous-acromial »,
///     « prévention valgus », « Prévention coiffe rotateurs », « Obligatoire HIIT/débutant ».
///
/// EXCLUS : `progression_logic`/`safety_notes` (non affichés) ; % de DOSE (-10/-25 % vs Wx) ;
/// vocabulaire gardé (fractionné 20/10, AMRAP/EMOM, Tabata, kettlebell, burpees, RPE,
/// VO2max/FCmax rendus tappables). EN/ES : citations enchâssées en prose = suivi (ce chantier
/// traite le FR, locale primaire — cf. running/cycling/hiking).
///
/// **Angle mort corrigé (audit HIIT 2026-07-26)** : "Préparation affûtage S12 (Mujika 2003)"
/// avait échappé au filet — pas parce que "Mujika" manquait à la liste (il y était déjà),
/// mais parce que `week.goal`/`week.theme` n'étaient PAS scannés (seuls session/exo l'étaient).
/// Ajout du scan week.goal/week.theme + un motif générique "(Auteur[s] AAAA)" qui attrape
/// toute citation auteur+année FUTURE sans dépendre d'une liste de noms tenue à la main.
final class NoUnclearHiitJargonTests: XCTestCase {

    // FR + EN + ES (passe EN/ES 2026-06-25). Tokens d'auteurs/orgs communs aux 3 langues +
    // cadrages MDR propres à chaque langue.
    private static let pattern = try! NSRegularExpression(
        pattern: [#"\bNSCA\b"#, #"\bMujika\b"#, #"\bGibala\b"#, #"\bPetersen\b"#, #"\bBJSM\b"#,
                  #"True Sports"#, #"170 ?% VO2má?x"#, #"fractionné 20/10 1996"#, #"20/10 \(1996\)"#,
                  #"[Pp]révention conflit"#, #"prévention valgus"#, #"Prévention coiffe"#,
                  #"\bimpingement\b"#, #"pinzamiento"#, #"subacromial"#,
                  #"prévent"#, #"prevent"#, #"prevenc"#, #"preventi"#,
                  #"Obligatoire (HIIT|chez le débutant HIIT)"#, #"Mandatory for the HIIT"#,
                  #"Obligatorio para el principiante de HIIT"#].joined(separator: "|"),
        options: [.caseInsensitive])

    /// Motif générique "(Auteur[s] ... AAAA)" — attrape toute citation auteur+année pas
    /// encore listée nommément ci-dessus (l'angle mort structurel signalé par Sophie).
    private static let genericCitationPattern = try! NSRegularExpression(
        pattern: #"\([^()]*[A-ZÀ-Ý][a-zà-ÿ]+[^()]*(?:19|20)\d{2}[^()]*\)"#,
        options: [])

    private func hit(_ loc: LocalizedText?) -> Bool {
        guard let loc else { return false }
        for v in [loc.fr, loc.en, loc.es] {
            guard let v else { continue }
            let range = NSRange(v.startIndex..., in: v)
            if Self.pattern.firstMatch(in: v, range: range) != nil { return true }
            if Self.genericCitationPattern.firstMatch(in: v, range: range) != nil { return true }
        }
        return false
    }

    func testNoCitationsOrMDRInHiitDisplayedFR() async throws {
        let templates = try await TemplateLoader.loadAll()
        guard templates.count >= 30 else { throw XCTSkip("bundle non peuplé (\(templates.count))") }
        let hiit = templates.filter { $0.sport == .hiit }
        XCTAssertFalse(hiit.isEmpty, "aucun template HIIT chargé")

        var failures: [String] = []
        func scan(_ field: String, _ loc: LocalizedText?, _ id: String) {
            if hit(loc) { failures.append("[\(id)] \(field): « \((loc?.fr ?? "").prefix(80))… »") }
        }
        for t in hiit {
            for w in t.weeks {
                scan("week.goal", w.goal, t.id)
                scan("week.theme", w.theme, t.id)
                for s in w.sessions {
                    scan("session.name", s.name, t.id)
                    scan("session.warmup", s.warmup, t.id)
                    scan("session.cooldown", s.cooldown, t.id)
                    var exos = s.exercises
                    for v in s.variants ?? [] {
                        scan("variant.name", v.name, t.id)
                        scan("variant.warmup", v.warmup, t.id)
                        scan("variant.cooldown", v.cooldown, t.id)
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
            "Citation/MDR HIIT (FR) non corrigé dans \(failures.count) champ(s) :\n"
                + failures.prefix(40).joined(separator: "\n"))
    }

    /// Filet de régression — audit HIIT (2026-07-26) : noms d'exos EMOM/AMRAP competitive
    /// jusqu'à 208 caractères, tronqués sur `SessionOverviewList` (.lineLimit(2)), à cause
    /// d'un parenthétique qui répétait littéralement ce que le début du nom venait de dire
    /// (ex. "Une série chaque minute 15 min (1 série chaque minute) — ..."). Verrouille
    /// l'absence de ces 3 gloses redondantes précises (retirées, pas juste raccourcies —
    /// un futur duplicata similaire ne sera PAS attrapé automatiquement, cf limite dans le
    /// commentaire de `testNoCitationsOrMDRInHiitDisplayedFR` pour la même classe de bug).
    func testNoRedundantGlossInHiitExerciseNames() async throws {
        let templates = try await TemplateLoader.loadAll()
        guard templates.count >= 30 else { throw XCTSkip("bundle non peuplé (\(templates.count))") }
        let hiit = templates.filter { $0.sport == .hiit }
        XCTAssertFalse(hiit.isEmpty, "aucun template HIIT chargé")

        let redundant = ["(1 série chaque minute)", "(una serie cada minuto)",
                          "(développé avec impulsion)", "(sauts double-tour)"]

        var failures: [String] = []
        for t in hiit {
            for w in t.weeks {
                for s in w.sessions {
                    for e in s.exercises {
                        for v in [e.name.fr, e.name.es] {
                            guard let v else { continue }
                            for phrase in redundant where v.contains(phrase) {
                                failures.append("[\(t.id)] S\(w.weekNumber) J\(s.day) « \(phrase) » : \(v.prefix(80))…")
                            }
                        }
                    }
                }
            }
        }
        XCTAssertTrue(failures.isEmpty,
            "Glose redondante réintroduite dans \(failures.count) nom(s) d'exo HIIT :\n"
                + failures.prefix(40).joined(separator: "\n"))
    }
}
