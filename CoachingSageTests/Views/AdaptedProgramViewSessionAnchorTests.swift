// CoachingSageTests/Views/AdaptedProgramViewSessionAnchorTests.swift
// Verrou 2026-08-08 (Sophie) : "je crée un programme, la description arrive
// scrollée sur la séance 3 au lieu de la 1ère". Régression résiduelle du fix
// 26/07 (AdaptedWeek.sessionsSortedByDay) : le fix avait aligné l'ORDRE
// D'AFFICHAGE des cartes (ForEach) sur sessionsSortedByDay, mais pas la cible
// de scroll auto en mode preview (record == nil, juste après création),
// restée sur `week.sessions.first` (ordre brut du tableau JSON du template,
// pas garanti trié par day).
import XCTest
import TemplateModel
@testable import CoachingSage

@MainActor
final class AdaptedProgramViewSessionAnchorTests: XCTestCase {

    private func makeSession(day: Int) -> AdaptedSession {
        AdaptedSession(
            day: day, name: LocalizedText(fr: "s\(day)", en: "s\(day)", es: "s\(day)"),
            durationMinutes: 30, type: .endurance, warmup: nil, exercises: [], cooldown: nil
        )
    }

    private func makeProgram(rawDayOrder: [Int]) -> AdaptedProgram {
        AdaptedProgram(
            templateId: "test-template",
            sport: .running,
            level: .beginner,
            appliedAt: Date(),
            weeks: [
                AdaptedWeek(
                    weekNumber: 1,
                    theme: LocalizedText(fr: "t", en: "t", es: "t"),
                    goal: LocalizedText(fr: "g", en: "g", es: "g"),
                    sessions: rawDayOrder.map(makeSession)
                )
            ],
            appliedRules: [],
            requiresAIAssist: false
        )
    }

    /// Reproduit exactement le scénario signalé : programme en mode preview
    /// (record == nil, juste après création) avec un tableau JSON de séances
    /// dans un ordre brut non trié par day.
    func testScrollAnchorInPreviewModeTargetsFirstDisplayedSessionNotRawArrayOrder() {
        let program = makeProgram(rawDayOrder: [2, 3, 4, 5, 6, 7, 1])
        let view = AdaptedProgramView(program: program)

        // recordId == nil (défaut) → record == nil (@State défaut) → mode preview.
        XCTAssertEqual(
            view.firstUndoneSessionAnchor,
            AdaptedProgramView.sessionAnchor(week: 1, day: 1),
            "En preview, le scroll doit cibler la 1ère séance AFFICHÉE (day 1), pas le 1er élément brut du tableau JSON (day 2)"
        )
    }

    func testScrollAnchorInPreviewModeIsNoOpWhenAlreadyOrdered() {
        let program = makeProgram(rawDayOrder: [1, 2, 3])
        let view = AdaptedProgramView(program: program)

        XCTAssertEqual(view.firstUndoneSessionAnchor, AdaptedProgramView.sessionAnchor(week: 1, day: 1))
    }
}
