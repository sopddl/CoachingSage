// CoachingSageTests/Coaching/SessionCompletion/SessionCompletionViewModelTests.swift
// Phase A boucle complétion — couvre load() / save() / clear() du VM contre
// `MockAdaptedProgramRepository`, en s'appuyant sur des records préchargés via
// `stubbedActive`.
import XCTest
import TemplateModel
@testable import CoachingSage

@MainActor
final class SessionCompletionViewModelTests: XCTestCase {

    private func makeRecord(
        recordId: UUID = UUID(),
        sessions: [PersistedSession] = []
    ) -> AdaptedProgramRecord {
        AdaptedProgramRecord(
            id: recordId,
            userId: UUID(),
            sportCode: "running",
            level: "beginner",
            templateId: "test",
            adaptedAt: Date(),
            weekStartDate: Date(),
            sessions: sessions
        )
    }

    private func makeSession(weekNumber: Int = 1, day: Int = 1) -> PersistedSession {
        PersistedSession(
            weekNumber: weekNumber,
            weekTheme: "Theme",
            weekGoal: "Goal",
            day: day,
            name: "Session \(weekNumber)·\(day)",
            durationMinutes: 30,
            type: .endurance,
            warmup: nil,
            exercises: [],
            cooldown: nil
        )
    }

    func testLoadReturnsNilWhenNoCompletion() async {
        let repo = MockAdaptedProgramRepository()
        let record = makeRecord(sessions: [makeSession()])
        repo.stubbedActive = [record]

        let vm = SessionCompletionViewModel(
            recordId: record.id,
            weekNumber: 1,
            day: 1,
            repository: repo
        )
        await vm.load()

        XCTAssertEqual(vm.loadState, .loaded)
        XCTAssertNil(vm.completion)
    }

    func testLoadReturnsExistingCompletion() async {
        let repo = MockAdaptedProgramRepository()
        let session = makeSession()
        let record = makeRecord(sessions: [session])
        var state = record.completionState
        state.sessionRecords[session.id] = SessionCompletionRecord(
            completedAt: Date(timeIntervalSince1970: 1_700_000_000),
            actualDurationMinutes: 32,
            perceivedEffort: 7,
            notes: "Bien"
        )
        record.completionState = state
        repo.stubbedActive = [record]

        let vm = SessionCompletionViewModel(
            recordId: record.id,
            weekNumber: 1,
            day: 1,
            repository: repo
        )
        await vm.load()

        XCTAssertEqual(vm.completion?.actualDurationMinutes, 32)
        XCTAssertEqual(vm.completion?.perceivedEffort, 7)
        XCTAssertEqual(vm.completion?.notes, "Bien")
    }

    func testSavePersistsCompletionAndUpdatesVM() async {
        let repo = MockAdaptedProgramRepository()
        let record = makeRecord(sessions: [makeSession(weekNumber: 2, day: 3)])
        repo.stubbedActive = [record]

        let vm = SessionCompletionViewModel(
            recordId: record.id,
            weekNumber: 2,
            day: 3,
            repository: repo
        )
        await vm.save(actualDurationMinutes: 45, rpe: 6, notes: "  ok  ")

        XCTAssertEqual(vm.saveState, .saved)
        XCTAssertEqual(vm.completion?.actualDurationMinutes, 45)
        XCTAssertEqual(vm.completion?.perceivedEffort, 6)
        // notes whitespace trimmées
        XCTAssertEqual(vm.completion?.notes, "ok")

        XCTAssertEqual(repo.recordedCompletions.count, 1)
        XCTAssertEqual(repo.recordedCompletions[0].weekNumber, 2)
        XCTAssertEqual(repo.recordedCompletions[0].day, 3)
        XCTAssertEqual(record.completionState.sessionRecords.count, 1)
    }

    func testSaveWithEmptyNotesPersistsNil() async {
        let repo = MockAdaptedProgramRepository()
        let record = makeRecord(sessions: [makeSession()])
        repo.stubbedActive = [record]

        let vm = SessionCompletionViewModel(
            recordId: record.id,
            weekNumber: 1,
            day: 1,
            repository: repo
        )
        await vm.save(actualDurationMinutes: 30, rpe: nil, notes: "   ")

        XCTAssertNil(vm.completion?.notes)
        XCTAssertNil(vm.completion?.perceivedEffort)
        XCTAssertEqual(vm.completion?.actualDurationMinutes, 30)
    }

    func testClearRemovesCompletion() async {
        let repo = MockAdaptedProgramRepository()
        let session = makeSession()
        let record = makeRecord(sessions: [session])
        var state = record.completionState
        state.sessionRecords[session.id] = SessionCompletionRecord(completedAt: Date())
        record.completionState = state
        repo.stubbedActive = [record]

        let vm = SessionCompletionViewModel(
            recordId: record.id,
            weekNumber: 1,
            day: 1,
            repository: repo
        )
        await vm.load()
        XCTAssertNotNil(vm.completion)

        await vm.clear()

        XCTAssertEqual(vm.saveState, .saved)
        XCTAssertNil(vm.completion)
        XCTAssertEqual(record.completionState.sessionRecords.count, 0)
    }

    func testSaveErrorExposedInSaveState() async {
        let repo = MockAdaptedProgramRepository()
        let record = makeRecord(sessions: [makeSession()])
        repo.stubbedActive = [record]
        repo.recordCompletionShouldThrow = true

        let vm = SessionCompletionViewModel(
            recordId: record.id,
            weekNumber: 1,
            day: 1,
            repository: repo
        )
        await vm.save(actualDurationMinutes: 30, rpe: 5, notes: "x")

        guard case .failed = vm.saveState else {
            XCTFail("Expected .failed save state")
            return
        }
        XCTAssertNil(vm.completion)
    }

    func testLoadErrorWhenRecordMissing() async {
        let repo = MockAdaptedProgramRepository()
        // pas de stubbedActive → record introuvable

        let vm = SessionCompletionViewModel(
            recordId: UUID(),
            weekNumber: 1,
            day: 1,
            repository: repo
        )
        await vm.load()

        guard case .failed = vm.loadState else {
            XCTFail("Expected .failed load state")
            return
        }
    }
}
