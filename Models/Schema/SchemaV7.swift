// Models/Schema/SchemaV7.swift
// Story 3.4 Phase B.1 — ajoute 2 nouveaux @Model pour persister la regen hebdo :
//   - WeeklyExecutionReportRecord : snapshots des semaines analysées (historique
//     pour PauseDetector).
//   - RegenJournalEntry : trace de chaque application de regen (idempotence +
//     badge dashboard + overlay sessions modifiées).
//
// Lightweight migration depuis SchemaV6 : 2 ajouts de tables, pas de transformation
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
            WeeklyExecutionReportRecord.self,
            RegenJournalEntry.self
        ]
    }
}
