import XCTest
@testable import TemplateLoader
import TemplateModel

/// Filet de régression — les 4 templates HIIT énoncent eux-mêmes dans `safety_notes`/
/// `progression_logic` une règle « récupération inter-séances HIIT ≥ 48h, JAMAIS 2 séances
/// HIIT consécutives » (doctrine ACSM 2014). Bug trouvé 2026-07-25 : `hiit-regular-10sem`
/// plaçait une 3e séance `interval` (« Max de tours ») le lendemain direct (J5→J6, 24h) sur
/// 5 semaines/10 (S3, S5, S6, S7, S9) — le template se contredisait lui-même. Corrigé par
/// swap J3↔J6 (motif lun/mer/ven, 48h partout intra + inter-semaines).
///
/// Ce test vérifie mécaniquement ce que le texte narratif revendique, pour éviter qu'une
/// future édition (nouvelle semaine, réordonnancement) réintroduise le même écart sans
/// que personne ne le recoupe avec la doctrine.
final class HiitIntervalRecoverySpacingTests: XCTestCase {

    func testNoTwoIntervalSessionsWithinFortyEightHours() async throws {
        let templates = try await TemplateLoader.loadAll()
        let hiit = templates.filter { $0.sport == .hiit }
        guard !hiit.isEmpty else { throw XCTSkip("bundle non peuplé (aucun template hiit)") }

        var failures: [String] = []

        for t in hiit {
            var previousWeekLastIntervalDay: Int?
            for w in t.weeks.sorted(by: { $0.weekNumber < $1.weekNumber }) {
                let intervalDays = w.sessions
                    .filter { $0.type == .interval }
                    .map(\.day)
                    .sorted()

                for (a, b) in zip(intervalDays, intervalDays.dropFirst()) where b - a < 2 {
                    failures.append("[\(t.id)] S\(w.weekNumber) : J\(a)→J\(b) = \((b - a) * 24)h (attendu ≥48h)")
                }

                if let lastPrev = previousWeekLastIntervalDay, let firstThis = intervalDays.first {
                    let gapDays = (7 - lastPrev) + firstThis
                    if gapDays < 2 {
                        failures.append(
                            "[\(t.id)] S\(w.weekNumber - 1)J\(lastPrev) → S\(w.weekNumber)J\(firstThis) "
                            + "= \(gapDays * 24)h (attendu ≥48h, chevauchement de semaine)"
                        )
                    }
                }
                if let lastThis = intervalDays.last {
                    previousWeekLastIntervalDay = lastThis
                }
            }
        }

        XCTAssertTrue(
            failures.isEmpty,
            """
            \(failures.count) écart(s) < 48h entre séances HIIT — viole la règle que le \
            template énonce lui-même (safety_notes/progression_logic « JAMAIS 2 séances \
            HIIT consécutives ») :
            \(failures.joined(separator: "\n"))
            """
        )
    }
}
