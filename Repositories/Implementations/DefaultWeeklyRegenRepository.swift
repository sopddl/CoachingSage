// Repositories/Implementations/DefaultWeeklyRegenRepository.swift
// Story 3.4 Phase B.1 — backend SwiftData (Reports) + JSON file plat (Journal).
//
// **Choix archi V1 (2026-05-12)** : `RegenJournalEntry` n'est PAS un @Model
// SwiftData — crash silencieux `Lost connection to testmanagerd` sur
// `FetchDescriptor<@Model>` non résolu après 10 tentatives. Le journal vit
// dans un fichier JSON plat (`<Documents>/regen_journal.json`). Reports
// restent en SwiftData (`WeeklyExecutionReportRecord`).
//
// Volumes V1 faibles (~52 entries/yr/user), pas de risque perf. Le fichier
// est petit (~10 KB/an max). Lecture/écriture synchrone via `Data` :
// négligeable côté UI.
import Foundation
import SwiftData

@MainActor
final class DefaultWeeklyRegenRepository: WeeklyRegenRepository {
    private let modelContext: ModelContext
    private let journalStore: JournalFileStore

    init(
        modelContext: ModelContext,
        journalStore: JournalFileStore = .documentsDefault()
    ) {
        self.modelContext = modelContext
        self.journalStore = journalStore
    }

    // MARK: - Reports (SwiftData)

    func fetchReports(
        recordId: UUID,
        before weekNumber: Int,
        limit: Int
    ) async throws -> [WeeklyExecutionReportSnapshot] {
        // Fetch-all + filter Swift. `#Predicate` SwiftData avec capture UUID+Int
        // a crashé 2026-05-12 — pattern maintenu pour safety.
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

    // MARK: - Journal (JSON file)

    func fetchJournal(
        recordId: UUID,
        targetWeek: Int,
        shiftGeneration: Int
    ) async throws -> RegenJournalEntry? {
        let entries = try journalStore.loadAll()
        return entries.first {
            $0.recordId == recordId
                && $0.targetWeekNumber == targetWeek
                && $0.shiftGeneration == shiftGeneration
        }
    }

    func saveJournal(_ entry: RegenJournalEntry) async throws {
        var entries = try journalStore.loadAll()
        entries.append(entry)
        try journalStore.saveAll(entries)
    }

    func fetchJournalForCurrentWeek(
        userId: UUID,
        weekStart: Date
    ) async throws -> [RegenJournalEntry] {
        let calendar = Calendar.current
        let lowerBound = calendar.date(byAdding: .day, value: -1, to: weekStart) ?? weekStart
        let upperBound = calendar.date(byAdding: .day, value: 7, to: weekStart) ?? weekStart
        let entries = try journalStore.loadAll()
        return entries
            .filter { $0.userId == userId && $0.appliedAt >= lowerBound && $0.appliedAt < upperBound }
            .sorted { $0.appliedAt > $1.appliedAt }
    }
}

// MARK: - JournalFileStore

/// Wrapper sur un fichier JSON contenant `[RegenJournalEntry]`. Injectable pour
/// les tests (en passant un fichier temporaire). Pas de mémoire interne :
/// chaque opération relit/réécrit le fichier — V1 OK car volumes faibles.
struct JournalFileStore: Sendable {
    let fileURL: URL

    /// Variante par défaut : `<Documents>/regen_journal.json`.
    static func documentsDefault() -> JournalFileStore {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        return JournalFileStore(fileURL: docs.appendingPathComponent("regen_journal.json"))
    }

    func loadAll() throws -> [RegenJournalEntry] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return [] }
        let data = try Data(contentsOf: fileURL)
        guard !data.isEmpty else { return [] }
        return try JSONDecoder().decode([RegenJournalEntry].self, from: data)
    }

    func saveAll(_ entries: [RegenJournalEntry]) throws {
        let data = try JSONEncoder().encode(entries)
        try data.write(to: fileURL, options: .atomic)
    }
}
