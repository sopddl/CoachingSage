// Coaching/Session/SessionTimerPhase.swift
// Story 3.34 (FOCUS Minuté) — décomposition d'une séance HIIT/yoga en une suite
// de PHASES chronométrées que `SessionTimerEngine` déroule automatiquement.
//
// Anti-Decathlon (figé) : chaque phase d'effort (work/hold) est précédée d'une
// phase `.prepare` (pré-annonce « Prochain : … » + countdown 3·2·1) — **le 1ᵉʳ
// exo inclus**, pour ne jamais démarrer à froid.
//
// Mode dégradé assumé (R1 + chantier C2 format-aware) : si les durées work/rest
// (HIIT) ou de tenue (yoga) sont absentes du template, on applique des défauts
// raisonnables plutôt que de bloquer.
import Foundation
import TemplateModel

struct SessionTimerPhase: Equatable, Identifiable {
    enum Kind: Equatable {
        case prepare   // pré-annonce + countdown avant un effort
        case work      // effort HIIT
        case rest      // récup HIIT
        case hold      // tenue de posture yoga
    }

    let id: Int                 // index séquentiel stable
    let kind: Kind
    let duration: Int           // secondes
    /// Index du `SessionStep` (exo/posture) auquel cette phase se rapporte.
    let stepIndex: Int
    /// Nom lisible de l'étape associée (exo/posture) — pour la pré-annonce.
    let title: String

    // Progression HIIT (nil pour yoga / prepare hors HIIT).
    let round: Int?
    let totalRounds: Int?
    let exerciseInRound: Int?
    let totalInRound: Int?
}

enum SessionTimerPhaseBuilder {

    /// Défauts dégradés quand le template ne porte pas la donnée (chantier C2).
    static let defaultWorkSeconds = 40
    static let defaultRestSeconds = 20
    static let defaultHoldSeconds = 45
    static let prepareSeconds = 3

    /// Construit les phases chronométrées d'une séance selon son mode minuté.
    /// - HIIT (`SessionType.interval` ou sport hiit) → work/rest répétés en tours.
    /// - Yoga (`sportCode == "yoga"` ou `.mobility`) → tenue par posture.
    static func phases(for session: AdaptedSession, sportCode: String) -> [SessionTimerPhase] {
        let steps = SessionStep.steps(for: session)
        let isYoga = sportCode == "yoga" || session.type == .mobility
        if isYoga {
            return yogaPhases(steps: steps)
        }
        return hiitPhases(session: session, steps: steps)
    }

    // MARK: - Yoga (tenue par posture)

    private static func yogaPhases(steps: [SessionStep]) -> [SessionTimerPhase] {
        var phases: [SessionTimerPhase] = []
        var id = 0
        for step in steps {
            guard case .exercise(let ex) = step.kind else { continue }
            let hold = seconds(from: ex.duration) ?? defaultHoldSeconds
            phases.append(SessionTimerPhase(id: id, kind: .prepare, duration: prepareSeconds,
                                            stepIndex: step.index, title: ex.displayName,
                                            round: nil, totalRounds: nil, exerciseInRound: nil, totalInRound: nil))
            id += 1
            phases.append(SessionTimerPhase(id: id, kind: .hold, duration: hold,
                                            stepIndex: step.index, title: ex.displayName,
                                            round: nil, totalRounds: nil, exerciseInRound: nil, totalInRound: nil))
            id += 1
        }
        return phases
    }

    // MARK: - HIIT (tours work/rest)

    private static func hiitPhases(session: AdaptedSession, steps: [SessionStep]) -> [SessionTimerPhase] {
        let exoSteps = steps.filter { if case .exercise = $0.kind { return true } else { return false } }
        guard !exoSteps.isEmpty else { return [] }

        // Détection circuit répété : un exo unique porte `sets` (= tours) + work/rest.
        if exoSteps.count == 1, case .exercise(let ex) = exoSteps[0].kind,
           let wr = workRest(from: ex), let rounds = ex.sets, rounds >= 2 {
            return circuitPhases(step: exoSteps[0], ex: ex, work: wr.work, rest: wr.rest, rounds: rounds)
        }

        // Sinon : chaque exo = un work (+ rest) une fois (K exos, 1 tour).
        var phases: [SessionTimerPhase] = []
        var id = 0
        let total = exoSteps.count
        for (i, step) in exoSteps.enumerated() {
            guard case .exercise(let ex) = step.kind else { continue }
            let wr = workRest(from: ex)
            let work = wr?.work ?? seconds(from: ex.duration) ?? defaultWorkSeconds
            let rest = wr?.rest ?? ex.restSeconds ?? defaultRestSeconds
            phases.append(prepare(id: &id, step: step, title: ex.displayName, round: 1, totalRounds: 1, k: i + 1, K: total))
            phases.append(SessionTimerPhase(id: id, kind: .work, duration: work, stepIndex: step.index,
                                            title: ex.displayName, round: 1, totalRounds: 1,
                                            exerciseInRound: i + 1, totalInRound: total)); id += 1
            if i < total - 1, rest > 0 {
                phases.append(SessionTimerPhase(id: id, kind: .rest, duration: rest, stepIndex: step.index,
                                                title: ex.displayName, round: 1, totalRounds: 1,
                                                exerciseInRound: i + 1, totalInRound: total)); id += 1
            }
        }
        return phases
    }

    /// Un seul exo répété R tours : (prepare → work → rest) × R (pas de rest après le dernier).
    private static func circuitPhases(step: SessionStep, ex: AdaptedExercise, work: Int, rest: Int, rounds: Int) -> [SessionTimerPhase] {
        var phases: [SessionTimerPhase] = []
        var id = 0
        for r in 1...rounds {
            phases.append(prepare(id: &id, step: step, title: ex.displayName, round: r, totalRounds: rounds, k: 1, K: 1))
            phases.append(SessionTimerPhase(id: id, kind: .work, duration: work, stepIndex: step.index,
                                            title: ex.displayName, round: r, totalRounds: rounds,
                                            exerciseInRound: 1, totalInRound: 1)); id += 1
            if r < rounds, rest > 0 {
                phases.append(SessionTimerPhase(id: id, kind: .rest, duration: rest, stepIndex: step.index,
                                                title: ex.displayName, round: r, totalRounds: rounds,
                                                exerciseInRound: 1, totalInRound: 1)); id += 1
            }
        }
        return phases
    }

    private static func prepare(id: inout Int, step: SessionStep, title: String, round: Int?, totalRounds: Int?, k: Int?, K: Int?) -> SessionTimerPhase {
        let p = SessionTimerPhase(id: id, kind: .prepare, duration: prepareSeconds, stepIndex: step.index,
                                  title: title, round: round, totalRounds: totalRounds,
                                  exerciseInRound: k, totalInRound: K)
        id += 1
        return p
    }

    // MARK: - Parsing util

    /// (work, rest) depuis `duration` "40/20"/"30s/30s". nil si pas exploitable.
    static func workRest(from ex: AdaptedExercise) -> (work: Int, rest: Int)? {
        guard let d = ex.duration else { return nil }
        let parts = d.split(separator: "/")
        if parts.count == 2, let w = firstInt(in: String(parts[0])), let r = firstInt(in: String(parts[1])) {
            return (w, r)
        }
        return nil
    }

    /// Secondes depuis une durée libre : "45 s"→45, "1 min"→60, "2 min"→120, "30s"→30.
    static func seconds(from text: String?) -> Int? {
        guard let text else { return nil }
        let lower = text.lowercased()
        guard let n = firstInt(in: lower) else { return nil }
        if lower.contains("min") || lower.contains("mn") { return n * 60 }
        return n // par défaut : secondes
    }

    private static func firstInt(in s: String) -> Int? {
        var digits = ""
        for ch in s {
            if ch.isNumber { digits.append(ch) }
            else if !digits.isEmpty { break }
        }
        return Int(digits)
    }
}
