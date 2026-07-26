import XCTest
@testable import TemplateLoader
import TemplateModel

/// Filet de régression — 39 des 40 templates prod promettent (dans `summary`,
/// `progression_logic` ou le `goal` de la dernière semaine) une « checklist »/« bilan »
/// d'autonomie ou d'autoévaluation en fin de programme. Bug trouvé 2026-07-25 : la
/// promesse n'était tenue nulle part dans le contenu réel pour swimming (3/4),
/// cycling (4/4) et hiking (1/4) — juste une phrase vague ou rien du tout. Corrigé par
/// l'ajout d'un exercice « Checklist autonomie »/« Bilan d'autonomie » dédié dans la
/// dernière semaine des 8 templates concernés.
///
/// Ce test vérifie mécaniquement, pour TOUT template qui fait la promesse, qu'une vraie
/// liste de critères vérifiables (≥3 puces/items numérotés) existe quelque part dans le
/// contenu de la dernière semaine — pas juste une phrase narrative. Sport-agnostique :
/// un futur template qui reprend cette formule (nouveau sport, nouvelle édition) est
/// automatiquement couvert.
///
/// NB : ne vérifie PAS que le nombre d'items livrés == nombre promis dans le texte (« 5
/// critères » qui n'en liste que 4) — bug distinct, plus mineur, non couvert ici (cf
/// backlog `hiit-regular-10sem`, `running-regular-semi-marathon-12sem`,
/// `hiking-recreational-day-hikes-10sem`).
final class ChecklistAutonomiePromiseKeptTests: XCTestCase {

    private static let promisePattern = try! NSRegularExpression(
        pattern: #"autonomie|auto-?évaluation"#,
        options: [.caseInsensitive]
    )

    /// Puce (« • ») ou item numéroté (« (1) », « 1. ») — pas ancré en tête de ligne :
    /// certains templates (football-regular-club) numérotent des critères EN LIGNE dans
    /// un paragraphe (« ...(1) Je tiens... (2) ... »), pas un par ligne.
    private static let bulletPattern = try! NSRegularExpression(
        pattern: #"•|\(\d+\)|\b\d+\.\s"#,
        options: []
    )

    private func hasMatch(_ re: NSRegularExpression, _ text: String) -> Bool {
        re.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) != nil
    }

    private func bulletCount(_ text: String) -> Int {
        Self.bulletPattern.numberOfMatches(in: text, range: NSRange(text.startIndex..., in: text))
    }

    func testFinalWeekDeliversPromisedAutonomyChecklist() async throws {
        let templates = try await TemplateLoader.loadAll()
        guard templates.count >= 30 else { throw XCTSkip("bundle non peuplé (\(templates.count))") }

        var failures: [String] = []

        for t in templates {
            guard let lastWeek = t.weeks.max(by: { $0.weekNumber < $1.weekNumber }) else { continue }

            let promiseText = [t.summary.fr, t.progressionLogic.fr, lastWeek.goal.fr].joined(separator: "\n")
            guard hasMatch(Self.promisePattern, promiseText) else { continue }

            let exos = lastWeek.sessions.flatMap { s in
                s.exercises + (s.variants ?? []).flatMap { $0.exercises }
            }
            let sessionTexts = lastWeek.sessions.flatMap { [$0.warmup?.fr, $0.cooldown?.fr] }.compactMap { $0 }
            let deliveredText = ([lastWeek.goal.fr] + sessionTexts + exos.compactMap { $0.notes?.fr })
                .joined(separator: "\n")
            let count = bulletCount(deliveredText)

            if count < 3 {
                failures.append(
                    "[\(t.id)] promesse d'autonomie/autoévaluation détectée mais seulement "
                    + "\(count) item(s) vérifiable(s) en dernière semaine (attendu ≥3)"
                )
            }
        }

        XCTAssertTrue(
            failures.isEmpty,
            "Promesse de checklist d'autonomie non tenue dans \(failures.count) template(s) :\n"
                + failures.joined(separator: "\n")
        )
    }
}
