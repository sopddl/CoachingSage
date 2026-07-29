// CoachingSageTests/Adapter/AdaptedWeekSessionOrderTests.swift
// Bug rouvert 2026-07-26 (hiking beginner, P0) : PR #4 (07-06) n'avait corrigé qu'un
// échange de contenu entre deux jours, pas l'affichage. `AdaptedWeek.sessions` garde
// l'ordre brut du tableau JSON du template (ex: [2,3,4,5,6,7,1]), qui ne correspond
// pas forcément à l'ordre chronologique day ascendant attendu par la numérotation
// affichée (AdaptedProgramView.globalSessionNumber trie par day). Sans tri à
// l'affichage, la 1ère carte visible pouvait porter un numéro de séance plus grand
// que la dernière.
//
// Verrou : `AdaptedWeek.sessionsSortedByDay` (utilisé par AdaptedProgramView pour le
// ForEach) doit toujours renvoyer les séances triées par day croissant, quel que soit
// l'ordre brut du tableau — testé en isolation ET sur le vrai template en cause.
import XCTest
import TemplateModel
import TemplateLoader

final class AdaptedWeekSessionOrderTests: XCTestCase {

    private func makeSession(day: Int) -> AdaptedSession {
        AdaptedSession(
            day: day, name: LocalizedText(fr: "s\(day)", en: "s\(day)", es: "s\(day)"),
            durationMinutes: 30, type: .endurance, warmup: nil, exercises: [], cooldown: nil
        )
    }

    func testSessionsSortedByDayReordersRawJSONArrayOrder() {
        // Reproduit exactement la forme du bug : tableau brut [2,3,4,5,6,7,1].
        let rawOrder = [2, 3, 4, 5, 6, 7, 1]
        let week = AdaptedWeek(
            weekNumber: 1,
            theme: LocalizedText(fr: "t", en: "t", es: "t"),
            goal: LocalizedText(fr: "g", en: "g", es: "g"),
            sessions: rawOrder.map(makeSession)
        )

        XCTAssertEqual(week.sessions.map(\.day), rawOrder, "sessions garde l'ordre brut du template")
        XCTAssertEqual(
            week.sessionsSortedByDay.map(\.day), [1, 2, 3, 4, 5, 6, 7],
            "sessionsSortedByDay doit être en ordre chronologique day croissant pour l'affichage"
        )
    }

    func testSessionsSortedByDayIsNoOpWhenAlreadyOrdered() {
        let week = AdaptedWeek(
            weekNumber: 1,
            theme: LocalizedText(fr: "t", en: "t", es: "t"),
            goal: LocalizedText(fr: "g", en: "g", es: "g"),
            sessions: [1, 2, 3].map(makeSession)
        )
        XCTAssertEqual(week.sessionsSortedByDay.map(\.day), [1, 2, 3])
    }

    /// Verrou sur le scénario réel signalé par Sophie (hiking-beginner-decouverte-8sem,
    /// 8 semaines) : le tableau JSON de chaque semaine est dans l'ordre [2,3,4,5,6,7,1]
    /// (cf commit 055aed5 qui a permuté le CONTENU des jours 2↔4 sans jamais toucher à
    /// l'ordre du tableau). On vérifie ici que l'adapter + sessionsSortedByDay
    /// produisent bien un ordre chronologique pour CHAQUE semaine du plan.
    func testHikingBeginnerTemplateDisplaysSessionsInChronologicalOrder() async throws {
        let templates = try await TemplateLoader.loadAll()
        guard let template = templates.first(where: { $0.id == "hiking-beginner-decouverte-8sem" }) else {
            throw XCTSkip("template hiking-beginner-decouverte-8sem absent du bundle")
        }

        let adapter = ProgramAdapter()
        let adapted = adapter.adapt(
            template: template,
            sportProfile: AdapterTestFixtures.sportProfile(),
            coachingProfile: AdapterTestFixtures.coachingProfile()
        )

        for week in adapted.weeks {
            let sortedDays = week.sessionsSortedByDay.map(\.day)
            XCTAssertEqual(
                sortedDays, sortedDays.sorted(),
                "semaine \(week.weekNumber) : sessionsSortedByDay doit être day-ascendant"
            )
        }
    }
}
