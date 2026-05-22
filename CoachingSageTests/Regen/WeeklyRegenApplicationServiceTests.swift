// CoachingSageTests/Regen/WeeklyRegenApplicationServiceTests.swift
// Story 3.4 Phase B.2 — tests du `DefaultWeeklyRegenApplicationService` :
//   - helpers purs (SessionVolumeScaler, Level.regressedForRestart, currentWeekNumber)
//   - applyDecision : mutation des durées de S+1, skip rest, clamp, restart level régressé,
//     write journal + snapshot
//
// Les tests `checkAndApplyIfDue_*` sont déférés à B.8 e2e — orchestration plus
// large + idempotence à valider avec un ModelContext file-based (pattern
// `DefaultWeeklyRegenRepositoryTests`).
//
// Mocks in-memory pour les 2 repositories (AdaptedProgramRepository partagé via
// `CoachingSageTests/Mocks/`, WeeklyRegenRepository local au fichier).
import XCTest
import TemplateModel

@MainActor
final class WeeklyRegenApplicationServiceTests: XCTestCase {

    // MARK: - SessionVolumeScaler (pure)

    func testScale_progressIncreasesDuration() {
        XCTAssertEqual(SessionVolumeScaler.scale(durationMinutes: 30, multiplier: 1.10), 33)
        XCTAssertEqual(SessionVolumeScaler.scale(durationMinutes: 50, multiplier: 1.10), 55)
        XCTAssertEqual(SessionVolumeScaler.scale(durationMinutes: 20, multiplier: 1.10), 22)
    }

    func testScale_reduceDecreasesDuration() {
        XCTAssertEqual(SessionVolumeScaler.scale(durationMinutes: 40, multiplier: 0.75), 30)
        XCTAssertEqual(SessionVolumeScaler.scale(durationMinutes: 60, multiplier: 0.75), 45)
        XCTAssertEqual(SessionVolumeScaler.scale(durationMinutes: 40, multiplier: 0.5), 20)
    }

    func testScale_maintainKeepsDuration() {
        XCTAssertEqual(SessionVolumeScaler.scale(durationMinutes: 30, multiplier: 1.0), 30)
    }

    func testScale_clampsToMinDuration() {
        XCTAssertEqual(SessionVolumeScaler.scale(durationMinutes: 4, multiplier: 0.5), 5)
        XCTAssertEqual(SessionVolumeScaler.scale(durationMinutes: 10, multiplier: 0.1), 5)
    }

    func testScale_clampsToMaxDuration() {
        XCTAssertEqual(SessionVolumeScaler.scale(durationMinutes: 200, multiplier: 2.0), 240)
    }

    func testScale_zeroDurationStaysZero() {
        XCTAssertEqual(SessionVolumeScaler.scale(durationMinutes: 0, multiplier: 1.10), 0)
    }

    func testScale_clampsCorruptedMultiplier() {
        XCTAssertEqual(SessionVolumeScaler.scale(durationMinutes: 30, multiplier: 100), 240)
    }

    // MARK: - Level.regressedForRestart (pure)

    func testRegressedForRestart_steppedDown() {
        XCTAssertEqual(Level.competitive.regressedForRestart(), .regular)
        XCTAssertEqual(Level.regular.regressedForRestart(), .recreational)
        XCTAssertEqual(Level.recreational.regressedForRestart(), .beginner)
    }

    func testRegressedForRestart_beginnerFloor() {
        XCTAssertEqual(Level.beginner.regressedForRestart(), .beginner)
    }

    // MARK: - currentWeekNumber (pure)

    func testCurrentWeekNumber_atWeekStart_isOne() {
        let weekStart = Self.makeWeekStart()
        XCTAssertEqual(
            DefaultWeeklyRegenApplicationService.currentWeekNumber(
                weekStartDate: weekStart,
                now: weekStart
            ),
            1
        )
    }

    func testCurrentWeekNumber_day3_stillWeekOne() {
        let weekStart = Self.makeWeekStart()
        let day3 = weekStart.addingTimeInterval(2 * 24 * 3600)
        XCTAssertEqual(
            DefaultWeeklyRegenApplicationService.currentWeekNumber(
                weekStartDate: weekStart,
                now: day3
            ),
            1
        )
    }

    func testCurrentWeekNumber_day8_isWeekTwo() {
        let weekStart = Self.makeWeekStart()
        let day8 = weekStart.addingTimeInterval(8 * 24 * 3600)
        XCTAssertEqual(
            DefaultWeeklyRegenApplicationService.currentWeekNumber(
                weekStartDate: weekStart,
                now: day8
            ),
            2
        )
    }

    func testCurrentWeekNumber_day15_isWeekThree() {
        let weekStart = Self.makeWeekStart()
        let day15 = weekStart.addingTimeInterval(15 * 24 * 3600)
        XCTAssertEqual(
            DefaultWeeklyRegenApplicationService.currentWeekNumber(
                weekStartDate: weekStart,
                now: day15
            ),
            3
        )
    }

    func testCurrentWeekNumber_nowBeforeStart_returnsOne() {
        let weekStart = Self.makeWeekStart()
        let beforeStart = weekStart.addingTimeInterval(-3600)
        XCTAssertEqual(
            DefaultWeeklyRegenApplicationService.currentWeekNumber(
                weekStartDate: weekStart,
                now: beforeStart
            ),
            1
        )
    }

    // MARK: - applyDecision (mutation record)

    func testApplyDecision_progressMultiplier_increasesTargetWeekDurations() async throws {
        let record = makeRecord(sessions: [
            makeSession(weekNumber: 1, day: 1, durationMinutes: 30),
            makeSession(weekNumber: 2, day: 1, durationMinutes: 30),
            makeSession(weekNumber: 2, day: 3, durationMinutes: 50),
            makeSession(weekNumber: 2, day: 5, durationMinutes: 20)
        ])
        let (service, _, regenRepo) = makeSystem()

        let entry = try await service.applyDecision(
            makeDecision(adjustment: .progress(percent: 0.10), reason: .onTrack),
            to: record,
            userId: record.userId,
            now: Date()
        )

        let s1 = try XCTUnwrap(record.sessions.first { $0.weekNumber == 1 && $0.day == 1 })
        XCTAssertEqual(s1.durationMinutes, 30, "S1 (analyzedWeek) ne doit pas être touchée.")

        let week2 = record.sessions.filter { $0.weekNumber == 2 }.sorted { $0.day < $1.day }
        XCTAssertEqual(week2.map(\.durationMinutes), [33, 55, 22])
        XCTAssertEqual(entry.affectedSessionIds.count, 3)
        XCTAssertEqual(entry.multiplier, 1.10, accuracy: 1e-6)
        XCTAssertEqual(entry.reason, .onTrack)
        XCTAssertFalse(entry.requiresRebuild)
        XCTAssertEqual(regenRepo.savedJournalEntries.count, 1)
        XCTAssertEqual(regenRepo.savedReports.count, 1)
        XCTAssertEqual(regenRepo.savedReports.first?.snapshot.weekNumber, 1)
    }

    func testApplyDecision_reduceMultiplier_decreasesTargetWeekDurations() async throws {
        let record = makeRecord(sessions: [
            makeSession(weekNumber: 2, day: 1, durationMinutes: 40),
            makeSession(weekNumber: 2, day: 3, durationMinutes: 60)
        ])
        let (service, _, _) = makeSystem()

        _ = try await service.applyDecision(
            makeDecision(adjustment: .reduce(percent: 0.25), reason: .missedSessions),
            to: record,
            userId: record.userId,
            now: Date()
        )
        let week2 = record.sessions.filter { $0.weekNumber == 2 }.sorted { $0.day < $1.day }
        XCTAssertEqual(week2.map(\.durationMinutes), [30, 45])
    }

    func testApplyDecision_skipsRestSessions() async throws {
        let record = makeRecord(sessions: [
            makeSession(weekNumber: 2, day: 1, durationMinutes: 30, type: .endurance),
            makeSession(weekNumber: 2, day: 4, durationMinutes: 0, type: .rest),
            makeSession(weekNumber: 2, day: 7, durationMinutes: 45, type: .endurance)
        ])
        let (service, _, _) = makeSystem()

        let entry = try await service.applyDecision(
            makeDecision(adjustment: .progress(percent: 0.10), reason: .onTrack),
            to: record,
            userId: record.userId,
            now: Date()
        )
        let rest = try XCTUnwrap(record.sessions.first { $0.type == .rest })
        XCTAssertEqual(rest.durationMinutes, 0, "Une session rest ne doit jamais être multipliée.")
        XCTAssertFalse(entry.affectedSessionIds.contains(rest.id))
        XCTAssertEqual(entry.affectedSessionIds.count, 2)
    }

    func testApplyDecision_maintainMultiplier_doesNotChangeDurations() async throws {
        let record = makeRecord(sessions: [
            makeSession(weekNumber: 2, day: 1, durationMinutes: 30)
        ])
        let (service, _, _) = makeSystem()

        let entry = try await service.applyDecision(
            makeDecision(adjustment: .maintain, reason: .lowQuality),
            to: record,
            userId: record.userId,
            now: Date()
        )
        XCTAssertEqual(record.sessions.first?.durationMinutes, 30)
        XCTAssertTrue(entry.affectedSessionIds.isEmpty, "Maintain (×1.0) ne touche aucune session.")
        XCTAssertEqual(entry.reason, .lowQuality)
    }

    func testApplyDecision_restartRegressesLevelAndAppliesHalfMultiplier() async throws {
        let record = makeRecord(
            level: .regular,
            sessions: [makeSession(weekNumber: 2, day: 1, durationMinutes: 40)]
        )
        let (service, _, _) = makeSystem()

        let entry = try await service.applyDecision(
            makeDecision(adjustment: .restart, reason: .pauseExtended, pauseLevel: .extended),
            to: record,
            userId: record.userId,
            now: Date()
        )
        XCTAssertEqual(record.level, Level.recreational.rawValue, "Regular → recreational (1 cran).")
        XCTAssertTrue(entry.requiresRebuild)
        XCTAssertEqual(entry.pauseLevel, .extended)
        XCTAssertEqual(record.sessions.first?.durationMinutes, 20, "40 × 0.5")
    }

    // **Story 3.11 AC18/AC26** — `applyDecision` écrit l'entry avec le
    // `shiftGeneration` courant du record. Permet la ré-application des regens
    // post-shift week sans conflit d'idempotence avec l'historique.
    func testApplyDecision_writesEntryWithCurrentShiftGeneration() async throws {
        let record = AdaptedProgramRecord(
            userId: UUID(),
            sportCode: "running",
            level: Level.regular.rawValue,
            templateId: "running_regular_v2",
            adaptedAt: Date(),
            weekStartDate: Self.makeWeekStart(),
            mode: .ondemand,
            sessions: [makeSession(weekNumber: 2, day: 1, durationMinutes: 30)],
            shiftGeneration: 2
        )
        let (service, _, regenRepo) = makeSystem()

        let entry = try await service.applyDecision(
            makeDecision(adjustment: .progress(percent: 0.10), reason: .onTrack),
            to: record,
            userId: record.userId,
            now: Date()
        )

        XCTAssertEqual(entry.shiftGeneration, 2)
        XCTAssertEqual(regenRepo.savedJournalEntries.first?.shiftGeneration, 2)
    }

    func testApplyDecision_restartFromBeginnerStaysBeginner() async throws {
        let record = makeRecord(
            level: .beginner,
            sessions: [makeSession(weekNumber: 2, day: 1, durationMinutes: 30)]
        )
        let (service, _, _) = makeSystem()

        _ = try await service.applyDecision(
            makeDecision(adjustment: .restart, reason: .pauseExtended, pauseLevel: .extended),
            to: record,
            userId: record.userId,
            now: Date()
        )
        XCTAssertEqual(record.level, Level.beginner.rawValue, "Beginner = plancher.")
    }

    // MARK: - Helpers / fixtures

    nonisolated static func makeWeekStart() -> Date {
        var c = DateComponents()
        c.year = 2024
        c.month = 7
        c.day = 8 // lundi
        c.hour = 0
        return Calendar.current.date(from: c)!
    }

    private func makeSession(
        weekNumber: Int,
        day: Int,
        durationMinutes: Int,
        type: SessionType = .endurance
    ) -> PersistedSession {
        PersistedSession(
            weekNumber: weekNumber,
            weekTheme: "test theme",
            weekGoal: "test goal",
            day: day,
            name: "Test session",
            durationMinutes: durationMinutes,
            type: type,
            warmup: nil,
            exercises: [],
            cooldown: nil
        )
    }

    private func makeRecord(
        userId: UUID = UUID(),
        level: Level = .regular,
        sessions: [PersistedSession]
    ) -> AdaptedProgramRecord {
        AdaptedProgramRecord(
            userId: userId,
            sportCode: "running",
            level: level.rawValue,
            templateId: "running_regular_v2",
            adaptedAt: Date(),
            weekStartDate: Self.makeWeekStart(),
            mode: .ondemand,
            sessions: sessions
        )
    }

    private func makeDecision(
        analyzedWeek: Int = 1,
        targetWeek: Int = 2,
        adjustment: VolumeAdjustment,
        reason: RegressionDecision.Reason,
        pauseLevel: PauseLevel = .none
    ) -> WeeklyRegenDecision {
        let report = WeeklyExecutionReport(
            weekNumber: analyzedWeek,
            weekStartDate: Self.makeWeekStart(),
            plannedSessionCount: 3,
            plannedActiveSessionCount: 3,
            completedSessionCount: 3,
            completionRate: 1.0,
            globalQuality: 80,
            overExecutedCount: 0,
            isOverallOverExecuted: false,
            matches: []
        )
        return WeeklyRegenDecision(
            analyzedWeekNumber: analyzedWeek,
            targetWeekNumber: targetWeek,
            report: report,
            pauseDetection: PauseDetectionResult(
                level: pauseLevel,
                daysSinceLastWorkout: nil,
                consecutiveLowWeeks: 0
            ),
            adjustment: adjustment,
            reason: reason
        )
    }

    private func makeSystem() -> (DefaultWeeklyRegenApplicationService, MockAdaptedProgramRepository, LocalRegenRepoStub) {
        let adaptedRepo = MockAdaptedProgramRepository()
        let regenRepo = LocalRegenRepoStub()
        let provider = MockInputsProvider { _, _ in nil }
        let service = DefaultWeeklyRegenApplicationService(
            adaptedProgramRepository: adaptedRepo,
            regenRepository: regenRepo,
            inputsProvider: provider
        )
        return (service, adaptedRepo, regenRepo)
    }
}

// MARK: - Mocks

// `MockAdaptedProgramRepository` est partagé : `CoachingSageTests/Mocks/MockAdaptedProgramRepository.swift`.

@MainActor
private final class LocalRegenRepoStub: WeeklyRegenRepository {
    var savedReports: [(snapshot: WeeklyExecutionReportSnapshot, recordId: UUID, userId: UUID, sportCode: String)] = []
    var savedJournalEntries: [RegenJournalEntry] = []

    func fetchReports(recordId: UUID, before weekNumber: Int, limit: Int) async throws -> [WeeklyExecutionReportSnapshot] {
        savedReports
            .filter { $0.recordId == recordId && $0.snapshot.weekNumber < weekNumber }
            .sorted { $0.snapshot.weekNumber > $1.snapshot.weekNumber }
            .prefix(limit)
            .map(\.snapshot)
    }

    func saveReport(_ snapshot: WeeklyExecutionReportSnapshot, recordId: UUID, userId: UUID, sportCode: String) async throws {
        if let idx = savedReports.firstIndex(where: { $0.recordId == recordId && $0.snapshot.weekNumber == snapshot.weekNumber }) {
            savedReports[idx] = (snapshot, recordId, userId, sportCode)
        } else {
            savedReports.append((snapshot, recordId, userId, sportCode))
        }
    }

    func fetchJournal(recordId: UUID, targetWeek: Int, shiftGeneration: Int) async throws -> RegenJournalEntry? {
        savedJournalEntries.first {
            $0.recordId == recordId
                && $0.targetWeekNumber == targetWeek
                && $0.shiftGeneration == shiftGeneration
        }
    }

    func saveJournal(_ entry: RegenJournalEntry) async throws {
        savedJournalEntries.append(entry)
    }

    func fetchJournalForCurrentWeek(userId: UUID, weekStart: Date) async throws -> [RegenJournalEntry] {
        let lowerBound = weekStart.addingTimeInterval(-24 * 3600)
        let upperBound = weekStart.addingTimeInterval(7 * 24 * 3600)
        return savedJournalEntries
            .filter { $0.userId == userId && $0.appliedAt >= lowerBound && $0.appliedAt <= upperBound }
            .sorted { $0.appliedAt > $1.appliedAt }
    }
}

@MainActor
private final class MockInputsProvider: WeeklyRegenInputsProviding {
    let factory: (AdaptedProgramRecord, Int) -> WeeklyRegenDecision?

    init(_ factory: @escaping (AdaptedProgramRecord, Int) -> WeeklyRegenDecision?) {
        self.factory = factory
    }

    func makeDecision(
        for record: AdaptedProgramRecord,
        analyzedWeekNumber: Int,
        now: Date
    ) async throws -> WeeklyRegenDecision? {
        factory(record, analyzedWeekNumber)
    }
}
