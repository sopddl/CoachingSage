// Models/Schema/SchemaV2.swift
// Story 2.2 — ajoute CoachingProfile (lightweight migration depuis SchemaV1).
import SwiftData

enum SchemaV2: VersionedSchema {
    static var versionIdentifier = Schema.Version(2, 0, 0)

    static var models: [any PersistentModel.Type] {
        [
            SageCoreProfile.self,
            PendingOperation.self,
            CoachingProfile.self
        ]
    }
}
