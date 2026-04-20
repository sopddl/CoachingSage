//
//  PendingOperation.swift
//  CoachingSage
//
//  [COPIE IDENTIQUE] — synchroniser avec GardenSage et TailorSage.
//

import Foundation
import SwiftData

/// Queue de synchronisation offline — persiste sur disque, survit aux crashes.
/// Drainée par SyncService à la reconnexion réseau (FIFO + exponential backoff ×3).
/// Pas de soft delete : une opération drainée est supprimée du ModelContext.
@Model
final class PendingOperation {
    var id: UUID
    var operationType: String  // "create_session" | "update_core_profile" | ...
    var payload: Data          // JSON encodé des paramètres de l'opération
    var createdAt: Date
    var retryCount: Int        // Incrémenté à chaque échec — supprimé après 3 tentatives

    init(id: UUID = UUID(), operationType: String, payload: Data) {
        self.id = id
        self.operationType = operationType
        self.payload = payload
        self.createdAt = Date()
        self.retryCount = 0
    }
}
