// Repositories/Protocols/AdaptedProgramRepository.swift
// Story 3.8 — accès SwiftData aux AdaptedProgramRecord. Local-first V1
// (synchro Supabase déférée — cf spec Story 3.8 « Hors scope »).
//
// Story 3.10 — ajout `fetchStartedCount` / `fetchDormantCount` + `markStarted`
// (+ check caps dormant/démarré au `save` / `markStarted`).
import Foundation

@MainActor
protocol AdaptedProgramRepository {
    /// Programmes actifs (`isActive == true`) du user, triés par `adaptedAt` desc.
    func fetchActive(for userId: UUID) async throws -> [AdaptedProgramRecord]

    /// **Story 3.10** — Programmes actifs démarrés (`weekStartDate != nil`)
    /// du user. Sert au check du cap `ProgramCapReached.started(limit: 5)`.
    func fetchStartedCount(for userId: UUID) async throws -> Int

    /// **Story 3.10** — Programmes actifs dormants (`weekStartDate == nil`)
    /// du user. Sert au check du cap `ProgramCapReached.dormant(limit: 10)`.
    func fetchDormantCount(for userId: UUID) async throws -> Int

    /// Persiste un nouveau record (sortie du bridge Story 3.3a).
    /// **Story 3.10** — Si le record est dormant (`weekStartDate == nil`),
    /// throw `ProgramCapReached.dormant(limit: 10)` quand le cap est atteint
    /// pour le user. Si le record est démarré (édition manuelle, peu probable
    /// hors tests), throw `ProgramCapReached.started(limit: 5)` au-delà.
    func save(_ record: AdaptedProgramRecord) async throws

    /// Persiste les mutations d'un record déjà tracké (drag&drop hebdo Story 3.8 :
    /// `sessions[i].plannedDate` modifiée + bascule éventuelle de `mode`).
    func update(_ record: AdaptedProgramRecord) async throws

    /// **Story 3.10** — Bascule un programme dormant en démarré (pose
    /// `weekStartDate` sur lundi de la semaine courante). Idempotent : no-op
    /// si déjà démarré. Throw `ProgramCapReached.started(limit: 5)` quand le
    /// cap de programmes démarrés est atteint pour le user.
    func markStarted(recordId: UUID) async throws

    /// **Story 3.11** — Récupère un record par son `id` (cross-user, V1
    /// local-first mono-user). Retourne nil si le record n'existe pas ou
    /// est archivé. Utilisé par `ReplanifyService` qui n'a que l'id du
    /// programme courant (la sheet est invoquée depuis le carrousel).
    func fetchById(recordId: UUID) async throws -> AdaptedProgramRecord?

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

/// **Story 3.10** — Erreur typée renvoyée par `save` / `markStarted` quand le
/// cap de programmes (dormants ou démarrés) est atteint pour le user.
/// L'UI catch cette erreur pour afficher une `.alert(...)` avec titre/message
/// `dashboard.program.cap.{dormant,started}.alert.title/message`.
///
/// Caps choisis (Story 3.10 spec) :
///   - 5 démarrés simultanés max (`weekStartDate != nil && isActive == true`)
///   - 10 dormants simultanés max (`weekStartDate == nil && isActive == true`)
enum ProgramCapReached: Error, Equatable {
    case dormant(limit: Int)
    case started(limit: Int)
}
