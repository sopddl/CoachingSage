// CoachingSageTests/Coaching/Session/SessionFocusViewModelTests.swift
// Story 3.33 (AC9) — logique du mode FOCUS : étapes warmup/cooldown en
// première/dernière position, cocher → complétion, « Passer » ne coche pas,
// reprise = 1ʳᵉ non faite, tous faits → terminée, persistance/reprise après quit.
import XCTest
import TemplateModel

@MainActor
final class SessionFocusViewModelTests: XCTestCase {

    private var tmpURL: URL!

    override func setUp() {
        super.setUp()
        tmpURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("focus_progress_test_\(UUID().uuidString).json")
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: tmpURL)
        super.tearDown()
    }

    // MARK: - Construction des étapes

    func test_steps_warmupFirstCooldownLast() {
        let vm = makeVM(session: fullSession())
        XCTAssertEqual(vm.steps.count, 4) // warmup + 2 exos + cooldown
        guard case .warmup = vm.steps.first?.kind else { return XCTFail("première = warmup") }
        guard case .cooldown = vm.steps.last?.kind else { return XCTFail("dernière = cooldown") }
    }

    func test_steps_noWarmupCooldown_onlyExercises() {
        let s = AdaptedSession(day: 1, name: "S", durationMinutes: 30, type: .strength,
                               warmup: nil, exercises: [ex("A"), ex("B")], cooldown: nil)
        let vm = makeVM(session: s)
        XCTAssertEqual(vm.steps.count, 2)
        XCTAssertEqual(vm.steps.map(\.index), [0, 1])
    }

    // MARK: - Complétion

    func test_initial_nothingCompleted() {
        let vm = makeVM(session: fullSession())
        XCTAssertEqual(vm.completedCount, 0)
        XCTAssertFalse(vm.allCompleted)
        XCTAssertFalse(vm.hasProgress)
    }

    func test_markDone_incrementsCount() {
        let vm = makeVM(session: fullSession())
        vm.markDone(vm.steps[0])
        XCTAssertEqual(vm.completedCount, 1)
        XCTAssertTrue(vm.isCompleted(vm.steps[0]))
        XCTAssertTrue(vm.hasProgress)
    }

    func test_markDone_isIdempotent() {
        let vm = makeVM(session: fullSession())
        vm.markDone(vm.steps[0])
        vm.markDone(vm.steps[0])
        XCTAssertEqual(vm.completedCount, 1)
    }

    func test_allCompleted_whenEveryStepDone() {
        let vm = makeVM(session: fullSession())
        vm.steps.forEach { vm.markDone($0) }
        XCTAssertTrue(vm.allCompleted)
    }

    func test_skip_doesNotComplete() {
        let vm = makeVM(session: fullSession())
        vm.skip(vm.steps[1])
        XCTAssertFalse(vm.isCompleted(vm.steps[1]))
        XCTAssertEqual(vm.completedCount, 0)
    }

    func test_toggle_onThenOff() {
        let vm = makeVM(session: fullSession())
        vm.toggle(vm.steps[0])
        XCTAssertTrue(vm.isCompleted(vm.steps[0]))
        vm.toggle(vm.steps[0])
        XCTAssertFalse(vm.isCompleted(vm.steps[0]))
    }

    func test_markUndone_removes() {
        let vm = makeVM(session: fullSession())
        vm.markDone(vm.steps[2])
        vm.markUndone(vm.steps[2])
        XCTAssertEqual(vm.completedCount, 0)
    }

    // MARK: - Reprise

    func test_resumeIndex_firstUncompleted() {
        let vm = makeVM(session: fullSession())
        vm.markDone(vm.steps[0]) // warmup fait
        XCTAssertEqual(vm.resumeIndex, 1)
        XCTAssertEqual(vm.resumeStepNumber, 2)
    }

    func test_resumeIndex_zeroWhenNothingDone() {
        let vm = makeVM(session: fullSession())
        XCTAssertEqual(vm.resumeIndex, 0)
        XCTAssertEqual(vm.resumeStepNumber, 1)
    }

    func test_resumeIndex_zeroWhenAllDone() {
        let vm = makeVM(session: fullSession())
        vm.steps.forEach { vm.markDone($0) }
        XCTAssertEqual(vm.resumeIndex, 0)
    }

    // MARK: - Persistance / reprise après quit

    func test_persistence_reloadsCompletedAfterQuit() {
        let recordId = UUID()
        let store = SessionProgressStore(fileURL: tmpURL)
        let vm1 = SessionFocusViewModel(session: fullSession(), recordId: recordId, week: 1, day: 1, store: store)
        vm1.markDone(vm1.steps[0])
        vm1.markDone(vm1.steps[1])
        // « Quit » → nouvelle instance même recordId + même fichier.
        let vm2 = SessionFocusViewModel(session: fullSession(), recordId: recordId, week: 1, day: 1, store: store)
        XCTAssertEqual(vm2.completedCount, 2)
        XCTAssertTrue(vm2.isCompleted(vm2.steps[0]))
        XCTAssertEqual(vm2.resumeIndex, 2)
    }

    func test_noRecordId_doesNotPersist() {
        let store = SessionProgressStore(fileURL: tmpURL)
        let vm1 = SessionFocusViewModel(session: fullSession(), recordId: nil, week: 1, day: 1, store: store)
        vm1.markDone(vm1.steps[0])
        // Pas de recordId → rien écrit ; un store frais ne voit rien.
        XCTAssertFalse(FileManager.default.fileExists(atPath: tmpURL.path))
    }

    // MARK: - Helpers

    private func makeVM(session: AdaptedSession) -> SessionFocusViewModel {
        // recordId nil → mémoire seule, pas d'IO disque (logique pure).
        SessionFocusViewModel(session: session, recordId: nil, week: 1, day: 1, store: nil)
    }

    private func fullSession() -> AdaptedSession {
        AdaptedSession(
            day: 1, name: "Full body", durationMinutes: 50, type: .strength,
            warmup: "10 min mobilité",
            exercises: [ex("Squat"), ex("Pompes")],
            cooldown: "5 min étirements"
        )
    }

    private func ex(_ name: String) -> AdaptedExercise {
        AdaptedExercise(name: LocalizedText(fr: name), originalName: name, sets: 3, reps: "10")
    }
}
