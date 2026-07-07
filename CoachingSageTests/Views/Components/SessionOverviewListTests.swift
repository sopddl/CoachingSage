// CoachingSageTests/Views/Components/SessionOverviewListTests.swift
// Story 3.32 (AC11) — aperçu scannable : ordre des lignes + index d'ancrage
// (contrat de scroll vers la timeline) + métrique-clé. Plus libellés Intensité.
import XCTest
import SwiftUI
import TemplateModel

final class SessionOverviewListTests: XCTestCase {

    // MARK: - Ordre & index d'ancrage (warmup → exos → cooldown)

    func test_rows_fullSession_orderAndAnchorIndices() {
        let s = AdaptedSession(
            day: 1, name: "S", durationMinutes: 50, type: .strength,
            warmup: "10 min mobilité",
            exercises: [ex(name: "Squat"), ex(name: "Pompes")],
            cooldown: "5 min étirements"
        )
        let rows = SessionOverviewList.rows(for: s, locale: Locale(identifier: "fr"))
        XCTAssertEqual(rows.count, 4)
        XCTAssertEqual(rows[0].kind, .warmup)
        XCTAssertEqual(rows[0].anchorIndex, 0)
        XCTAssertEqual(rows[1].kind, .exercise(number: 1))
        XCTAssertEqual(rows[1].anchorIndex, 1)
        XCTAssertEqual(rows[2].kind, .exercise(number: 2))
        XCTAssertEqual(rows[2].anchorIndex, 2)
        XCTAssertEqual(rows[3].kind, .cooldown)
        XCTAssertEqual(rows[3].anchorIndex, 3)
    }

    func test_rows_noWarmupNoCooldown_exercisesStartAtZero() {
        let s = AdaptedSession(
            day: 1, name: "S", durationMinutes: 30, type: .endurance,
            warmup: nil, exercises: [ex(name: "A"), ex(name: "B"), ex(name: "C")], cooldown: nil
        )
        let rows = SessionOverviewList.rows(for: s, locale: Locale(identifier: "fr"))
        XCTAssertEqual(rows.map(\.anchorIndex), [0, 1, 2])
        XCTAssertEqual(rows.map(\.kind), [.exercise(number: 1), .exercise(number: 2), .exercise(number: 3)])
    }

    func test_rows_emptyWarmupString_ignored() {
        let s = AdaptedSession(
            day: 1, name: "S", durationMinutes: 30, type: .endurance,
            warmup: "", exercises: [ex(name: "A")], cooldown: ""
        )
        let rows = SessionOverviewList.rows(for: s, locale: Locale(identifier: "fr"))
        XCTAssertEqual(rows.count, 1)
        XCTAssertEqual(rows[0].kind, .exercise(number: 1))
        XCTAssertEqual(rows[0].anchorIndex, 0)
    }

    /// Contrat d'ancrage AC7 : l'index d'aperçu correspond à l'offset utilisé par
    /// la timeline pour `.id(SessionStepAnchor.id(idx))` — donc même nombre
    /// d'items dans le même ordre.
    func test_anchorContract_matchesTimelineItemCount() {
        let s = AdaptedSession(
            day: 1, name: "S", durationMinutes: 50, type: .strength,
            warmup: "warm", exercises: [ex(name: "A"), ex(name: "B")], cooldown: "cool"
        )
        let rows = SessionOverviewList.rows(for: s, locale: Locale(identifier: "fr"))
        // warmup + 2 exos + cooldown = 4 items → anchors 0..3 contigus.
        XCTAssertEqual(rows.map(\.anchorIndex), Array(0..<4))
    }

    func test_sessionStepAnchor_idIsStable() {
        XCTAssertEqual(SessionStepAnchor.id(0), "coaching.session.step.0")
        XCTAssertEqual(SessionStepAnchor.id(7), "coaching.session.step.7")
    }

    // MARK: - Métrique-clé

    func test_compactMetric_setsAndReps() {
        XCTAssertEqual(SessionOverviewList.compactMetric(for: ex(sets: 4, reps: "8"), locale: Locale(identifier: "fr")), "4×8")
    }

    func test_compactMetric_durationOnly() {
        XCTAssertEqual(SessionOverviewList.compactMetric(for: ex(duration: "2 min"), locale: Locale(identifier: "fr")), "2 min")
    }

    func test_compactMetric_repsOnly() {
        XCTAssertEqual(SessionOverviewList.compactMetric(for: ex(reps: "12"), locale: Locale(identifier: "fr")), "12")
    }

    func test_compactMetric_nothing_returnsNil() {
        XCTAssertNil(SessionOverviewList.compactMetric(for: ex(), locale: Locale(identifier: "fr")))
    }

    // MARK: - Durée de tête (warmup/cooldown)

    func test_leadingDuration_minutes() {
        XCTAssertEqual(SessionOverviewList.leadingDuration(in: "10 min footing + 4 strides"), "10 min")
    }

    func test_leadingDuration_seconds() {
        XCTAssertEqual(SessionOverviewList.leadingDuration(in: "30s sprint"), "30 s")
    }

    func test_leadingDuration_noDuration_returnsNil() {
        XCTAssertNil(SessionOverviewList.leadingDuration(in: "étirements doux du bas du corps"))
    }

    // MARK: - Intensité (AC5) — libellés figés 1-5

    func test_intensityLabel_returnsExpectedKeys() {
        XCTAssertEqual(SessionStatsCalculator.intensityLabel(level: 1), "coaching.session.intensity.1")
        XCTAssertEqual(SessionStatsCalculator.intensityLabel(level: 2), "coaching.session.intensity.2")
        XCTAssertEqual(SessionStatsCalculator.intensityLabel(level: 3), "coaching.session.intensity.3")
        XCTAssertEqual(SessionStatsCalculator.intensityLabel(level: 4), "coaching.session.intensity.4")
        XCTAssertEqual(SessionStatsCalculator.intensityLabel(level: 5), "coaching.session.intensity.5")
    }

    func test_intensityLabel_clampsOutOfRange() {
        XCTAssertEqual(SessionStatsCalculator.intensityLabel(level: 0), "coaching.session.intensity.1")
        XCTAssertEqual(SessionStatsCalculator.intensityLabel(level: 9), "coaching.session.intensity.5")
    }

    // MARK: - Helpers

    private func ex(name: String = "Exo", sets: Int? = nil, reps: String? = nil, duration: String? = nil) -> AdaptedExercise {
        AdaptedExercise(name: LocalizedText(fr: name), originalName: name, sets: sets, reps: reps, duration: duration)
    }
}
