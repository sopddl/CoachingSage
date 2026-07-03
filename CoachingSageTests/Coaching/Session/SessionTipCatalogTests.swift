// CoachingSageTests/Coaching/Session/SessionTipCatalogTests.swift
// Story 3.19 Jalon 3 — tests catalogue tips Léon par pattern.
// Garantit que (a) chaque pattern V1 a un tip non-nil sauf `.generic`,
// (b) chaque pattern a une clé i18n distincte (pas de doublon accidentel),
// (c) `.generic` renvoie nil (la bubble ne s'affiche pas dans la card exo).
import XCTest
import SwiftUI

final class SessionTipCatalogTests: XCTestCase {

    // MARK: - Couverture pattern

    func test_tip_strength_squat_isNonNil() {
        XCTAssertNotNil(SessionTipCatalog.tip(for: .squat, exerciseName: "Squat poids du corps"))
    }

    func test_tip_strength_hinge_isNonNil() {
        XCTAssertNotNil(SessionTipCatalog.tip(for: .hinge, exerciseName: "Romanian Deadlift"))
    }

    func test_tip_strength_pushHorizontal_isNonNil() {
        XCTAssertNotNil(SessionTipCatalog.tip(for: .pushHorizontal, exerciseName: "Pompe diamant"))
    }

    func test_tip_strength_pushVertical_isNonNil() {
        XCTAssertNotNil(SessionTipCatalog.tip(for: .pushVertical, exerciseName: "Développé épaule"))
    }

    func test_tip_strength_pullHorizontal_isNonNil() {
        XCTAssertNotNil(SessionTipCatalog.tip(for: .pullHorizontal, exerciseName: "Rowing barre"))
    }

    func test_tip_strength_pullVertical_isNonNil() {
        XCTAssertNotNil(SessionTipCatalog.tip(for: .pullVertical, exerciseName: "Traction"))
    }

    func test_tip_strength_lunge_isNonNil() {
        XCTAssertNotNil(SessionTipCatalog.tip(for: .lunge, exerciseName: "Fente avant"))
    }

    func test_tip_strength_core_isNonNil() {
        XCTAssertNotNil(SessionTipCatalog.tip(for: .core, exerciseName: "Plank"))
    }

    func test_tip_strength_plyo_isNonNil() {
        XCTAssertNotNil(SessionTipCatalog.tip(for: .plyo, exerciseName: "Box jump"))
    }

    func test_tip_strength_mobility_isNonNil() {
        XCTAssertNotNil(SessionTipCatalog.tip(for: .mobility, exerciseName: "Étirements ischio"))
    }

    func test_tip_run_endurance_isNonNil() {
        XCTAssertNotNil(SessionTipCatalog.tip(for: .runEndurance, exerciseName: "Footing Z2"))
    }

    func test_tip_run_interval_isNonNil() {
        XCTAssertNotNil(SessionTipCatalog.tip(for: .runInterval, exerciseName: "Fractionné 8×400"))
    }

    func test_tip_run_drills_isNonNil() {
        XCTAssertNotNil(SessionTipCatalog.tip(for: .runDrills, exerciseName: "Gammes éducatives"))
    }

    func test_tip_swim_endurance_isNonNil() {
        XCTAssertNotNil(SessionTipCatalog.tip(for: .swimEndurance, exerciseName: "1500m continus"))
    }

    func test_tip_swim_drill_isNonNil() {
        XCTAssertNotNil(SessionTipCatalog.tip(for: .swimDrill, exerciseName: "Drill 6-3-6"))
    }

    func test_tip_cycle_endurance_isNonNil() {
        XCTAssertNotNil(SessionTipCatalog.tip(for: .cycleEndurance, exerciseName: "Sortie Z2"))
    }

    func test_tip_cycle_interval_isNonNil() {
        XCTAssertNotNil(SessionTipCatalog.tip(for: .cycleInterval, exerciseName: "5×5 FTP"))
    }

    func test_tip_yoga_isNonNil() {
        XCTAssertNotNil(SessionTipCatalog.tip(for: .yoga, exerciseName: "Chien tête en bas"))
    }

    // MARK: - .generic ne renvoie pas de tip

    func test_tip_generic_isNil() {
        XCTAssertNil(SessionTipCatalog.tip(for: .generic, exerciseName: "Exo bidon"))
    }

    // MARK: - Pas de doublon clé entre patterns biomécaniques

    func test_allTipsHaveDistinctKeys() {
        let patternsWithTip: [ExercisePattern] = [
            .squat, .hinge, .pushHorizontal, .pushVertical,
            .pullHorizontal, .pullVertical, .lunge, .core,
            .plyo, .mobility, .runEndurance, .runInterval, .runDrills,
            .swimEndurance, .swimDrill, .cycleEndurance, .cycleInterval, .yoga
        ]
        // Capture la description String de chaque LocalizedStringKey pour
        // détecter les doublons accidentels (ex: squat ≡ hinge).
        let keyStrings: [String] = patternsWithTip.compactMap { p in
            SessionTipCatalog.tip(for: p, exerciseName: "x").map { "\($0)" }
        }
        XCTAssertEqual(keyStrings.count, patternsWithTip.count, "Tous les patterns doivent avoir un tip non-nil")
        XCTAssertEqual(Set(keyStrings).count, keyStrings.count, "Aucune clé i18n ne doit être partagée entre 2 patterns")
    }

    // MARK: - Couverture exhaustive (gardien anti-régression)

    func test_allPatternCases_areCovered() {
        // Itère sur toutes les cases enum et vérifie que seul `.generic`
        // renvoie nil. Si on ajoute un pattern, ce test casse jusqu'à ce
        // qu'un tip soit catalogué.
        for pattern in ExercisePattern.allCases {
            let tip = SessionTipCatalog.tip(for: pattern, exerciseName: "x")
            if pattern == .generic {
                XCTAssertNil(tip, ".generic doit renvoyer nil")
            } else {
                XCTAssertNotNil(tip, "Pattern \(pattern) doit avoir un tip catalogué")
            }
        }
    }
}
