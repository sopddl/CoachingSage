// Models/Schema/SchemaV1.swift
// V1 — Story 1.1a bootstrap Epic 1 Foundation.
// Contient uniquement SageCoreProfile (partagé Sage) + PendingOperation (queue sync offline).
// Les modèles domaine CoachingSage (CoachingSportProfile, CoachingSession, etc.) arrivent en Epic 2+.

import SwiftData

enum SchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [
            SageCoreProfile.self,
            PendingOperation.self
        ]
    }
}
