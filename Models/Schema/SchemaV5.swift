// Models/Schema/SchemaV5.swift
// Story 3.3b — ajoute 4 propriétés à AdaptedProgramRecord pour persister le flag
// requiresAIAssist (émis par 3.3a, perdu en V4 car retourné en dur à false par
// toAdaptedProgram) et tracker l'application d'un patch IA Léon (idempotence +
// audit). Lightweight migration depuis SchemaV4 : 4 ajouts avec defaults
// (Bool false / String? nil), pas de transformation.
import SwiftData

enum SchemaV5: VersionedSchema {
    static var versionIdentifier = Schema.Version(5, 0, 0)

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
