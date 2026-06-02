// CoachingSageTests/Coaching/Progress/ProgressViewModelTests.swift
// Story 3.9 — VM onglet Progrès. Empty state, fallback HK indisponible, reload.
import XCTest
import TemplateModel

@MainActor
final class ProgressViewModelTests: XCTestCase {

    private let userId = UUID()
    private let now = Date(timeIntervalSince1970: 1_715_000_000)

    func testEmptyProgramsAndNoHKHistoryTriggersEmptyState() async {
        let hk = MockHealthKitService()
        // Aucun workout HK sur la période → vrai cas d'empty state.
        let vm = ProgressViewModel(healthKit: hk, nowProvider: { self.now }, userDefaults: seenDefaults())

        await vm.reload(programs: [])
        XCTAssertTrue(vm.isEmpty)
        XCTAssertFalse(vm.hasActivePrograms)
        XCTAssertEqual(vm.stats, .empty)
    }

    // Story sœur 3.z — un user fresh onboarding (0 programme actif) avec
    // historique Strava→Santé doit voir son volume HK, pas l'empty state.
    // Casse la promesse de la Story 3.z si on régresse là-dessus.
    func testZeroProgramsButHKHistoryShowsVolumeBlock() async {
        let hk = MockHealthKitService()
        hk.stubbedWorkoutVolumeByActivityType = [
            37: 90 * 60  // 1h30 running (Strava→Santé sync) — HKWorkoutActivityType.running = 37
        ]
        let vm = ProgressViewModel(healthKit: hk, nowProvider: { self.now }, userDefaults: seenDefaults())

        await vm.reload(programs: [])

        XCTAssertFalse(vm.isEmpty, "0 programs mais workouts HK historiques → pas d'empty state")
        XCTAssertFalse(vm.hasActivePrograms)
        guard case .loaded(let rows) = vm.volumeRows else {
            return XCTFail("Volume block doit être loaded")
        }
        XCTAssertEqual(rows.count, 1)
        XCTAssertEqual(rows.first?.sportCode, .running)
        XCTAssertEqual(rows.first?.totalMinutes, 90)
        // Stats et PR restent vides — dépendent des séances trackées par l'app.
        XCTAssertEqual(vm.stats, .empty)
        if case .loaded(let prs) = vm.personalRecords {
            XCTAssertTrue(prs.isEmpty)
        } else {
            XCTFail("PR block doit être loaded vide quand 0 program actif")
        }
    }

    // Edge case : 0 programme + HK RHR/HRV présent mais aucun workout → empty
    // state quand même. Sans historique d'activité, on n'a rien à raconter.
    func testZeroProgramsAndHKFitnessOnlyButNoVolumeTriggersEmptyState() async {
        let hk = MockHealthKitService()
        hk.stubbedRestingHeartRateAverage = 55
        hk.stubbedHRVAverage = 70
        // Pas de workouts.
        let vm = ProgressViewModel(healthKit: hk, nowProvider: { self.now }, userDefaults: seenDefaults())

        await vm.reload(programs: [])

        XCTAssertTrue(vm.isEmpty, "RHR seul sans aucun workout ne suffit pas à sortir de l'empty state")
    }

    func testHKFullyUnavailableReturnsThreeNilLines() async {
        let hk = MockHealthKitService()
        // Pas de stubs → toutes les méthodes HK retournent nil par défaut.
        let vm = ProgressViewModel(healthKit: hk, nowProvider: { self.now }, userDefaults: seenDefaults())
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
        let vm = ProgressViewModel(healthKit: hk, nowProvider: { self.now }, userDefaults: seenDefaults())
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
        let vm = ProgressViewModel(healthKit: hk, nowProvider: { self.now }, userDefaults: seenDefaults())
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
        let vm = ProgressViewModel(healthKit: hk, nowProvider: { self.now }, userDefaults: seenDefaults())
        let prog = makeProgramWithOneSession()

        await vm.reload(programs: [prog])
        XCTAssertEqual(vm.period, .week)

        await vm.selectPeriod(.month, programs: [prog])
        XCTAssertEqual(vm.period, .month)
    }

    // MARK: - Story 3.z — premier launch wow (AC15)

    func testFirstLaunchSetsQuarterPeriod() {
        let defaults = isolatedDefaults()
        // Flag absent → premier launch.
        let vm = ProgressViewModel(healthKit: MockHealthKitService(), nowProvider: { self.now }, userDefaults: defaults)
        XCTAssertEqual(vm.period, .quarter, "Premier launch doit forcer la période sur .quarter (effet wow 3 mois)")
    }

    func testSecondLaunchKeepsWeekPeriod() {
        let defaults = isolatedDefaults()
        defaults.set(true, forKey: ProgressViewModel.firstLaunchSeenKey)
        let vm = ProgressViewModel(healthKit: MockHealthKitService(), nowProvider: { self.now }, userDefaults: defaults)
        XCTAssertEqual(vm.period, .week, "Launchs suivants doivent revenir au défaut .week")
    }

    func testMarkFirstLaunchSeenPersistsFlag() {
        let defaults = isolatedDefaults()
        let vm = ProgressViewModel(healthKit: MockHealthKitService(), nowProvider: { self.now }, userDefaults: defaults)
        XCTAssertFalse(defaults.bool(forKey: ProgressViewModel.firstLaunchSeenKey))
        vm.markFirstLaunchSeen()
        XCTAssertTrue(defaults.bool(forKey: ProgressViewModel.firstLaunchSeenKey))
        // Idempotent : un 2e appel ne crash pas et ne ré-écrit pas le flag.
        vm.markFirstLaunchSeen()
        XCTAssertTrue(defaults.bool(forKey: ProgressViewModel.firstLaunchSeenKey))
    }

    // MARK: - Helpers

    /// `UserDefaults` isolé avec suiteName aléatoire — pas de pollution croisée
    /// entre tests ni avec l'environnement de l'app.
    private func isolatedDefaults() -> UserDefaults {
        let suite = "test.progress.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        return defaults
    }

    /// Variante d'`isolatedDefaults` avec le flag premier-launch déjà à `true`
    /// — pour les tests qui veulent observer le défaut `.week` historique.
    private func seenDefaults() -> UserDefaults {
        let defaults = isolatedDefaults()
        defaults.set(true, forKey: ProgressViewModel.firstLaunchSeenKey)
        return defaults
    }

    // MARK: - Bloc 5 natation (Story 3.16 Phase 2.D)

    func testSwimBlock_loadedFromHKDetails() async {
        let hk = MockHealthKitService()
        let start = Date(timeIntervalSince1970: 1_714_000_000)
        let laps = (1...4).map { i in
            HealthKitSwimLap(
                index: i, startDate: start, durationSeconds: 30, distanceMeters: 25,
                strokeStyle: .freestyle, paceSecondsPer100m: 120, averageHeartRateBpm: nil,
                strokeCount: 18, minHeartRateBpm: nil, maxHeartRateBpm: nil,
                swolfScore: 48, restAfterSeconds: 1
            )
        }
        hk.stubbedSwimWorkoutDetails = [
            HealthKitSwimWorkoutDetail(
                id: UUID(), startDate: start, endDate: start.addingTimeInterval(2400),
                durationSeconds: 2400, totalDistanceMeters: 1000, totalStrokes: 700,
                averageHeartRateBpm: 128, maxHeartRateBpm: 142, minHeartRateBpm: 110,
                activeEnergyKcal: 300, totalEnergyKcal: 350, averageMETs: 8.5,
                poolLengthMeters: 25, swimLocationType: .pool, sourceProductType: "Watch6,16",
                appleWatchDetected: true, deviceDescription: "Apple Watch", sourceDescription: "Watch",
                isIndoorWorkout: false, timeZoneIdentifier: "Europe/Paris",
                eventCounts: ["lap": 4], laps: laps, rawMetadata: [], rawStatistics: []
            )
        ]
        let vm = ProgressViewModel(healthKit: hk, nowProvider: { self.now }, userDefaults: seenDefaults())

        await vm.reload(programs: [])

        guard case .loaded(let summary) = vm.swim else {
            return XCTFail("Swim block doit être loaded")
        }
        XCTAssertEqual(summary.sessionCount, 1)
        XCTAssertEqual(summary.totalDistanceMeters, 1000)
        XCTAssertEqual(try XCTUnwrap(summary.avgPaceSecondsPer100m), 120, accuracy: 0.01)
    }

    func testSwimBlock_emptyWhenNoSwimWorkouts() async {
        let hk = MockHealthKitService() // stubbedSwimWorkoutDetails = [] par défaut
        let vm = ProgressViewModel(healthKit: hk, nowProvider: { self.now }, userDefaults: seenDefaults())

        await vm.reload(programs: [])

        guard case .loaded(let summary) = vm.swim else {
            return XCTFail("Swim block doit être loaded même vide")
        }
        XCTAssertEqual(summary.sessionCount, 0)
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
