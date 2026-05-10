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

            // Hydrate-on-miss : SwiftData local vide (ex: réinstallation app) → fetch Supabase et hydrate.
            // Aligné DefaultCoachingProfileRepository (qui a déjà ce pattern).
            // ⚠️ DRIFT [COPIE IDENTIQUE] vs GardenSage/TailorSage : à propager en story dédiée.
            // Bug Story 3.1 (2026-04-29) : sans hydrate, ProfileViewModel échouait avec .notFound après une réinstall
            // (CoachingProfile était re-hydraté mais SageCoreProfile restait nil).
            guard ProcessInfo.processInfo.environment["IS_UI_TESTING"] == nil else {
                // En UI testing, pas d'appel Supabase (credentials placeholder → timeout).
                let fallback = FetchDescriptor<SageCoreProfile>(
                    predicate: #Predicate { profile in profile.isSoftDeleted == false }
                )
                return try modelContext.fetch(fallback).first
            }

            do {
                let response = try await SupabaseService.shared.client
                    .from("core_profiles")
                    .select()
                    .eq("id", value: authUserId.uuidString)
                    .eq("is_soft_deleted", value: false)
                    .limit(1)
                    .execute()

                let dtos = try JSONDecoder.supabase().decode([CoreProfileDTO].self, from: response.data)
                if let dto = dtos.first {
                    let hydrated = dto.toModel()
                    modelContext.insert(hydrated)
                    try modelContext.save()
                    #if DEBUG
                    Self.logger.debug("Hydrated SageCoreProfile from Supabase for user \(authUserId)")
                    #endif
                    return hydrated
                }
            } catch let decodingError as DecodingError {
                Self.logger.error("Hydrate-on-miss SageCoreProfile DECODER bug: \(String(describing: decodingError))")
            } catch {
                #if DEBUG
                Self.logger.debug("Hydrate-on-miss SageCoreProfile network/auth: \(error.localizedDescription)")
                #endif
            }
        }

        // Fallback final : retourne n'importe quel profil non soft-deleted (cas edge sans session).
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
            // Sophie 2026-05-11 — passage de silent catch à throw. Cause : bug
            // "Profil non chargé" sur ProfileView, root cause = upsert silently
            // fail au finalize onboarding (RLS, session, etc.) → user marqué
            // localement onboarded mais row Supabase absente → fetch retourne nil.
            // Propager force l'UI à afficher l'erreur réelle et permet au user
            // de la voir + corriger (vs zombie state).
            Self.logger.error("Supabase upsert core_profiles FAILED: \(error) — user=\(profile.id)")
            throw AppError.sync("Erreur de synchronisation Supabase (core_profiles) : \(error.localizedDescription)")
        }
    }

    func softDelete(_ profile: SageCoreProfile) async throws {
        profile.isSoftDeleted = true
        profile.deletedAt = Date()
        profile.updatedAt = Date()
        try modelContext.save()

        // En UI testing, pas d'appel Supabase (credentials placeholder → timeout).
        guard ProcessInfo.processInfo.environment["IS_UI_TESTING"] == nil else { return }

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
