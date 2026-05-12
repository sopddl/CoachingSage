// Repositories/Protocols/WeeklyRegenRepository.swift
// Story 3.4 Phase B.1 — accès SwiftData aux 2 stores regen :
//   - `WeeklyExecutionReportRecord` : snapshots des semaines analysées
//   - `RegenJournalEntry` : trace des regens appliquées
//
// Local-first V1 — pas de synchro Supabase (alignement Story 3.8).
import Foundation

@MainActor
protocol WeeklyRegenRepository {
    // MARK: - Reports

    /// Récupère les `limit` derniers rapports d'exécution d'un programme,
    /// strictement antérieurs à `weekNumber`, triés du plus RÉCENT au plus
    /// ANCIEN (index 0 = semaine la plus proche de `weekNumber`).
    ///
    /// Conforme au contrat de `PauseDetector.detect(recentReports:…)`.
    func fetchReports(
        recordId: UUID,
        before weekNumber: Int,
        limit: Int
    ) async throws -> [WeeklyExecutionReportSnapshot]

    /// Insère ou met à jour le rapport d'une semaine. Si un record existe déjà
    /// pour le couple `(recordId, weekNumber)`, son snapshot est remplacé
    /// (upsert) — on ne crée jamais de doublon.
    func saveReport(
        _ snapshot: WeeklyExecutionReportSnapshot,
        recordId: UUID,
        userId: UUID,
        sportCode: String
    ) async throws

    // MARK: - Journal

    /// Retourne l'entrée du journal pour `(recordId, targetWeekNumber)` si elle
    /// existe — utilisée pour l'idempotence (no-op si déjà appliquée).
    func fetchJournal(
        recordId: UUID,
        targetWeek: Int
    ) async throws -> RegenJournalEntry?

    /// Insère une nouvelle entrée du journal. L'appelant DOIT avoir vérifié
    /// l'idempotence via `fetchJournal(...)` avant.
    func saveJournal(_ entry: RegenJournalEntry) async throws

    /// Toutes les regens du user dont la `targetWeekNumber` correspond à la
    /// semaine courante (lundi ≤ now < lundi+7j) — sert au badge dashboard.
    /// Trié du plus récent au plus ancien.
    func fetchJournalForCurrentWeek(
        userId: UUID,
        weekStart: Date
    ) async throws -> [RegenJournalEntry]
}
