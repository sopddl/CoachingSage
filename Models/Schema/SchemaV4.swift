// Models/Schema/SchemaV4.swift
// Story 3.8 — ajoute AdaptedProgramRecord + RoutineRecord (lightweight migration depuis SchemaV3).
// Avant 3.8, l'AdaptedProgram retourné par 3.3a restait en mémoire ; la persistance
// permet le dashboard Séances (prochaine séance, tri par date, drag&drop hebdo, complétion).
import SwiftData

enum SchemaV4: VersionedSchema {
    static var versionIdentifier = Schema.Version(4, 0, 0)

    static var models: [any PersistentModel.Type] {
        [
            SageCoreProfile.self,
            PendingOperation.self,
            CoachingProfile.self,
            CoachingSportProfile.self,
            AdaptedProgramRecord.self,
            RoutineRecord.self
        ]
    }
}
