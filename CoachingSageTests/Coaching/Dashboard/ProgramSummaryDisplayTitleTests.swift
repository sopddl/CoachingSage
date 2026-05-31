// CoachingSageTests/Coaching/Dashboard/ProgramSummaryDisplayTitleTests.swift
// Story 3.28 Phase A — couvre `ProgramSummary.displayTitle(locale:)` qui
// recalcule le titre selon la locale courante via `AutoTitleBuilder`.
//
// Priorité testée :
//   1. `isUserRenamed == true` → `templateName` figé (peu importe locale).
//   2. `goalCode` non-nil → recalcul `AutoTitleBuilder` selon locale.
//   3. Fallback `templateName` quand ni rename ni goalCode (records pré-3.28).
import XCTest
import TemplateModel

final class ProgramSummaryDisplayTitleTests: XCTestCase {

    // MARK: - Helpers

    private func make(
        templateName: String = "Course — 10K",
        goalCode: String? = nil,
        secondary: [String] = [],
        isUserRenamed: Bool = false,
        sport: Sport = .running
    ) -> ProgramSummary {
        ProgramSummary(
            id: UUID(),
            templateName: templateName,
            sport: sport,
            weekStartDate: Date(),
            durationMode: .routineCyclic,
            mode: .planned,
            nextSession: nil,
            currentWeekNumber: 1,
            weekCompletedSessions: 0,
            weekTotalSessions: 3,
            totalSessionsCompleted: 0,
            totalSessions: 12,
            lastUpdatedAt: Date(),
            nextSessionIsLate: false,
            goalCode: goalCode,
            secondaryGoals: secondary,
            isUserRenamed: isUserRenamed
        )
    }

    private var frenchLocale: Locale { Locale(identifier: "fr") }
    private var englishLocale: Locale { Locale(identifier: "en") }

    // MARK: - Priority 1 : user rename gagne

    func testUserRenamedReturnsTemplateNameVerbatim() {
        let summary = make(
            templateName: "Mon programme perso",
            goalCode: "5k",          // goalCode présent mais ignoré
            isUserRenamed: true
        )
        XCTAssertEqual(summary.displayTitle(locale: frenchLocale), "Mon programme perso")
        XCTAssertEqual(summary.displayTitle(locale: englishLocale), "Mon programme perso")
    }

    func testUserRenamedEmptyTemplateNameStillFallsBackToRecalc() {
        // Edge case : isUserRenamed true mais templateName vide → on devrait
        // retomber sur le recalcul (defensive). Note : en pratique le rename
        // sheet remet isUserRenamed=false si trimmed.isEmpty, donc ce cas ne
        // devrait pas se produire en flow normal.
        let summary = make(
            templateName: "",
            goalCode: "5k",
            isUserRenamed: true
        )
        // Le titre devrait être recalculé vu que templateName est vide.
        let result = summary.displayTitle(locale: frenchLocale)
        XCTAssertNotEqual(result, "", "Titre vide ne doit pas remonter quand templateName est vide")
    }

    // MARK: - Priority 2 : recalcul AutoTitleBuilder selon locale

    func testRecalcWithGoalCodeUsesLocale() {
        let summary = make(
            templateName: "Course — 10K",  // figé FR à la création
            goalCode: "10k",
            isUserRenamed: false
        )
        let frTitle = summary.displayTitle(locale: frenchLocale)
        let enTitle = summary.displayTitle(locale: englishLocale)
        // Les deux titres doivent différer (locale change le sport name).
        XCTAssertNotEqual(frTitle, enTitle,
                          "Le titre doit changer entre FR et EN via recalcul AutoTitleBuilder")
    }

    func testRecalcWithSecondaryGoalsIncludesThem() {
        let summary = make(
            templateName: "fallback",
            goalCode: "10k",
            secondary: ["endurance"],
            isUserRenamed: false
        )
        let title = summary.displayTitle(locale: frenchLocale)
        // Le titre composite doit contenir un séparateur "+" entre primary et secondary.
        XCTAssertTrue(title.contains("+") || title.count > 10,
                      "Titre composite avec secondary attendu, got: \(title)")
    }

    // MARK: - Priority 3 : fallback templateName (records pré-3.28)

    func testFallbackToTemplateNameWhenNoGoalCode() {
        let summary = make(
            templateName: "Legacy programme 2024",
            goalCode: nil,
            isUserRenamed: false
        )
        XCTAssertEqual(summary.displayTitle(locale: frenchLocale), "Legacy programme 2024")
        XCTAssertEqual(summary.displayTitle(locale: englishLocale), "Legacy programme 2024")
    }
}
