// Coaching/Selector/SportCodeMapping.swift
// Story 3.2 — pont SportCode (app) ↔ Sport (package Templates).
// Le mismatch unique : SportCode.strengthTraining = "strengthTraining"
// vs Sport.strengthTraining = "strength_training". Tous les autres rawValues
// sont alignés Story 0.5.8.
//
// Hotfix 2026-05-12 : expose aussi `localizedKey: LocalizedStringKey` pour
// affichage UI i18n-safe. SwiftUI ne résout PAS les clés construites par
// string interpolation (`LocalizedStringKey("foo.\(bar)")` traite `\(bar)`
// comme un placeholder `%@`, casse la résolution xcstrings). Le pattern
// correct = un switch statique sur l'enum qui retourne une `LocalizedStringKey`
// littérale par cas. Cohérent avec règle `multilangue_extensible_regle`.
import Foundation
import SwiftUI
import TemplateModel

extension Sport {
    init?(sportCode: String) {
        if let direct = Sport(rawValue: sportCode) {
            self = direct
            return
        }
        if sportCode == "strengthTraining" {
            self = .strengthTraining
            return
        }
        return nil
    }

    /// Story sœur post-3.3b — bridge inverse : `Sport` (TemplateModel) → app sportCode
    /// (camelCase, format attendu par CoachingSportProfile + CHECK constraint Supabase
    /// `coaching_sport_profiles.sport`). Utiliser ce helper PARTOUT où on transforme
    /// un `template.sport` en identifier app, à la place de `template.sport.rawValue`.
    ///
    /// Bug fix Sophie 2026-05-10 : la suggestion empty mode dashboard transmettait
    /// `"strength_training"` au pipeline questionnaire → save Supabase rejeté
    /// par CHECK constraint, et clé i18n manquante (xcstrings utilisent `strengthTraining`).
    var appSportCode: String {
        switch self {
        case .strengthTraining: return "strengthTraining"
        default: return rawValue
        }
    }

    /// Clé i18n statique pour l'affichage UI. Voir header pour le pourquoi.
    var localizedKey: LocalizedStringKey {
        switch self {
        case .running:          return "onboarding.sport.running"
        case .cycling:          return "onboarding.sport.cycling"
        case .swimming:         return "onboarding.sport.swimming"
        case .triathlon:        return "onboarding.sport.triathlon"
        case .strengthTraining: return "onboarding.sport.strengthTraining"
        case .yoga:             return "onboarding.sport.yoga"
        case .hiit:             return "onboarding.sport.hiit"
        case .hiking:           return "onboarding.sport.hiking"
        case .tennis:           return "onboarding.sport.tennis"
        case .football:         return "onboarding.sport.football"
        }
    }

    /// SF Symbol sport-specific pour affichage UI. Sophie 2026-05-15 bug B1 :
    /// SessionDetailView affichait `figure.run` sur toutes les séances `endurance`
    /// (runner sur vélo) car `AdaptedProgramFormatting.sfSymbol(for:)` mappait sur
    /// `SessionType`. Le sport est porté par le programme, pas par le type de
    /// session — on utilise donc ce mapping sport-aware.
    var sfSymbol: String {
        switch self {
        case .running:          return "figure.run"
        case .cycling:          return "figure.outdoor.cycle"
        case .swimming:         return "figure.pool.swim"
        case .triathlon:        return "figure.mixed.cardio"
        case .strengthTraining: return "dumbbell.fill"
        case .yoga:             return "figure.yoga"
        case .hiit:             return "bolt.heart.fill"
        case .hiking:           return "figure.hiking"
        case .tennis:           return "figure.tennis"
        case .football:         return "soccerball"
        }
    }
}

extension Level {
    init?(profileLevel: String) {
        self.init(rawValue: profileLevel)
    }

    /// Clé i18n statique pour l'affichage UI.
    var localizedKey: LocalizedStringKey {
        switch self {
        case .beginner:     return "onboarding.level.beginner"
        case .recreational: return "onboarding.level.recreational"
        case .regular:      return "onboarding.level.regular"
        case .competitive:  return "onboarding.level.competitive"
        }
    }
}

extension SessionType {
    /// Story 3.15 — Clé i18n statique pour le pill intensité affiché sur la
    /// NextSessionCard focale. Mapping court : "Endurance", "Fractionné",
    /// "Technique", "Renforcement", "Mixte", "Mobilité", "Récup", "Séance".
    /// Pattern statique (anti `LocalizedStringKey("foo.\(bar)")` cf hotfix
    /// 2026-05-12).
    var localizedKey: LocalizedStringKey {
        switch self {
        case .endurance: return "session.type.endurance"
        case .interval:  return "session.type.interval"
        case .technique: return "session.type.technique"
        case .strength:  return "session.type.strength"
        case .mixed:     return "session.type.mixed"
        case .mobility:  return "session.type.mobility"
        case .rest:      return "session.type.rest"
        case .other:     return "session.type.other"
        }
    }
}
