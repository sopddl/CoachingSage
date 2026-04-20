// CoachingSage/Repositories/Implementations/DefaultCoreProfileRepository.swift
// [COPIE IDENTIQUE] — synchroniser avec GardenSage et TailorSage.
import Foundation
import os
import SwiftData
import SageCore

@MainActor
final class DefaultCoreProfileRepository: CoreProfileRepository {
    private static let logger = Logger(subsystem: "com.sopddl.coachingsage", category: "repository")
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchCurrentProfile() async throws -> SageCoreProfile? {
        if let authUserId = SupabaseService.shared.client.auth.currentSession?.user.id {
            let authDescriptor = FetchDescriptor<SageCoreProfile>(
                predicate: #Predicate { profile in
                    profile.id == authUserId && profile.isSoftDeleted == false
                }
            )
            if let match = try modelContext.fetch(authDescriptor).first {
                return match
            }
        }

        let descriptor = FetchDescriptor<SageCoreProfile>(
            predicate: #Predicate { profile in
                profile.isSoftDeleted == false
            }
        )
        return try modelContext.fetch(descriptor).first
    }

    func cleanupOrphanProfiles() {
        guard let authUserId = SupabaseService.shared.client.auth.currentSession?.user.id else { return }

        let authDescriptor = FetchDescriptor<SageCoreProfile>(
            predicate: #Predicate { profile in
                profile.id == authUserId && profile.isSoftDeleted == false
            }
        )
        let authProfileExists = (try? modelContext.fetch(authDescriptor).first) != nil

        let orphanDescriptor = FetchDescriptor<SageCoreProfile>(
            predicate: #Predicate { profile in
                profile.id != authUserId && profile.isSoftDeleted == false
            }
        )
        guard let orphans = try? modelContext.fetch(orphanDescriptor), !orphans.isEmpty else { return }

        if authProfileExists {
            for orphan in orphans {
                modelContext.delete(orphan)
            }
            #if DEBUG
            Self.logger.debug("Supprimé \(orphans.count) profil(s) orphelin(s)")
            #endif
        } else {
            let keeper = orphans[0]
            keeper.id = authUserId
            keeper.updatedAt = Date()
            for orphan in orphans.dropFirst() {
                modelContext.delete(orphan)
            }
            #if DEBUG
            Self.logger.debug("Réattribué profil orphelin → auth userId \(authUserId)")
            #endif
        }
        try? modelContext.save()
    }

    func ensureLocalProfileExists() {
        guard let authUserId = SupabaseService.shared.client.auth.currentSession?.user.id else { return }
        let descriptor = FetchDescriptor<SageCoreProfile>(
            predicate: #Predicate { profile in
                profile.id == authUserId && profile.isSoftDeleted == false
            }
        )
        guard (try? modelContext.fetch(descriptor).first) == nil else { return }

        let profile = SageCoreProfile(id: authUserId)
        modelContext.insert(profile)
        try? modelContext.save()
        #if DEBUG
        Self.logger.debug("Créé profil local minimal pour auth userId \(authUserId)")
        #endif
    }

    func save(_ profile: SageCoreProfile) async throws {
        modelContext.insert(profile)
        try modelContext.save()

        // En UI testing, pas d'appel Supabase (credentials placeholder → timeout)
        guard ProcessInfo.processInfo.environment["IS_UI_TESTING"] == nil else { return }

        do {
            let dto = CoreProfileUpsertDTO(
                id: profile.id,
                firstName: profile.firstName,
                language: profile.language,
                region: profile.region,
                latitude: profile.latitude,
                longitude: profile.longitude,
                altitude: profile.altitude,
                analyticsConsent: profile.analyticsConsent,
                notificationPreferences: profile.notificationPreferences,
                vacationEndDate: profile.vacationEndDate,
                createdAt: profile.createdAt,
                updatedAt: profile.updatedAt
            )
            try await SupabaseService.shared.client
                .from("core_profiles")
                .upsert(dto)
                .execute()
        } catch {
            Self.logger.error("Supabase upsert FAILED: \(error)")
        }
    }

    func softDelete(_ profile: SageCoreProfile) async throws {
        profile.isSoftDeleted = true
        profile.deletedAt = Date()
        profile.updatedAt = Date()
        try modelContext.save()

        let now = Date()
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        do {
            try await SupabaseService.shared.client
                .from("core_profiles")
                .update([
                    "is_soft_deleted": "true",
                    "deleted_at": formatter.string(from: now),
                    "updated_at": formatter.string(from: now)
                ])
                .eq("id", value: profile.id.uuidString)
                .execute()
        } catch {
            throw AppError.sync("softDelete core_profiles Supabase failed: \(error.localizedDescription)")
        }
    }
}
