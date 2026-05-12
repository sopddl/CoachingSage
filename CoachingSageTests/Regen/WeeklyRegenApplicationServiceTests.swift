// CoachingSageTests/Regen/WeeklyRegenApplicationServiceTests.swift
// Story 3.4 Phase B.2 — tests des helpers purs (SessionVolumeScaler,
// Level.regressedForRestart, currentWeekNumber). Les tests d'orchestration
// (applyDecision + checkAndApplyIfDue) sont déférés à B.8 e2e — `Task 167`
// crash runtime 2026-05-12 sur mutation `@Model AdaptedProgramRecord` hors
// `ModelContext`, cf `lessons_swiftdata_inmemory_test_hang` cousin probable.
import XCTest
import TemplateModel
@testable import CoachingSage

final class WeeklyRegenApplicationServiceTests: XCTestCase {

    // MARK: - SessionVolumeScaler

    func testScale_progressIncreasesDuration() {
        XCTAssertEqual(SessionVolumeScaler.scale(durationMinutes: 30, multiplier: 1.10), 33)
        XCTAssertEqual(SessionVolumeScaler.scale(durationMinutes: 50, multiplier: 1.10), 55)
        XCTAssertEqual(SessionVolumeScaler.scale(durationMinutes: 20, multiplier: 1.10), 22)
    }

    func testScale_reduceDecreasesDuration() {
        XCTAssertEqual(SessionVolumeScaler.scale(durationMinutes: 40, multiplier: 0.75), 30)
        XCTAssertEqual(SessionVolumeScaler.scale(durationMinutes: 60, multiplier: 0.75), 45)
        XCTAssertEqual(SessionVolumeScaler.scale(durationMinutes: 40, multiplier: 0.5), 20)
    }

    func testScale_maintainKeepsDuration() {
        XCTAssertEqual(SessionVolumeScaler.scale(durationMinutes: 30, multiplier: 1.0), 30)
    }

    func testScale_clampsToMinDuration() {
        // 4 × 0.5 = 2 → clamp à 5 (plancher).
        XCTAssertEqual(SessionVolumeScaler.scale(durationMinutes: 4, multiplier: 0.5), 5)
        XCTAssertEqual(SessionVolumeScaler.scale(durationMinutes: 10, multiplier: 0.1), 5)
    }

    func testScale_clampsToMaxDuration() {
        // 200 × 2.0 = 400 → clamp à 240 (plafond filet anti-multiplier corrompu).
        XCTAssertEqual(SessionVolumeScaler.scale(durationMinutes: 200, multiplier: 2.0), 240)
    }

    func testScale_zeroDurationStaysZero() {
        // Une session rest avec duration=0 ne doit pas être promue à 5.
        XCTAssertEqual(SessionVolumeScaler.scale(durationMinutes: 0, multiplier: 1.10), 0)
    }

    func testScale_clampsCorruptedMultiplier() {
        // Multiplier 100x (bug amont) → clampé à 10x avant application.
        XCTAssertEqual(SessionVolumeScaler.scale(durationMinutes: 30, multiplier: 100), 240)
    }

    // MARK: - Level.regressedForRestart

    func testRegressedForRestart_steppedDown() {
        XCTAssertEqual(Level.competitive.regressedForRestart(), .regular)
        XCTAssertEqual(Level.regular.regressedForRestart(), .recreational)
        XCTAssertEqual(Level.recreational.regressedForRestart(), .beginner)
    }

    func testRegressedForRestart_beginnerFloor() {
        XCTAssertEqual(Level.beginner.regressedForRestart(), .beginner)
    }

    // MARK: - currentWeekNumber

    private func makeWeekStart() -> Date {
        var c = DateComponents()
        c.year = 2024
        c.month = 7
        c.day = 8 // lundi
        c.hour = 0
        return Calendar.current.date(from: c)!
    }

    func testCurrentWeekNumber_atWeekStart_isOne() {
        let weekStart = makeWeekStart()
        XCTAssertEqual(
            DefaultWeeklyRegenApplicationService.currentWeekNumber(
                weekStartDate: weekStart,
                now: weekStart
            ),
            1
        )
    }

    func testCurrentWeekNumber_day3_stillWeekOne() {
        let weekStart = makeWeekStart()
        let day3 = weekStart.addingTimeInterval(2 * 24 * 3600)
        XCTAssertEqual(
            DefaultWeeklyRegenApplicationService.currentWeekNumber(
                weekStartDate: weekStart,
                now: day3
            ),
            1
        )
    }

    func testCurrentWeekNumber_day8_isWeekTwo() {
        let weekStart = makeWeekStart()
        let day8 = weekStart.addingTimeInterval(8 * 24 * 3600)
        XCTAssertEqual(
            DefaultWeeklyRegenApplicationService.currentWeekNumber(
                weekStartDate: weekStart,
                now: day8
            ),
            2
        )
    }

    func testCurrentWeekNumber_day15_isWeekThree() {
        let weekStart = makeWeekStart()
        let day15 = weekStart.addingTimeInterval(15 * 24 * 3600)
        XCTAssertEqual(
            DefaultWeeklyRegenApplicationService.currentWeekNumber(
                weekStartDate: weekStart,
                now: day15
            ),
            3
        )
    }

    func testCurrentWeekNumber_nowBeforeStart_returnsOne() {
        let weekStart = makeWeekStart()
        let beforeStart = weekStart.addingTimeInterval(-3600) // 1h avant
        XCTAssertEqual(
            DefaultWeeklyRegenApplicationService.currentWeekNumber(
                weekStartDate: weekStart,
                now: beforeStart
            ),
            1
        )
    }
}
