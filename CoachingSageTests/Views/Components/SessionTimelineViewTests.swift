// CoachingSageTests/Views/Components/SessionTimelineViewTests.swift
// Story 3.18 Phase 2 — tests light SessionTimelineView (label substitution).
import XCTest
import SwiftUI
import TemplateModel

final class SessionTimelineViewTests: XCTestCase {

    // MARK: - userFriendlyAdaptationLabel

    func test_userFriendlyAdaptationLabel_equipmentPrefix_returnsEquipmentKey() {
        let key = SessionTimelineView.userFriendlyAdaptationLabel(reason: "equipment:dumbbells")
        XCTAssertEqual(key, "coaching.adapter.exercise.adapted.equipment")
    }

    func test_userFriendlyAdaptationLabel_constraintPrefix_returnsConstraintKey() {
        let key = SessionTimelineView.userFriendlyAdaptationLabel(reason: "constraint:knee-injury")
        XCTAssertEqual(key, "coaching.adapter.exercise.adapted.constraint")
    }

    func test_userFriendlyAdaptationLabel_unknownPrefix_returnsGenericKey() {
        let key = SessionTimelineView.userFriendlyAdaptationLabel(reason: "something:other")
        XCTAssertEqual(key, "coaching.adapter.exercise.adapted.generic")
    }

    func test_userFriendlyAdaptationLabel_emptyString_returnsGenericKey() {
        let key = SessionTimelineView.userFriendlyAdaptationLabel(reason: "")
        XCTAssertEqual(key, "coaching.adapter.exercise.adapted.generic")
    }
}
