// Models/Schema/CoachingSageMigrationPlan.swift
// Plan de migration SwiftData. Historique git :
//   V1 (Story 1.1a) → V2 (Story 2.2) → V3 (Story 3.1) → V4 (Story 3.8) → V5 (Story 3.3b) → V6 (Story sœur post-3.3b) → V7 (Story 3.4 Phase B) → V8 (Story 3.10)
//
// 2026-05-09 : drop des V1-V4 du plan runtime suite à un crash SwiftData
// "Duplicate version checksums detected". Cause : SchemaV4 et SchemaV5 référencent
// LE MÊME @Model `AdaptedProgramRecord` (qui contient maintenant les 4 nouveaux
// champs Léon en V5), donc le checksum de version est calculé identique pour
// les deux. Le pattern Apple "VersionedSchema avec snapshot par version" demande
// de dupliquer la classe @Model par version (lourd pour 4 champs).
//
// En dev solo sans utilisateurs prod, on simplifie : seul le dernier schema
// reste dans `schemas`. Conséquence : les stores locaux antérieurs (= juste les
// simus de Sophie) doivent être reset (uninstall app sur simu). Les fichiers
// SchemaV1-V7 restent en historique git mais ne sont plus exposés au runtime.
//
// Story 3.10 (V8) — migration breaking weekStartDate nullable + drop
// RoutineRecord. Wipe simu obligatoire au premier run post-merge.
// Story 3.12 (V9) — ajout AdaptedProgramRecord.customTitle. Wipe simu
// obligatoire au premier run post-merge.
// Story 3.21 hotfix (V10) — ajout CoachingProfile.bootstrappedDormantsLocal
// (SwiftData-only, fix Bug F cross-device). Wipe simu obligatoire.
// Story 3.28 (V11) — ajout AdaptedProgramRecord.goalCode + secondaryGoalsCSV
// + isUserRenamed (i18n titres re-localisables). Wipe simu obligatoire.
import SwiftData

enum CoachingSageMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [SchemaV11.self]
    }

    static var stages: [MigrationStage] {
        []
    }
}
