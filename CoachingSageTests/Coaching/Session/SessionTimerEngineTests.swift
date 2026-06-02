// CoachingSageTests/Coaching/Session/SessionTimerEngineTests.swift
// Story 3.34 (AC9) — moteur de timer + décomposition en phases : countdown,
// transition work/rest, fin de tour → tour suivant, dernier tour → terminé,
// pause gèle le temps, passer saute l'étape, pré-annonce avant chaque étape
// (1ʳᵉ incluse, anti-Decathlon).
import XCTest
@testable import CoachingSage
import TemplateModel

@MainActor
final class SessionTimerEngineTests: XCTestCase {

    // MARK: - Engine de base

    func test_emptyPhases_isFinished() {
        let e = SessionTimerEngine(phases: [])
        XCTAssertTrue(e.isFinished)
        XCTAssertNil(e.currentPhase)
    }

    func test_init_remainingIsFirstPhaseDuration() {
        let e = SessionTimerEngine(phases: [phase(.work, 40)])
        XCTAssertEqual(e.remaining, 40)
        XCTAssertFalse(e.isFinished)
    }

    func test_tick_noOpBeforeStart() {
        let e = SessionTimerEngine(phases: [phase(.work, 40)])
        e.tick()
        XCTAssertEqual(e.remaining, 40)
    }

    func test_tick_decrementsAfterStart() {
        let e = SessionTimerEngine(phases: [phase(.work, 40)])
        e.start()
        e.tick()
        XCTAssertEqual(e.remaining, 39)
    }

    func test_countdown_drainsThenAdvances() {
        let e = SessionTimerEngine(phases: [phase(.prepare, 3), phase(.work, 40)])
        e.start()
        tick(e, 3) // draine la prepare de 3 s
        XCTAssertEqual(e.currentIndex, 1)
        XCTAssertEqual(e.currentPhase?.kind, .work)
        XCTAssertEqual(e.remaining, 40)
    }

    func test_transition_workToRest() {
        let e = SessionTimerEngine(phases: [phase(.work, 2), phase(.rest, 2)])
        e.start()
        tick(e, 2)
        XCTAssertEqual(e.currentPhase?.kind, .rest)
    }

    func test_lastPhase_drainsToFinished() {
        let e = SessionTimerEngine(phases: [phase(.work, 2), phase(.rest, 2)])
        e.start()
        tick(e, 4)
        XCTAssertTrue(e.isFinished)
        XCTAssertFalse(e.isRunning)
    }

    func test_pause_freezesTime() {
        let e = SessionTimerEngine(phases: [phase(.work, 40)])
        e.start()
        e.tick() // 39
        e.pause()
        tick(e, 5)
        XCTAssertEqual(e.remaining, 39)
        XCTAssertTrue(e.isPaused)
    }

    func test_resume_continues() {
        let e = SessionTimerEngine(phases: [phase(.work, 40)])
        e.start(); e.pause(); e.resume()
        e.tick()
        XCTAssertEqual(e.remaining, 39)
    }

    func test_skip_jumpsToNextPhase() {
        let e = SessionTimerEngine(phases: [phase(.work, 40), phase(.rest, 20)])
        e.start()
        e.skip()
        XCTAssertEqual(e.currentIndex, 1)
        XCTAssertEqual(e.remaining, 20)
    }

    func test_skip_onLastPhase_finishes() {
        let e = SessionTimerEngine(phases: [phase(.work, 40)])
        e.start()
        e.skip()
        XCTAssertTrue(e.isFinished)
    }

    // MARK: - Builder HIIT (tours work/rest)

    func test_builder_hiitCircuit_roundsWorkRest() {
        // 1 exo répété 3 tours, work/rest 40/20.
        let s = session(type: .interval, exercises: [
            AdaptedExercise(name: "Burpees", originalName: "Burpees", sets: 3, duration: "40/20")
        ])
        let phases = SessionTimerPhaseBuilder.phases(for: s, sportCode: "hiit")
        // (prepare, work, rest) ×3 sans rest final = 3*2 + 2 = 8 phases.
        XCTAssertEqual(phases.count, 8)
        XCTAssertEqual(phases.first?.kind, .prepare) // anti-Decathlon : 1ʳᵉ phase = prepare
        let works = phases.filter { $0.kind == .work }
        XCTAssertEqual(works.count, 3)
        XCTAssertEqual(works.first?.duration, 40)
        XCTAssertEqual(works.first?.totalRounds, 3)
        XCTAssertEqual(phases.filter { $0.kind == .rest }.first?.duration, 20)
        XCTAssertEqual(phases.last?.kind, .work) // pas de rest après le dernier tour
    }

    func test_builder_preannounceBeforeEachEffort() {
        let s = session(type: .interval, exercises: [
            AdaptedExercise(name: "A", originalName: "A", sets: 2, duration: "30/15")
        ])
        let phases = SessionTimerPhaseBuilder.phases(for: s, sportCode: "hiit")
        // Chaque work est précédé d'une prepare.
        for (i, p) in phases.enumerated() where p.kind == .work {
            XCTAssertGreaterThan(i, 0)
            XCTAssertEqual(phases[i - 1].kind, .prepare, "work à l'index \(i) non précédé d'une prepare")
        }
    }

    func test_builder_hiitMultiExo_oneRound() {
        let s = session(type: .interval, exercises: [
            AdaptedExercise(name: "A", originalName: "A", duration: "30/15"),
            AdaptedExercise(name: "B", originalName: "B", duration: "30/15")
        ])
        let phases = SessionTimerPhaseBuilder.phases(for: s, sportCode: "hiit")
        XCTAssertEqual(phases.filter { $0.kind == .work }.count, 2)
    }

    // MARK: - Builder yoga (tenue)

    func test_builder_yoga_holdPerPosture() {
        let s = session(type: .mobility, exercises: [
            AdaptedExercise(name: "Guerrier", originalName: "Guerrier", duration: "45 s"),
            AdaptedExercise(name: "Arbre", originalName: "Arbre", duration: "1 min")
        ])
        let phases = SessionTimerPhaseBuilder.phases(for: s, sportCode: "yoga")
        // prepare + hold par posture = 4 phases.
        XCTAssertEqual(phases.count, 4)
        let holds = phases.filter { $0.kind == .hold }
        XCTAssertEqual(holds.map(\.duration), [45, 60]) // "45 s" et "1 min"
        XCTAssertEqual(phases.first?.kind, .prepare)
    }

    func test_builder_yoga_defaultHoldWhenNoDuration() {
        let s = session(type: .mobility, exercises: [
            AdaptedExercise(name: "X", originalName: "X")
        ])
        let phases = SessionTimerPhaseBuilder.phases(for: s, sportCode: "yoga")
        XCTAssertEqual(phases.filter { $0.kind == .hold }.first?.duration, SessionTimerPhaseBuilder.defaultHoldSeconds)
    }

    // MARK: - Helpers

    private func tick(_ e: SessionTimerEngine, _ n: Int) {
        for _ in 0..<n { e.tick() }
    }

    private func phase(_ kind: SessionTimerPhase.Kind, _ duration: Int) -> SessionTimerPhase {
        SessionTimerPhase(id: 0, kind: kind, duration: duration, stepIndex: 0, title: "T",
                          round: 1, totalRounds: 1, exerciseInRound: 1, totalInRound: 1)
    }

    private func session(type: SessionType, exercises: [AdaptedExercise]) -> AdaptedSession {
        AdaptedSession(day: 1, name: "S", durationMinutes: 30, type: type,
                       warmup: nil, exercises: exercises, cooldown: nil)
    }
}
