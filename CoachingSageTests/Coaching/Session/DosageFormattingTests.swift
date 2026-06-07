// CoachingSageTests/Coaching/Session/DosageFormattingTests.swift
// Chantier dosage caméléon (pilote muscu) — D1 (zéro jargon) + D4 (côté).
import XCTest
@testable import CoachingSage

final class DosageFormattingTests: XCTestCase {

    private let fr = Locale(identifier: "fr")

    // D1/AC1 : le jargon RPE devient un libellé d'effort en français normal.
    func test_plainEffort_convertsRPE_noJargon() {
        let out = DosageFormatting.plainEffort(from: "RPE 6-7", locale: fr)
        XCTAssertNotNil(out)
        XCTAssertFalse(out!.uppercased().contains("RPE"))
        XCTAssertTrue(out!.contains("6-7"))
        XCTAssertTrue(out!.contains("10"))
    }

    func test_plainEffort_singleValue() {
        let out = DosageFormatting.plainEffort(from: "rpe:8", locale: fr)
        XCTAssertEqual(out?.contains("8"), true)
        XCTAssertEqual(out?.uppercased().contains("RPE"), false)
    }

    // Les vraies zones d'allure (autres sports) ne sont PAS converties → glossaire préservé.
    func test_plainEffort_nilForRunningZones() {
        XCTAssertNil(DosageFormatting.plainEffort(from: "Z2", locale: fr))
        XCTAssertNil(DosageFormatting.plainEffort(from: "Daniels-E", locale: fr))
        XCTAssertNil(DosageFormatting.plainEffort(from: "", locale: fr))
    }

    // D4 : détection unilatérale depuis le texte des reps (FR/EN/ES).
    func test_isUnilateral() {
        XCTAssertTrue(DosageFormatting.isUnilateral(reps: "10 par côté"))
        XCTAssertTrue(DosageFormatting.isUnilateral(reps: "8 each side"))
        XCTAssertTrue(DosageFormatting.isUnilateral(reps: "12 cada lado"))
        XCTAssertFalse(DosageFormatting.isUnilateral(reps: "8"))
        XCTAssertFalse(DosageFormatting.isUnilateral(reps: "12-15"))
        XCTAssertFalse(DosageFormatting.isUnilateral(reps: nil))
    }

    // AC2 : le héros ne montre que le nombre, la latéralité passe en guidage à part.
    func test_repsHero_stripsSideSuffix() {
        XCTAssertEqual(DosageFormatting.repsHero(from: "10 par côté"), "10")
        XCTAssertEqual(DosageFormatting.repsHero(from: "8 each side"), "8")
        XCTAssertEqual(DosageFormatting.repsHero(from: "8"), "8")
        XCTAssertEqual(DosageFormatting.repsHero(from: "12-15"), "12-15")
    }
}
