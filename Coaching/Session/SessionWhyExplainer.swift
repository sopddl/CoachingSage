// Coaching/Session/SessionWhyExplainer.swift
// Story 3.18 Phase 2 — heuristique locale qui retourne une justification
// pédagogique "Pourquoi cette séance ?" en fonction du type, position de la
// semaine dans le programme et du mode de durée. 100% offline, multilingue
// via xcstrings, pas d'IA.
import Foundation
import SwiftUI
import TemplateModel

enum SessionWhyExplainer {

    /// Position de la séance dans le déroulé du programme.
    enum Position {
        case early   // week ≤ 2
        case late    // dernières 2 semaines AVEC date cible (taper / affûtage)
        case mid     // entre les deux (ou toujours pour routineCyclic)
    }

    /// Calcule la position de la semaine donnée dans le programme. La phase
    /// "late" (affûtage) n'existe qu'en mode `deadlineFixed`/`deadlineEstimated`.
    /// En `routineCyclic`, après la phase early on reste en mid jusqu'au cycle
    /// suivant.
    static func position(weekNumber: Int, program: AdaptedProgram) -> Position {
        if weekNumber <= 2 { return .early }
        let total = program.weeks.count
        guard total >= 4 else { return .mid }
        let hasTaper = program.durationMode != .routineCyclic
        if hasTaper && weekNumber >= total - 1 {
            return .late
        }
        return .mid
    }

    /// Renvoie la clé i18n de la justification pour la séance donnée. Renvoie
    /// `nil` si la séance n'a pas vocation à afficher un panel (ex: `.rest`).
    static func explanationKey(session: AdaptedSession, week: AdaptedWeek, program: AdaptedProgram) -> String? {
        if session.type == .rest { return nil }
        let pos = position(weekNumber: week.weekNumber, program: program)
        switch session.type {
        case .interval:
            switch pos {
            case .early: return "coaching.session.why.interval.early"
            case .mid:   return "coaching.session.why.interval.mid"
            case .late:  return "coaching.session.why.interval.late"
            }
        case .endurance:
            switch pos {
            case .early: return "coaching.session.why.endurance.early"
            case .mid:   return "coaching.session.why.endurance.mid"
            case .late:  return "coaching.session.why.endurance.late"
            }
        case .strength:
            switch pos {
            case .early: return "coaching.session.why.strength.early"
            case .mid:   return "coaching.session.why.strength.mid"
            case .late:  return "coaching.session.why.strength.late"
            }
        case .technique:
            return "coaching.session.why.technique.any"
        case .mobility:
            return "coaching.session.why.mobility.any"
        case .mixed:
            return "coaching.session.why.mixed.any"
        case .other:
            return "coaching.session.why.generic"
        case .rest:
            return nil
        }
    }
}
