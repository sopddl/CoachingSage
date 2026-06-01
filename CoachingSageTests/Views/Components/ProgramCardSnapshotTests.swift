// CoachingSageTests/Views/Components/ProgramCardSnapshotTests.swift
// Story 3.27 Phase C — filet régression visuel de `ProgramCard` (card du
// carrousel "Programmes en cours"), la card la plus refondue par la Story 3.27.
// Couvre les états distincts : actif normal, late, programme terminé, dormant,
// titre long (truncation lineLimit(1)).
//
// ⚠️ Limite locale (cf `ExerciseTimelineCardSnapshotTests`) : les
// `LocalizedStringKey` (« Non commencé », « Programme terminé ») ne sont PAS
// résolues à FR dans le contexte `UIHostingController` de SnapshotTesting
// (Bundle.main non swizzlé) → elles apparaissent en raw key dans les .png. Le
// statut interpolé (« Semaine X — Y/Z séances ») passe par `String.localized`
// et rend correctement en FR. Le filet reste utile : layout, icône sport, barre
// progression, truncation titre, présence ligne late. Couverture EN visuelle =
// story snapshot-infra dédiée à venir (bundle swizzle).
//
// Mode `record` : à la 1ère exécution les .png de référence sont créés sous
// `__Snapshots__/`. Pour reset après un changement UI intentionnel, supprimer le
// .png correspondant et relancer.
import XCTest
import SwiftUI
import SnapshotTesting
import TemplateModel

final class ProgramCardSnapshotTests: XCTestCase {

    private let frenchLocale = Locale(identifier: "fr")

    // MARK: - Fixtures

    private func summary(
        templateName: String = "Course — Forme",
        sport: Sport = .running,
        weekStartDate: Date? = Date(timeIntervalSince1970: 1_700_000_000),
        currentWeekNumber: Int = 2,
        weekCompletedSessions: Int = 1,
        weekTotalSessions: Int = 3,
        totalSessionsCompleted: Int = 4,
        totalSessions: Int = 12,
        nextSessionIsLate: Bool = false,
        nextSession: PersistedSession? = nil
    ) -> ProgramSummary {
        ProgramSummary(
            id: UUID(),
            templateName: templateName,
            sport: sport,
            weekStartDate: weekStartDate,
            durationMode: .deadlineFixed,
            mode: .planned,
            nextSession: nextSession,
            currentWeekNumber: currentWeekNumber,
            weekCompletedSessions: weekCompletedSessions,
            weekTotalSessions: weekTotalSessions,
            totalSessionsCompleted: totalSessionsCompleted,
            totalSessions: totalSessions,
            lastUpdatedAt: Date(timeIntervalSince1970: 1_700_000_000),
            nextSessionIsLate: nextSessionIsLate,
            goalCode: nil,
            secondaryGoals: [],
            isUserRenamed: true // titre figé = `templateName`, rendu stable (pas d'AutoTitleBuilder)
        )
    }

    private func session(weekNumber: Int) -> PersistedSession {
        PersistedSession(
            id: UUID(), weekNumber: weekNumber, weekTheme: "W\(weekNumber)", weekGoal: "G",
            day: 1, name: "Séance", durationMinutes: 40, type: .endurance,
            warmup: nil, exercises: [], cooldown: nil
        )
    }

    private func card(_ summary: ProgramSummary, isSelected: Bool = true) -> some View {
        ProgramCard(summary: summary, badge: nil, isSelected: isSelected, onTap: {})
            .frame(width: 200)
            .padding()
            .background(Color(uiColor: .systemBackground))
            .environment(\.locale, frenchLocale)
    }

    // MARK: - Tests

    // `testName: #function` est évalué au call site (= nom du test appelant),
    // sinon SnapshotTesting dérive le nom du `#function` du helper → collision
    // entre les 6 snapshots.
    private func assert(_ view: some View, height: CGFloat,
                        testName: String = #function, line: UInt = #line) {
        assertSnapshot(of: view, as: .image(precision: 0.99, perceptualPrecision: 0.97,
                                            layout: .fixed(width: 232, height: height)),
                       testName: testName, line: line)
    }

    func testActiveNormal_selected() {
        assert(card(summary()), height: 150)
    }

    func testActiveNormal_unselected() {
        assert(card(summary(), isSelected: false), height: 150)
    }

    func testLate() {
        // currentWeek 3 mais prochaine séance en semaine 1 → ligne late visible.
        let s = summary(currentWeekNumber: 3, nextSessionIsLate: true,
                        nextSession: session(weekNumber: 1))
        assert(card(s), height: 170)
    }

    func testProgramCompleted() {
        let s = summary(weekCompletedSessions: 3, totalSessionsCompleted: 12, totalSessions: 12)
        assert(card(s), height: 150)
    }

    func testDormant() {
        let s = summary(weekStartDate: nil, currentWeekNumber: 1,
                        weekCompletedSessions: 0, totalSessionsCompleted: 0)
        assert(card(s), height: 150)
    }

    func testLongTitle_truncation() {
        // Vérifie le rendu lineLimit(1) sur un titre composite long (point de
        // vigilance party doc « Triathlon — Distanc... »).
        let s = summary(templateName: "Triathlon — Distance Olympique préparation été",
                        sport: .triathlon)
        assert(card(s), height: 150)
    }
}
