// Coaching/DurationScaling/SessionDurationAdjustmentService.swift
// Chantier durée réglable, pilote cycling (Increment 3) — pont persistance entre l'UI
// (SessionDetailView) et le moteur pur `SessionDurationScaler` (Increment 2). Mirroir du
// pattern `DefaultReplanifyService` : fetch le record, mute `record.sessions` en place
// (id préservé, doctrine D-T2), persiste via `AdaptedProgramRepository.update`.
import Foundation
import TemplateModel

/// Résultat exposé à l'UI après ajustement — `session` porte le chiffre RÉEL appliqué
/// (jamais la cible brute demandée), cf doctrine D7 « Léon borne honnête ».
struct SessionDurationAdjustmentResult: Equatable, Sendable {
    let session: PersistedSession
    let wasBounded: Bool
}

enum SessionDurationAdjustmentError: Error, Equatable {
    case programNotFound
    case sessionNotFound
    /// Doctrine section 9.3 — une séance déjà marquée terminée ne se réajuste pas
    /// (garde-fou côté service, en plus du gate côté UI qui masque l'entrée).
    case sessionAlreadyCompleted
    /// Séance non annotée (hors V1 cycling, ou contenu overlay synthétique) —
    /// `SessionDurationScaler.isAdjustable` == false.
    case notAdjustable
}

@MainActor
protocol SessionDurationAdjustmentService {
    /// Ajuste la séance `(weekNumber, day)` du programme `programId` vers `targetMinutes`.
    /// Throw `sessionAlreadyCompleted` si une `SessionCompletionRecord` existe déjà pour
    /// cette séance (doctrine section 9.3). Throw `notAdjustable` si la séance n'est pas
    /// (encore) annotée en blocs budgétés.
    func adjustDuration(
        programId: UUID, weekNumber: Int, day: Int, targetMinutes: Int
    ) async throws -> SessionDurationAdjustmentResult
}

@MainActor
final class DefaultSessionDurationAdjustmentService: SessionDurationAdjustmentService {
    private let adaptedProgramRepository: any AdaptedProgramRepository
    private let nowProvider: () -> Date

    init(
        adaptedProgramRepository: any AdaptedProgramRepository,
        nowProvider: @escaping () -> Date = Date.init
    ) {
        self.adaptedProgramRepository = adaptedProgramRepository
        self.nowProvider = nowProvider
    }

    func adjustDuration(
        programId: UUID, weekNumber: Int, day: Int, targetMinutes: Int
    ) async throws -> SessionDurationAdjustmentResult {
        guard let record = try await adaptedProgramRepository.fetchById(recordId: programId) else {
            throw SessionDurationAdjustmentError.programNotFound
        }
        guard let index = record.sessions.firstIndex(where: { $0.weekNumber == weekNumber && $0.day == day }) else {
            throw SessionDurationAdjustmentError.sessionNotFound
        }
        let target = record.sessions[index]
        guard record.completionState.sessionRecords[target.id] == nil else {
            throw SessionDurationAdjustmentError.sessionAlreadyCompleted
        }
        guard SessionDurationScaler.isAdjustable(target), let level = Level(rawValue: record.level) else {
            throw SessionDurationAdjustmentError.notAdjustable
        }

        let result = SessionDurationScaler.scale(target, toTargetMinutes: targetMinutes, level: level)
        var sessions = record.sessions
        sessions[index] = result.session
        record.sessions = sessions
        record.lastUpdatedAt = nowProvider()
        try await adaptedProgramRepository.update(record)

        return SessionDurationAdjustmentResult(session: result.session, wasBounded: result.wasBounded)
    }
}
