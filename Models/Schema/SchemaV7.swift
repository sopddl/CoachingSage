// Models/Schema/SchemaV7.swift
// Story 3.4 Phase B.1 — ajoute UN nouveau @Model pour persister les snapshots
// des semaines analysées (historique pour PauseDetector) :
//   - WeeklyExecutionReportRecord
//
// `RegenJournalEntry` est PASSÉ en JSON file plat (cf
// `Coaching/Persistence/RegenJournalEntry.swift`), pas un @Model — crash
// SwiftData `Lost connection to testmanagerd` non résolu après 10 tentatives
// 2026-05-12. Volumes V1 faibles, file plat OK.
//
// Lightweight migration depuis SchemaV6 : 1 ajout de table, pas de transformation
// sur les models existants. Comme V6 (cf. note CoachingSageMigrationPlan), on
// drop V6 du runtime — un dev solo sans utilisateur prod a juste à reset son
// simu si le store local pré-V7 traîne.
import SwiftData

enum SchemaV7: VersionedSchema {
    static var versionIdentifier = Schema.Version(7, 0, 0)

    static var models: [any PersistentModel.Type] {
        [
            SageCoreProfile.self,
            PendingOperation.self,
            CoachingProfile.self,
            CoachingSportProfile.self,
            AdaptedProgramRecord.self,
            RoutineRecord.self,
            WeeklyExecutionReportRecord.self
        ]
    }
}
