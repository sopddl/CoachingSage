import XCTest
@testable import TemplateLoader
import TemplateModel

/// Garde-fou pérenne — chantier « safety_notes/progression_logic jamais affichés »
/// (audit transverse 2026-07-26). `safety_notes`/`progression_logic` restent une
/// doctrine interne dense (génération/review), jamais montrée telle quelle à
/// l'utilisateur (`ProgramAdapter` les vide explicitement). `overload_signs` et
/// `missed_session_policy` sont le sous-ensemble COURT et actionnable extrait de
/// `safety_notes` pour CHAQUE template, destiné lui à être réellement affiché.
///
/// Invariant verrouillé : les 40 templates bundlés ont ces 2 champs peuplés en
/// FR/EN/ES (sinon dead content silencieux comme leurs parents), et le contenu
/// reste exempt de jargon brut / citations académiques (même contrat que les
/// autres champs affichés — cf `NoRawJargonInDisplayedTextTests`,
/// `NoResidualEnglishInDisplayedFRTests`).
final class OverloadSignsAndMissedSessionPolicyTests: XCTestCase {

    private static let bannedJargon: [String] = [
        "daniels-", "ftp-z", "%1rm", "nsca", "acsm", "schoenfeld", "israetel",
        "coggan", "friel", "pubmed", "seiler", "pfitzinger", "ellenbecker", "kovacs",
    ]

    func testAllTemplatesHaveOverloadSignsAndMissedSessionPolicy() async throws {
        let templates = try await TemplateLoader.loadAll()
        guard templates.count >= 30 else { throw XCTSkip("bundle non peuplé (\(templates.count))") }

        var missing: [String] = []
        for t in templates {
            for (label, field) in [("overload_signs", t.overloadSigns), ("missed_session_policy", t.missedSessionPolicy)] {
                guard let field else {
                    missing.append("\(t.id): \(label) absent")
                    continue
                }
                for (lang, value) in [("fr", field.fr), ("en", field.en), ("es", field.es)] {
                    let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                    if trimmed.isEmpty {
                        missing.append("\(t.id): \(label).\(lang) vide/absent")
                    }
                }
            }
        }
        XCTAssertTrue(
            missing.isEmpty,
            "overload_signs/missed_session_policy manquant(s) sur \(missing.count) champ(s) :\n"
                + missing.prefix(40).joined(separator: "\n"))
    }

    func testNoRawJargonOrCitationsInExtractedFields() async throws {
        let templates = try await TemplateLoader.loadAll()
        guard templates.count >= 30 else { throw XCTSkip("bundle non peuplé (\(templates.count))") }

        var hits: [String] = []
        for t in templates {
            for (label, field) in [("overload_signs", t.overloadSigns), ("missed_session_policy", t.missedSessionPolicy)] {
                guard let field else { continue }
                for (lang, value) in [("fr", field.fr), ("en", field.en), ("es", field.es)] {
                    guard let value else { continue }
                    let lower = value.lowercased()
                    for banned in Self.bannedJargon where lower.contains(banned) {
                        hits.append("\(t.id): \(label).\(lang) contient « \(banned) »")
                    }
                }
            }
        }
        XCTAssertTrue(
            hits.isEmpty,
            "Jargon brut / citation académique détecté dans \(hits.count) champ(s) affiché(s) :\n"
                + hits.prefix(40).joined(separator: "\n"))
    }
}
