// CoachingSageTests/Adapter/ProgramDurationResolverTests.swift
// Story sœur post-3.3b — tests métier du resolver durée + resize.
import XCTest
import TemplateModel
@testable import CoachingSage

final class ProgramDurationResolverTests: XCTestCase {

    let resolver = ProgramDurationResolver()

    // MARK: - resolve(): routineCyclic

    func testResolveRoutineCyclicAlways12WeeksRegardlessOfTemplate() {
        let (weeks, target) = resolver.resolve(
            durationMode: .routineCyclic,
            targetDate: nil,
            goal: "wellness",
            sport: .running,
            level: .regular,
            templateDurationWeeks: 8,
            now: Date()
        )
        XCTAssertEqual(weeks, 12)
        XCTAssertNil(target)
    }

    // MARK: - resolve(): deadlineFixed

    func testResolveDeadlineFixedComputesWeeksFromTarget() {
        let now = Date(timeIntervalSince1970: 1_700_000_000)
        let target = Calendar.current.date(byAdding: .weekOfYear, value: 10, to: now)!

        let (weeks, finalTarget) = resolver.resolve(
            durationMode: .deadlineFixed,
            targetDate: target,
            goal: "10k",
            sport: .running,
            level: .regular,
            templateDurationWeeks: 16,  // template plus long que demandé
            now: now
        )

        XCTAssertEqual(weeks, 10)
        XCTAssertEqual(finalTarget, target)
    }

    func testResolveDeadlineFixedClampsToMinWhenTooShort() {
        let now = Date(timeIntervalSince1970: 1_700_000_000)
        let target = Calendar.current.date(byAdding: .day, value: 5, to: now)!  // < 1 sem

        let (weeks, _) = resolver.resolve(
            durationMode: .deadlineFixed,
            targetDate: target,
            goal: "5k",
            sport: .running,
            level: .beginner,
            templateDurationWeeks: 8,
            now: now
        )

        XCTAssertEqual(weeks, ProgramDurationResolver.minWeeks)
    }

    func testResolveDeadlineFixedClampsToMaxWhenTooLong() {
        let now = Date(timeIntervalSince1970: 1_700_000_000)
        let target = Calendar.current.date(byAdding: .weekOfYear, value: 50, to: now)!

        let (weeks, _) = resolver.resolve(
            durationMode: .deadlineFixed,
            targetDate: target,
            goal: "marathon",
            sport: .running,
            level: .beginner,
            templateDurationWeeks: 20,
            now: now
        )

        XCTAssertEqual(weeks, ProgramDurationResolver.maxWeeks)
    }

    func testResolveDeadlineFixedFallsBackToTemplateDurationIfTargetNil() {
        let (weeks, finalTarget) = resolver.resolve(
            durationMode: .deadlineFixed,
            targetDate: nil,  // anormal — defensif
            goal: "10k",
            sport: .running,
            level: .regular,
            templateDurationWeeks: 8,
            now: Date()
        )

        XCTAssertEqual(weeks, 8)
        XCTAssertNil(finalTarget)
    }

    // MARK: - resolve(): deadlineEstimated

    func testResolveDeadlineEstimatedUsesLUT() {
        let now = Date(timeIntervalSince1970: 1_700_000_000)

        let (weeksMarathon, _) = resolver.resolve(
            durationMode: .deadlineEstimated,
            targetDate: nil,
            goal: "marathon",
            sport: .running,
            level: .beginner,
            templateDurationWeeks: 16,  // ignoré en estimated
            now: now
        )
        XCTAssertEqual(weeksMarathon, 20)  // LUT running:marathon:beginner

        let (weeks5k, _) = resolver.resolve(
            durationMode: .deadlineEstimated,
            targetDate: nil,
            goal: "5k",
            sport: .running,
            level: .competitive,
            templateDurationWeeks: 8,
            now: now
        )
        XCTAssertEqual(weeks5k, 6)  // LUT running:5k:competitive
    }

    func testResolveDeadlineEstimatedComputesTargetDateFromNow() {
        let now = Date(timeIntervalSince1970: 1_700_000_000)
        let (weeks, finalTarget) = resolver.resolve(
            durationMode: .deadlineEstimated,
            targetDate: nil,
            goal: "half_marathon",
            sport: .running,
            level: .recreational,
            templateDurationWeeks: 12,
            now: now
        )

        XCTAssertEqual(weeks, 12)
        let expected = Calendar.current.date(byAdding: .weekOfYear, value: 12, to: now)!
        XCTAssertEqual(finalTarget, expected)
    }

    func testResolveDeadlineEstimatedFallsBackToDefaultIfNotInLUT() {
        let (weeks, _) = resolver.resolve(
            durationMode: .deadlineEstimated,
            targetDate: nil,
            goal: "imaginary_goal",
            sport: .running,
            level: .beginner,
            templateDurationWeeks: 12,
            now: Date()
        )
        XCTAssertEqual(weeks, 10)  // default beginner

        let (weeksAdv, _) = resolver.resolve(
            durationMode: .deadlineEstimated,
            targetDate: nil,
            goal: "imaginary_goal",
            sport: .swimming,
            level: .competitive,
            templateDurationWeeks: 8,
            now: Date()
        )
        XCTAssertEqual(weeksAdv, 6)  // default competitive
    }

    // MARK: - resize(): truncate / cycle / no-op

    func testResizeNoOpWhenSameLength() {
        let weeks = makeWeeks(count: 4)
        let result = resolver.resize(weeks: weeks, to: 4)
        XCTAssertEqual(result.count, 4)
        XCTAssertEqual(result.map(\.weekNumber), [1, 2, 3, 4])
    }

    func testResizeTruncatesToFirstN() {
        let weeks = makeWeeks(count: 8)
        let result = resolver.resize(weeks: weeks, to: 5)
        XCTAssertEqual(result.count, 5)
        XCTAssertEqual(result.map(\.weekNumber), [1, 2, 3, 4, 5])
        // Vérifie que ce sont les 5 premiers weeks (renumérotés).
        XCTAssertEqual(result.map(\.theme), ["Theme1", "Theme2", "Theme3", "Theme4", "Theme5"])
    }

    func testResizeCyclesFromWeek1WhenLonger() {
        let weeks = makeWeeks(count: 4)  // themes T1, T2, T3, T4
        let result = resolver.resize(weeks: weeks, to: 10)

        XCTAssertEqual(result.count, 10)
        XCTAssertEqual(result.map(\.weekNumber), [1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
        // Cycle : T1, T2, T3, T4, T1, T2, T3, T4, T1, T2
        XCTAssertEqual(result.map(\.theme),
            ["Theme1", "Theme2", "Theme3", "Theme4",
             "Theme1", "Theme2", "Theme3", "Theme4",
             "Theme1", "Theme2"])
    }

    func testResizeEmptyInputReturnsEmpty() {
        let result = resolver.resize(weeks: [], to: 12)
        XCTAssertTrue(result.isEmpty)
    }

    func testResizeZeroTargetReturnsInputUnchanged() {
        let weeks = makeWeeks(count: 3)
        let result = resolver.resize(weeks: weeks, to: 0)
        XCTAssertEqual(result.count, 3)  // no-op : guard targetWeeks > 0
    }

    // MARK: - Helpers

    private func makeWeeks(count: Int) -> [AdaptedWeek] {
        (1...count).map { n in
            AdaptedWeek(
                weekNumber: n,
                theme: "Theme\(n)",
                goal: "Goal\(n)",
                sessions: [
                    AdaptedSession(
                        day: 1,
                        name: "Session W\(n)",
                        durationMinutes: 30,
                        type: .endurance,
                        warmup: nil,
                        exercises: [],
                        cooldown: nil
                    )
                ]
            )
        }
    }
}
