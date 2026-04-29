// Models/Schema/CoachingSageMigrationPlan.swift
// Plan de migration SwiftData :
//   V1 (Story 1.1a) → V2 (Story 2.2 : + CoachingProfile) → V3 (Story 3.1 : + CoachingSportProfile)
// Lightweight à chaque étape : ajout de model uniquement, pas de rename ni transformation.
// SwiftData applique la migration automatiquement à l'init du ModelContainer.
import SwiftData

enum CoachingSageMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [SchemaV1.self, SchemaV2.self, SchemaV3.self]
    }

    static var stages: [MigrationStage] {
        [
            .lightweight(fromVersion: SchemaV1.self, toVersion: SchemaV2.self),
            .lightweight(fromVersion: SchemaV2.self, toVersion: SchemaV3.self)
        ]
    }
}
