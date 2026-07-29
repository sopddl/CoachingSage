import XCTest
@testable import TemplateLoader
import TemplateModel

/// Filet de régression — bug P0 factuel rouvert 2026-07-26 (audit contenu hiking).
///
/// `hiking-competitive-fastpacking-16sem`, semaine 16 (pré-trek, -80% volume) annonçait
/// « 2000 m D+ » / « -56% D+ vs W13 » dans son `goal`, alors que les séances réellement
/// prescrites cette semaine-là (marches plates + activation très courte, day 7 = jour
/// marqueur du trek sans contenu) ne peuvent produire qu'environ 150-250 m de D+. Le
/// chiffre venait d'une décroissance en pourcentage appliquée mécaniquement au volume
/// pic (4500 m × 0.44 ≈ 2000 m) sans jamais être confronté au contenu réel de la semaine.
///
/// Ce test verrouille : (1) le chiffre fabriqué ne réapparaît pas, (2) le goal reste
/// honnête sur le fait que le D+ du trek lui-même n'est pas compté dans le plan.
final class HikingTaperWeekElevationConsistencyTests: XCTestCase {

    private static let stalePattern = try! NSRegularExpression(
        pattern: #"2000\s*m\s*(D\+|elevation|desnivel)|-56\s*%"#,
        options: [.caseInsensitive]
    )

    private func hasMatch(_ re: NSRegularExpression, _ text: String) -> Bool {
        re.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) != nil
    }

    func testWeek16GoalDoesNotRestateTheFabricatedElevationFigure() async throws {
        let templates = try await TemplateLoader.loadAll()
        guard templates.count >= 30 else { throw XCTSkip("bundle non peuplé (\(templates.count))") }
        guard let template = templates.first(where: { $0.id == "hiking-competitive-fastpacking-16sem" }) else {
            throw XCTSkip("template hiking-competitive-fastpacking-16sem absent du bundle")
        }
        guard let w16 = template.weeks.first(where: { $0.weekNumber == 16 }) else {
            return XCTFail("semaine 16 introuvable dans hiking-competitive-fastpacking-16sem")
        }

        for (lang, text) in [("fr", w16.goal.fr), ("en", w16.goal.en), ("es", w16.goal.es)] {
            guard let text else { continue }
            XCTAssertFalse(
                hasMatch(Self.stalePattern, text),
                "[\(lang)] W16 goal réintroduit le chiffre D+ fabriqué (2000m/-56%) — " +
                "incohérent avec les séances réellement prescrites (taper quasi-plat) : \(text.prefix(200))…"
            )
        }
    }

    /// Verrou complémentaire : le goal doit expliciter que le D+ du trek objectif n'est
    /// pas comptabilisé dans le plan (évite qu'un futur edit réintroduise un chiffre
    /// fantaisiste sans cette clarification).
    func testWeek16GoalClarifiesTrekElevationIsOutOfPlanScope() async throws {
        let templates = try await TemplateLoader.loadAll()
        guard templates.count >= 30 else { throw XCTSkip("bundle non peuplé (\(templates.count))") }
        guard let template = templates.first(where: { $0.id == "hiking-competitive-fastpacking-16sem" }),
              let w16 = template.weeks.first(where: { $0.weekNumber == 16 }) else {
            throw XCTSkip("template/semaine 16 absents du bundle")
        }

        let clarificationPattern = try! NSRegularExpression(
            pattern: #"pas compt|not tracked|no se contabiliza"#,
            options: [.caseInsensitive]
        )
        XCTAssertTrue(
            hasMatch(clarificationPattern, w16.goal.fr),
            "W16 goal (fr) devrait clarifier que le D+ réel du trek n'est pas dans le plan"
        )
    }
}
