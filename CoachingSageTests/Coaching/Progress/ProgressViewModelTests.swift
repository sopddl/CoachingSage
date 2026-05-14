// CoachingSageTests/Coaching/Progress/ProgressViewModelTests.swift
// Story 3.9 — VM onglet Progrès. Empty state, fallback HK indisponible, reload.
import XCTest
import TemplateModel
@testable import CoachingSage

@MainActor
final class ProgressViewModelTests: XCTestCase {

    private let userId = UUID()
    private let now = Date(timeIntervalSince1970: 1_715_000_000)

    func testEmptyProgramsTriggersEmptyState() async {
        let hk = MockHealthKitService()
        let vm = ProgressViewModel(healthKit: hk, nowProvider: { self.now })

        await vm.reload(programs: [])
        XCTAssertTrue(vm.isEmpty)
        XCTAssertEqual(vm.stats, .empty)
    }

    func testHKFullyUnavailableReturnsThreeNilLines() async {
        let hk = MockHealthKitService()
        // Pas de stubs → toutes les méthodes HK retournent nil par défaut.
        let vm = ProgressViewModel(healthKit: hk, nowProvider: { self.now })
        let prog = makeProgramWithOneSession()

        await vm.reload(programs: [prog])

        XCTAssertFalse(vm.isEmpty)
        guard case .loaded(let readout) = vm.hkFitness else {
            return XCTFail("HK block doit être loaded")
        }
        XCTAssertTrue(readout.isFullyUnavailable, "Sans stubs, les 3 valeurs HK doivent être nil")
        XCTAssertNil(readout.restingHR)
        XCTAssertNil(readout.hrv)
        XCTAssertNil(readout.sleepMinutes)
    }

    func testHKPartialAvailabilityReturnsOnlyAvailableValues() async {
        let hk = MockHealthKitService()
        hk.stubbedRestingHeartRateAverage = 52
        hk.stubbedHRVAverage = 68
        // sleep reste nil → ligne sleep "—"
        let vm = ProgressViewModel(healthKit: hk, nowProvider: { self.now })
        let prog = makeProgramWithOneSession()

        await vm.reload(programs: [prog])

        guard case .loaded(let readout) = vm.hkFitness else {
            return XCTFail()
        }
        XCTAssertFalse(readout.isFullyUnavailable)
        XCTAssertEqual(readout.restingHR, 52)
        XCTAssertEqual(readout.hrv, 68)
        XCTAssertNil(readout.sleepMinutes)
    }

    func testWorkoutVolumeMapsToSportCodeRows() async {
        let hk = MockHealthKitService()
        hk.stubbedWorkoutVolumeByActivityType = [
            // HKWorkoutActivityType.running = 37
            37: 60 * 60, // 1h running
            // .cycling = 13
            13: 30 * 60 // 30min cycling
        ]
        let vm = ProgressViewModel(healthKit: hk, nowProvider: { self.now })
        let prog = makeProgramWithOneSession()

        await vm.reload(programs: [prog])

        guard case .loaded(let rows) = vm.volumeRows else {
            return XCTFail()
        }
        XCTAssertEqual(rows.count, 2)
        // Trié par volume desc.
        XCTAssertEqual(rows.first?.sportCode, .running)
        XCTAssertEqual(rows.first?.totalMinutes, 60)
        XCTAssertEqual(rows.last?.sportCode, .cycling)
        XCTAssertEqual(rows.last?.totalMinutes, 30)
    }

    func testSelectPeriodTriggersReload() async {
        let hk = MockHealthKitService()
        let vm = ProgressViewModel(healthKit: hk, nowProvider: { self.now })
        let prog = makeProgramWithOneSession()

        await vm.reload(programs: [prog])
        XCTAssertEqual(vm.period, .week)

        await vm.selectPeriod(.month, programs: [prog])
        XCTAssertEqual(vm.period, .month)
    }

    // MARK: - Helpers

    private func makeProgramWithOneSession() -> AdaptedProgramRecord {
        let session = PersistedSession(
            id: UUID(), weekNumber: 1, weekTheme: "W", weekGoal: "G",
            day: 1, name: "S", durationMinutes: 30,
            type: .endurance, warmup: nil, exercises: [], cooldown: nil
        )
        let prog = AdaptedProgramRecord(
            userId: userId, sportCode: "running", level: "beginner",
            templateId: "t", adaptedAt: now, weekStartDate: now,
            mode: .ondemand, sessions: [session]
        )
        var state = ProgramCompletionState.empty
        state.sessionRecords[session.id] = SessionCompletionRecord(completedAt: now)
        prog.completionState = state
        return prog
    }
}
