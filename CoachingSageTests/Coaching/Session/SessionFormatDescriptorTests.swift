// CoachingSageTests/Coaching/Session/SessionFormatDescriptorTests.swift
// Story 3.32 (AC10) — la case "Format" caméléon : un cas par sport + fallback +
// séance vide. Invariant : libellé non vide, jamais "—".
import XCTest
@testable import CoachingSage
import TemplateModel

final class SessionFormatDescriptorTests: XCTestCase {

    // MARK: - Un cas par sport

    func test_strength_returnsBlocks() {
        let s = session(type: .strength, exercises: [ex(), ex(), ex()])
        XCTAssertEqual(SessionFormatDescriptor.format(for: s, sportCode: "strengthTraining"), .blocks(3))
    }

    func test_hiit_withWorkRest_returnsRounds() {
        // Un circuit unique répété 4 fois, work/rest "40/20".
        let circuit = ex(sets: 4, duration: "40/20")
        let s = session(type: .interval, exercises: [circuit])
        XCTAssertEqual(
            SessionFormatDescriptor.format(for: s, sportCode: "hiit"),
            .rounds(count: 4, workSeconds: 40, restSeconds: 20)
        )
    }

    func test_hiit_workRestFromDurationPlusRestSeconds() {
        let circuit = ex(sets: 3, duration: "30s", restSeconds: 15)
        let s = session(type: .interval, exercises: [circuit])
        XCTAssertEqual(
            SessionFormatDescriptor.format(for: s, sportCode: "hiit"),
            .rounds(count: 3, workSeconds: 30, restSeconds: 15)
        )
    }

    func test_hiit_withoutWorkRest_returnsIntervals() {
        let s = session(type: .interval, exercises: [ex(), ex(), ex(), ex()])
        XCTAssertEqual(SessionFormatDescriptor.format(for: s, sportCode: "hiit"), .intervals(4))
    }

    func test_yoga_returnsPostures() {
        let s = session(type: .mobility, exercises: [ex(), ex(), ex(), ex(), ex()])
        XCTAssertEqual(SessionFormatDescriptor.format(for: s, sportCode: "yoga"), .postures(5))
    }

    func test_running_withKeySession_returnsKeySession() {
        // 4×800 m : un exo répété 4 fois avec reps "800 m".
        let key = ex(sets: 4, reps: "800 m")
        let s = session(type: .interval, exercises: [key, ex()])
        XCTAssertEqual(SessionFormatDescriptor.format(for: s, sportCode: "running"), .keySession("4×800 m"))
    }

    func test_running_withoutKeySession_returnsBlocks() {
        let s = session(type: .endurance, exercises: [ex(), ex()])
        XCTAssertEqual(SessionFormatDescriptor.format(for: s, sportCode: "running"), .blocks(2))
    }

    func test_cycling_isCardioFamily() {
        let s = session(type: .endurance, exercises: [ex()])
        XCTAssertEqual(SessionFormatDescriptor.format(for: s, sportCode: "cycling"), .blocks(1))
    }

    func test_hiking_isCardioFamily() {
        let s = session(type: .endurance, exercises: [ex(), ex(), ex()])
        XCTAssertEqual(SessionFormatDescriptor.format(for: s, sportCode: "hiking"), .blocks(3))
    }

    func test_hiking_strengthSession_returnsBlocks_notKeySession() {
        // Bug audit 2026-06-04 : la séance "Renforcement préventif" (strength)
        // d'un programme hiking ne doit PAS afficher "2×8 par lettre" (échauffement
        // Y-T-W faussement lu en séance-clé) mais un nombre de blocs propre.
        let ytw = ex(sets: 2, reps: "8 par lettre")
        let s = session(type: .strength, exercises: [ytw, ex(), ex(), ex(), ex(), ex()])
        XCTAssertEqual(SessionFormatDescriptor.format(for: s, sportCode: "hiking"), .blocks(6))
    }

    func test_cardio_keySessionRejectsWordyMetric() {
        // Une métrique porteuse de mots ("8 par lettre") ne doit jamais composer
        // une séance-clé, même sur une séance endurance → repli blocs propre.
        let wordy = ex(sets: 2, reps: "8 par lettre")
        let s = session(type: .endurance, exercises: [wordy, ex()])
        XCTAssertEqual(SessionFormatDescriptor.format(for: s, sportCode: "running"), .blocks(2))
    }

    func test_swim_returnsSeries() {
        let s = session(type: .technique, exercises: [ex(), ex()])
        XCTAssertEqual(SessionFormatDescriptor.format(for: s, sportCode: "swimming"), .series(2))
    }

    func test_triathlon_inheritsDisciplineMode() {
        // Côté HUB, triathlon est résolu en sa discipline (ici cycling) avant appel.
        let s = session(type: .endurance, exercises: [ex(), ex()])
        XCTAssertEqual(SessionFormatDescriptor.format(for: s, sportCode: "cycling"), .blocks(2))
    }

    func test_genericFallback_returnsExercises() {
        // Sport non couvert (tennis) + type mixed → fallback générique.
        let s = session(type: .mixed, exercises: [ex(), ex(), ex()])
        XCTAssertEqual(SessionFormatDescriptor.format(for: s, sportCode: "tennis"), .exercises(3))
    }

    // MARK: - Séance vide → libellé non vide, jamais "—"

    func test_emptySession_neverDashNeverEmpty() {
        let empty = session(type: .rest, exercises: [])
        let f = SessionFormatDescriptor.format(for: empty, sportCode: "tennis")
        XCTAssertFalse(f.debugLabel.isEmpty)
        XCTAssertNotEqual(f.debugLabel, "—")
    }

    func test_allFormats_haveNonEmptyDebugLabel() {
        let sports = ["strengthTraining", "hiit", "yoga", "running", "cycling", "hiking", "swimming", "tennis"]
        for code in sports {
            let s = session(type: .mixed, exercises: [ex(), ex()])
            let label = SessionFormatDescriptor.format(for: s, sportCode: code).debugLabel
            XCTAssertFalse(label.isEmpty, "format vide pour \(code)")
            XCTAssertNotEqual(label, "—", "format = — pour \(code)")
        }
    }

    // MARK: - Helpers

    private func session(type: SessionType, exercises: [AdaptedExercise]) -> AdaptedSession {
        AdaptedSession(day: 1, name: "Test", durationMinutes: 40, type: type,
                       warmup: nil, exercises: exercises, cooldown: nil)
    }

    private func ex(sets: Int? = nil, reps: String? = nil, duration: String? = nil, restSeconds: Int? = nil) -> AdaptedExercise {
        AdaptedExercise(name: "Exo", originalName: "Exo", sets: sets, reps: reps,
                        duration: duration, restSeconds: restSeconds)
    }
}
