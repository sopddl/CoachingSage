// Models/Schema/CoachingSageMigrationPlan.swift
// Plan de migration SwiftData. Historique git :
//   V1 (Story 1.1a) → V2 (Story 2.2) → V3 (Story 3.1) → V4 (Story 3.8) → V5 (Story 3.3b)
//
// 2026-05-09 : drop des V1-V4 du plan runtime suite à un crash SwiftData
// "Duplicate version checksums detected". Cause : SchemaV4 et SchemaV5 référencent
// LE MÊME @Model `AdaptedProgramRecord` (qui contient maintenant les 4 nouveaux
// champs Léon en V5), donc le checksum de version est calculé identique pour
// les deux. Le pattern Apple "VersionedSchema avec snapshot par version" demande
// de dupliquer la classe @Model par version (lourd pour 4 champs).
//
// En dev solo sans utilisateurs prod, on simplifie : seul SchemaV5 reste dans
// `schemas`. Conséquence : les stores locaux en V1-V4 (= juste les simus de
// Sophie) doivent être reset (uninstall app sur simu). Les fichiers SchemaV1-V4
// restent en historique git mais ne sont plus exposés au runtime.
import SwiftData

enum CoachingSageMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [SchemaV5.self]
    }

    static var stages: [MigrationStage] {
        []
    }
}
