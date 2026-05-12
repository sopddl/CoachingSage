// Coaching/Persistence/RegenJournalEntry.swift
// Story 3.4 Phase B.1 — trace chaque application de regen S+1 par
// `WeeklyRegenApplicationService`. Sert à 3 usages :
//   1. Idempotence : empêcher la double-application d'une regen pour le même
//      `(recordId, targetWeekNumber)`.
//   2. Badge dashboard "Léon a ajusté ta semaine N+1".
//   3. Overlay sur sessions modifiées : `affectedSessionIds`.
//
// Pattern SwiftData strict, copié EXACTEMENT sur `WeeklyExecutionReportRecord`
// qui fonctionne :
//   - stored properties SANS default value
//   - `private` sur le Data-JSON field
//   - computed type-safe accessors en extension (même fichier)
//
// Toute déviation (defaults, non-private) cause un crash silencieux SwiftData
// `FetchDescriptor<RegenJournalEntry>` reproduit 2026-05-12. Ne pas toucher.
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

    /// `RegressionDecision.Reason.rawValue` — accès type-safe via `reason` en extension.
    var reasonRaw: String

    /// Multiplicateur effectivement appliqué (clampé) — utile pour l'overlay UI.
    var multiplier: Double

    /// `PauseLevel.rawValue` — accès type-safe via `pauseLevel` en extension.
    var pauseLevelRaw: String

    /// `true` si la regen a déclenché un rebuild from template base (cas `.restart`).
    var requiresRebuild: Bool

    /// `[UUID]` des sessions de S+1 modifiées par la regen, sérialisé en JSON.
    /// Accès type-safe via `affectedSessionIds` en extension (file-private OK).
    private var affectedSessionIdsJsonData: Data

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

// MARK: - Computed type-safe accessors (file-private accès au Data)

extension RegenJournalEntry {
    var reason: RegressionDecision.Reason {
        get { RegressionDecision.Reason(rawValue: reasonRaw) ?? .onTrack }
        set { reasonRaw = newValue.rawValue }
    }

    var pauseLevel: PauseLevel {
        get { PauseLevel(rawValue: pauseLevelRaw) ?? .none }
        set { pauseLevelRaw = newValue.rawValue }
    }

    var affectedSessionIds: [UUID] {
        get { (try? JSONDecoder().decode([UUID].self, from: affectedSessionIdsJsonData)) ?? [] }
        set { affectedSessionIdsJsonData = (try? JSONEncoder().encode(newValue)) ?? Data() }
    }
}
