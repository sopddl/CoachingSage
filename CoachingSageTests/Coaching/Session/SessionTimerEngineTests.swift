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
        // 1 pré-annonce en tête + (work, rest) ×3 sans rest final = 1 + 5 = 6.
        XCTAssertEqual(phases.count, 6)
        XCTAssertEqual(phases.first?.kind, .prepare) // anti-Decathlon : 1ʳᵉ phase = prepare
        let works = phases.filter { $0.kind == .work }
        XCTAssertEqual(works.count, 3)
        XCTAssertEqual(works.first?.duration, 40)
        XCTAssertEqual(works.first?.totalRounds, 3)
        XCTAssertEqual(phases.filter { $0.kind == .rest }.first?.duration, 20)
        XCTAssertEqual(phases.last?.kind, .work) // pas de rest après le dernier tour
    }

    func test_builder_singleLeadingPrepare() {
        // Story 3.35f — UNE seule pré-annonce en tête (les transitions suivantes
        // sont annoncées à la voix, pas par une phase prepare).
        let s = session(type: .interval, exercises: [
            AdaptedExercise(name: "A", originalName: "A", sets: 2, duration: "30/15")
        ])
        let phases = SessionTimerPhaseBuilder.phases(for: s, sportCode: "hiit")
        XCTAssertEqual(phases.filter { $0.kind == .prepare }.count, 1)
        XCTAssertEqual(phases.first?.kind, .prepare)
    }

    // MARK: - Run/walk AVEC échauffement + récup (cause racine device 3.35f)

    func test_builder_runWalk_withWarmupCooldown_stillDecomposes() {
        // La vraie séance : échauffement + bloc run/walk (sets 8) + récup.
        // Régression du bug `steps.count == 1` qui empêchait la décomposition.
        let s = AdaptedSession(
            day: 1, name: "Run/walk découverte", durationMinutes: 35, type: .mixed,
            warmup: "5 min marche + 10 cercles. Total : 8 min.",
            exercises: [AdaptedExercise(name: "Bloc run/walk 1 min / 1 min 30", originalName: "x",
                                        sets: 8, duration: "1 min course lente + 1 min 30 marche rapide", restSeconds: 0)],
            cooldown: "3 min marche lente."
        )
        let phases = SessionTimerPhaseBuilder.phases(for: s, sportCode: "running")
        // warmup(chrono) + prepare + (course+marche)×8 + cooldown(chrono) = 1+1+16+1 = 19.
        XCTAssertEqual(phases.count, 19)
        XCTAssertEqual(phases.first?.kind, .warmup)
        // Bug #6 — échauffement/récup chronométrés (auto-avance + pause), plus manuels.
        XCTAssertFalse(phases.first?.isManual ?? true)
        XCTAssertEqual(phases.first?.duration, 480) // « Total : 8 min »
        XCTAssertEqual(phases.last?.kind, .cooldown)
        XCTAssertFalse(phases.last?.isManual ?? true)
        XCTAssertEqual(phases.last?.duration, 180)  // « 3 min marche lente »
        // Décomposition bien présente malgré warmup/cooldown.
        XCTAssertTrue(phases.contains { $0.label == .run(index: 1, total: 8) })
        XCTAssertTrue(phases.contains { $0.label == .walk(index: 8, total: 8) })
        // Le segment course dure 60 s (et pas 1 s ni la durée du bloc entier).
        // (on exclut la pré-annonce qui porte aussi le label du 1ᵉʳ segment)
        let firstRun = phases.first { phase in
            guard phase.kind == .work else { return false }
            if case .run = phase.label { return true }
            return false
        }
        XCTAssertEqual(firstRun?.duration, 60)
    }

    func test_engine_manualPhaseWaitsForSkip() {
        // L'échauffement manuel ne décompte pas tout seul.
        let warmup = SessionTimerPhase(id: 0, kind: .warmup, duration: 0, stepIndex: 0, label: .warmup, isManual: true)
        let work = SessionTimerPhase(id: 1, kind: .work, duration: 60, stepIndex: 1, label: .effort)
        let e = SessionTimerEngine(phases: [warmup, work])
        e.start()
        tick(e, 5) // ne doit pas avancer (phase manuelle)
        XCTAssertEqual(e.currentPhase?.kind, .warmup)
        e.skip()   // « Avancer »
        XCTAssertEqual(e.currentPhase?.kind, .work)
        XCTAssertEqual(e.remaining, 60)
    }

    func test_builder_hiitMultiExo_oneRound() {
        let s = session(type: .interval, exercises: [
            AdaptedExercise(name: "A", originalName: "A", duration: "30/15"),
            AdaptedExercise(name: "B", originalName: "B", duration: "30/15")
        ])
        let phases = SessionTimerPhaseBuilder.phases(for: s, sportCode: "hiit")
        XCTAssertEqual(phases.filter { $0.kind == .work }.count, 2)
    }

    // MARK: - Builder run/walk (décomposition, fix device 3.35d)

    func test_builder_runWalk_decomposesIntoSegments() {
        // 1 exo run/walk, sets=8, "1 min course lente + 1 min 30 marche rapide".
        let s = session(type: .mixed, exercises: [
            AdaptedExercise(name: "Bloc run/walk", originalName: "Bloc run/walk",
                            sets: 8, duration: "1 min course lente + 1 min 30 marche rapide", restSeconds: 0)
        ])
        let phases = SessionTimerPhaseBuilder.phases(for: s, sportCode: "running")
        // 1 prepare + 8 tours × 2 segments = 17 phases.
        XCTAssertEqual(phases.count, 1 + 8 * 2)
        XCTAssertEqual(phases.first?.kind, .prepare)
        // Premier segment = Course (60 s, .work), deuxième = Marche (90 s, .rest).
        XCTAssertEqual(phases[1].kind, .work)
        XCTAssertEqual(phases[1].duration, 60)
        XCTAssertEqual(phases[1].label, .run(index: 1, total: 8))
        XCTAssertEqual(phases[2].kind, .rest)
        XCTAssertEqual(phases[2].duration, 90) // "1 min 30" = 90 s (et pas 1 s)
        XCTAssertEqual(phases[2].label, .walk(index: 1, total: 8))
        // Numérotation croissante sur les tours.
        XCTAssertEqual(phases[3].label, .run(index: 2, total: 8))
        XCTAssertEqual(phases[4].label, .walk(index: 2, total: 8))
        XCTAssertEqual(phases.last?.label, .walk(index: 8, total: 8))
    }

    func test_builder_runWalk_engineAdvancesThroughSegments() {
        // Régression du P0 device : l'avance ne menait nulle part (1 seul bloc).
        let s = session(type: .mixed, exercises: [
            AdaptedExercise(name: "Bloc run/walk", originalName: "Bloc run/walk",
                            sets: 2, duration: "1 min course + 1 min 30 marche", restSeconds: 0)
        ])
        let phases = SessionTimerPhaseBuilder.phases(for: s, sportCode: "running")
        let e = SessionTimerEngine(phases: phases)
        e.start()
        XCTAssertEqual(e.currentPhase?.kind, .prepare)
        e.skip() // → Course 1
        XCTAssertEqual(e.currentPhase?.label, .run(index: 1, total: 2))
        e.skip() // → Marche 1
        XCTAssertEqual(e.currentPhase?.label, .walk(index: 1, total: 2))
        e.skip() // → Course 2
        XCTAssertEqual(e.currentPhase?.label, .run(index: 2, total: 2))
    }

    // MARK: - Builder yoga (tenue)

    func test_builder_yoga_holdPerPosture() {
        let s = session(type: .mobility, exercises: [
            AdaptedExercise(name: "Guerrier", originalName: "Guerrier", duration: "45 s"),
            AdaptedExercise(name: "Arbre", originalName: "Arbre", duration: "1 min")
        ])
        let phases = SessionTimerPhaseBuilder.phases(for: s, sportCode: "yoga")
        // 1 pré-annonce en tête + 1 tenue par posture = 3 phases.
        XCTAssertEqual(phases.count, 3)
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

    // MARK: - Bug #9 — muscu décomposée en séries (work estimé + repos), auto-chaînée

    func test_builder_strength_decomposesPerSet() {
        let s = session(type: .strength, exercises: [
            AdaptedExercise(name: "Squat", originalName: "Squat", sets: 3, reps: "8", restSeconds: 90),
            AdaptedExercise(name: "Pompes", originalName: "Pompes", sets: 2, reps: "12", restSeconds: 60)
        ])
        let phases = SessionTimerPhaseBuilder.phases(for: s, sportCode: "strengthTraining")
        // 3 séries squat + 2 séries pompes = 5 phases work.
        XCTAssertEqual(phases.filter { $0.kind == .work }.count, 5)
        // Repos après chaque série SAUF la toute dernière → 4 phases rest.
        XCTAssertEqual(phases.filter { $0.kind == .rest }.count, 4)
        // La dernière phase n'est pas un repos (pas de repos final).
        XCTAssertEqual(phases.last?.kind, .work)
        // 1ʳᵉ série squat : work estimé (8 reps × 4 = 32 s), round 1/3, exo 1/2.
        let firstWork = phases.first { $0.kind == .work }
        XCTAssertEqual(firstWork?.duration, 32)
        XCTAssertEqual(firstWork?.round, 1)
        XCTAssertEqual(firstWork?.totalRounds, 3)
        XCTAssertEqual(firstWork?.exerciseInRound, 1)
        XCTAssertEqual(firstWork?.totalInRound, 2)
    }

    func test_estimatedSetSeconds_repsAndDurationAndClamp() {
        // Reps : ~4 s/rep, borné [25, 75].
        XCTAssertEqual(SessionTimerPhaseBuilder.estimatedSetSeconds(
            AdaptedExercise(name: "x", originalName: "x", sets: 4, reps: "10")), 40)
        XCTAssertEqual(SessionTimerPhaseBuilder.estimatedSetSeconds(
            AdaptedExercise(name: "x", originalName: "x", sets: 4, reps: "5")), 25)   // borne basse
        XCTAssertEqual(SessionTimerPhaseBuilder.estimatedSetSeconds(
            AdaptedExercise(name: "x", originalName: "x", sets: 4, reps: "30")), 75)  // borne haute
        // Durée explicite (gainage « 30s ») fait foi.
        XCTAssertEqual(SessionTimerPhaseBuilder.estimatedSetSeconds(
            AdaptedExercise(name: "Gainage", originalName: "Gainage", sets: 3, duration: "30s")), 30)
        // Ni reps ni durée → défaut.
        XCTAssertEqual(SessionTimerPhaseBuilder.estimatedSetSeconds(
            AdaptedExercise(name: "x", originalName: "x", sets: 3)), SessionTimerPhaseBuilder.defaultWorkSeconds)
    }

    // MARK: - back() (revue ui-reviewer 2026-06-07 — retour arrière en minuté)

    func test_back_returnsToPreviousPhaseAndResetsTime() {
        let e = SessionTimerEngine(phases: [phase(.work, 40), phase(.rest, 20)])
        e.start()
        e.skip()
        XCTAssertEqual(e.currentIndex, 1)
        e.back()
        XCTAssertEqual(e.currentIndex, 0)
        XCTAssertEqual(e.remaining, 40)
    }

    func test_back_onFirstPhase_restartsItNoUnderflow() {
        let e = SessionTimerEngine(phases: [phase(.work, 40)])
        e.start(); tick(e, 2)
        e.back()
        XCTAssertEqual(e.currentIndex, 0)
        XCTAssertEqual(e.remaining, 40)
    }

    func test_back_whenFinished_reopensLastPhase() {
        let e = SessionTimerEngine(phases: [phase(.work, 40)])
        e.start(); e.skip()
        XCTAssertTrue(e.isFinished)
        e.back()
        XCTAssertFalse(e.isFinished)
        XCTAssertEqual(e.currentPhase?.kind, .work)
        XCTAssertEqual(e.remaining, 40)
    }

    private func tick(_ e: SessionTimerEngine, _ n: Int) {
        for _ in 0..<n { e.tick() }
    }

    private func phase(_ kind: SessionTimerPhase.Kind, _ duration: Int) -> SessionTimerPhase {
        SessionTimerPhase(id: 0, kind: kind, duration: duration, stepIndex: 0, label: .effort,
                          round: 1, totalRounds: 1, exerciseInRound: 1, totalInRound: 1)
    }

    private func session(type: SessionType, exercises: [AdaptedExercise]) -> AdaptedSession {
        AdaptedSession(day: 1, name: "S", durationMinutes: 30, type: type,
                       warmup: nil, exercises: exercises, cooldown: nil)
    }
}
