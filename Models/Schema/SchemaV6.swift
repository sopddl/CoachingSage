// Models/Schema/SchemaV6.swift
// Story sœur (post-3.3b) — ajoute 3 propriétés à AdaptedProgramRecord pour persister
// le mode de durée du programme (deadline fixée, deadline estimée par algo, routine
// cyclique 3 mois) + la date cible + le numéro de cycle (incrémenté à chaque
// renouvellement d'une routine).
//
// Lightweight migration depuis SchemaV5 : 3 ajouts avec defaults
// (`durationModeRaw = "routineCyclic"`, `targetDate = nil`, `cycleNumber = 1`),
// pas de transformation. Comme V5 (Story 3.3b), on drop V5 du runtime pour éviter
// le crash "Duplicate version checksums detected" (cf. CoachingSageMigrationPlan).
// En dev solo sans utilisateurs prod, les simus de Sophie doivent être reset.
import SwiftData

enum SchemaV6: VersionedSchema {
    static var versionIdentifier = Schema.Version(6, 0, 0)

    static var models: [any PersistentModel.Type] {
        [
            SageCoreProfile.self,
            PendingOperation.self,
            CoachingProfile.self,
            CoachingSportProfile.self,
            AdaptedProgramRecord.self
            // RoutineRecord.self retiré en Story 3.10 (V8) — @Model supprimé.
        ]
    }
}
