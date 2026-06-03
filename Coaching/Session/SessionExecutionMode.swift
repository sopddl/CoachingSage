// Coaching/Session/SessionExecutionMode.swift
// Story 3.33 (AC0) — table de routage CENTRALISÉE de la « façon d'avancer » d'une
// séance FOCUS. Le shell plein écran est identique pour tous les sports ; seule
// la façon d'avancer change :
//   - Manuel  (3.33) : tap « ✓ Fait » / swipe — strength + fallback universel.
//   - Minuté  (3.34) : compte à rebours auto — HIIT / yoga.
//   - Audio   (3.35) : voix + temps — running / cycling / hiking.
//   - Montre  (3.36) : Apple Watch — swim.
//
// **Fallback gracieux (AC0)** : tant que 3.34-3.36 ne sont pas livrées, tout mode
// non encore embarqué retombe sur Manuel — jamais de cul-de-sac. On élargit
// `shippedModes` au fur et à mesure des livraisons.
//
// **Triathlon (AC0 bis)** : une séance triathlon = une discipline à la fois. Le
// code sport passé ici est le **code effectif** (déjà résolu par
// `SessionSportInference` côté HUB : triathlon → swim/bike/run) → pas de mode propre.
import Foundation
import TemplateModel

enum SessionExecutionMode: String, Equatable, CaseIterable {
    case manual
    case timed
    case audio
    case watch

    /// Modes effectivement embarqués à ce jour. 3.36 ajoutera `.watch` (montre).
    static let shippedModes: Set<SessionExecutionMode> = [.manual, .timed, .audio]

    /// Mode **cible** idéal pour un sport/type (indépendant de ce qui est livré).
    /// `sportCode` doit être le code EFFECTIF (triathlon déjà résolu en discipline).
    static func target(sportCode: String, sessionType: SessionType) -> SessionExecutionMode {
        switch sportCode {
        case "strengthTraining":              return .manual
        case "hiit", "yoga":                  return .timed
        case "running", "cycling", "hiking":  return .audio
        case "swimming":                      return .watch
        default:
            // Sport non spécifiquement routé (tennis, football, inconnu) :
            // on s'appuie sur le type de séance, fallback Manuel.
            switch sessionType {
            case .interval, .mobility: return .timed
            case .endurance:           return .audio
            default:                   return .manual
            }
        }
    }

    /// Mode **disponible** = cible si embarquée, sinon Manuel (fallback gracieux).
    static func available(sportCode: String, sessionType: SessionType) -> SessionExecutionMode {
        let t = target(sportCode: sportCode, sessionType: sessionType)
        return shippedModes.contains(t) ? t : .manual
    }
}
