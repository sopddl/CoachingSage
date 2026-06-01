// Coaching/Regen/RoutineCyclePlanning.swift
// Story 3.31 — types + algo deterministic du renouvellement de cycle pour les
// routines (`ProgramDurationMode.routineCyclic`).
//
// Une routine est un programme cyclique de 12 semaines (= 3 mois) sans date
// cible. À l'approche de la fin du cycle, on propose à l'utilisateur de générer
// la suite, **adaptée à ses 12 dernières semaines** (autorégulation déterministe,
// 0 IA, cf pivot algo-first [[epic3_leon_algo_first]]).
//
// `CycleRenewalPlanner` est PUR (entrées = sessions + completion state) : pas de
// dépendance HK live, pas de réseau, entièrement testable. Il produit un
// `RoutineCycleDecision` (multiplier de volume + raison) que `RoutineCycleService`
// applique aux durées des sessions du prochain cycle via `SessionVolumeScaler`.
import Foundation
import TemplateModel

// MARK: - RoutineRenewalState

/// État de renouvellement d'une routine, calculé à chaque refresh dashboard.
/// Seul `routineCyclic` actif peut être autre chose que `.notApplicable`.
enum RoutineRenewalState: Equatable, Sendable {
    /// Pas une routine (mode deadline) ou programme archivé/vide.
    case notApplicable
    /// Routine en cours, cycle pas assez avancé pour proposer la suite.
    case notDue
    /// **J−14** — début de la semaine 11/12 (2 sem avant la fin). On propose la
    /// suite de façon non-bloquante : l'utilisateur a encore des séances.
    case due(cycleNumber: Int)
    /// Cycle terminé (temps écoulé OU toutes les séances actives faites). La
    /// routine **reste visible** (jamais auto-archivée) avec un CTA proéminent
    /// pour éviter le dashboard vide.
    case cycleCompleted(cycleNumber: Int)

    /// `true` quand l'UI doit afficher la bannière de renouvellement (CTA actif).
    var isActionable: Bool {
        switch self {
        case .due, .cycleCompleted: return true
        case .notApplicable, .notDue: return false
        }
    }

    /// `true` pour l'état terminal proéminent (cycle à court de séances), vs le
    /// simple hint J−14 non-bloquant.
    var isCompleted: Bool {
        if case .cycleCompleted = self { return true }
        return false
    }
}

// MARK: - RoutineCycleDecision

/// Pourquoi le prochain cycle est ajusté — pilote le ton du message de feedback.
enum RoutineRenewalReason: String, Codable, Sendable {
    /// Forte complétion + effort confortable → on corse un peu (progression).
    case progress
    /// Rythme tenu sans excès → on reconduit à l'identique.
    case maintain
    /// Complétion faible ou effort très élevé → on allège pour aider à tenir.
    case recover
}

/// Décision de renouvellement : facteur de volume appliqué au prochain cycle +
/// raison. `multiplier == 1.0` = reconduction sans changement de volume (mais le
/// cycle repart quand même à neuf : completion remise à zéro, semaine 1).
struct RoutineCycleDecision: Equatable, Sendable {
    let multiplier: Double
    let reason: RoutineRenewalReason
}

// MARK: - CycleRenewalPlanner

/// Algo déterministe d'autorégulation du prochain cycle. Pur et testable.
enum CycleRenewalPlanner {

    /// Seuil de complétion haut : au-dessus, l'utilisateur suit bien la routine.
    static let highCompletion = 0.85
    /// Seuil de complétion bas : en-dessous, il décroche → on allège.
    static let lowCompletion = 0.50
    /// RPE moyen confortable (Borg CR-10) : sous ce seuil, marge pour progresser.
    static let comfortableRPE = 5.5
    /// RPE moyen élevé : au-dessus, signal de fatigue → on allège même si la
    /// complétion est correcte.
    static let highRPE = 8.0

    /// Multiplier de progression (corse le volume du prochain cycle).
    static let progressMultiplier = 1.10
    /// Multiplier d'allègement.
    static let recoverMultiplier = 0.90

    /// Calcule la décision de renouvellement à partir de l'exécution du cycle
    /// écoulé (sessions planifiées + état de complétion avec RPE).
    ///
    /// Logique (autorégulation simple) :
    ///   - complétion ≥ 85 % ET RPE confortable (ou inconnu) → progression (+10 %)
    ///   - complétion < 50 % OU RPE élevé → allègement (−10 %)
    ///   - sinon → reconduction (×1.0)
    ///
    /// `elapsedWeeks` borne le dénominateur aux semaines déjà entamées : au
    /// renouvellement J−14 (semaine 11/12) on ne compte pas les 2 dernières
    /// semaines pas encore dues, sinon un utilisateur assidu plafonnerait à
    /// 10/12 = 83 % et n'atteindrait jamais le seuil de progression. `.max`
    /// (défaut) = compte toutes les semaines (renouvellement à cycle terminé).
    static func plan(
        sessions: [PersistedSession],
        completionState: ProgramCompletionState,
        elapsedWeeks: Int = .max
    ) -> RoutineCycleDecision {
        let activeSessions = sessions.filter { $0.type != .rest && $0.weekNumber <= elapsedWeeks }
        let totalActive = activeSessions.count
        guard totalActive > 0 else {
            return RoutineCycleDecision(multiplier: 1.0, reason: .maintain)
        }

        let activeIds = Set(activeSessions.map(\.id))
        let completedRecords = completionState.sessionRecords.filter { activeIds.contains($0.key) }
        let completionRate = Double(completedRecords.count) / Double(totalActive)

        let rpes = completedRecords.values.compactMap(\.perceivedEffort)
        let averageRPE: Double? = rpes.isEmpty
            ? nil
            : Double(rpes.reduce(0, +)) / Double(rpes.count)

        if completionRate >= highCompletion,
           averageRPE == nil || averageRPE! <= comfortableRPE {
            return RoutineCycleDecision(multiplier: progressMultiplier, reason: .progress)
        }
        if completionRate < lowCompletion || (averageRPE.map { $0 >= highRPE } ?? false) {
            return RoutineCycleDecision(multiplier: recoverMultiplier, reason: .recover)
        }
        return RoutineCycleDecision(multiplier: 1.0, reason: .maintain)
    }
}
