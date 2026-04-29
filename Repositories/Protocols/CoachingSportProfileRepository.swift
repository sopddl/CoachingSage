// Repositories/Protocols/CoachingSportProfileRepository.swift
// Story 3.1 — repo pour les profils sportifs détaillés (1 par user × sport).
// Pattern strict CoachingProfileRepository : SwiftData local + upsert Supabase, hydrate-on-miss.
import Foundation

protocol CoachingSportProfileRepository {
    /// Récupère le profil sport pour le user connecté + `sportCode` donné.
    /// **Hydrate-on-miss** : si SwiftData local nil, fetch Supabase ; hydrate SwiftData si row distante existe.
    /// Retourne nil si aucun profil pour ce (user × sport).
    func fetchProfile(for sportCode: String) async throws -> CoachingSportProfile?

    /// UPSERT SwiftData + UPSERT Supabase (`coaching_sport_profiles`, ON CONFLICT user_id+sport).
    /// Throws si Supabase échoue (UX bandeau erreur AC9 — différent du pattern CoachingProfile qui swallow).
    func save(_ profile: CoachingSportProfile) async throws

    /// Cleanup SwiftData + Supabase. Utilisé si l'user retire un sport via Story 2.3 (orphelin).
    /// V1 : appel manuel depuis le code, pas de hook automatique.
    func delete(for sportCode: String) async throws
}
