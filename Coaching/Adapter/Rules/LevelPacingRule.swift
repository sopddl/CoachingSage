// Coaching/Adapter/Rules/LevelPacingRule.swift
// Story 3.3a — règle 4 : ajustement de l'intensité cible par level individuel.
//
// **Stub actif** tant que Story 3.1.5 (HK pre-fill VMA / FTP / CSS) n'est pas
// livrée. Selon la spec 3.3a :
//
// > Pacing par level : si Story 3.1.5 livrée (HK pre-fill) → ajuster intensité
// > cible / allures via VMA / FTP / CSS estimé. Sinon → utiliser défaut level
// > générique du template.
//
// Comme le profil sportif n'expose pas encore VMA/FTP/CSS estimé, la règle
// log un `noChange` global et reporte l'enrichissement à la livraison de
// Story 3.1.5. Le squelette de la règle existe pour faciliter le branchement
// futur sans toucher `ProgramAdapter`.
import Foundation
import TemplateModel

public struct LevelPacingRule: AdaptationRule {
    public let ruleType: AppliedRule.RuleType = .levelPacing

    public init() {}

    public func apply(
        weeks: [AdaptedWeek],
        template: ProgramTemplate,
        sport: Sport,
        level: Level,
        sportProfile: AdapterSportProfile,
        coachingProfile: AdapterCoachingProfile
    ) -> RuleResult {
        // Story 3.1.5 non livrée : pas d'estimation VMA/FTP/CSS dans
        // `AdapterSportProfile`. On laisse les target_zone du template intacts
        // (le level générique est déjà encodé dans la sélection de template
        // amont — Story 3.2).
        return RuleResult(weeks: weeks, appliedRules: [])
    }
}
