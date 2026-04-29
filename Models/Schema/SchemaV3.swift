// Models/Schema/SchemaV3.swift
// Story 3.1 — ajoute CoachingSportProfile (lightweight migration depuis SchemaV2).
import SwiftData

enum SchemaV3: VersionedSchema {
    static var versionIdentifier = Schema.Version(3, 0, 0)

    static var models: [any PersistentModel.Type] {
        [
            SageCoreProfile.self,
            PendingOperation.self,
            CoachingProfile.self,
            CoachingSportProfile.self
        ]
    }
}
