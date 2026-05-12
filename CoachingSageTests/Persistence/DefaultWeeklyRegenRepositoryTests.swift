// CoachingSageTests/Persistence/DefaultWeeklyRegenRepositoryTests.swift
// Story 3.4 Phase B.1 — tests du backend SwiftData :
//   - JSON round-trip pour `WeeklyExecutionReportSnapshot` et `RegenJournalEntry.affectedSessionIds`
//   - upsert reports : 2× saveReport sur même weekNumber → 1 seul record en DB
//   - fetchReports : tri du plus récent au plus ancien, filtre `before`, limit
//   - fetchJournal : retourne nil si pas trouvé, l'entrée si trouvée
//   - fetchJournalForCurrentWeek : filet 7j (J-1 → J+7)
//
// Container file-based en URL temp dir (cf `AdaptedProgramRecordTests` —
// in-memory hang sur try save() avec @Attribute(.unique) UUID).
import XCTest
import SwiftData
@testable import CoachingSage

@MainActor
final class DefaultWeeklyRegenRepositoryTests: XCTestCase {

    private var modelContext: ModelContext!
    private var repo: DefaultWeeklyRegenRepository!

    override func setUpWithError() throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("WeeklyRegenRepo-\(UUID()).sqlite")
        let config = ModelConfiguration(url: url)
        let container = try ModelContainer(
            for: WeeklyExecutionReportRecord.self, RegenJournalEntry.self,
            configurations: config
        )
        self.modelContext = container.mainContext
        self.repo = DefaultWeeklyRegenRepository(modelContext: modelContext)
    }

    override func tearDown() {
        self.repo = nil
        self.modelContext = nil
    }

    // MARK: - Helpers

    private func makeSnapshot(weekNumber: Int, completionRate: Double = 0.8, globalQuality: Double = 75) -> WeeklyExecutionReportSnapshot {
        WeeklyExecutionReportSnapshot(
            weekNumber: weekNumber,
            weekStartDate: monday(weeksAgo: 10 - weekNumber),
            plannedSessionCount: 4,
            plannedActiveSessionCount: 3,
            completedSessionCount: Int(Double(3) * completionRate),
            completionRate: completionRate,
            globalQuality: globalQuality,
            overExecutedCount: 0,
            isOverallOverExecuted: false
        )
    }

    private func monday(weeksAgo: Int) -> Date {
        let cal = Calendar.current
        var c = cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
        c.weekOfYear = (c.weekOfYear ?? 1) - weeksAgo
        c.weekday = 2 // lundi
        return cal.date(from: c) ?? Date()
    }

    // MARK: - JSON round-trip

    func testSnapshotJsonRoundTrip() throws {
        let snapshot = makeSnapshot(weekNumber: 3, completionRate: 0.66, globalQuality: 82)
        let record = WeeklyExecutionReportRecord(
            userId: UUID(),
            recordId: UUID(),
            sportCode: "running",
            snapshot: snapshot
        )
        XCTAssertEqual(record.snapshot.weekNumber, 3)
        XCTAssertEqual(record.snapshot.completionRate, 0.66, accuracy: 1e-6)
        XCTAssertEqual(record.snapshot.globalQuality, 82, accuracy: 1e-6)
    }

    func testJournalAffectedSessionIdsRoundTrip() throws {
        let ids = [UUID(), UUID(), UUID()]
        let entry = RegenJournalEntry(
            userId: UUID(),
            recordId: UUID(),
            analyzedWeekNumber: 2,
            targetWeekNumber: 3,
            reason: .onTrack,
            multiplier: 1.10,
            pauseLevel: .none,
            requiresRebuild: false,
            affectedSessionIds: ids
        )
        XCTAssertEqual(entry.affectedSessionIds, ids)
        XCTAssertEqual(entry.reason, .onTrack)
        XCTAssertEqual(entry.pauseLevel, .none)
    }

    // MARK: - Reports

    func testSaveAndFetchReports_sortedRecentFirst() async throws {
        let recordId = UUID()
        let userId = UUID()
        try await repo.saveReport(makeSnapshot(weekNumber: 1), recordId: recordId, userId: userId, sportCode: "running")
        try await repo.saveReport(makeSnapshot(weekNumber: 2), recordId: recordId, userId: userId, sportCode: "running")
        try await repo.saveReport(makeSnapshot(weekNumber: 3), recordId: recordId, userId: userId, sportCode: "running")

        let reports = try await repo.fetchReports(recordId: recordId, before: 4, limit: 3)
        XCTAssertEqual(reports.map(\.weekNumber), [3, 2, 1])
    }

    func testFetchReports_excludesCurrentAndFutureWeeks() async throws {
        let recordId = UUID()
        let userId = UUID()
        try await repo.saveReport(makeSnapshot(weekNumber: 1), recordId: recordId, userId: userId, sportCode: "running")
        try await repo.saveReport(makeSnapshot(weekNumber: 2), recordId: recordId, userId: userId, sportCode: "running")
        try await repo.saveReport(makeSnapshot(weekNumber: 3), recordId: recordId, userId: userId, sportCode: "running")

        // before=3 exclut la semaine 3 elle-même.
        let reports = try await repo.fetchReports(recordId: recordId, before: 3, limit: 10)
        XCTAssertEqual(reports.map(\.weekNumber), [2, 1])
    }

    func testFetchReports_appliesLimit() async throws {
        let recordId = UUID()
        let userId = UUID()
        for w in 1...5 {
            try await repo.saveReport(makeSnapshot(weekNumber: w), recordId: recordId, userId: userId, sportCode: "running")
        }
        let reports = try await repo.fetchReports(recordId: recordId, before: 10, limit: 3)
        XCTAssertEqual(reports.map(\.weekNumber), [5, 4, 3])
    }

    func testFetchReports_filtersByRecordId() async throws {
        let recordA = UUID()
        let recordB = UUID()
        let userId = UUID()
        try await repo.saveReport(makeSnapshot(weekNumber: 1), recordId: recordA, userId: userId, sportCode: "running")
        try await repo.saveReport(makeSnapshot(weekNumber: 2), recordId: recordA, userId: userId, sportCode: "running")
        try await repo.saveReport(makeSnapshot(weekNumber: 5), recordId: recordB, userId: userId, sportCode: "cycling")

        let reportsA = try await repo.fetchReports(recordId: recordA, before: 10, limit: 10)
        XCTAssertEqual(reportsA.map(\.weekNumber), [2, 1])

        let reportsB = try await repo.fetchReports(recordId: recordB, before: 10, limit: 10)
        XCTAssertEqual(reportsB.map(\.weekNumber), [5])
    }

    func testSaveReport_isUpsertOnSameWeek() async throws {
        let recordId = UUID()
        let userId = UUID()
        try await repo.saveReport(makeSnapshot(weekNumber: 2, completionRate: 0.5), recordId: recordId, userId: userId, sportCode: "running")
        try await repo.saveReport(makeSnapshot(weekNumber: 2, completionRate: 0.9), recordId: recordId, userId: userId, sportCode: "running")

        let reports = try await repo.fetchReports(recordId: recordId, before: 10, limit: 10)
        XCTAssertEqual(reports.count, 1, "Upsert : 1 seul rapport pour (recordId, week=2)")
        let completionRate = try XCTUnwrap(reports.first?.completionRate)
        XCTAssertEqual(completionRate, 0.9, accuracy: 1e-6)
    }

    // MARK: - Journal

    func testFetchJournal_returnsNilIfNotFound() async throws {
        let result = try await repo.fetchJournal(recordId: UUID(), targetWeek: 5)
        XCTAssertNil(result)
    }

    func testSaveAndFetchJournal() async throws {
        let recordId = UUID()
        let entry = RegenJournalEntry(
            userId: UUID(),
            recordId: recordId,
            analyzedWeekNumber: 2,
            targetWeekNumber: 3,
            reason: .missedSessions,
            multiplier: 0.75,
            pauseLevel: .none,
            requiresRebuild: false,
            affectedSessionIds: [UUID()]
        )
        try await repo.saveJournal(entry)

        let found = try await repo.fetchJournal(recordId: recordId, targetWeek: 3)
        let entryFound = try XCTUnwrap(found)
        XCTAssertEqual(entryFound.reason, .missedSessions)
        XCTAssertEqual(entryFound.multiplier, 0.75, accuracy: 1e-6)
    }

    func testFetchJournalForCurrentWeek_includesEntriesAppliedWithinWindow() async throws {
        let userId = UUID()
        let weekStart = monday(weeksAgo: 0)
        let withinWindow = weekStart.addingTimeInterval(2 * 24 * 3600) // mardi de la semaine cible
        let beforeWindow = weekStart.addingTimeInterval(-3 * 24 * 3600) // 3j avant lundi → exclu
        let afterWindow = weekStart.addingTimeInterval(10 * 24 * 3600) // semaine suivante → exclu

        let inEntry = RegenJournalEntry(
            userId: userId, recordId: UUID(),
            analyzedWeekNumber: 1, targetWeekNumber: 2,
            appliedAt: withinWindow,
            reason: .onTrack, multiplier: 1.10, pauseLevel: .none,
            requiresRebuild: false, affectedSessionIds: []
        )
        let outBefore = RegenJournalEntry(
            userId: userId, recordId: UUID(),
            analyzedWeekNumber: 1, targetWeekNumber: 2,
            appliedAt: beforeWindow,
            reason: .onTrack, multiplier: 1.10, pauseLevel: .none,
            requiresRebuild: false, affectedSessionIds: []
        )
        let outAfter = RegenJournalEntry(
            userId: userId, recordId: UUID(),
            analyzedWeekNumber: 1, targetWeekNumber: 2,
            appliedAt: afterWindow,
            reason: .onTrack, multiplier: 1.10, pauseLevel: .none,
            requiresRebuild: false, affectedSessionIds: []
        )
        try await repo.saveJournal(inEntry)
        try await repo.saveJournal(outBefore)
        try await repo.saveJournal(outAfter)

        let badges = try await repo.fetchJournalForCurrentWeek(userId: userId, weekStart: weekStart)
        XCTAssertEqual(badges.count, 1)
        XCTAssertEqual(badges.first?.id, inEntry.id)
    }

    func testFetchJournalForCurrentWeek_filtersByUserId() async throws {
        let userA = UUID()
        let userB = UUID()
        let weekStart = monday(weeksAgo: 0)
        let withinWindow = weekStart.addingTimeInterval(2 * 24 * 3600)

        let entryA = RegenJournalEntry(
            userId: userA, recordId: UUID(),
            analyzedWeekNumber: 1, targetWeekNumber: 2,
            appliedAt: withinWindow,
            reason: .onTrack, multiplier: 1.10, pauseLevel: .none,
            requiresRebuild: false, affectedSessionIds: []
        )
        let entryB = RegenJournalEntry(
            userId: userB, recordId: UUID(),
            analyzedWeekNumber: 1, targetWeekNumber: 2,
            appliedAt: withinWindow,
            reason: .onTrack, multiplier: 1.10, pauseLevel: .none,
            requiresRebuild: false, affectedSessionIds: []
        )
        try await repo.saveJournal(entryA)
        try await repo.saveJournal(entryB)

        let badgesA = try await repo.fetchJournalForCurrentWeek(userId: userA, weekStart: weekStart)
        XCTAssertEqual(badgesA.count, 1)
        XCTAssertEqual(badgesA.first?.id, entryA.id)
    }

    // MARK: - Snapshot <-> Report bridge

    func testReportToSnapshotAndBack_preservesAggregateFields() {
        let report = WeeklyExecutionReport(
            weekNumber: 4,
            weekStartDate: monday(weeksAgo: 1),
            plannedSessionCount: 5,
            plannedActiveSessionCount: 4,
            completedSessionCount: 3,
            completionRate: 0.75,
            globalQuality: 82.5,
            overExecutedCount: 1,
            isOverallOverExecuted: false,
            matches: []
        )
        let snap = report.snapshot
        let rebuilt = WeeklyExecutionReport.from(snapshot: snap)

        XCTAssertEqual(rebuilt.weekNumber, 4)
        XCTAssertEqual(rebuilt.completionRate, 0.75, accuracy: 1e-6)
        XCTAssertEqual(rebuilt.globalQuality, 82.5, accuracy: 1e-6)
        XCTAssertEqual(rebuilt.plannedActiveSessionCount, 4)
        XCTAssertTrue(rebuilt.matches.isEmpty, "Le rebuild ne reconstitue pas les matches (out-of-scope V1).")
    }
}
