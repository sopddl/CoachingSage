import XCTest
@testable import TemplateLoader
import TemplateModel

/// Filet de régression G8 — chantier densité B, increment 1 (2026-07-02) :
/// toute semaine dont le theme/goal EN annonce une décharge (deload, cutback,
/// taper, easy week, recovery week) DOIT figurer dans `deload_weeks` — le marqueur
/// structurel que `DensityRule` consulte pour ne JAMAIS densifier ces semaines.
///
/// `deload_weeks` est généré build-time par `scripts/densite_b/generate_deload_weeks.py`
/// (mêmes mots-clés + mêmes contextes d'exclusion — garder les deux synchrones), puis
/// revu à la main. Ce filet attrape la régression future : template édité/ajouté avec
/// une semaine allégée non marquée.
final class DeloadWeeksMarkerTests: XCTestCase {

    private static let keywords = try! NSRegularExpression(
        pattern: #"easy week|recovery week|deload|cutback|taper"#,
        options: [.caseInsensitive]
    )

    /// Contextes où le mot-clé référence une décharge passée/future depuis une semaine
    /// de build adjacente (« post-deload return », « +30% vs W4 cutback », « before the
    /// W8 taper », « the deload arrives in W12 »…). Miroir des EXCLUSIONS du script.
    private static let exclusions: [NSRegularExpression] = {
        let marker = #"(?:deload|cutback|taper)"#
        let weekRef = #"(?:the )?(?:light |w\d+ |week[-\s]?\d+ )?"#
        return [
            "post[-\\s]?\(marker)",
            "pre[-\\s]?\(marker)",
            "(?:after|out of|vs\\.?|versus) \(weekRef)\(marker)",
            "before \(weekRef)(?:\(marker)|recovery week)",
            "\(marker)(?: that starts| arrives)? in w\\d+",
            "toward the \(marker)",
            "no competitive taper",
        ].map { try! NSRegularExpression(pattern: $0, options: [.caseInsensitive]) }
    }()

    /// Faux positifs connus (trouvés 2026-07-25, audit "des semaines deload sont en
    /// fait des pics de charge") : le mot-clé taper/deload matché ne qualifie qu'UNE
    /// séance de la semaine (souvent J1, allégée en prépa d'un pic J5), pas le volume
    /// hebdo réel — qui est en fait au maximum ou proche du maximum du plan. Vérifié
    /// à la main sur le contenu FR (theme/goal + volumes chiffrés). Miroir de
    /// `OVERRIDES["remove"]` dans `scripts/densite_b/generate_deload_weeks.py` —
    /// garder les deux synchrones.
    private static let knownFalsePositives: [String: Set<Int>] = [
        "cycling-beginner-reprise-6sem": [6],
        "football-competitive-saison-regional-16sem": [14],
        "hiit-competitive-athletique-12sem": [11],
        "strength-training-competitive-strength-5x5-cycle": [11],
        "cycling-recreational-endurance-10sem": [10],
        "running-beginner-5k-8sem": [8],
    ]

    /// Le texte contient-il un mot-clé décharge NON couvert par un contexte d'exclusion ?
    private func hasDeloadMarker(_ text: String) -> Bool {
        let range = NSRange(text.startIndex..., in: text)
        let excludedRanges = Self.exclusions.flatMap {
            $0.matches(in: text, range: range).map(\.range)
        }
        return Self.keywords.matches(in: text, range: range).contains { kw in
            !excludedRanges.contains { NSIntersectionRange($0, kw.range) == kw.range }
        }
    }

    func testEveryDeloadThemedWeekIsMarked() async throws {
        let templates = try await TemplateLoader.loadAll()
        guard templates.count >= 30 else { throw XCTSkip("bundle non peuplé (\(templates.count))") }

        var failures: [String] = []
        for t in templates {
            guard let deload = t.deloadWeeks else {
                failures.append("[\(t.id)] deload_weeks ABSENT du template bundlé")
                continue
            }
            // Bornes saines : numéros de semaine valides, sans doublon.
            XCTAssertEqual(Set(deload).count, deload.count, "[\(t.id)] doublons dans deload_weeks")
            XCTAssertTrue(deload.allSatisfy { (1...t.durationWeeks).contains($0) },
                          "[\(t.id)] deload_weeks hors bornes 1...\(t.durationWeeks) : \(deload)")

            let falsePositives = Self.knownFalsePositives[t.id] ?? []
            for w in t.weeks {
                guard !falsePositives.contains(w.weekNumber) else { continue }
                let text = "\(w.theme.en ?? "") | \(w.goal.en ?? "")"
                if hasDeloadMarker(text), !deload.contains(w.weekNumber) {
                    failures.append("[\(t.id)] W\(w.weekNumber) thème décharge non marqué : « \(text.prefix(90)) »")
                }
            }
        }
        XCTAssertTrue(
            failures.isEmpty,
            """
            \(failures.count) semaine(s) décharge/taper hors deload_weeks — régénérer via \
            scripts/densite_b/generate_deload_weeks.py (ou compléter les overrides revus) :
            \(failures.prefix(20).joined(separator: "\n"))
            """
        )
    }
}
