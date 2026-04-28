// Repositories/Protocols/CoachingProfileRepository.swift
// Story 2.2 — repo CS-only (pas de [COPIE IDENTIQUE]).
import Foundation

protocol CoachingProfileRepository {
    /// Récupère le profil coaching de l'utilisateur connecté (filtre isSoftDeleted == false).
    /// **Hydrate-on-miss** : si SwiftData local nil, fetch Supabase ; hydrate SwiftData si row distante existe.
    /// Évite l'écrasement de la row Supabase au `save()` quand un user revient sur un nouveau device.
    func fetchCurrentProfile() async throws -> CoachingProfile?

    /// UPSERT SwiftData + UPSERT Supabase (`coaching_profiles`).
    func save(_ profile: CoachingProfile) async throws
}
