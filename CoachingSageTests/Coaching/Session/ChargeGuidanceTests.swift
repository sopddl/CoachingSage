// CoachingSageTests/Coaching/Session/ChargeGuidanceTests.swift
// Chantier charge muscu V2 — TRANCHE 1. Classification du type de résistance qui
// pilote la consigne charge NON-kg (élastique / poids du corps / charge libre).
import XCTest
import TemplateModel
@testable import CoachingSage

final class ChargeGuidanceTests: XCTestCase {

    private func exo(_ name: String) -> AdaptedExercise {
        AdaptedExercise(name: LocalizedText(fr: name), originalName: name)
    }

    func test_nonStrength_returnsNil() {
        XCTAssertNil(ChargeGuidance.resistance(for: exo("Squat"), isStrength: false))
    }

    func test_band_detected() {
        XCTAssertEqual(ChargeGuidance.resistance(for: exo("Tirage élastique"), isStrength: true), .band)
        XCTAssertEqual(ChargeGuidance.resistance(for: exo("Band pull-apart"), isStrength: true), .band)
    }

    func test_loadedKeywords_takePriorityOverBodyweightWord() {
        // « squat barre » contient « squat » mais est chargé → free/machine.
        XCTAssertEqual(ChargeGuidance.resistance(for: exo("Squat barre nuque"), isStrength: true), .freeOrMachine)
        XCTAssertEqual(ChargeGuidance.resistance(for: exo("Fente haltères"), isStrength: true), .freeOrMachine)
        XCTAssertEqual(ChargeGuidance.resistance(for: exo("Goblet squat"), isStrength: true), .freeOrMachine)
    }

    func test_bodyweight_detected() {
        XCTAssertEqual(ChargeGuidance.resistance(for: exo("Pompes"), isStrength: true), .bodyweight)
        XCTAssertEqual(ChargeGuidance.resistance(for: exo("Tractions"), isStrength: true), .bodyweight)
        XCTAssertEqual(ChargeGuidance.resistance(for: exo("Gainage planche"), isStrength: true), .bodyweight)
    }

    func test_defaultStrength_isFreeOrMachine() {
        // Exo muscu non reconnu comme élastique/poids du corps → charge libre par défaut.
        XCTAssertEqual(ChargeGuidance.resistance(for: exo("Développé Arnold"), isStrength: true), .freeOrMachine)
    }

    // Device-test #16 : exo en TENUE (durée, pas de reps) → repère de tension, pas « reps ».
    func test_isHold_durationNoReps() {
        let plank = AdaptedExercise(name: LocalizedText(fr: "Planche ventrale"), originalName: "Planche ventrale",
                                    reps: nil, duration: "30 sec")
        XCTAssertTrue(ChargeGuidance.isHold(plank))
        let wallSit = AdaptedExercise(name: LocalizedText(fr: "Chaise contre le mur"), originalName: "Chaise contre le mur",
                                      reps: "", duration: "30 sec")
        XCTAssertTrue(ChargeGuidance.isHold(wallSit))
    }

    func test_isHold_falseWhenReps() {
        let squat = AdaptedExercise(name: LocalizedText(fr: "Squat"), originalName: "Squat",
                                    reps: "10", duration: nil)
        XCTAssertFalse(ChargeGuidance.isHold(squat))
        // Reps + durée (estimation) → pas une tenue : les reps priment.
        let repsAndDur = AdaptedExercise(name: LocalizedText(fr: "Pont fessier"), originalName: "Pont fessier",
                                         reps: "12", duration: "40 sec")
        XCTAssertFalse(ChargeGuidance.isHold(repsAndDur))
    }
}
