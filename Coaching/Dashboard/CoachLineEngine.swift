// Coaching/Dashboard/CoachLineEngine.swift
// Story 3.8 sous-tâche 8 — génère deterministically la phrase italique Léon
// pour la variante rest day du dashboard Séances. **Pas d'appel IA** : la
// phrase dérive de l'historique séances locales (cohérent garde-fou EU MDR
// + roadmap algo-first 2026-04-29).
//
// L'API renvoie une `LocalizedStringKey` ; les variantes sont définies dans
// `Localizable.xcstrings` (FR/EN). Pour ajouter une variante : étendre l'enum
// `RestDayMood` + clé i18n + couvrir dans les tests.
import Foundation
import SwiftUI

struct CoachLineEngine: Sendable {
    init() {}

    /// 4 « moods » selon l'intensité de la semaine en cours, mappés vers une clé i18n.
    /// La clé reste opaque côté View (pas d'interpolation côté SwiftUI Text par sécurité).
    enum RestDayMood: String, Equatable, Sendable {
        /// Pas de séance cette semaine — encouragement neutre.
        case fresh
        /// 1 séance cette semaine — repos mérité simple.
        case warmingUp
        /// 2 séances — équilibre training/repos.
        case balanced
        /// 3+ séances — récupération marquée.
        case intense
    }

    /// Calcule le mood depuis le compteur de complétions de la semaine courante
    /// (typiquement `WeeklyStats.completedCount`).
    func mood(weeklyCompletedCount: Int) -> RestDayMood {
        switch weeklyCompletedCount {
        case 0: return .fresh
        case 1: return .warmingUp
        case 2: return .balanced
        default: return .intense
        }
    }

    /// Hint italique Léon affichée sous la card rest day.
    func restDayHint(weeklyCompletedCount: Int) -> LocalizedStringKey {
        switch mood(weeklyCompletedCount: weeklyCompletedCount) {
        case .fresh:      return "dashboard.active.rest.hint.fresh"
        case .warmingUp:  return "dashboard.active.rest.hint.warmingUp"
        case .balanced:   return "dashboard.active.rest.hint.balanced"
        case .intense:    return "dashboard.active.rest.hint.intense"
        }
    }
}
