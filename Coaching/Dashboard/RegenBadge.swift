// Coaching/Dashboard/RegenBadge.swift
// Story 3.4 Phase B.5 — modèle ViewModel-side du badge regen affiché sur les
// cards programme du dashboard quand une regen S+1 a été appliquée cette
// semaine. Dérivé de `RegenJournalEntry` via `from(entry:)`.
//
// Source de vérité runtime : journal JSON via
// `WeeklyRegenRepository.fetchJournalForCurrentWeek`. Une seule entrée par
// `(recordId, targetWeekNumber)` → mapping `[UUID: RegenBadge]` côté VM.
//
// i18n FR/EN : les `LocalizedStringKey` sont déclarées ici, la résolution
// strings est différée à B.7 (xcstrings xcloc). En attendant elles
// s'affichent en clé brute → acceptable pour test simu interne.
import Foundation
import SwiftUI

struct RegenBadge: Equatable {
    /// Clé localisée de la raison (mapping 1-1 sur `RegressionDecision.Reason`).
    let reasonKey: LocalizedStringKey
    /// Pourcentage signé du multiplier appliqué : "+10%", "-25%", "0%".
    /// `Text(verbatim:)` côté Vue — pas i18n (numérique pur).
    let percentLabel: String
    /// `true` quand la regen est un `.restart` (rebuild forcé). Détermine le
    /// style visuel (ton orange/alerte vs vert/info).
    let requiresRebuild: Bool
    /// Phase B.6 — UUIDs des `PersistedSession` mutés par la regen S+1.
    /// Utilisés par le dashboard VM (`modifiedSessionCoordinates(forRecordId:)`)
    /// pour résoudre les `(weekNumber, day)` à highlight dans
    /// `AdaptedProgramView` et `SessionDetailView`.
    let affectedSessionIds: [UUID]

    /// Construit le badge à partir d'une entrée du journal. Le `multiplier`
    /// est arrondi entier pour l'affichage utilisateur.
    static func from(entry: RegenJournalEntry) -> RegenBadge {
        RegenBadge(
            reasonKey: reasonKey(for: entry.reason),
            percentLabel: percentLabel(for: entry.multiplier),
            requiresRebuild: entry.requiresRebuild,
            affectedSessionIds: entry.affectedSessionIds
        )
    }

    /// `+X%` / `-X%` / `0%` selon le multiplier (1.0 = neutre). Bornes UI
    /// laissées au formatter — la borne algo est déjà appliquée côté
    /// `SessionVolumeScaler`.
    static func percentLabel(for multiplier: Double) -> String {
        let delta = (multiplier - 1.0) * 100
        let rounded = Int(delta.rounded())
        switch rounded {
        case 0: return "0%"
        case let n where n > 0: return "+\(n)%"
        default: return "\(rounded)%"
        }
    }

    private static func reasonKey(for reason: RegressionDecision.Reason) -> LocalizedStringKey {
        switch reason {
        case .onTrack:        return "dashboard.regen.reason.onTrack"
        case .lowQuality:     return "dashboard.regen.reason.lowQuality"
        case .overExecuting:  return "dashboard.regen.reason.overExecuting"
        case .missedSessions: return "dashboard.regen.reason.missedSessions"
        case .pauseLight:     return "dashboard.regen.reason.pauseLight"
        case .pauseModerate:  return "dashboard.regen.reason.pauseModerate"
        case .pauseExtended:  return "dashboard.regen.reason.pauseExtended"
        }
    }
}

// MARK: - SessionCoordinate (Phase B.6)

/// Coordonnée (`weekNumber`, `day`) d'une session dans un `AdaptedProgram`. Le
/// rendu (`AdaptedProgramView`, `SessionDetailView`) consomme `AdaptedSession`
/// qui n'a pas d'UUID — on highlight donc par coordonnée. La résolution
/// `RegenJournalEntry.affectedSessionIds (UUID) → SessionCoordinate` est faite
/// côté `SessionDashboardViewModel.modifiedSessionCoordinates(forRecordId:)`
/// en croisant avec le `PersistedSession.weekNumber/day` du record.
struct SessionCoordinate: Hashable, Sendable {
    let weekNumber: Int
    let day: Int
}

