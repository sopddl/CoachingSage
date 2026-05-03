// Repositories/Implementations/DefaultCoachingProfileRepository.swift
// Story 2.2 — UPSERT SwiftData + Supabase, hydrate-on-miss côté fetch (review P0-2).
import Foundation
import os
import SwiftData
import SageCore

@MainActor
final class DefaultCoachingProfileRepository: CoachingProfileRepository {
    private static let logger = Logger(subsystem: "com.sopddl.coachingsage", category: "repository")
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchCurrentProfile() async throws -> CoachingProfile? {
        guard let authUserId = SupabaseService.shared.client.auth.currentSession?.user.id else {
            return nil
        }

        // 1. SwiftData local
        let descriptor = FetchDescriptor<CoachingProfile>(
            predicate: #Predicate { profile in
                profile.id == authUserId && profile.isSoftDeleted == false
            }
        )
        if let local = try modelContext.fetch(descriptor).first {
            return local
        }

        // 2. Hydrate-on-miss : fetch Supabase. Si la row existe → hydrate SwiftData.
        // Évite l'écrasement de la row Supabase au save() quand un user revient sur nouveau device.
        guard ProcessInfo.processInfo.environment["IS_UI_TESTING"] == nil else { return nil }

        do {
            let response = try await SupabaseService.shared.client
                .from("coaching_profiles")
                .select()
                .eq("id", value: authUserId.uuidString)
                .eq("is_soft_deleted", value: false)
                .limit(1)
                .execute()

            let dtos = try JSONDecoder.supabase().decode([CoachingProfileDTO].self, from: response.data)
            guard let dto = dtos.first else { return nil }

            let hydrated = dto.toModel()
            modelContext.insert(hydrated)
            try modelContext.save()
            #if DEBUG
            Self.logger.debug("Hydrated CoachingProfile from Supabase for user \(authUserId)")
            #endif
            return hydrated
        } catch let decodingError as DecodingError {
            Self.logger.error("Hydrate-on-miss CoachingProfile DECODER bug: \(String(describing: decodingError))")
            return nil
        } catch {
            #if DEBUG
            Self.logger.debug("Hydrate-on-miss CoachingProfile network/auth: \(error.localizedDescription)")
            #endif
            return nil
        }
    }

    func save(_ profile: CoachingProfile) async throws {
        profile.updatedAt = Date()
        modelContext.insert(profile)
        try modelContext.save()

        // En UI testing, pas d'appel Supabase (credentials placeholder → timeout).
        guard ProcessInfo.processInfo.environment["IS_UI_TESTING"] == nil else { return }

        // Aligné DefaultCoreProfileRepository.save: log only en cas d'échec Supabase.
        // Évite de laisser un état SwiftData/Supabase incohérent (local marqué onboarded
        // mais row distante absente) qui bloquerait l'UX si Supabase est down.
        // Le drain offline ressortira via SyncService Epic 7+ (PendingOperation type CoachingProfile à ajouter).
        do {
            let dto = CoachingProfileUpsertDTO(from: profile)
            try await SupabaseService.shared.client
                .from("coaching_profiles")
                .upsert(dto)
                .execute()
        } catch {
            Self.logger.error("Supabase upsert FAILED: \(error)")
        }
    }
}
