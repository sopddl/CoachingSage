// Repositories/Implementations/DefaultRoutineRepository.swift
// Story 3.8 — backend SwiftData. V1 sans création UI (cf RoutineRecord doc),
// la lecture suffit pour alimenter la section « Mes routines » du dashboard.
import Foundation
import SwiftData

@MainActor
final class DefaultRoutineRepository: RoutineRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchAll(for userId: UUID) async throws -> [RoutineRecord] {
        // SwiftData ne sait pas trier par optionnel `lastUsedAt` avec nil-last natif :
        // on trie en mémoire après fetch (volume routines attendu ≪ 100, coût négligeable).
        let descriptor = FetchDescriptor<RoutineRecord>(
            predicate: #Predicate { $0.userId == userId }
        )
        let all = try modelContext.fetch(descriptor)
        return all.sorted { lhs, rhs in
            switch (lhs.lastUsedAt, rhs.lastUsedAt) {
            case let (l?, r?): return l > r
            case (_?, nil):    return true
            case (nil, _?):    return false
            case (nil, nil):   return lhs.createdAt > rhs.createdAt
            }
        }
    }
}
