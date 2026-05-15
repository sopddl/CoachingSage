// Repositories/Implementations/DefaultAdaptedProgramRepository.swift
// Story 3.8 — backend SwiftData. Pas de Supabase V1 (local-first, cf Story 3.8 « Hors scope »).
import Foundation
import SwiftData

@MainActor
final class DefaultAdaptedProgramRepository: AdaptedProgramRepository {
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

    func save(_ record: AdaptedProgramRecord) async throws {
        record.lastUpdatedAt = Date()
        modelContext.insert(record)
        try modelContext.save()
    }

    func update(_ record: AdaptedProgramRecord) async throws {
        record.lastUpdatedAt = Date()
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
        try modelContext.save()
    }
}
