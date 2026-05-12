// Repositories/Implementations/DefaultWeeklyRegenRepository.swift
// Story 3.4 Phase B.1 — backend SwiftData du `WeeklyRegenRepository`. Local-first
// V1, pas de synchro Supabase.
import Foundation
import SwiftData

@MainActor
final class DefaultWeeklyRegenRepository: WeeklyRegenRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Reports

    func fetchReports(
        recordId: UUID,
        before weekNumber: Int,
        limit: Int
    ) async throws -> [WeeklyExecutionReportSnapshot] {
        // Fetch-all + filter Swift : crash `#Predicate` SwiftData avec capture
        // `UUID + Int` reproduit 2026-05-12 sur Task 174 EXC_BAD_INSTRUCTION.
        // Volumes V1 faibles, perf OK.
        let descriptor = FetchDescriptor<WeeklyExecutionReportRecord>()
        let all = try modelContext.fetch(descriptor)
        return all
            .filter { $0.recordId == recordId && $0.weekNumber < weekNumber }
            .sorted { $0.weekNumber > $1.weekNumber }
            .prefix(limit)
            .map(\.snapshot)
    }

    func saveReport(
        _ snapshot: WeeklyExecutionReportSnapshot,
        recordId: UUID,
        userId: UUID,
        sportCode: String
    ) async throws {
        // Upsert : un seul rapport par (recordId, weekNumber). Fetch-all +
        // filter Swift (cf note `fetchReports` — predicate SwiftData crash).
        let weekN = snapshot.weekNumber
        let descriptor = FetchDescriptor<WeeklyExecutionReportRecord>()
        let existing = try modelContext.fetch(descriptor)
            .first { $0.recordId == recordId && $0.weekNumber == weekN }

        if let existing {
            existing.snapshot = snapshot
            existing.weekStartDate = snapshot.weekStartDate
        } else {
            let record = WeeklyExecutionReportRecord(
                userId: userId,
                recordId: recordId,
                sportCode: sportCode,
                snapshot: snapshot
            )
            modelContext.insert(record)
        }
        try modelContext.save()
    }

    // MARK: - Journal

    func fetchJournal(
        recordId: UUID,
        targetWeek: Int
    ) async throws -> RegenJournalEntry? {
        // Fetch-all + filter-in-Swift : le `#Predicate` SwiftData avec
        // `recordId UUID + targetWeek Int` sur RegenJournalEntry provoque un
        // `Lost connection to testmanagerd` (crash test process) 2026-05-12.
        // Cause exacte non identifiée (combinaison computed enums + private
        // `[UUID]` JSON Data ?). Volumes V1 faibles (~1 user × 52 weeks/yr ×
        // N programs), perf OK. À reconsidérer si volumes augmentent.
        let descriptor = FetchDescriptor<RegenJournalEntry>()
        let all = try modelContext.fetch(descriptor)
        return all.first { $0.recordId == recordId && $0.targetWeekNumber == targetWeek }
    }

    func saveJournal(_ entry: RegenJournalEntry) async throws {
        modelContext.insert(entry)
        try modelContext.save()
    }

    func fetchJournalForCurrentWeek(
        userId: UUID,
        weekStart: Date
    ) async throws -> [RegenJournalEntry] {
        // Filet 7j : un badge dashboard ne s'affiche que pendant la semaine
        // cible. weekStart est le lundi 00:00 local. On retient les entrées
        // appliquées entre weekStart - 1j (regen J-1) et weekStart + 7j.
        // Filtrage en Swift (cf note `fetchJournal` ci-dessus).
        let calendar = Calendar.current
        let lowerBound = calendar.date(byAdding: .day, value: -1, to: weekStart) ?? weekStart
        let upperBound = calendar.date(byAdding: .day, value: 7, to: weekStart) ?? weekStart

        let descriptor = FetchDescriptor<RegenJournalEntry>()
        let all = try modelContext.fetch(descriptor)
        return all
            .filter { $0.userId == userId && $0.appliedAt >= lowerBound && $0.appliedAt < upperBound }
            .sorted { $0.appliedAt > $1.appliedAt }
    }
}
