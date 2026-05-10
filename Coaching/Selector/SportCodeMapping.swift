// Coaching/Selector/SportCodeMapping.swift
// Story 3.2 — pont SportCode (app) ↔ Sport (package Templates).
// Le mismatch unique : SportCode.strengthTraining = "strengthTraining"
// vs Sport.strengthTraining = "strength_training". Tous les autres rawValues
// sont alignés Story 0.5.8.
import Foundation
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
}

extension Level {
    init?(profileLevel: String) {
        self.init(rawValue: profileLevel)
    }
}
