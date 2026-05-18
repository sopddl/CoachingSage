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
    /// **Story 3.10** — snapshot du `AdaptedProgramRecord.shiftGeneration` au
    /// moment où la regen a été appliquée. Sert à Story 3.11 pour l'idempotence
    /// post-shift week (une regen sur generation N est invalidée si le user
    /// shift à N+1, le service peut alors la rappliquer). Default 0 pour
    /// décodage rétro-compatible des entries écrites avant 3.10.
    let shiftGeneration: Int

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
        affectedSessionIds: [UUID],
        shiftGeneration: Int = 0
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
        self.shiftGeneration = shiftGeneration
    }

    // MARK: - Codable rétro-compatible
    //
    // Les entries écrites avant Story 3.10 n'ont pas le champ `shiftGeneration`.
    // On le décode via `decodeIfPresent` avec default 0 pour ne pas casser le
    // load JSON existant. `encode(to:)` synthétisé par défaut écrit le champ.

    private enum CodingKeys: String, CodingKey {
        case id, userId, recordId, analyzedWeekNumber, targetWeekNumber,
             appliedAt, reason, multiplier, pauseLevel, requiresRebuild,
             affectedSessionIds, shiftGeneration
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try c.decode(UUID.self, forKey: .id)
        self.userId = try c.decode(UUID.self, forKey: .userId)
        self.recordId = try c.decode(UUID.self, forKey: .recordId)
        self.analyzedWeekNumber = try c.decode(Int.self, forKey: .analyzedWeekNumber)
        self.targetWeekNumber = try c.decode(Int.self, forKey: .targetWeekNumber)
        self.appliedAt = try c.decode(Date.self, forKey: .appliedAt)
        self.reason = try c.decode(RegressionDecision.Reason.self, forKey: .reason)
        self.multiplier = try c.decode(Double.self, forKey: .multiplier)
        self.pauseLevel = try c.decode(PauseLevel.self, forKey: .pauseLevel)
        self.requiresRebuild = try c.decode(Bool.self, forKey: .requiresRebuild)
        self.affectedSessionIds = try c.decode([UUID].self, forKey: .affectedSessionIds)
        self.shiftGeneration = try c.decodeIfPresent(Int.self, forKey: .shiftGeneration) ?? 0
    }
}
