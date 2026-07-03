// CoachingSageTests/Coaching/Session/SessionWhyExplainerTests.swift
// Story 3.18 Phase 2 — tests heuristique justification "Pourquoi cette séance ?".
import XCTest
import TemplateModel

final class SessionWhyExplainerTests: XCTestCase {

    // MARK: - position

    func test_position_earlyForWeek1() {
        let p = program(durationMode: .deadlineEstimated, totalWeeks: 8, hasTarget: true)
        XCTAssertEqual(SessionWhyExplainer.position(weekNumber: 1, program: p), .early)
    }

    func test_position_earlyForWeek2() {
        let p = program(durationMode: .deadlineEstimated, totalWeeks: 8, hasTarget: true)
        XCTAssertEqual(SessionWhyExplainer.position(weekNumber: 2, program: p), .early)
    }

    func test_position_lateForLast2WeeksOfDeadline() {
        let p = program(durationMode: .deadlineEstimated, totalWeeks: 8, hasTarget: true)
        XCTAssertEqual(SessionWhyExplainer.position(weekNumber: 7, program: p), .late)
        XCTAssertEqual(SessionWhyExplainer.position(weekNumber: 8, program: p), .late)
    }

    func test_position_midForMiddleWeeksOfDeadline() {
        let p = program(durationMode: .deadlineEstimated, totalWeeks: 8, hasTarget: true)
        XCTAssertEqual(SessionWhyExplainer.position(weekNumber: 3, program: p), .mid)
        XCTAssertEqual(SessionWhyExplainer.position(weekNumber: 5, program: p), .mid)
        XCTAssertEqual(SessionWhyExplainer.position(weekNumber: 6, program: p), .mid)
    }

    func test_position_noLateInRoutineCyclic() {
        // En routineCyclic, jamais de phase taper même en fin de cycle
        let p = program(durationMode: .routineCyclic, totalWeeks: 12, hasTarget: false)
        XCTAssertEqual(SessionWhyExplainer.position(weekNumber: 11, program: p), .mid)
        XCTAssertEqual(SessionWhyExplainer.position(weekNumber: 12, program: p), .mid)
    }

    func test_position_shortProgramOnlyEarlyOrMid() {
        // total < 4 → pas de phase late significative, fallback mid
        let p = program(durationMode: .deadlineEstimated, totalWeeks: 3, hasTarget: true)
        XCTAssertEqual(SessionWhyExplainer.position(weekNumber: 3, program: p), .mid)
    }

    // MARK: - explanationKey — par type & position

    func test_explanationKey_intervalEarly() {
        let p = program(durationMode: .deadlineEstimated, totalWeeks: 8, hasTarget: true)
        let key = SessionWhyExplainer.explanationKey(
            session: session(type: .interval),
            week: AdaptedWeek(weekNumber: 1, theme: "", goal: "", sessions: []),
            program: p
        )
        XCTAssertEqual(key, "coaching.session.why.interval.early")
    }

    func test_explanationKey_intervalMid() {
        let p = program(durationMode: .deadlineEstimated, totalWeeks: 8, hasTarget: true)
        let key = SessionWhyExplainer.explanationKey(
            session: session(type: .interval),
            week: AdaptedWeek(weekNumber: 4, theme: "", goal: "", sessions: []),
            program: p
        )
        XCTAssertEqual(key, "coaching.session.why.interval.mid")
    }

    func test_explanationKey_intervalLate() {
        let p = program(durationMode: .deadlineEstimated, totalWeeks: 8, hasTarget: true)
        let key = SessionWhyExplainer.explanationKey(
            session: session(type: .interval),
            week: AdaptedWeek(weekNumber: 8, theme: "", goal: "", sessions: []),
            program: p
        )
        XCTAssertEqual(key, "coaching.session.why.interval.late")
    }

    func test_explanationKey_enduranceEarly() {
        let p = program(durationMode: .deadlineEstimated, totalWeeks: 8, hasTarget: true)
        let key = SessionWhyExplainer.explanationKey(
            session: session(type: .endurance),
            week: AdaptedWeek(weekNumber: 1, theme: "", goal: "", sessions: []),
            program: p
        )
        XCTAssertEqual(key, "coaching.session.why.endurance.early")
    }

    func test_explanationKey_strengthMid() {
        let p = program(durationMode: .deadlineEstimated, totalWeeks: 8, hasTarget: true)
        let key = SessionWhyExplainer.explanationKey(
            session: session(type: .strength),
            week: AdaptedWeek(weekNumber: 4, theme: "", goal: "", sessions: []),
            program: p
        )
        XCTAssertEqual(key, "coaching.session.why.strength.mid")
    }

    func test_explanationKey_techniqueAnyPosition() {
        let p = program(durationMode: .deadlineEstimated, totalWeeks: 8, hasTarget: true)
        XCTAssertEqual(
            SessionWhyExplainer.explanationKey(
                session: session(type: .technique),
                week: AdaptedWeek(weekNumber: 1, theme: "", goal: "", sessions: []),
                program: p
            ),
            "coaching.session.why.technique.any"
        )
        XCTAssertEqual(
            SessionWhyExplainer.explanationKey(
                session: session(type: .technique),
                week: AdaptedWeek(weekNumber: 8, theme: "", goal: "", sessions: []),
                program: p
            ),
            "coaching.session.why.technique.any"
        )
    }

    func test_explanationKey_mobility() {
        let p = program(durationMode: .deadlineEstimated, totalWeeks: 8, hasTarget: true)
        XCTAssertEqual(
            SessionWhyExplainer.explanationKey(
                session: session(type: .mobility),
                week: AdaptedWeek(weekNumber: 4, theme: "", goal: "", sessions: []),
                program: p
            ),
            "coaching.session.why.mobility.any"
        )
    }

    func test_explanationKey_mixed() {
        let p = program(durationMode: .deadlineEstimated, totalWeeks: 8, hasTarget: true)
        XCTAssertEqual(
            SessionWhyExplainer.explanationKey(
                session: session(type: .mixed),
                week: AdaptedWeek(weekNumber: 3, theme: "", goal: "", sessions: []),
                program: p
            ),
            "coaching.session.why.mixed.any"
        )
    }

    func test_explanationKey_other_returnsGeneric() {
        let p = program(durationMode: .deadlineEstimated, totalWeeks: 8, hasTarget: true)
        XCTAssertEqual(
            SessionWhyExplainer.explanationKey(
                session: session(type: .other),
                week: AdaptedWeek(weekNumber: 1, theme: "", goal: "", sessions: []),
                program: p
            ),
            "coaching.session.why.generic"
        )
    }

    func test_explanationKey_rest_returnsNil() {
        let p = program(durationMode: .deadlineEstimated, totalWeeks: 8, hasTarget: true)
        XCTAssertNil(
            SessionWhyExplainer.explanationKey(
                session: session(type: .rest),
                week: AdaptedWeek(weekNumber: 4, theme: "", goal: "", sessions: []),
                program: p
            )
        )
    }

    func test_explanationKey_routineCyclicNeverLate() {
        // En routineCyclic, semaine 11/12 ne produit jamais "late" → mid
        let p = program(durationMode: .routineCyclic, totalWeeks: 12, hasTarget: false)
        XCTAssertEqual(
            SessionWhyExplainer.explanationKey(
                session: session(type: .interval),
                week: AdaptedWeek(weekNumber: 12, theme: "", goal: "", sessions: []),
                program: p
            ),
            "coaching.session.why.interval.mid"
        )
    }

    // MARK: - Helpers

    private func session(type: SessionType) -> AdaptedSession {
        AdaptedSession(
            day: 1,
            name: "Test",
            durationMinutes: 30,
            type: type,
            warmup: nil,
            exercises: [],
            cooldown: nil
        )
    }

    private func program(durationMode: ProgramDurationMode, totalWeeks: Int, hasTarget: Bool) -> AdaptedProgram {
        let weeks = (1...totalWeeks).map { wn in
            AdaptedWeek(weekNumber: wn, theme: "—", goal: "—", sessions: [])
        }
        return AdaptedProgram(
            templateId: "fx", sport: .running, level: .beginner,
            appliedAt: Date(), weeks: weeks, appliedRules: [],
            requiresAIAssist: false,
            durationMode: durationMode,
            targetDate: hasTarget ? Date().addingTimeInterval(Double(totalWeeks * 7 * 86400)) : nil
        )
    }
}
