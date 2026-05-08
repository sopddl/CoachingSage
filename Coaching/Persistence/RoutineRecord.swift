// Coaching/Persistence/RoutineRecord.swift
// Story 3.8 — persistance SwiftData des routines (séances libres préparées par
// l'utilisateur, hors programme). Pattern « Routines » repris de Hevy
// (cf party design 2026-05-07 §3 patterns marché).
//
// V1 : pas de UI de création (décision Sophie #4 — pas de routines en mode vide,
// l'entrée se fera plus tard). Le @Model existe pour permettre au dashboard
// d'afficher la section « Mes routines » dès qu'il y a ≥ 1 row, sans dépendance
// future bloquante.
import Foundation
import SwiftData

@Model
final class RoutineRecord {
    @Attribute(.unique) var id: UUID
    var userId: UUID
    var name: String
    var durationMinutes: Int

    /// Codes équipement (kebab-case côté templates V2) requis pour la routine.
    /// Stocké direct car `[String]` est natif SwiftData.
    var equipmentRequired: [String]

    var createdAt: Date

    /// Dernière fois que l'user a démarré la routine. Sert à trier la liste
    /// "Mes routines" (plus récente en haut). `nil` tant que jamais lancée.
    var lastUsedAt: Date?

    init(
        id: UUID = UUID(),
        userId: UUID,
        name: String,
        durationMinutes: Int,
        equipmentRequired: [String] = [],
        createdAt: Date = Date(),
        lastUsedAt: Date? = nil
    ) {
        self.id = id
        self.userId = userId
        self.name = name
        self.durationMinutes = durationMinutes
        self.equipmentRequired = equipmentRequired
        self.createdAt = createdAt
        self.lastUsedAt = lastUsedAt
    }
}
