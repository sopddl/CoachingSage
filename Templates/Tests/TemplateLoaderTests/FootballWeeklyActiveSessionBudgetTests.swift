import XCTest
@testable import TemplateLoader
import TemplateModel

/// Filet de régression — audit contenu football (2026-07-26), P0.
///
/// `football-competitive-saison-regional-16sem` déclare `sessions_per_week: 6` et
/// documente explicitement, dans son propre `progression_logic`, que la gestion
/// des congestions de calendrier (coupe en milieu de semaine) passe par un
/// REPORT/raccourcissement de séance — jamais par l'ajout d'une séance en plus.
/// Bug trouvé : S6 (pic de volume présaison, sans congestion) et S10 (congestion
/// coupe, cas nommé par la doctrine elle-même) avaient chacune 7 séances actives
/// et 0 jour de repos — le jour `type: rest` habituel (J4, présent dans les 14
/// autres semaines du plan) avait été remplacé par une séance active en plus,
/// au lieu d'un report. Fix : J4 restauré en `Repos complet` (`type: rest`) sur
/// S6 et S10, alignées sur les 14 autres semaines.
///
/// Portée volontairement limitée à `football-competitive-saison-regional-16sem` :
/// c'est le seul template football qui énumère explicitement un jour `rest` par
/// semaine (beginner/recreational/regular ne listent que les jours actifs, sans
/// jour de repos explicite dans le tableau — convention différente, hors
/// périmètre de ce filet).
final class FootballWeeklyActiveSessionBudgetTests: XCTestCase {

    func testCompetitiveNeverExceedsDeclaredSessionsPerWeekWithZeroRest() async throws {
        let templates = try await TemplateLoader.loadAll()
        guard templates.count >= 30 else { throw XCTSkip("bundle non peuplé (\(templates.count))") }
        guard let template = templates.first(where: { $0.id == "football-competitive-saison-regional-16sem" }) else {
            throw XCTSkip("template football-competitive-saison-regional-16sem absent du bundle")
        }

        var failures: [String] = []
        for w in template.weeks {
            let activeCount = w.sessions.filter { $0.type != .rest }.count
            let hasRestDay = w.sessions.contains { $0.type == .rest }
            // Semaines de transition volontairement sous le budget (W1 montée en
            // charge, W16 affûtage final) : on ne verrouille que le DÉPASSEMENT
            // (garde-fou "reporter, pas ajouter"), pas le sous-effectif.
            if activeCount > template.sessionsPerWeek {
                failures.append("semaine \(w.weekNumber) : \(activeCount) séances actives (déclaré \(template.sessionsPerWeek)), rest day présent: \(hasRestDay)")
            }
        }
        XCTAssertTrue(failures.isEmpty,
            "Garde-fou « reporter pas ajouter » (congestion calendaire) non respecté :\n" + failures.joined(separator: "\n"))
    }
}
