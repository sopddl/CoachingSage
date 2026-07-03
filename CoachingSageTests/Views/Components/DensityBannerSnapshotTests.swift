// CoachingSageTests/Views/Components/DensityBannerSnapshotTests.swift
// Densité B (2026-07-02, increment 4) — preuve visuelle de la bannière phrase
// Léon dans `AdaptedProgramView` : affichée quand `program.appliedRules`
// contient une règle `.density` (hot path post-création), absente sinon.
//
// ⚠️ Même limite locale que `ProgramCardSnapshotTests` : les `LocalizedStringKey`
// rendent en raw key dans le contexte SnapshotTesting (Bundle.main non swizzlé).
// Le filet vérifie : présence/absence de la bannière, layout, icône. La
// résolution FR/EN/ES réelle des clés est verrouillée par `DensityI18nTests`.
//
// Mode `record` : 1ère exécution crée les .png sous `__Snapshots__/`.
import XCTest
import SwiftUI
import SnapshotTesting
import TemplateModel

final class DensityBannerSnapshotTests: XCTestCase {

    private let frenchLocale = Locale(identifier: "fr")

    // MARK: - Fixtures

    private func makeProgram(densified: Bool) -> AdaptedProgram {
        let week = AdaptedWeek(
            weekNumber: 1,
            theme: "Reprise",
            goal: "Retrouver le rythme",
            sessions: [
                AdaptedSession(
                    day: 1,
                    name: "Renfo de support",
                    durationMinutes: 35,
                    type: .strength,
                    warmup: "5 min de mobilité",
                    exercises: [
                        AdaptedExercise(
                            name: "Gainage planche",
                            originalName: "Gainage planche",
                            sets: densified ? 3 : 2,
                            reps: "10",
                            restSeconds: 45,
                            targetZone: "RPE 5-6"
                        )
                    ],
                    cooldown: "5 min d'étirements"
                )
            ]
        )
        let rules: [AppliedRule] = densified
            ? [AppliedRule(
                ruleType: .density, weekNumber: 1, day: 1,
                originalExerciseName: "Gainage planche", outcome: .densified,
                detail: "+1 série (2 → 3)"
            )]
            : []
        return AdaptedProgram(
            templateId: "running-beginner-couch-to-5k",
            sport: .running,
            level: .beginner,
            appliedAt: Date(timeIntervalSince1970: 1_700_000_000),
            weeks: [week],
            appliedRules: rules,
            requiresAIAssist: false,
            aiAssistReason: nil,
            durationMode: .routineCyclic,
            targetDate: nil
        )
    }

    private func view(densified: Bool) -> some View {
        AdaptedProgramView(program: makeProgram(densified: densified))
            .background(Color(uiColor: .systemBackground))
            .environment(\.locale, frenchLocale)
    }

    // MARK: - Tests

    private func assert(_ view: some View,
                        testName: String = #function, line: UInt = #line) {
        assertSnapshot(of: view, as: .image(precision: 0.99, perceptualPrecision: 0.97,
                                            layout: .fixed(width: 393, height: 500)),
                       testName: testName, line: line)
    }

    func testDensityBannerVisibleWhenDensityRuleApplied() {
        assert(view(densified: true))
    }

    func testNoBannerWithoutDensityRule() {
        assert(view(densified: false))
    }
}
