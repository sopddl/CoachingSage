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
        // SwiftData : on filtre puis on trie en mémoire. Trier par `weekNumber`
        // (= numéro de semaine du programme) reflète l'ordre chronologique
        // intra-programme. `weekStartDate` est redondant mais utile pour
        // ordonner deux programmes différents — ici on est filtré par
        // `recordId` donc `weekNumber` suffit.
        let descriptor = FetchDescriptor<WeeklyExecutionReportRecord>(
            predicate: #Predicate { record in
                record.recordId == recordId && record.weekNumber < weekNumber
            }
        )
        let all = try modelContext.fetch(descriptor)
        let sorted = all.sorted { $0.weekNumber > $1.weekNumber }
        return sorted.prefix(limit).map(\.snapshot)
    }

    func saveReport(
        _ snapshot: WeeklyExecutionReportSnapshot,
        recordId: UUID,
        userId: UUID,
        sportCode: String
    ) async throws {
        // Upsert : un seul rapport par (recordId, weekNumber). Si on re-analyse
        // une même semaine (cas où l'user a fait une séance tard et re-trigger
        // la regen), on remplace le snapshot existant plutôt que de doublonner.
        let weekN = snapshot.weekNumber
        let existing = try modelContext.fetch(
            FetchDescriptor<WeeklyExecutionReportRecord>(
                predicate: #Predicate { record in
                    record.recordId == recordId && record.weekNumber == weekN
                }
            )
        ).first

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
        let descriptor = FetchDescriptor<RegenJournalEntry>(
            predicate: #Predicate { entry in
                entry.recordId == recordId && entry.targetWeekNumber == targetWeek
            }
        )
        return try modelContext.fetch(descriptor).first
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
        let calendar = Calendar.current
        let lowerBound = calendar.date(byAdding: .day, value: -1, to: weekStart) ?? weekStart
        let upperBound = calendar.date(byAdding: .day, value: 7, to: weekStart) ?? weekStart

        let descriptor = FetchDescriptor<RegenJournalEntry>(
            predicate: #Predicate { entry in
                entry.userId == userId &&
                entry.appliedAt >= lowerBound &&
                entry.appliedAt < upperBound
            }
        )
        let all = try modelContext.fetch(descriptor)
        return all.sorted { $0.appliedAt > $1.appliedAt }
    }
}
