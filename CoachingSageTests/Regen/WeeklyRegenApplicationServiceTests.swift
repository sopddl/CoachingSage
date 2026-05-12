// CoachingSageTests/Regen/WeeklyRegenApplicationServiceTests.swift
// Story 3.4 Phase B.2 — tests du `DefaultWeeklyRegenApplicationService`.
// Mocks in-memory pour les 3 dépendances (AdaptedProgramRepository,
// WeeklyRegenRepository, WeeklyRegenInputsProviding) — focus sur la logique
// d'orchestration et de mutation, pas SwiftData (déjà couvert par
// DefaultWeeklyRegenRepositoryTests).
import XCTest
import TemplateModel
@testable import CoachingSage

@MainActor
final class WeeklyRegenApplicationServiceTests: XCTestCase {

    // MARK: - Helpers / fixtures

    private func makeWeekStart(weeksAgo: Int = 1) -> Date {
        // Lundi 8 juillet 2024 00:00 — stable et pas en bord DST.
        var c = DateComponents()
        c.year = 2024
        c.month = 7
        c.day = 8
        c.hour = 0
        let monday = Calendar.current.date(from: c)!
        return monday.addingTimeInterval(-Double(weeksAgo) * 7 * 24 * 3600)
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
        weekStartDate: Date? = nil,
        sessions: [PersistedSession]
    ) -> AdaptedProgramRecord {
        AdaptedProgramRecord(
            userId: userId,
            sportCode: "running",
            level: level.rawValue,
            templateId: "running_regular_v2",
            adaptedAt: Date(),
            weekStartDate: weekStartDate ?? makeWeekStart(weeksAgo: 1),
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
            weekStartDate: makeWeekStart(weeksAgo: 1),
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

    private func makeSystem(
        records: [AdaptedProgramRecord] = [],
        decisionFactory: @escaping (AdaptedProgramRecord, Int) -> WeeklyRegenDecision? = { _, _ in nil }
    ) -> (DefaultWeeklyRegenApplicationService, MockAdaptedProgramRepository, MockWeeklyRegenRepository, MockInputsProvider) {
        let adaptedRepo = MockAdaptedProgramRepository()
        adaptedRepo.stubbedActive = records
        let regenRepo = MockWeeklyRegenRepository()
        let provider = MockInputsProvider(factory: decisionFactory)
        let service = DefaultWeeklyRegenApplicationService(
            adaptedProgramRepository: adaptedRepo,
            regenRepository: regenRepo,
            inputsProvider: provider
        )
        return (service, adaptedRepo, regenRepo, provider)
    }

    // MARK: - applyDecision : mutation des durées

    func testApplyDecision_progressMultiplier_increasesTargetWeekDurations() async throws {
        let record = makeRecord(sessions: [
            makeSession(weekNumber: 1, day: 1, durationMinutes: 30), // S — non touchée
            makeSession(weekNumber: 2, day: 1, durationMinutes: 30),
            makeSession(weekNumber: 2, day: 3, durationMinutes: 50),
            makeSession(weekNumber: 2, day: 5, durationMinutes: 20)
        ])
        let (service, _, regenRepo, _) = makeSystem()

        let decision = makeDecision(
            adjustment: .progress(percent: 0.10),
            reason: .onTrack
        )
        let entry = try await service.applyDecision(
            decision,
            to: record,
            userId: record.userId,
            now: Date()
        )

        let s1 = try XCTUnwrap(record.sessions.first { $0.weekNumber == 1 && $0.day == 1 })
        XCTAssertEqual(s1.durationMinutes, 30, "S1 ne doit pas être touchée par une regen S+1.")

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
        let (service, _, _, _) = makeSystem()

        _ = try await service.applyDecision(
            makeDecision(adjustment: .reduce(percent: 0.25), reason: .missedSessions),
            to: record,
            userId: record.userId,
            now: Date()
        )
        let week2 = record.sessions.filter { $0.weekNumber == 2 }.sorted { $0.day < $1.day }
        XCTAssertEqual(week2.map(\.durationMinutes), [30, 45]) // 40*0.75 / 60*0.75
    }

    func testApplyDecision_skipsRestSessions() async throws {
        let record = makeRecord(sessions: [
            makeSession(weekNumber: 2, day: 1, durationMinutes: 30, type: .endurance),
            makeSession(weekNumber: 2, day: 4, durationMinutes: 0, type: .rest),
            makeSession(weekNumber: 2, day: 7, durationMinutes: 45, type: .endurance)
        ])
        let (service, _, _, _) = makeSystem()

        let entry = try await service.applyDecision(
            makeDecision(adjustment: .progress(percent: 0.10), reason: .onTrack),
            to: record,
            userId: record.userId,
            now: Date()
        )
        let rest = try XCTUnwrap(record.sessions.first { $0.type == .rest })
        XCTAssertEqual(rest.durationMinutes, 0, "Une session rest ne doit jamais être multipliée.")
        XCTAssertFalse(entry.affectedSessionIds.contains(rest.id))
        XCTAssertEqual(entry.affectedSessionIds.count, 2, "Seules les 2 sessions endurance modifiées.")
    }

    func testApplyDecision_maintainMultiplier_doesNotChangeDurations() async throws {
        let record = makeRecord(sessions: [
            makeSession(weekNumber: 2, day: 1, durationMinutes: 30)
        ])
        let (service, _, _, _) = makeSystem()

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

    func testApplyDecision_clampsToMinDuration() async throws {
        // 4 × 0.5 = 2, doit clamp à 5 (plancher SessionVolumeScaler).
        let record = makeRecord(sessions: [
            makeSession(weekNumber: 2, day: 1, durationMinutes: 4)
        ])
        let (service, _, _, _) = makeSystem()

        _ = try await service.applyDecision(
            makeDecision(adjustment: .restart, reason: .pauseExtended, pauseLevel: .extended),
            to: record,
            userId: record.userId,
            now: Date()
        )
        XCTAssertEqual(record.sessions.first?.durationMinutes, 5)
    }

    func testApplyDecision_restartRegressesLevel() async throws {
        let record = makeRecord(
            level: .regular,
            sessions: [makeSession(weekNumber: 2, day: 1, durationMinutes: 40)]
        )
        let (service, _, _, _) = makeSystem()

        let entry = try await service.applyDecision(
            makeDecision(adjustment: .restart, reason: .pauseExtended, pauseLevel: .extended),
            to: record,
            userId: record.userId,
            now: Date()
        )
        XCTAssertEqual(record.level, Level.recreational.rawValue, "Restart depuis regular descend d'un cran.")
        XCTAssertTrue(entry.requiresRebuild)
        XCTAssertEqual(entry.pauseLevel, .extended)
        XCTAssertEqual(record.sessions.first?.durationMinutes, 20) // 40 × 0.5
    }

    func testApplyDecision_restartFromBeginnerStaysBeginner() async throws {
        let record = makeRecord(
            level: .beginner,
            sessions: [makeSession(weekNumber: 2, day: 1, durationMinutes: 30)]
        )
        let (service, _, _, _) = makeSystem()

        _ = try await service.applyDecision(
            makeDecision(adjustment: .restart, reason: .pauseExtended, pauseLevel: .extended),
            to: record,
            userId: record.userId,
            now: Date()
        )
        XCTAssertEqual(record.level, Level.beginner.rawValue, "Beginner = plancher, pas de rétrogradage plus bas.")
    }

    // MARK: - checkAndApplyIfDue

    func testCheckAndApplyIfDue_noOpInWeek1() async throws {
        let userId = UUID()
        // weekStartDate = aujourd'hui → currentWeekNumber = 1 → no-op.
        let record = makeRecord(
            userId: userId,
            weekStartDate: Date(),
            sessions: [makeSession(weekNumber: 2, day: 1, durationMinutes: 30)]
        )

        var providerCalls = 0
        let (service, _, regenRepo, _) = makeSystem(
            records: [record],
            decisionFactory: { _, _ in
                providerCalls += 1
                return self.makeDecision(adjustment: .progress(percent: 0.10), reason: .onTrack)
            }
        )

        try await service.checkAndApplyIfDue(userId: userId, now: Date())

        XCTAssertEqual(providerCalls, 0, "Pas d'appel au provider en S1.")
        XCTAssertTrue(regenRepo.savedJournalEntries.isEmpty)
    }

    func testCheckAndApplyIfDue_appliesWhenDue() async throws {
        let userId = UUID()
        let now = Date()
        // weekStart 8j avant now → currentWeekNumber = 2 → analyzedWeek = 1, targetWeek = 2.
        let weekStart = now.addingTimeInterval(-8 * 24 * 3600)
        let record = makeRecord(
            userId: userId,
            weekStartDate: weekStart,
            sessions: [
                makeSession(weekNumber: 1, day: 1, durationMinutes: 30),
                makeSession(weekNumber: 2, day: 1, durationMinutes: 30)
            ]
        )

        let (service, _, regenRepo, _) = makeSystem(
            records: [record],
            decisionFactory: { _, analyzedWeek in
                XCTAssertEqual(analyzedWeek, 1)
                return self.makeDecision(
                    analyzedWeek: 1,
                    targetWeek: 2,
                    adjustment: .progress(percent: 0.10),
                    reason: .onTrack
                )
            }
        )

        try await service.checkAndApplyIfDue(userId: userId, now: now)

        XCTAssertEqual(regenRepo.savedJournalEntries.count, 1)
        XCTAssertEqual(regenRepo.savedJournalEntries.first?.targetWeekNumber, 2)
        let s2 = try XCTUnwrap(record.sessions.first { $0.weekNumber == 2 })
        XCTAssertEqual(s2.durationMinutes, 33) // 30 × 1.10
    }

    func testCheckAndApplyIfDue_isIdempotent() async throws {
        let userId = UUID()
        let now = Date()
        let weekStart = now.addingTimeInterval(-8 * 24 * 3600)
        let record = makeRecord(
            userId: userId,
            weekStartDate: weekStart,
            sessions: [makeSession(weekNumber: 2, day: 1, durationMinutes: 30)]
        )

        var providerCalls = 0
        let (service, _, regenRepo, _) = makeSystem(
            records: [record],
            decisionFactory: { _, _ in
                providerCalls += 1
                return self.makeDecision(adjustment: .progress(percent: 0.10), reason: .onTrack)
            }
        )

        try await service.checkAndApplyIfDue(userId: userId, now: now)
        try await service.checkAndApplyIfDue(userId: userId, now: now)

        XCTAssertEqual(providerCalls, 1, "2e check → provider non re-appelé (journal existe).")
        XCTAssertEqual(regenRepo.savedJournalEntries.count, 1)
        XCTAssertEqual(record.sessions.first?.durationMinutes, 33, "Pas de double-application 30→33→36.")
    }

    func testCheckAndApplyIfDue_noOpIfProviderReturnsNil() async throws {
        let userId = UUID()
        let now = Date()
        let weekStart = now.addingTimeInterval(-8 * 24 * 3600)
        let record = makeRecord(
            userId: userId,
            weekStartDate: weekStart,
            sessions: [makeSession(weekNumber: 2, day: 1, durationMinutes: 30)]
        )
        let (service, _, regenRepo, _) = makeSystem(
            records: [record],
            decisionFactory: { _, _ in nil }
        )

        try await service.checkAndApplyIfDue(userId: userId, now: now)

        XCTAssertTrue(regenRepo.savedJournalEntries.isEmpty)
        XCTAssertEqual(record.sessions.first?.durationMinutes, 30, "Rien appliqué.")
    }

    // MARK: - Helpers `currentWeekNumber`

    func testCurrentWeekNumber_atWeekStart_isOne() {
        let weekStart = makeWeekStart(weeksAgo: 0)
        XCTAssertEqual(
            DefaultWeeklyRegenApplicationService.currentWeekNumber(
                weekStartDate: weekStart,
                now: weekStart
            ),
            1
        )
    }

    func testCurrentWeekNumber_day8_isWeekTwo() {
        let weekStart = makeWeekStart(weeksAgo: 0)
        let day8 = weekStart.addingTimeInterval(8 * 24 * 3600)
        XCTAssertEqual(
            DefaultWeeklyRegenApplicationService.currentWeekNumber(
                weekStartDate: weekStart,
                now: day8
            ),
            2
        )
    }

    func testCurrentWeekNumber_nowBeforeStart_returnsOne() {
        let weekStart = makeWeekStart(weeksAgo: 0)
        let beforeStart = weekStart.addingTimeInterval(-3600) // 1h avant
        XCTAssertEqual(
            DefaultWeeklyRegenApplicationService.currentWeekNumber(
                weekStartDate: weekStart,
                now: beforeStart
            ),
            1
        )
    }
}

// MARK: - Mocks

// `MockAdaptedProgramRepository` est partagé : voir `CoachingSageTests/Mocks/MockAdaptedProgramRepository.swift`.

@MainActor
private final class MockWeeklyRegenRepository: WeeklyRegenRepository {
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

    func fetchJournal(recordId: UUID, targetWeek: Int) async throws -> RegenJournalEntry? {
        savedJournalEntries.first { $0.recordId == recordId && $0.targetWeekNumber == targetWeek }
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

    init(factory: @escaping (AdaptedProgramRecord, Int) -> WeeklyRegenDecision?) {
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
