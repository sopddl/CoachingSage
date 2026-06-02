// CoachingSageTests/Coaching/Session/SessionProgressStoreTests.swift
// Story 3.33 (AC9) — persistance JSON plat de la complétion FOCUS : écriture /
// relecture, reprise après « quit », isolation par séance, clear.
import XCTest
@testable import CoachingSage

final class SessionProgressStoreTests: XCTestCase {

    private var tmpURL: URL!
    private var store: SessionProgressStore!
    private let recordId = UUID()

    override func setUp() {
        super.setUp()
        tmpURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("session_progress_test_\(UUID().uuidString).json")
        store = SessionProgressStore(fileURL: tmpURL)
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: tmpURL)
        super.tearDown()
    }

    func test_emptyStore_returnsNoSteps() {
        XCTAssertTrue(store.completedSteps(recordId: recordId, week: 1, day: 1).isEmpty)
    }

    func test_setStep_thenRead() {
        store.setStep(0, done: true, recordId: recordId, week: 1, day: 1)
        store.setStep(2, done: true, recordId: recordId, week: 1, day: 1)
        XCTAssertEqual(store.completedSteps(recordId: recordId, week: 1, day: 1), [0, 2])
    }

    func test_setStep_falseRemoves() {
        store.setStep(0, done: true, recordId: recordId, week: 1, day: 1)
        store.setStep(0, done: false, recordId: recordId, week: 1, day: 1)
        XCTAssertTrue(store.completedSteps(recordId: recordId, week: 1, day: 1).isEmpty)
    }

    /// Reprise après « quit » : un nouveau store sur le même fichier relit l'état.
    func test_persistsAcrossInstances_resumeAfterQuit() {
        store.setStep(0, done: true, recordId: recordId, week: 2, day: 3)
        store.setStep(1, done: true, recordId: recordId, week: 2, day: 3)
        let fresh = SessionProgressStore(fileURL: tmpURL)
        XCTAssertEqual(fresh.completedSteps(recordId: recordId, week: 2, day: 3), [0, 1])
    }

    func test_isolationBySession() {
        store.setStep(0, done: true, recordId: recordId, week: 1, day: 1)
        store.setStep(5, done: true, recordId: recordId, week: 1, day: 2) // autre jour
        XCTAssertEqual(store.completedSteps(recordId: recordId, week: 1, day: 1), [0])
        XCTAssertEqual(store.completedSteps(recordId: recordId, week: 1, day: 2), [5])
    }

    func test_isolationByRecord() {
        let other = UUID()
        store.setStep(0, done: true, recordId: recordId, week: 1, day: 1)
        XCTAssertTrue(store.completedSteps(recordId: other, week: 1, day: 1).isEmpty)
    }

    func test_clear_removesSessionOnly() {
        store.setStep(0, done: true, recordId: recordId, week: 1, day: 1)
        store.setStep(1, done: true, recordId: recordId, week: 1, day: 2)
        store.clear(recordId: recordId, week: 1, day: 1)
        XCTAssertTrue(store.completedSteps(recordId: recordId, week: 1, day: 1).isEmpty)
        XCTAssertEqual(store.completedSteps(recordId: recordId, week: 1, day: 2), [1])
    }

    func test_key_isStableAndDistinct() {
        let k1 = SessionProgressStore.key(recordId: recordId, week: 1, day: 1)
        let k2 = SessionProgressStore.key(recordId: recordId, week: 1, day: 2)
        XCTAssertNotEqual(k1, k2)
        XCTAssertEqual(k1, SessionProgressStore.key(recordId: recordId, week: 1, day: 1))
    }
}
