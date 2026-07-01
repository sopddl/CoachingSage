// Repositories/Implementations/DefaultAdaptedProgramRepository.swift
// Story 3.8 — backend SwiftData. Pas de Supabase V1 (local-first, cf Story 3.8 « Hors scope »).
// Story 3.10 — caps dormant/démarré (10 / 8) + markStarted + auto-archive à complétion.
import Foundation
import SwiftData

@MainActor
final class DefaultAdaptedProgramRepository: AdaptedProgramRepository {
    /// **Story 3.10** — cap programmes dormants simultanés actifs (`weekStartDate == nil`).
    static let dormantCap = 10
    /// **Story 3.10** — cap programmes démarrés simultanés actifs (`weekStartDate != nil`).
    /// Relevé 5 → 8 (Sophie 2026-07-01) : plus de marge sans surcharger le carrousel
    /// dashboard ni multiplier les regen/notifs. Reste sous `dormantCap` (10).
    static let startedCap = 8

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchActive(for userId: UUID) async throws -> [AdaptedProgramRecord] {
        let descriptor = FetchDescriptor<AdaptedProgramRecord>(
            predicate: #Predicate { $0.userId == userId && $0.isActive },
            sortBy: [SortDescriptor(\.adaptedAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    func fetchStartedCount(for userId: UUID) async throws -> Int {
        // SwiftData #Predicate ne supporte pas `weekStartDate != nil` directement
        // dans toutes les versions iOS — filtre côté Swift après fetchActive
        // (volumes V1 < 15 rows par user, perf non-critique).
        let active = try await fetchActive(for: userId)
        return active.filter { $0.weekStartDate != nil }.count
    }

    func fetchDormantCount(for userId: UUID) async throws -> Int {
        let active = try await fetchActive(for: userId)
        return active.filter { $0.weekStartDate == nil }.count
    }

    func save(_ record: AdaptedProgramRecord) async throws {
        // **Story 3.10** — check cap selon le type du record entrant.
        let active = try await fetchActive(for: record.userId)
        if record.weekStartDate == nil {
            let dormantCount = active.filter { $0.weekStartDate == nil }.count
            guard dormantCount < Self.dormantCap else {
                throw ProgramCapReached.dormant(limit: Self.dormantCap)
            }
        } else {
            let startedCount = active.filter { $0.weekStartDate != nil }.count
            guard startedCount < Self.startedCap else {
                throw ProgramCapReached.started(limit: Self.startedCap)
            }
        }
        record.lastUpdatedAt = Date()
        modelContext.insert(record)
        try modelContext.save()
    }

    func update(_ record: AdaptedProgramRecord) async throws {
        record.lastUpdatedAt = Date()
        try modelContext.save()
    }

    /// **Story 3.11** — fetch d'un record par son id. Retourne nil si introuvable
    /// ou archivé (cohérent avec les call-sites `ReplanifyService` qui ne
    /// devraient pas opérer sur un record archivé).
    func fetchById(recordId: UUID) async throws -> AdaptedProgramRecord? {
        let descriptor = FetchDescriptor<AdaptedProgramRecord>(
            predicate: #Predicate { $0.id == recordId && $0.isActive }
        )
        return try modelContext.fetch(descriptor).first
    }

    /// **Story 3.10 AC8/AC13** — bascule un dormant en démarré + check cap.
    /// Le record est fetché par `recordId`, `markStarted()` est idempotent.
    /// No-op silencieux si le record n'existe plus (cas dégénéré : user archive
    /// pendant qu'on tape le bouton démarrer).
    func markStarted(recordId: UUID) async throws {
        let descriptor = FetchDescriptor<AdaptedProgramRecord>(
            predicate: #Predicate { $0.id == recordId }
        )
        guard let record = try modelContext.fetch(descriptor).first else { return }
        // Déjà démarré : no-op idempotent (pas de check cap, on garde tel quel).
        guard record.weekStartDate == nil else { return }
        // Check cap démarrés AVANT mutation.
        let startedCount = try await fetchStartedCount(for: record.userId)
        guard startedCount < Self.startedCap else {
            throw ProgramCapReached.started(limit: Self.startedCap)
        }
        record.markStarted()
        try modelContext.save()
    }

    func archive(_ record: AdaptedProgramRecord) async throws {
        record.isActive = false
        record.archivedAt = Date()
        record.lastUpdatedAt = Date()
        try modelContext.save()
    }

    func applyLeonPatch(recordId: UUID, patch: AdaptationPatch) async throws {
        let descriptor = FetchDescriptor<AdaptedProgramRecord>(
            predicate: #Predicate { $0.id == recordId }
        )
        guard let record = try modelContext.fetch(descriptor).first else { return }
        try record.applyLeonPatch(patch)
        try modelContext.save()
    }

    func loadSessionCompletion(recordId: UUID, weekNumber: Int, day: Int) async throws -> SessionCompletionRecord? {
        let descriptor = FetchDescriptor<AdaptedProgramRecord>(
            predicate: #Predicate { $0.id == recordId }
        )
        guard let record = try modelContext.fetch(descriptor).first else {
            throw SessionCompletionRepositoryError.recordNotFound
        }
        guard let session = record.sessions.first(where: { $0.weekNumber == weekNumber && $0.day == day }) else {
            return nil
        }
        return record.completionState.sessionRecords[session.id]
    }

    func recordSessionCompletion(
        recordId: UUID,
        weekNumber: Int,
        day: Int,
        record: SessionCompletionRecord?
    ) async throws {
        let descriptor = FetchDescriptor<AdaptedProgramRecord>(
            predicate: #Predicate { $0.id == recordId }
        )
        guard let programRecord = try modelContext.fetch(descriptor).first else {
            throw SessionCompletionRepositoryError.recordNotFound
        }
        guard let session = programRecord.sessions.first(where: { $0.weekNumber == weekNumber && $0.day == day }) else {
            throw SessionCompletionRepositoryError.sessionNotFound
        }
        var state = programRecord.completionState
        if let record {
            state.sessionRecords[session.id] = record
        } else {
            state.sessionRecords.removeValue(forKey: session.id)
        }
        programRecord.completionState = state
        programRecord.lastUpdatedAt = Date()

        // **Story 3.10 AC14** — auto-archive à complétion : si toutes les
        // sessions du programme sont cochées, on flip `isActive = false`
        // silencieusement (libère le slot du cap). Seul l'ajout (record != nil)
        // peut compléter — un retrait ne déclenche pas l'auto-archive.
        //
        // **Story 3.31** — une routine (`routineCyclic`) ne s'auto-archive
        // JAMAIS : à complétion elle bascule en « cycle terminé » et reste
        // visible avec un CTA de renouvellement (`RoutineCycleService`). Sans ça
        // l'utilisateur qui voulait s'entretenir « sans fin » se retrouverait
        // devant un dashboard vide. Les modes deadline gardent l'auto-archive.
        //
        // **Story 3.31 follow-up** — dénominateur = sessions ACTIVES (hors
        // `.rest`). Les jours de repos ne sont jamais complétables, donc un
        // programme deadline avec des jours de repos n'atteignait jamais
        // `completedCount == sessions.count` et ne s'auto-archivait JAMAIS
        // (il squattait un slot `startedCap` à vie). `completedCount` est déjà
        // active-only (le repos n'entre jamais dans `completionState`).
        let activeSessionCount = programRecord.sessions.filter { $0.type != .rest }.count
        if record != nil,
           programRecord.durationMode != .routineCyclic,
           activeSessionCount > 0,
           programRecord.completionState.completedCount >= activeSessionCount {
            programRecord.isActive = false
            programRecord.archivedAt = Date()
        }

        try modelContext.save()
    }
}
