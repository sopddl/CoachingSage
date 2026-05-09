// Repositories/Protocols/RoutineRepository.swift
// Story 3.8 — accès SwiftData aux RoutineRecord. Local-first V1.
import Foundation

@MainActor
protocol RoutineRepository {
    /// Routines du user, triées par `lastUsedAt` desc (nil en bas), puis `createdAt` desc.
    func fetchAll(for userId: UUID) async throws -> [RoutineRecord]
}
