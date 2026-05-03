// Repositories/Implementations/DefaultCoachingSportProfileRepository.swift
// Story 3.1 — UPSERT SwiftData + Supabase, hydrate-on-miss côté fetch.
// Pattern strict DefaultCoachingProfileRepository (Story 2.2).
// ⚠️ UUID lowercased avant insert/eq (review P0-3, lesson lessons_supabase #8).
import Foundation
import os
import SwiftData

@MainActor
final class DefaultCoachingSportProfileRepository: CoachingSportProfileRepository {
    private static let logger = Logger(subsystem: "com.sopddl.coachingsage", category: "repository")
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchProfile(for sportCode: String) async throws -> CoachingSportProfile? {
        guard let authUserId = SupabaseService.shared.client.auth.currentSession?.user.id else {
            return nil
        }

        // 1. SwiftData local
        let descriptor = FetchDescriptor<CoachingSportProfile>(
            predicate: #Predicate { profile in
                profile.userId == authUserId && profile.sportCode == sportCode
            }
        )
        if let local = try modelContext.fetch(descriptor).first {
            return local
        }

        // 2. Hydrate-on-miss : fetch Supabase. Skip en UI testing.
        guard ProcessInfo.processInfo.environment["IS_UI_TESTING"] == nil else { return nil }

        do {
            let userIdString = authUserId.uuidString.lowercased()  // review P0-3 / lesson #8
            let response = try await SupabaseService.shared.client
                .from("coaching_sport_profiles")
                .select()
                .eq("user_id", value: userIdString)
                .eq("sport", value: sportCode)
                .limit(1)
                .execute()

            let dtos = try JSONDecoder.supabase().decode([CoachingSportProfileDTO].self, from: response.data)
            guard let dto = dtos.first else { return nil }

            let hydrated = dto.toModel()
            modelContext.insert(hydrated)
            try modelContext.save()
            #if DEBUG
            Self.logger.debug("Hydrated CoachingSportProfile from Supabase user=\(authUserId) sport=\(sportCode)")
            #endif
            return hydrated
        } catch let decodingError as DecodingError {
            Self.logger.error("Hydrate-on-miss CoachingSportProfile DECODER bug: \(String(describing: decodingError))")
            return nil
        } catch {
            #if DEBUG
            Self.logger.debug("Hydrate-on-miss CoachingSportProfile network/auth: \(error.localizedDescription)")
            #endif
            return nil
        }
    }

    func save(_ profile: CoachingSportProfile) async throws {
        profile.lastUpdatedAt = Date()

        // SwiftData : pas de UNIQUE composite native sur (userId, sportCode) → dedup manuel avant insert.
        // Évite que 2 rows existent pour le même (user, sport) si bug downstream.
        let userId = profile.userId
        let sportCode = profile.sportCode
        let profileId = profile.id
        let descriptor = FetchDescriptor<CoachingSportProfile>(
            predicate: #Predicate { existing in
                existing.userId == userId
                && existing.sportCode == sportCode
                && existing.id != profileId
            }
        )
        let duplicates = try modelContext.fetch(descriptor)
        for dup in duplicates {
            modelContext.delete(dup)
        }
        modelContext.insert(profile)
        try modelContext.save()

        // En UI testing, pas d'appel Supabase.
        guard ProcessInfo.processInfo.environment["IS_UI_TESTING"] == nil else { return }

        // Différent du pattern CoachingProfile : on THROW si Supabase échoue, pour que le ViewModel
        // puisse afficher le bandeau "Réessayer" (AC9). Le SwiftData reste sauvé localement → recovery garanti.
        do {
            let dto = CoachingSportProfileUpsertDTO(from: profile)
            try await SupabaseService.shared.client
                .from("coaching_sport_profiles")
                .upsert(dto, onConflict: "user_id,sport", ignoreDuplicates: false)
                .execute()
        } catch {
            Self.logger.error("Supabase upsert CoachingSportProfile FAILED: \(error)")
            throw error
        }
    }

    func delete(for sportCode: String) async throws {
        guard let authUserId = SupabaseService.shared.client.auth.currentSession?.user.id else { return }

        // SwiftData
        let descriptor = FetchDescriptor<CoachingSportProfile>(
            predicate: #Predicate { profile in
                profile.userId == authUserId && profile.sportCode == sportCode
            }
        )
        let toDelete = try modelContext.fetch(descriptor)
        for profile in toDelete {
            modelContext.delete(profile)
        }
        try modelContext.save()

        // Supabase
        guard ProcessInfo.processInfo.environment["IS_UI_TESTING"] == nil else { return }
        do {
            try await SupabaseService.shared.client
                .from("coaching_sport_profiles")
                .delete()
                .eq("user_id", value: authUserId.uuidString.lowercased())
                .eq("sport", value: sportCode)
                .execute()
        } catch {
            Self.logger.error("Supabase delete CoachingSportProfile FAILED: \(error)")
        }
    }
}
