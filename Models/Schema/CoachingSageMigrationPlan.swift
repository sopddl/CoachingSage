// Models/Schema/CoachingSageMigrationPlan.swift
// Story 2.2 — plan de migration SwiftData V1 → V2.
// Lightweight : ajout du model CoachingProfile, pas de rename ni transformation.
// SwiftData applique la migration automatiquement à l'init du ModelContainer.
import SwiftData

enum CoachingSageMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [SchemaV1.self, SchemaV2.self]
    }

    static var stages: [MigrationStage] {
        [.lightweight(fromVersion: SchemaV1.self, toVersion: SchemaV2.self)]
    }
}
