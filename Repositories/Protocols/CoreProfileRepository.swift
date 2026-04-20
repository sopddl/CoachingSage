// CoachingSage/Repositories/Protocols/CoreProfileRepository.swift
// [COPIE IDENTIQUE] — synchroniser avec GardenSage et TailorSage.
import Foundation

protocol CoreProfileRepository {
    /// Récupère le profil core de l'utilisateur connecté (filtre isSoftDeleted == false).
    func fetchCurrentProfile() async throws -> SageCoreProfile?

    /// Crée ou met à jour un SageCoreProfile dans SwiftData + Supabase.
    func save(_ profile: SageCoreProfile) async throws

    /// Soft-delete SwiftData (isSoftDeleted=true, deletedAt=now) + UPDATE core_profiles Supabase.
    func softDelete(_ profile: SageCoreProfile) async throws

    /// Supprime ou réattribue les profils orphelins qui ne correspondent pas à l'auth userId.
    func cleanupOrphanProfiles()

    /// Crée un profil local minimal si aucun n'existe pour l'auth userId.
    func ensureLocalProfileExists()
}
