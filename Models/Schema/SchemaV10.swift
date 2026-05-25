// Models/Schema/SchemaV10.swift
// Story 3.21 hotfix Bug F — ajout `CoachingProfile.bootstrappedDormantsLocal: Bool = false`,
// flag SwiftData-only (jamais sync Supabase) pour distinguer "bootstrap déjà fait
// sur CE device" de "bootstrap déjà fait globalement pour cet user" (flag
// `bootstrappedDormants` sync via `CoachingProfileDTO`).
//
// Différence V9 → V10 :
//   1. `CoachingProfile.bootstrappedDormantsLocal: Bool` — default `false`,
//      JAMAIS dans `CoachingProfileDTO` / `CoachingProfileUpsertDTO`.
//      Conséquence cross-device : un user qui re-install sur un nouveau device
//      verra `bootstrappedDormants=true` (sync) mais `bootstrappedDormantsLocal=false`
//      (local fresh) → `DormantBootstrapService.bootstrapIfNeeded()` re-déclenche.
//
// **Pattern wipe-simu dev solo** : `CoachingSageMigrationPlan.stages = []`
// inchangé. Wipe simu obligatoire au premier run post-merge (uninstall
// l'app sur le simu).
import SwiftData

enum SchemaV10: VersionedSchema {
    static var versionIdentifier = Schema.Version(10, 0, 0)

    static var models: [any PersistentModel.Type] {
        [
            SageCoreProfile.self,
            PendingOperation.self,
            CoachingProfile.self,
            CoachingSportProfile.self,
            AdaptedProgramRecord.self,
            WeeklyExecutionReportRecord.self
        ]
    }
}
