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

    /// Persiste les mutations d'un record déjà tracké (drag&drop hebdo Story 3.8 :
    /// `sessions[i].plannedDate` modifiée + bascule éventuelle de `mode`).
    func update(_ record: AdaptedProgramRecord) async throws

    /// Archive un record (`isActive = false`, `archivedAt = now`).
    func archive(_ record: AdaptedProgramRecord) async throws

    /// Story 3.3b — applique un patch Léon sur un record persisté et sauvegarde
    /// l'idempotence (aiPatchApplied + aiPatchJSON). No-op silencieux si le record
    /// n'existe plus (cas dégénéré : user a archivé pendant qu'on call Léon).
    func applyLeonPatch(recordId: UUID, patch: AdaptationPatch) async throws

    /// Phase A boucle complétion — lit la SessionCompletionRecord existante pour
    /// une session identifiée par (weekNumber, day). Renvoie nil si la session
    /// n'a pas encore été marquée terminée. Throw recordNotFound si le programme
    /// n'existe plus.
    func loadSessionCompletion(recordId: UUID, weekNumber: Int, day: Int) async throws -> SessionCompletionRecord?

    /// Phase A boucle complétion — set ou clear (record == nil) la
    /// SessionCompletionRecord pour une session. Le mapping (weekNumber, day) →
    /// PersistedSession.id est résolu par le repo. Throw si record/session
    /// introuvables.
    func recordSessionCompletion(
        recordId: UUID,
        weekNumber: Int,
        day: Int,
        record: SessionCompletionRecord?
    ) async throws
}

enum SessionCompletionRepositoryError: Error, Equatable {
    case recordNotFound
    case sessionNotFound
}
