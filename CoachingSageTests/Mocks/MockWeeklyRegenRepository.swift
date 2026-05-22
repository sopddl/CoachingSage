// CoachingSageTests/Mocks/MockWeeklyRegenRepository.swift
// Story 3.4 Phase B.5 — fake in-memory pour les tests qui veulent contrôler
// les entrées du journal sans dérouler la stack SwiftData + JSON file plat.
//
// Couvre les 5 méthodes du protocole : `fetchReports`, `saveReport`,
// `fetchJournal`, `saveJournal`, `fetchJournalForCurrentWeek`. Le tri /
// filter de `fetchJournalForCurrentWeek` reproduit celui du Default (filtre
// fenêtre [weekStart-1j, weekStart+7j[ sur `appliedAt`, tri desc).
import Foundation

@MainActor
final class MockWeeklyRegenRepository: WeeklyRegenRepository {
    var stubbedJournalEntries: [RegenJournalEntry] = []
    var stubbedReports: [(snapshot: WeeklyExecutionReportSnapshot, recordId: UUID)] = []

    var fetchJournalForCurrentWeekShouldThrow: Bool = false
    private(set) var fetchJournalForCurrentWeekCallCount: Int = 0
    private(set) var lastWeekStart: Date?

    func fetchReports(
        recordId: UUID,
        before weekNumber: Int,
        limit: Int
    ) async throws -> [WeeklyExecutionReportSnapshot] {
        stubbedReports
            .filter { $0.recordId == recordId && $0.snapshot.weekNumber < weekNumber }
            .map(\.snapshot)
            .sorted { $0.weekNumber > $1.weekNumber }
            .prefix(limit)
            .map { $0 }
    }

    func saveReport(
        _ snapshot: WeeklyExecutionReportSnapshot,
        recordId: UUID,
        userId: UUID,
        sportCode: String
    ) async throws {
        stubbedReports.append((snapshot: snapshot, recordId: recordId))
    }

    func fetchJournal(
        recordId: UUID,
        targetWeek: Int,
        shiftGeneration: Int
    ) async throws -> RegenJournalEntry? {
        stubbedJournalEntries.first {
            $0.recordId == recordId
                && $0.targetWeekNumber == targetWeek
                && $0.shiftGeneration == shiftGeneration
        }
    }

    func saveJournal(_ entry: RegenJournalEntry) async throws {
        stubbedJournalEntries.append(entry)
    }

    func fetchJournalForCurrentWeek(
        userId: UUID,
        weekStart: Date
    ) async throws -> [RegenJournalEntry] {
        fetchJournalForCurrentWeekCallCount += 1
        lastWeekStart = weekStart
        if fetchJournalForCurrentWeekShouldThrow {
            throw URLError(.notConnectedToInternet)
        }
        let calendar = Calendar.current
        let lower = calendar.date(byAdding: .day, value: -1, to: weekStart) ?? weekStart
        let upper = calendar.date(byAdding: .day, value: 7, to: weekStart) ?? weekStart
        return stubbedJournalEntries
            .filter { $0.userId == userId && $0.appliedAt >= lower && $0.appliedAt < upper }
            .sorted { $0.appliedAt > $1.appliedAt }
    }
}
