// Coaching/Session/SessionTimerPhase.swift
// Story 3.34 + 3.35d/f — décomposition d'une séance chronométrée en PHASES.
//
// Story 3.35f (fix device Sophie 2026-06-03) — CAUSE RACINE : la décomposition
// run/walk ne se déclenchait que si la séance n'avait NI échauffement NI récup
// (`steps.count == 1`). Or une vraie séance = échauffement + exo + récup → l'exo
// n'était jamais décomposé. Désormais :
//   - échauffement & récup = phases MANUELLES (« Avancer » à son rythme, pas de
//     chrono imposé sur des mouvements libres) ;
//   - l'exo run/walk est décomposé en segments Course/Marche × tours ;
//   - une pré-annonce (3·2·1) précède le 1ᵉʳ effort chronométré.
// Le mot « bloc » n'apparaît JAMAIS côté écran.
import Foundation
import TemplateModel

/// Libellé typé d'une phase (rendu localisé par la vue).
enum PhaseLabel: Equatable {
    case raw(String)                    // nom d'exo / posture (contenu)
    case effort                         // « Effort » générique
    case recovery                       // « Récup »
    case run(index: Int, total: Int)    // « Course N sur K »
    case walk(index: Int, total: Int)   // « Marche N sur K »
    case warmup                         // « Échauffement »
    case cooldown                       // « Retour au calme »
}

struct SessionTimerPhase: Equatable, Identifiable {
    enum Kind: Equatable {
        case prepare
        case work
        case rest
        case hold
        case warmup     // échauffement (manuel)
        case cooldown   // récup (manuel)
    }

    let id: Int
    let kind: Kind
    let duration: Int
    let stepIndex: Int
    let label: PhaseLabel
    /// Phase à avance MANUELLE (pas de compte à rebours) : l'utilisateur tape
    /// « Avancer » quand prêt. True pour échauffement/récup.
    let isManual: Bool

    let round: Int?
    let totalRounds: Int?
    let exerciseInRound: Int?
    let totalInRound: Int?

    init(id: Int, kind: Kind, duration: Int, stepIndex: Int, label: PhaseLabel,
         isManual: Bool = false,
         round: Int? = nil, totalRounds: Int? = nil, exerciseInRound: Int? = nil, totalInRound: Int? = nil) {
        self.id = id
        self.kind = kind
        self.duration = duration
        self.stepIndex = stepIndex
        self.label = label
        self.isManual = isManual
        self.round = round
        self.totalRounds = totalRounds
        self.exerciseInRound = exerciseInRound
        self.totalInRound = totalInRound
    }
}

enum SessionTimerPhaseBuilder {

    static let defaultWorkSeconds = 40
    static let defaultRestSeconds = 20
    static let defaultHoldSeconds = 45
    static let prepareSeconds = 3
    // Bug #6 — échauffement/récup chronométrés (auto-avance + pause, décision Sophie
    // 2026-06-04). Durée = total parsé dans le texte, sinon ces défauts.
    static let defaultWarmupSeconds = 300   // 5 min
    static let defaultCooldownSeconds = 180 // 3 min

    /// Durée chronométrée d'une phase échauffement/récup : total parsé dans le texte
    /// (« 10 min … » → 600), sinon défaut selon le type.
    static func phaseDuration(forText text: String, fallback: Int) -> Int {
        SessionPhaseText.totalSeconds(from: text) ?? fallback
    }

    /// Construit les phases FOCUS minuté/audio. Ordre : échauffement (manuel) →
    /// pré-annonce → efforts chronométrés → récup (manuelle).
    static func phases(for session: AdaptedSession, sportCode: String) -> [SessionTimerPhase] {
        let steps = SessionStep.steps(for: session)
        guard !steps.isEmpty else { return [] }
        let isYoga = sportCode == "yoga" || session.type == .mobility

        var warmupStep: SessionStep?
        var cooldownStep: SessionStep?
        var exoSteps: [SessionStep] = []
        for step in steps {
            switch step.kind {
            case .warmup:   warmupStep = step
            case .cooldown: cooldownStep = step
            case .exercise: exoSteps.append(step)
            }
        }

        var id = 0
        func next() -> Int { defer { id += 1 }; return id }

        var phases: [SessionTimerPhase] = []

        if let w = warmupStep, case .warmup(let text) = w.kind {
            // Bug #6 — échauffement chronométré (auto-avance + pause).
            let dur = phaseDuration(forText: text, fallback: defaultWarmupSeconds)
            phases.append(SessionTimerPhase(id: next(), kind: .warmup, duration: dur, stepIndex: w.index,
                                            label: .warmup, isManual: false))
        }

        let effortPhases = exerciseEffortPhases(exoSteps: exoSteps, isYoga: isYoga, startId: &id)
        if let first = effortPhases.first {
            // Pré-annonce du 1ᵉʳ effort chronométré (anti-Decathlon).
            phases.append(SessionTimerPhase(id: next(), kind: .prepare, duration: prepareSeconds,
                                            stepIndex: first.stepIndex, label: first.label,
                                            round: first.round, totalRounds: first.totalRounds,
                                            exerciseInRound: first.exerciseInRound, totalInRound: first.totalInRound))
        }
        phases.append(contentsOf: effortPhases)

        if let c = cooldownStep, case .cooldown(let text) = c.kind {
            // Bug #6 — récup chronométrée (auto-avance + pause).
            let dur = phaseDuration(forText: text, fallback: defaultCooldownSeconds)
            phases.append(SessionTimerPhase(id: next(), kind: .cooldown, duration: dur, stepIndex: c.index,
                                            label: .cooldown, isManual: false))
        }
        return phases
    }

    // MARK: - Efforts chronométrés (yoga tenue / run-walk segments / HIIT)

    private static func exerciseEffortPhases(exoSteps: [SessionStep], isYoga: Bool, startId: inout Int) -> [SessionTimerPhase] {
        func next() -> Int { defer { startId += 1 }; return startId }

        // Yoga : une tenue par posture.
        if isYoga {
            var out: [SessionTimerPhase] = []
            for step in exoSteps {
                guard case .exercise(let ex) = step.kind else { continue }
                let hold = SessionDurationParser.seconds(ex.duration) ?? defaultHoldSeconds
                out.append(SessionTimerPhase(id: next(), kind: .hold, duration: hold, stepIndex: step.index,
                                             label: .raw(ex.displayName)))
            }
            return out
        }

        // Run/walk : 1 exo, sets>=2, durée multi-segments (« + ») → segments alternés.
        if exoSteps.count == 1, case .exercise(let ex) = exoSteps[0].kind,
           let sets = ex.sets, sets >= 2 {
            let segs = SessionDurationParser.segments(ex.duration)
            if segs.count >= 2 {
                return runWalkSegments(step: exoSteps[0], sets: sets, segments: segs, next: next)
            }
            // Circuit HIIT work/rest (« 40/20 ») répété.
            if let wr = workRest(from: ex) {
                return circuitPhases(step: exoSteps[0], work: wr.work, rest: wr.rest, rounds: sets, next: next)
            }
        }

        // Sinon : chaque exo = un effort chronométré (work) + récup éventuelle.
        var out: [SessionTimerPhase] = []
        let total = exoSteps.count
        for (i, step) in exoSteps.enumerated() {
            guard case .exercise(let ex) = step.kind else { continue }
            let wr = workRest(from: ex)
            let work = wr?.work ?? SessionDurationParser.seconds(ex.duration) ?? defaultWorkSeconds
            let rest = wr?.rest ?? ex.restSeconds ?? 0
            out.append(SessionTimerPhase(id: next(), kind: .work, duration: work, stepIndex: step.index,
                                         label: .raw(ex.displayName), round: 1, totalRounds: 1,
                                         exerciseInRound: i + 1, totalInRound: total))
            if i < total - 1, rest > 0 {
                out.append(SessionTimerPhase(id: next(), kind: .rest, duration: rest, stepIndex: step.index,
                                             label: .recovery, round: 1, totalRounds: 1,
                                             exerciseInRound: i + 1, totalInRound: total))
            }
        }
        return out
    }

    private static func runWalkSegments(step: SessionStep, sets: Int, segments: [SessionDurationParser.Segment],
                                        next: () -> Int) -> [SessionTimerPhase] {
        var out: [SessionTimerPhase] = []
        for r in 1...sets {
            for seg in segments {
                let dur = max(seg.seconds, 1)
                switch classify(seg.label) {
                case .run:     out.append(SessionTimerPhase(id: next(), kind: .work, duration: dur, stepIndex: step.index,
                                                            label: .run(index: r, total: sets), round: r, totalRounds: sets))
                case .walk:    out.append(SessionTimerPhase(id: next(), kind: .rest, duration: dur, stepIndex: step.index,
                                                            label: .walk(index: r, total: sets), round: r, totalRounds: sets))
                case .generic: out.append(SessionTimerPhase(id: next(), kind: .work, duration: dur, stepIndex: step.index,
                                                            label: .effort, round: r, totalRounds: sets))
                }
            }
        }
        return out
    }

    private static func circuitPhases(step: SessionStep, work: Int, rest: Int, rounds: Int, next: () -> Int) -> [SessionTimerPhase] {
        guard case .exercise(let ex) = step.kind else { return [] }
        var out: [SessionTimerPhase] = []
        for r in 1...rounds {
            out.append(SessionTimerPhase(id: next(), kind: .work, duration: work, stepIndex: step.index,
                                         label: .raw(ex.displayName), round: r, totalRounds: rounds))
            if r < rounds, rest > 0 {
                out.append(SessionTimerPhase(id: next(), kind: .rest, duration: rest, stepIndex: step.index,
                                             label: .recovery, round: r, totalRounds: rounds))
            }
        }
        return out
    }

    // MARK: - Classification & parsing

    private enum SegClass { case run, walk, generic }

    private static func classify(_ label: String?) -> SegClass {
        guard let l = label?.lowercased() else { return .generic }
        if l.contains("course") || l.contains("run") || l.contains("cours") { return .run }
        if l.contains("marche") || l.contains("walk") { return .walk }
        return .generic
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
