// Models/Schema/SchemaV4.swift
// Story 3.8 — ajoute AdaptedProgramRecord + RoutineRecord (lightweight migration depuis SchemaV3).
// Avant 3.8, l'AdaptedProgram retourné par 3.3a restait en mémoire ; la persistance
// permet le dashboard Séances (prochaine séance, tri par date, drag&drop hebdo, complétion).
//
// **Story 3.10 (V8)** : `RoutineRecord.self` retiré de la liste — le @Model a été
// supprimé du code app. Fichier conservé pour la trace historique git, mais
// désormais hors runtime (`CoachingSageMigrationPlan.schemas = [SchemaV8.self]`).
import SwiftData

enum SchemaV4: VersionedSchema {
    static var versionIdentifier = Schema.Version(4, 0, 0)

    static var models: [any PersistentModel.Type] {
        [
            SageCoreProfile.self,
            PendingOperation.self,
            CoachingProfile.self,
            CoachingSportProfile.self,
            AdaptedProgramRecord.self
        ]
    }
}
