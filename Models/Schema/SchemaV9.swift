// Models/Schema/SchemaV9.swift
// Story 3.12 — ajout `AdaptedProgramRecord.customTitle: String?` pour le
// titre éditable par l'utilisateur (rename via tap nav bar).
//
// Différence V8 → V9 :
//   1. `AdaptedProgramRecord.customTitle: String?` — nullable, default nil
//      (rétro-compat : records pré-V9 ont `customTitle == nil`, fallback côté
//      UI vers `"{Sport} — {Goal}"` calculé à la volée).
//
// **Pattern wipe-simu dev solo** : `CoachingSageMigrationPlan.stages = []`
// inchangé. Wipe simu obligatoire au premier run post-merge (uninstall
// l'app sur le simu).
import SwiftData

enum SchemaV9: VersionedSchema {
    static var versionIdentifier = Schema.Version(9, 0, 0)

    static var models: [any PersistentModel.Type] {
        [
            SageCoreProfile.self,
            PendingOperation.self,
            CoachingProfile.self,
            CoachingSportProfile.self,
            AdaptedProgramRecord.self,
            WeeklyExecutionReportRecord.self
        ]
    }
}
