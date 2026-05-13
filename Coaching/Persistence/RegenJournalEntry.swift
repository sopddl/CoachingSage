// Coaching/Persistence/RegenJournalEntry.swift
// Story 3.4 Phase B.1 — trace chaque application de regen S+1 par
// `WeeklyRegenApplicationService`. Sert à 3 usages :
//   1. Idempotence : empêcher la double-application d'une regen pour le même
//      `(recordId, targetWeekNumber)`.
//   2. Badge dashboard "Léon a ajusté ta semaine N+1".
//   3. Overlay sur sessions modifiées : `affectedSessionIds`.
//
// **Choix archi V1 (2026-05-12)** : `struct Codable` stocké en JSON file plat,
// PAS un `@Model` SwiftData. Reproduction de 10 tentatives 2026-05-12 d'un crash
// silencieux `Lost connection to testmanagerd` sur `FetchDescriptor<@Model>` —
// cause profonde non identifiée sans accès debugger SwiftData interne. Volumes
// V1 faibles (~52 entries/yr/user), JSON file plat suffit largement.
//
// Migration : pas d'utilisateur prod, Schema V7 vient juste d'être ajouté avec
// ce @Model — on le retire avant migration. Pas de data loss.
import Foundation

/// Trace d'une regen S+1 appliquée. Stocké en JSON file via `WeeklyRegenRepository`.
struct RegenJournalEntry: Codable, Equatable, Sendable, Identifiable {
    let id: UUID
    let userId: UUID
    /// FK logique vers `AdaptedProgramRecord.id`.
    let recordId: UUID
    let analyzedWeekNumber: Int
    let targetWeekNumber: Int
    let appliedAt: Date
    let reason: RegressionDecision.Reason
    let multiplier: Double
    let pauseLevel: PauseLevel
    /// `true` si la regen a déclenché un rebuild from template base (cas `.restart`).
    let requiresRebuild: Bool
    let affectedSessionIds: [UUID]

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
        self.reason = reason
        self.multiplier = multiplier
        self.pauseLevel = pauseLevel
        self.requiresRebuild = requiresRebuild
        self.affectedSessionIds = affectedSessionIds
    }
}
