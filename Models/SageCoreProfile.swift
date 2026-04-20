// CoachingSage/Models/SageCoreProfile.swift
// [COPIE IDENTIQUE] — synchroniser avec GardenSage et TailorSage (cf. sage-app-blueprint.md).
import Foundation
import SwiftData
import SageCore

/// Profil core Sage — partagé entre toutes les apps de la suite.
/// Synchronisé avec la table `core_profiles` Supabase via CoreProfileDTO.
/// ⚠️ id DOIT être auth.users.id — jamais UUID() par défaut (RLS Supabase vérifie auth.uid() == id).
@Model
final class SageCoreProfile {
    var id: UUID             // = Supabase auth.users.id

    // Préférences communes à toutes les apps Sage
    var firstName: String?               // prénom utilisateur
    var language: String                 // "fr" | "en"
    var region: String                   // pour personnalisation régionale
    var latitude: Double?
    var longitude: Double?
    var altitude: Double?
    var analyticsConsent: Bool
    var notificationPreferences: Data?   // JSON
    var vacationEndDate: Date?

    // Monétisation — géré côté serveur, lu en sync
    var subscriptionTier: String = "free" // "free" | "plus" | "pro"
    var subscriptionExpiresAt: Date?

    // Soft delete + sync
    var createdAt: Date
    var updatedAt: Date
    @Attribute(originalName: "isDeleted") var isSoftDeleted: Bool
    var deletedAt: Date?

    init(
        id: UUID,
        language: String = "fr",
        region: String = ""
    ) {
        self.id = id
        self.firstName = nil
        self.language = language
        self.region = region
        self.latitude = nil
        self.longitude = nil
        self.altitude = nil
        self.analyticsConsent = false
        self.notificationPreferences = nil
        self.vacationEndDate = nil
        self.subscriptionTier = "free"
        self.subscriptionExpiresAt = nil
        self.createdAt = Date()
        self.updatedAt = Date()
        self.isSoftDeleted = false
        self.deletedAt = nil
    }
}
