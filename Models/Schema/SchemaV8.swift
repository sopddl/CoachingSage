// Models/Schema/SchemaV8.swift
// Story 3.10 — migration breaking weekStartDate `Date` → `Date?` + drop `RoutineRecord`.
//
// Différences V7 → V8 :
//   1. `AdaptedProgramRecord.weekStartDate` passe de `Date` non-null à `Date?`.
//      Un programme "dormant" (généré en avance, jamais démarré) a
//      `weekStartDate == nil`. Le premier tap "Démarrer ma séance" pose la date
//      via `AdaptedProgramRecord.markStarted()`.
//   2. `AdaptedProgramRecord.shiftGeneration: Int = 0` ajouté. Câblé par
//      Story 3.11 (idempotence regen post-shift) mais introduit ici pour ne pas
//      refaire de migration breaking.
//   3. Drop `@Model RoutineRecord` (suppression complète — aucun row en base
//      depuis Story 3.1, pas d'UI de création, code mort).
//
// **Pattern wipe-simu dev solo** : `CoachingSageMigrationPlan.stages = []`
// (comportement V6/V7 inchangé, cf commentaire dans
// `CoachingSageMigrationPlan.swift`). Wipe simu obligatoire au premier run
// post-merge. Aucune migration runtime à coder.
import SwiftData

enum SchemaV8: VersionedSchema {
    static var versionIdentifier = Schema.Version(8, 0, 0)

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
