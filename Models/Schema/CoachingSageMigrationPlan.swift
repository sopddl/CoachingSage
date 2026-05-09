// Models/Schema/CoachingSageMigrationPlan.swift
// Plan de migration SwiftData :
//   V1 (Story 1.1a) → V2 (Story 2.2 : + CoachingProfile) → V3 (Story 3.1 : + CoachingSportProfile)
//   → V4 (Story 3.8 : + AdaptedProgramRecord + RoutineRecord)
//   → V5 (Story 3.3b : + 4 propriétés AdaptedProgramRecord pour requiresAIAssist + aiPatch)
// Lightweight à chaque étape : ajout de model ou propriété uniquement, pas de rename ni transformation.
// SwiftData applique la migration automatiquement à l'init du ModelContainer.
import SwiftData

enum CoachingSageMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [SchemaV1.self, SchemaV2.self, SchemaV3.self, SchemaV4.self, SchemaV5.self]
    }

    static var stages: [MigrationStage] {
        [
            .lightweight(fromVersion: SchemaV1.self, toVersion: SchemaV2.self),
            .lightweight(fromVersion: SchemaV2.self, toVersion: SchemaV3.self),
            .lightweight(fromVersion: SchemaV3.self, toVersion: SchemaV4.self),
            .lightweight(fromVersion: SchemaV4.self, toVersion: SchemaV5.self)
        ]
    }
}
