// CoachingSageTests/Coaching/Dashboard/WeeklyCalendarViewModelTests.swift
// Story 3.8 sous-tâche drag&drop (commit 10/3) — tests du VM lecture seule.
//
// Les tests construisent leur `weekStart` via `WeeklyCalendarViewModel.startOfWeek(for:)`
// pour rester corrects en n'importe quelle TZ (Paris/UTC/etc.) — les checks
// portent sur la structure relative (pool / day index) plutôt que sur des dates
// absolues.
import XCTest
import TemplateModel
@testable import CoachingSage

@MainActor
final class WeeklyCalendarViewModelTests: XCTestCase {

    private let userId = UUID()
    /// Date arbitraire mardi 14 janvier 2025 10:00 UTC ≈ mardi 11:00 Paris.
    /// On pose `now` un mardi pour vérifier que la semaine ISO commence bien lundi.
    private let now = Date(timeIntervalSince1970: 1_736_852_400)

    // MARK: - Mode .singleProgram

    func testRefreshSingleProgramFiltersOnlyMatchingRecord() async {
        let target = makeRecord(sportCode: "running", sessionsCount: 2)
        let other = makeRecord(sportCode: "cycling", sessionsCount: 2)
        let vm = makeVM(mode: .singleProgram(id: target.id), records: [target, other])

        await vm.refresh(userId: userId)

        XCTAssertEqual(vm.loadedPrograms.count, 1)
        XCTAssertEqual(vm.loadedPrograms.first?.id, target.id)
        XCTAssertTrue(vm.hasLoaded)
    }

    func testRefreshSingleProgramWithMissingIdYieldsEmptyState() async {
        let other = makeRecord(sportCode: "running", sessionsCount: 2)
        let vm = makeVM(mode: .singleProgram(id: UUID()), records: [other])

        await vm.refresh(userId: userId)

        XCTAssertTrue(vm.loadedPrograms.isEmpty)
        XCTAssertTrue(vm.pool.isEmpty)
        XCTAssertEqual(vm.daySlots.count, 7)
        XCTAssertTrue(vm.daySlots.allSatisfy { $0.items.isEmpty })
    }

    // MARK: - Mode .allActivePrograms

    func testRefreshAllActiveAggregatesAllRecords() async {
        let progA = makeRecord(sportCode: "running", sessionsCount: 1)
        let progB = makeRecord(sportCode: "cycling", sessionsCount: 1)
        let vm = makeVM(mode: .allActivePrograms, records: [progA, progB])

        await vm.refresh(userId: userId)

        XCTAssertEqual(vm.loadedPrograms.count, 2)
        XCTAssertEqual(vm.pool.count, 2, "Sessions ondemand des 2 progs doivent agréger dans le pool")
    }

    // MARK: - Bucket assignment

    func testOndemandSessionsLandInPool() async {
        let prog = makeRecord(sportCode: "running", sessionsCount: 3)
        let vm = makeVM(mode: .singleProgram(id: prog.id), records: [prog])

        await vm.refresh(userId: userId)

        XCTAssertEqual(vm.pool.count, 3)
        XCTAssertTrue(vm.daySlots.allSatisfy { $0.items.isEmpty })
        XCTAssertNil(vm.pool.first?.plannedDate, "Pool sessions ne doivent pas avoir de plannedDate")
    }

    func testPlannedSessionLandsInCorrectDayBucket() async {
        let cal = Calendar.current
        let weekStart = WeeklyCalendarViewModel.startOfWeek(for: now)
        // Session posée mercredi (offset +2) → day[2]
        let wednesday = cal.date(byAdding: .day, value: 2, to: weekStart)!
        let prog = makePlannedRecord(sportCode: "running", date: wednesday)
        let vm = makeVM(mode: .singleProgram(id: prog.id), records: [prog])

        await vm.refresh(userId: userId)

        XCTAssertTrue(vm.pool.isEmpty, "Session datée ne doit pas être dans le pool")
        XCTAssertEqual(vm.daySlots[2].items.count, 1, "Mercredi (day[2]) doit contenir 1 session")
        XCTAssertEqual(vm.daySlots[0].items.count, 0)
        XCTAssertEqual(vm.daySlots[6].items.count, 0)
    }

    func testPlannedSessionOutsideCurrentWeekIsIgnored() async {
        let cal = Calendar.current
        let weekStart = WeeklyCalendarViewModel.startOfWeek(for: now)
        // Session posée la semaine prochaine → ignorée V1 (multi-week deferred)
        let nextWeek = cal.date(byAdding: .day, value: 8, to: weekStart)!
        let prog = makePlannedRecord(sportCode: "running", date: nextWeek)
        let vm = makeVM(mode: .singleProgram(id: prog.id), records: [prog])

        await vm.refresh(userId: userId)

        XCTAssertTrue(vm.pool.isEmpty, "Session hors semaine ne doit pas tomber dans le pool")
        XCTAssertTrue(vm.daySlots.allSatisfy { $0.items.isEmpty })
    }

    func testCompletedSessionsAreSkipped() async {
        let prog = makeRecord(sportCode: "running", sessionsCount: 3)
        var state = ProgramCompletionState.empty
        state.sessionRecords[prog.sessions[0].id] = SessionCompletionRecord(completedAt: now)
        prog.completionState = state
        let vm = makeVM(mode: .singleProgram(id: prog.id), records: [prog])

        await vm.refresh(userId: userId)

        XCTAssertEqual(vm.pool.count, 2, "Session complétée ne doit pas apparaître dans le calendrier")
    }

    // MARK: - Erreurs

    func testRefreshOnRepositoryFailureSetsErrorAndEmptyState() async {
        let progRepo = MockAdaptedProgramRepository()
        progRepo.fetchShouldThrow = true
        let vm = WeeklyCalendarViewModel(
            mode: .allActivePrograms,
            programRepository: progRepo,
            nowProvider: { self.now }
        )

        await vm.refresh(userId: userId)

        XCTAssertNotNil(vm.error)
        XCTAssertTrue(vm.pool.isEmpty)
        XCTAssertEqual(vm.daySlots.count, 7, "Day slots doivent rester structurés même en erreur")
        XCTAssertFalse(vm.loading)
    }

    // MARK: - Helpers

    private func makeVM(
        mode: WeeklyCalendarViewModel.Mode,
        records: [AdaptedProgramRecord]
    ) -> WeeklyCalendarViewModel {
        let progRepo = MockAdaptedProgramRepository()
        progRepo.stubbedActive = records
        return WeeklyCalendarViewModel(
            mode: mode,
            programRepository: progRepo,
            nowProvider: { self.now }
        )
    }

    private func makeRecord(
        sportCode: String,
        sessionsCount: Int
    ) -> AdaptedProgramRecord {
        let sessions = (1...sessionsCount).map { day in
            PersistedSession(
                id: UUID(), weekNumber: 1, weekTheme: "W1", weekGoal: "G1",
                day: day, name: "S\(sportCode)-\(day)", durationMinutes: 30,
                type: .endurance, warmup: nil, exercises: [], cooldown: nil
            )
        }
        return AdaptedProgramRecord(
            userId: userId,
            sportCode: sportCode,
            level: "beginner",
            templateId: "test-\(sportCode)",
            adaptedAt: now,
            weekStartDate: WeeklyCalendarViewModel.startOfWeek(for: now),
            mode: .ondemand,
            sessions: sessions
        )
    }

    private func makePlannedRecord(sportCode: String, date: Date) -> AdaptedProgramRecord {
        let session = PersistedSession(
            id: UUID(), weekNumber: 1, weekTheme: "W1", weekGoal: "G1",
            day: 1, name: "Planned-\(sportCode)", durationMinutes: 30,
            type: .endurance, warmup: nil, exercises: [], cooldown: nil,
            plannedDate: date
        )
        return AdaptedProgramRecord(
            userId: userId,
            sportCode: sportCode,
            level: "beginner",
            templateId: "test-\(sportCode)",
            adaptedAt: now,
            weekStartDate: WeeklyCalendarViewModel.startOfWeek(for: now),
            mode: .planned,
            sessions: [session]
        )
    }
}
