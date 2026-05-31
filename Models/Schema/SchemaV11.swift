// Models/Schema/SchemaV11.swift
// Story 3.28 Phase A — i18n contenu programmes : titres re-localisables au
// render via `AutoTitleBuilder` + `LanguageManager.currentLocale`.
//
// Différence V10 → V11 (sur `AdaptedProgramRecord`) :
//   1. `goalCode: String?` — code objectif primaire posé à la création
//      (ex "5k", "cyclosportive"). Permet le recalcul du titre selon locale.
//      `nil` = record pré-3.28 ou programme sport-seul.
//   2. `secondaryGoalsCSV: String?` — objectifs secondaires (Story 3.13) CSV.
//   3. `isUserRenamed: Bool = false` — flag : true si l'utilisateur a édité
//      manuellement `customTitle` via le rename sheet. Quand true, le titre
//      stocké gagne sur le recalcul AutoTitleBuilder (sinon le recalcul
//      écraserait le renommage à chaque changement de langue).
//
// **Pattern wipe-simu dev solo** (cf SchemaV10) : pas de stage de migration,
// `CoachingSageMigrationPlan.stages = []` inchangé. Wipe simu obligatoire au
// premier run post-merge (uninstall l'app sur le simu).
import SwiftData

enum SchemaV11: VersionedSchema {
    static var versionIdentifier = Schema.Version(11, 0, 0)

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
