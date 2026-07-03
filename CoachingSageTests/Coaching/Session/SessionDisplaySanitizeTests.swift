// CoachingSageTests/Coaching/Session/SessionDisplaySanitizeTests.swift
// Story 3.35e — zéro « / » dans la présentation des séances.
import XCTest
import TemplateModel

final class SessionDisplaySanitizeTests: XCTestCase {

    func test_sanitizedForDisplay_replacesSlashWithBullet() {
        XCTAssertEqual("Run/walk découverte".sanitizedForDisplay, "Run · walk découverte")
        XCTAssertEqual("1 min / 1 min 30".sanitizedForDisplay, "1 min · 1 min 30")
    }

    func test_sanitizedForDisplay_noSlashUnchanged() {
        XCTAssertEqual("Footing facile".sanitizedForDisplay, "Footing facile")
    }

    func test_adaptedExercise_displayName_stripsSlashAndPattern() {
        let ex = AdaptedExercise(name: "Bloc run/walk (pattern run.interval)", originalName: "x")
        // Le suffixe (pattern …) ET le « / » sont retirés.
        XCTAssertFalse(ex.displayName(Locale(identifier: "fr")).contains("/"))
        XCTAssertFalse(ex.displayName(Locale(identifier: "fr")).contains("pattern"))
        XCTAssertEqual(ex.displayName(Locale(identifier: "fr")), "Bloc run · walk")
    }
}
