// Coaching/Persistence/RegenJournalEntry.swift
// Story 3.4 Phase B.1 — trace chaque application de regen S+1 par
// `WeeklyRegenApplicationService`. Sert à 3 usages :
//   1. Idempotence : empêcher la double-application d'une regen pour le même
//      `(recordId, targetWeekNumber)`. Le check se fait via
//      `WeeklyRegenRepository.fetchJournal(recordId:targetWeek:)` avant
//      `applyDecision`.
//   2. Badge dashboard "Léon a ajusté ta semaine N+1" : affichable jusqu'à la
//      fin de la semaine cible. Le VM filtre par `appliedAt` récent.
//   3. Overlay sur sessions modifiées : `affectedSessionIds` permet à la card
//      de session d'afficher `+10%` / `-25%` / "Reprise".
//
// Pattern SwiftData strict : enums stockés en `String` (rawValue), `[UUID]`
// sérialisé en `Data` JSON.
import Foundation
import SwiftData

@Model
final class RegenJournalEntry {
    @Attribute(.unique) var id: UUID
    var userId: UUID
    /// FK logique vers `AdaptedProgramRecord.id`.
    var recordId: UUID

    /// Numéro de la semaine analysée (= S, celle qui vient de se terminer).
    var analyzedWeekNumber: Int

    /// Numéro de la semaine cible de la régen (= S+1).
    var targetWeekNumber: Int

    var appliedAt: Date

    /// `RegressionDecision.Reason.rawValue` — utiliser `reason` (computed) côté
    /// business code.
    var reasonRaw: String
    var reason: RegressionDecision.Reason {
        get { RegressionDecision.Reason(rawValue: reasonRaw) ?? .onTrack }
        set { reasonRaw = newValue.rawValue }
    }

    /// Multiplicateur effectivement appliqué (clampé) — utile pour l'overlay UI
    /// qui affiche `+10%` / `-25%` sans avoir à dupliquer la logique multiplier.
    var multiplier: Double

    /// `PauseLevel.rawValue` au moment de la regen. Utile pour le wording du
    /// badge (pauseLight vs pauseModerate vs pauseExtended).
    var pauseLevelRaw: String
    var pauseLevel: PauseLevel {
        get { PauseLevel(rawValue: pauseLevelRaw) ?? .none }
        set { pauseLevelRaw = newValue.rawValue }
    }

    /// `true` si la regen a déclenché un rebuild from template base (cas `.restart`).
    var requiresRebuild: Bool

    /// `[UUID]` des sessions de S+1 modifiées par la regen. Sérialisé en `Data`
    /// JSON pour rester compatible SwiftData. Lire/écrire via `affectedSessionIds`.
    private var affectedSessionIdsJsonData: Data
    var affectedSessionIds: [UUID] {
        get { (try? JSONDecoder().decode([UUID].self, from: affectedSessionIdsJsonData)) ?? [] }
        set { affectedSessionIdsJsonData = (try? JSONEncoder().encode(newValue)) ?? Data() }
    }

    init(
        id: UUID = UUID(),
        userId: UUID,
        recordId: UUID,
        analyzedWeekNumber: Int,
        targetWeekNumber: Int,
        appliedAt: Date = Date(),
        reason: RegressionDecision.Reason,
        multiplier: Double,
        pauseLevel: PauseLevel,
        requiresRebuild: Bool,
        affectedSessionIds: [UUID]
    ) {
        self.id = id
        self.userId = userId
        self.recordId = recordId
        self.analyzedWeekNumber = analyzedWeekNumber
        self.targetWeekNumber = targetWeekNumber
        self.appliedAt = appliedAt
        self.reasonRaw = reason.rawValue
        self.multiplier = multiplier
        self.pauseLevelRaw = pauseLevel.rawValue
        self.requiresRebuild = requiresRebuild
        self.affectedSessionIdsJsonData = (try? JSONEncoder().encode(affectedSessionIds)) ?? Data()
    }
}
