// Coaching/Session/SessionTimerPhase.swift
// Story 3.34 + 3.35d — décomposition d'une séance chronométrée en PHASES.
//
// Anti-Decathlon : une phase `.prepare` (pré-annonce + 3·2·1) ouvre le déroulé.
//
// Story 3.35d (fix device) : un bloc run/walk (1 exo `sets=N`, durée
// « 1 min course + 1 min 30 marche ») est DÉCOMPOSÉ en segments Course/Marche
// alternés × N tours (avant : tout était écrasé en un seul bloc → l'avance ne
// menait nulle part). Chaque phase porte un `label` typé (rendu i18n côté vue).
import Foundation
import TemplateModel

/// Libellé typé d'une phase (rendu localisé par la vue). Le mot « bloc »
/// n'apparaît JAMAIS côté écran (retour Sophie 2026-06-03).
enum PhaseLabel: Equatable {
    case raw(String)                    // nom d'exo / posture (contenu)
    case effort                         // « Effort » générique
    case recovery                       // « Récup »
    case run(index: Int, total: Int)    // « Course N sur K »
    case walk(index: Int, total: Int)   // « Marche N sur K »
}

struct SessionTimerPhase: Equatable, Identifiable {
    enum Kind: Equatable {
        case prepare
        case work
        case rest
        case hold
    }

    let id: Int
    let kind: Kind
    let duration: Int
    let stepIndex: Int
    /// Libellé typé affiché en grand. Pour `.prepare`, c'est le libellé de l'étape
    /// à venir (« Prochain : … »).
    let label: PhaseLabel

    let round: Int?
    let totalRounds: Int?
    let exerciseInRound: Int?
    let totalInRound: Int?
}

enum SessionTimerPhaseBuilder {

    static let defaultWorkSeconds = 40
    static let defaultRestSeconds = 20
    static let defaultHoldSeconds = 45
    static let prepareSeconds = 3

    static func phases(for session: AdaptedSession, sportCode: String) -> [SessionTimerPhase] {
        let steps = SessionStep.steps(for: session)
        let isYoga = sportCode == "yoga" || session.type == .mobility
        if isYoga { return yogaPhases(steps: steps) }

        // Bloc run/walk décomposable : 1 exo, sets>=2, durée multi-segments (« + »).
        if steps.count == 1, case .exercise(let ex) = steps[0].kind,
           let sets = ex.sets, sets >= 2 {
            let segs = SessionDurationParser.segments(ex.duration)
            if segs.count >= 2 {
                return intervalBlockPhases(step: steps[0], sets: sets, segments: segs)
            }
        }
        return hiitPhases(session: session, steps: steps)
    }

    // MARK: - Yoga (tenue par posture)

    private static func yogaPhases(steps: [SessionStep]) -> [SessionTimerPhase] {
        var phases: [SessionTimerPhase] = []
        var id = 0
        for step in steps {
            guard case .exercise(let ex) = step.kind else { continue }
            let hold = SessionDurationParser.seconds(ex.duration) ?? defaultHoldSeconds
            phases.append(SessionTimerPhase(id: id, kind: .prepare, duration: prepareSeconds,
                                            stepIndex: step.index, label: .raw(ex.displayName),
                                            round: nil, totalRounds: nil, exerciseInRound: nil, totalInRound: nil)); id += 1
            phases.append(SessionTimerPhase(id: id, kind: .hold, duration: hold,
                                            stepIndex: step.index, label: .raw(ex.displayName),
                                            round: nil, totalRounds: nil, exerciseInRound: nil, totalInRound: nil)); id += 1
        }
        return phases
    }

    // MARK: - Run/walk (segments alternés × tours)

    private enum SegClass { case run, walk, generic }

    private static func classify(_ label: String?) -> SegClass {
        guard let l = label?.lowercased() else { return .generic }
        if l.contains("course") || l.contains("run") || l.contains("cours") { return .run }
        if l.contains("marche") || l.contains("walk") { return .walk }
        return .generic
    }

    private static func intervalBlockPhases(step: SessionStep, sets: Int, segments: [SessionDurationParser.Segment]) -> [SessionTimerPhase] {
        // Construit la séquence de segments (× tours). Numérotation = le tour (1 course
        // + 1 marche par tour) → « Course 1 sur 8 », « Marche 1 sur 8 ».
        var built: [(kind: SessionTimerPhase.Kind, duration: Int, label: PhaseLabel, round: Int, k: Int)] = []
        for r in 1...sets {
            for (si, seg) in segments.enumerated() {
                let dur = max(seg.seconds, 1)
                switch classify(seg.label) {
                case .run:     built.append((.work, dur, .run(index: r, total: sets), r, si + 1))
                case .walk:    built.append((.rest, dur, .walk(index: r, total: sets), r, si + 1))
                case .generic: built.append((.work, dur, .effort, r, si + 1))
                }
            }
        }
        guard !built.isEmpty else { return [] }

        var phases: [SessionTimerPhase] = []
        var id = 0
        // Une seule pré-annonce en tête (anti-Decathlon) ; ensuite la voix annonce
        // chaque transition de segment → pas de 3·2·1 entre chaque (timing honnête).
        phases.append(SessionTimerPhase(id: id, kind: .prepare, duration: prepareSeconds,
                                        stepIndex: step.index, label: built[0].label,
                                        round: 1, totalRounds: sets, exerciseInRound: 1, totalInRound: segments.count)); id += 1
        for b in built {
            phases.append(SessionTimerPhase(id: id, kind: b.kind, duration: b.duration,
                                            stepIndex: step.index, label: b.label,
                                            round: b.round, totalRounds: sets,
                                            exerciseInRound: b.k, totalInRound: segments.count)); id += 1
        }
        return phases
    }

    // MARK: - HIIT (tours work/rest) — inchangé fonctionnellement (3.34)

    private static func hiitPhases(session: AdaptedSession, steps: [SessionStep]) -> [SessionTimerPhase] {
        let exoSteps = steps.filter { if case .exercise = $0.kind { return true } else { return false } }
        guard !exoSteps.isEmpty else { return [] }

        if exoSteps.count == 1, case .exercise(let ex) = exoSteps[0].kind,
           let wr = workRest(from: ex), let rounds = ex.sets, rounds >= 2 {
            return circuitPhases(step: exoSteps[0], ex: ex, work: wr.work, rest: wr.rest, rounds: rounds)
        }

        var phases: [SessionTimerPhase] = []
        var id = 0
        let total = exoSteps.count
        for (i, step) in exoSteps.enumerated() {
            guard case .exercise(let ex) = step.kind else { continue }
            let wr = workRest(from: ex)
            let work = wr?.work ?? SessionDurationParser.seconds(ex.duration) ?? defaultWorkSeconds
            let rest = wr?.rest ?? ex.restSeconds ?? defaultRestSeconds
            phases.append(prepare(id: &id, step: step, label: .raw(ex.displayName), round: 1, totalRounds: 1, k: i + 1, K: total))
            phases.append(SessionTimerPhase(id: id, kind: .work, duration: work, stepIndex: step.index,
                                            label: .raw(ex.displayName), round: 1, totalRounds: 1,
                                            exerciseInRound: i + 1, totalInRound: total)); id += 1
            if i < total - 1, rest > 0 {
                phases.append(SessionTimerPhase(id: id, kind: .rest, duration: rest, stepIndex: step.index,
                                                label: .recovery, round: 1, totalRounds: 1,
                                                exerciseInRound: i + 1, totalInRound: total)); id += 1
            }
        }
        return phases
    }

    private static func circuitPhases(step: SessionStep, ex: AdaptedExercise, work: Int, rest: Int, rounds: Int) -> [SessionTimerPhase] {
        var phases: [SessionTimerPhase] = []
        var id = 0
        for r in 1...rounds {
            phases.append(prepare(id: &id, step: step, label: .raw(ex.displayName), round: r, totalRounds: rounds, k: 1, K: 1))
            phases.append(SessionTimerPhase(id: id, kind: .work, duration: work, stepIndex: step.index,
                                            label: .raw(ex.displayName), round: r, totalRounds: rounds,
                                            exerciseInRound: 1, totalInRound: 1)); id += 1
            if r < rounds, rest > 0 {
                phases.append(SessionTimerPhase(id: id, kind: .rest, duration: rest, stepIndex: step.index,
                                                label: .recovery, round: r, totalRounds: rounds,
                                                exerciseInRound: 1, totalInRound: 1)); id += 1
            }
        }
        return phases
    }

    private static func prepare(id: inout Int, step: SessionStep, label: PhaseLabel, round: Int?, totalRounds: Int?, k: Int?, K: Int?) -> SessionTimerPhase {
        let p = SessionTimerPhase(id: id, kind: .prepare, duration: prepareSeconds, stepIndex: step.index,
                                  label: label, round: round, totalRounds: totalRounds,
                                  exerciseInRound: k, totalInRound: K)
        id += 1
        return p
    }

    /// (work, rest) depuis `duration` "40/20" / "1 min / 30 sec". nil si pas de « / ».
    static func workRest(from ex: AdaptedExercise) -> (work: Int, rest: Int)? {
        guard let d = ex.duration else { return nil }
        let parts = d.split(separator: "/")
        guard parts.count == 2,
              let w = SessionDurationParser.seconds(String(parts[0])),
              let r = SessionDurationParser.seconds(String(parts[1])) else { return nil }
        return (w, r)
    }
}
