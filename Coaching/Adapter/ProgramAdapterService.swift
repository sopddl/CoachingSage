// Coaching/Adapter/ProgramAdapterService.swift
// Story 3.3a — wiring entre les @Model SwiftData (`CoachingSportProfile`,
// `CoachingProfile`) et les façades pures de l'adapter (`AdapterSportProfile`,
// `AdapterCoachingProfile`). Permet à un appelant runtime de passer ses
// entités SwiftData sans connaître le détail interne de l'adapter.
//
// **Branchement runtime** : le seul appelant prévu dans Story 3.3a est
// `AdaptedProgramView` via un parent qui dispose d'un `ProgramTemplate`
// (sélectionné par Story 3.2) + `CoachingSportProfile` + `CoachingProfile`.
// L'écran de sélection de template est livré en Story 3.2 — d'ici là,
// le service est instanciable et testable mais non câblé dans la nav.
import Foundation
import TemplateModel

@MainActor
final class ProgramAdapterService {
    private let adapter: ProgramAdapter

    init(adapter: ProgramAdapter = ProgramAdapter()) {
        self.adapter = adapter
    }

    /// Adapte un `ProgramTemplate` au profil utilisateur. 100% local, sync,
    /// 0 token, 0 réseau. Si l'algo ne sait pas patcher proprement (contrainte
    /// sans alternative), `result.requiresAIAssist == true` et l'UI peut
    /// proposer Léon Story 3.3b.
    func adapt(
        template: ProgramTemplate,
        sportProfile: CoachingSportProfile,
        coachingProfile: CoachingProfile
    ) -> AdaptedProgram {
        let facade = sportProfile.adapterFacade(merging: coachingProfile.equipment)
        let adapted = adapter.adapt(
            template: template,
            sportProfile: facade,
            coachingProfile: coachingProfile.adapterFacade
        )

        // Story 3.13 Phase C — Overlay secondary goals après l'adapter, avant
        // persistence. Noop si secondary vide ou sport `notApplicable`.
        guard !facade.secondaryGoals.isEmpty, !facade.sportCode.isEmpty else {
            return adapted
        }
        let strategy = GoalCompatibilityMatrix.overlayStrategy(for: facade.sportCode)
        let overlay = SecondaryGoalOverlay.apply(
            weeks: adapted.weeks,
            template: template,
            primary: facade.goal,
            secondary: facade.secondaryGoals,
            frequency: facade.frequencyPerWeek,
            sportCode: facade.sportCode,
            strategy: strategy
        )
        guard !overlay.appliedOverlays.isEmpty else { return adapted }

        return AdaptedProgram(
            templateId: adapted.templateId,
            sport: adapted.sport,
            level: adapted.level,
            appliedAt: adapted.appliedAt,
            weeks: overlay.weeks,
            appliedRules: adapted.appliedRules,
            requiresAIAssist: adapted.requiresAIAssist,
            aiAssistReason: adapted.aiAssistReason,
            durationMode: adapted.durationMode,
            targetDate: adapted.targetDate
        )
    }
}

// MARK: - Bridges SwiftData → AdapterFacade

extension CoachingSportProfile {
    var adapterFacade: AdapterSportProfile {
        adapterFacade(merging: [])
    }

    /// Variante qui fusionne l'équipement global onboarding (`CoachingProfile.equipment`)
    /// avec l'équipement spécifique sport avant le bridge templates. Le mapping
    /// snake_case → kebab-case est fait sur l'union, et `bridgeEquipment` dédoublonne.
    func adapterFacade(merging globalEquipment: [String]) -> AdapterSportProfile {
        AdapterSportProfile(
            constraints: constraints.map(Self.mapConstraintToTemplate),
            equipment: Self.bridgeEquipment(equipment + globalEquipment, sportCode: sportCode),
            frequencyPerWeek: frequencyPerWeek,
            sessionDurationMinutes: sessionDurationMinutes,
            goal: goals.primary,
            secondaryGoals: goals.secondary,
            sportCode: sportCode,
            durationMode: durationMode,
            targetDate: targetDate
        )
    }

    /// Mappe les codes contraintes app (Q4 RunningQuestionnaire : knee/back/ankle/shin)
    /// vers les codes `incompatible_constraints` des templates V2 (kebab-case anglais).
    /// Sans ce mapping, ConstraintSubstitutionRule ne match jamais et les exercices
    /// contraignants (ex: bondissements pour un user `knee`) ne sont pas substitués.
    /// Mapping 1:1 conservateur — la granularité fine (acl-history, hip-pain…) sera
    /// adressée par la story autoprofil HealthKit (mémoire epic3_flow_choice_AB).
    private static func mapConstraintToTemplate(_ code: String) -> String {
        switch code {
        case "knee":  return "knee-injury"
        case "back":  return "lower-back-pain"
        case "ankle": return "ankle-injury"
        case "shin":  return "shin-splints"
        default:      return code
        }
    }

    /// Bridge équipement app → templates :
    /// 1. Convertit les codes Q5 (underscore_case) en codes templates (kebab-case).
    /// 2. Ajoute l'équipement implicite par sport (chaussures de course, mat de sol)
    ///    pour éviter qu'EquipmentSubstitutionRule substitue massivement les exercices
    ///    par leurs alternatives — souvent « tapis » (treadmill), ce qui est l'inverse
    ///    de ce qu'attend un user qui a juste son corps + ses chaussures + un sol.
    private static func bridgeEquipment(_ codes: [String], sportCode: String) -> [String] {
        var mapped: [String] = codes.map { code in
            switch code {
            case "gps_watch":          return "gps-watch"
            case "heart_rate_monitor": return "heart-rate-monitor"
            case "treadmill_access":   return "treadmill-access"
            default:                   return code
            }
        }
        switch sportCode {
        case "running":
            // 13/60 exos running requirent `mat` (plancher de sol pour gainage), 7/60 `gps-watch`.
            // running-shoes : assumé acquis pour quelqu'un qui demande un programme running.
            mapped.append(contentsOf: ["running-shoes", "mat"])
        case "cycling":
            // L3 indoor/outdoor (2026-06-11) — « choisir le vélo ⇒ a un vélo » (décision
            // Sophie, pragmatique). L'indoor/outdoor est un choix de LIEU (la puce), PAS
            // d'équipement → on assume le kit de roulage de base (vélo route + home-trainer
            // + casque/bidons/éclairage) pour qu'EquipmentSubstitutionRule ne dégrade JAMAIS
            // une sortie vélo en « Marche rapide »/elliptique. Le matériel de PERF
            // (power-meter, bike-computer, hrm) et de RENFO (dumbbells, mat) reste
            // substituable légitimement vers une version « au ressenti »/poids du corps.
            mapped.append(contentsOf: ["road-bike", "indoor-trainer", "helmet", "bidons", "front-light", "rear-light"])
        default:
            break
        }
        // Dédoublonne en préservant l'ordre — `running-shoes` peut déjà être présent
        // depuis l'input app, on ne veut pas le voir 2x dans availableEquipment.
        var seen = Set<String>()
        return mapped.filter { seen.insert($0).inserted }
    }
}

extension CoachingProfile {
    var adapterFacade: AdapterCoachingProfile {
        AdapterCoachingProfile(requiresMedicalClearance: requiresMedicalClearance)
    }
}
