// CoachingSageTests/Views/SessionSportInferenceExerciseTests.swift
// Fix "brick leak" (2026-07-24) — `sportCode(forSessionName:)` résout au niveau SÉANCE : un nom
// "Enchaîné vélo-course" matche `bikeKeywords` en premier et renvoie "cycling" pour TOUTE la
// séance, y compris son segment course (pictogramme/illustration/minuteur faux). Verrou de
// `sportCode(forExercise:targetZone:fallback:)`, la résolution PAR EXERCICE qui corrige ça.
import XCTest
import TemplateModel

final class SessionSportInferenceExerciseTests: XCTestCase {

    func test_brickSession_runSegment_resolvesRunningNotSessionLevelCycling() {
        // Répro exacte du finding : séance "Enchaîné vélo-course" → sportCode(forSessionName:)
        // renvoie "cycling" (bike keyword matché en premier). L'exo course doit malgré tout
        // résoudre "running" via son propre targetZone.
        let sessionLevelCode = SessionSportInference.sportCode(
            forSessionName: "Enchaîné vélo-course INTRO — vélo facile 35 min + course facile 10 min",
            programSportCode: "triathlon"
        )
        XCTAssertEqual(sessionLevelCode, "cycling", "précondition du bug : le niveau séance matche vélo en premier")

        let resolved = SessionSportInference.sportCode(
            forExercise: "Easy run 10 min — jelly-legs feel",
            targetZone: "Daniels-E",
            fallback: sessionLevelCode
        )
        XCTAssertEqual(resolved, "running")
    }

    func test_brickSession_bikeSegment_resolvesCycling() {
        let sessionLevelCode = SessionSportInference.sportCode(
            forSessionName: "Enchaîné vélo-course INTRO — vélo facile 35 min + course facile 10 min",
            programSportCode: "triathlon"
        )
        let resolved = SessionSportInference.sportCode(
            forExercise: "Bike 35 min (easy zone)", targetZone: "FTP-Z2", fallback: sessionLevelCode
        )
        XCTAssertEqual(resolved, "cycling")
    }

    func test_transitionExercise_noZoneNoKeyword_fallsBackToSessionCode() {
        // T1/T2 : pas de target_zone, nom neutre → doit garder le fallback (pas de faux positif).
        let resolved = SessionSportInference.sportCode(
            forExercise: "Real T2 transition", targetZone: nil, fallback: "cycling"
        )
        XCTAssertEqual(resolved, "cycling")
    }

    func test_swimZone_resolvesSwimmingEvenWithGenericFallback() {
        let resolved = SessionSportInference.sportCode(
            forExercise: "Technique drill", targetZone: "EN2", fallback: "triathlon"
        )
        XCTAssertEqual(resolved, "swimming")
    }

    func test_monoSportProgram_exerciseWithoutMatch_keepsFallbackUnchanged() {
        // Programme mono-sport : aucune ambiguïté à résoudre, ne doit jamais reclasser à tort.
        let resolved = SessionSportInference.sportCode(
            forExercise: "Squat gobelet", targetZone: nil, fallback: "strengthTraining"
        )
        XCTAssertEqual(resolved, "strengthTraining")
    }
}
