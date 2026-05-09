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
}
