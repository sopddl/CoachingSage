// Coaching/Progress/SportCodeMapper.swift
// Story 3.9 — pont SportCode (app) ↔ HKWorkoutActivityType (HealthKit) pour le
// bloc « Volume par sport » de l'onglet Progrès.
//
// Décision V1 : triathlon n'a pas de mapping direct côté HK (l'API n'expose pas
// `.triathlon`). Les sessions HK sont enregistrées par sous-discipline (running /
// cycling / swimming), donc le bloc Volume affichera 3 lignes plutôt qu'une
// agrégée "Triathlon" — plus parlant pour un user multi-discipline. Le mapping
// `toHKWorkoutActivityType(.triathlon)` retourne `.other` pour compatibilité API.
import Foundation
import HealthKit

enum SportCodeMapper {
    /// Mapping app → HK pour des cas où on a besoin d'un type (ex : query HK
    /// filtré sur un sport). Triathlon → `.other` (pas d'équivalent HK direct).
    static func toHKWorkoutActivityType(_ sportCode: SportCode) -> HKWorkoutActivityType {
        switch sportCode {
        case .running:          return .running
        case .cycling:          return .cycling
        case .swimming:         return .swimming
        case .triathlon:        return .other
        case .strengthTraining: return .traditionalStrengthTraining
        case .yoga:             return .yoga
        case .hiit:             return .highIntensityIntervalTraining
        case .hiking:           return .hiking
        case .tennis:           return .tennis
        case .football:         return .soccer
        }
    }

    /// Mapping inverse HK → app. Plusieurs types HK peuvent mapper sur le même
    /// SportCode (ex : `.functionalStrengthTraining` et `.traditionalStrengthTraining`
    /// → `.strengthTraining`). Retourne `nil` pour les types HK qu'on ne suit pas V1.
    static func fromHKWorkoutActivityType(_ rawValue: UInt) -> SportCode? {
        guard let type = HKWorkoutActivityType(rawValue: rawValue) else { return nil }
        switch type {
        case .running:
            return .running
        case .cycling:
            return .cycling
        case .swimming:
            return .swimming
        case .traditionalStrengthTraining,
             .functionalStrengthTraining,
             .coreTraining,
             .crossTraining:
            return .strengthTraining
        case .yoga, .flexibility, .pilates:
            return .yoga
        case .highIntensityIntervalTraining, .mixedCardio:
            return .hiit
        case .hiking, .walking:
            return .hiking
        case .tennis:
            return .tennis
        case .soccer:
            return .football
        default:
            return nil
        }
    }
}
