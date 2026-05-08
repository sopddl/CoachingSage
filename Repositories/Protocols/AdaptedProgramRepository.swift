// Repositories/Protocols/AdaptedProgramRepository.swift
// Story 3.8 — accès SwiftData aux AdaptedProgramRecord. Local-first V1
// (synchro Supabase déférée — cf spec Story 3.8 « Hors scope »).
import Foundation

@MainActor
protocol AdaptedProgramRepository {
    /// Programmes actifs (`isActive == true`) du user, triés par `adaptedAt` desc.
    func fetchActive(for userId: UUID) async throws -> [AdaptedProgramRecord]

    /// Persiste un nouveau record (sortie du bridge Story 3.3a).
    func save(_ record: AdaptedProgramRecord) async throws

    /// Archive un record (`isActive = false`, `archivedAt = now`).
    func archive(_ record: AdaptedProgramRecord) async throws
}
