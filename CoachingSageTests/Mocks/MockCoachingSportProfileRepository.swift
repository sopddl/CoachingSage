// CoachingSageTests/Mocks/MockCoachingSportProfileRepository.swift
// Story 3.1 — mock en mémoire pour les tests ViewModel + Repository.
import Foundation
@testable import CoachingSage

@MainActor
final class MockCoachingSportProfileRepository: CoachingSportProfileRepository {
    var stored: [String: CoachingSportProfile] = [:]
    var saveError: Error?
    var saveCallCount: Int = 0
    var fetchCallCount: Int = 0

    /// Permet l'instanciation depuis un contexte nonisolated (defaults de
    /// paramètres de tests `@MainActor`). Les stored properties initialisées
    /// par défaut ne touchent à aucun état partagé.
    nonisolated init() {}

    func fetchProfile(for sportCode: String) async throws -> CoachingSportProfile? {
        fetchCallCount += 1
        return stored[sportCode]
    }

    func save(_ profile: CoachingSportProfile) async throws {
        saveCallCount += 1
        if let err = saveError { throw err }
        stored[profile.sportCode] = profile
    }

    func delete(for sportCode: String) async throws {
        stored.removeValue(forKey: sportCode)
    }
}
