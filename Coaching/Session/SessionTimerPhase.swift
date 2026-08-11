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
    case raw(LocalizedText)             // nom d'exo / posture (contenu, résolu au render)
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
    /// « Avancer » quand prêt. Depuis le bug #6, échauffement/récup sont
    /// chronométrés (isManual = false) ; ce champ reste pour le fallback/engine.
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

    /// Chantier yoga débutant pas assez didactique (2026-08-10) — durée d'un sous-pas
    /// warmup/cooldown SANS durée chiffrée parsable (ex. « cercles poignets 10/sens »).
    /// Plancher `max(parsed, 10)` appliqué aussi aux durées parsées pour éviter un
    /// écran-flash si un segment parse à une valeur aberrante.
    static let defaultCueSeconds = 20
    private static let minSubPhaseSeconds = 10

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
        // Bug #9 — muscu : chaque exo est décomposé en séries (work estimé + repos),
        // qui s'enchaînent automatiquement avec pause possible.
        let isStrength = sportCode == "strengthTraining" || session.type == .strength

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
            // Chantier yoga débutant pas assez didactique (2026-08-10) — un ÉCRAN par
            // sous-pas (comme un exercice), plus un seul écran-pavé pour tout l'échauffement.
            phases.append(contentsOf: manualSubPhases(
                text: text, kind: .warmup, label: .warmup, stepIndex: w.index,
                fallbackTotal: defaultWarmupSeconds, next: next))
        }

        let effortPhases = exerciseEffortPhases(exoSteps: exoSteps, isYoga: isYoga, isStrength: isStrength, startId: &id)
        if let first = effortPhases.first {
            // Pré-annonce du 1ᵉʳ effort chronométré (anti-Decathlon).
            phases.append(SessionTimerPhase(id: next(), kind: .prepare, duration: prepareSeconds,
                                            stepIndex: first.stepIndex, label: first.label,
                                            round: first.round, totalRounds: first.totalRounds,
                                            exerciseInRound: first.exerciseInRound, totalInRound: first.totalInRound))
        }
        phases.append(contentsOf: effortPhases)

        if let c = cooldownStep, case .cooldown(let text) = c.kind {
            phases.append(contentsOf: manualSubPhases(
                text: text, kind: .cooldown, label: .cooldown, stepIndex: c.index,
                fallbackTotal: defaultCooldownSeconds, next: next))
        }
        return phases
    }

    /// Chantier yoga débutant pas assez didactique (2026-08-10) — éclate un step
    /// warmup/cooldown en UNE PHASE PAR SOUS-PAS (même découpage « + »/« . » que
    /// `SessionPhaseText.bulletLines`, déjà utilisé par la vue pour l'affichage —
    /// pas de nouvelle règle de split). Durée = durée chiffrée du segment si
    /// parsable (`SessionDurationParser`, même parseur que la voix égrenée), sinon
    /// `defaultCueSeconds`. `exerciseInRound`/`totalInRound` (champs génériques déjà
    /// utilisés par la muscu/run-walk) portent la position du sous-pas pour l'indicateur
    /// « N/M » et la sélection de la ligne à afficher côté vue. 1 seul segment → 1
    /// seule phase (comportement actuel préservé, ex. « Savasana 5 min. »).
    private static func manualSubPhases(
        text: LocalizedText, kind: SessionTimerPhase.Kind, label: PhaseLabel, stepIndex: Int,
        fallbackTotal: Int, next: () -> Int
    ) -> [SessionTimerPhase] {
        let segments = SessionPhaseText.bulletLines(from: text.canonical)
        guard !segments.isEmpty else {
            return [SessionTimerPhase(id: next(), kind: kind, duration: fallbackTotal, stepIndex: stepIndex,
                                      label: label, isManual: false)]
        }
        let total = segments.count
        return segments.enumerated().map { idx, segment in
            let parsed = SessionDurationParser.seconds(segment).map { max($0, minSubPhaseSeconds) }
            let duration = parsed ?? defaultCueSeconds
            return SessionTimerPhase(id: next(), kind: kind, duration: duration, stepIndex: stepIndex,
                                     label: label, isManual: false,
                                     exerciseInRound: idx + 1, totalInRound: total)
        }
    }

    // MARK: - Efforts chronométrés (yoga tenue / run-walk segments / HIIT)

    private static func exerciseEffortPhases(exoSteps: [SessionStep], isYoga: Bool, isStrength: Bool, startId: inout Int) -> [SessionTimerPhase] {
        func next() -> Int { defer { startId += 1 }; return startId }

        // Muscu : chaque exo → S séries (work estimé) entrecoupées de repos.
        if isStrength {
            return strengthPhases(exoSteps: exoSteps, next: next)
        }

        // Yoga : une tenue par posture.
        if isYoga {
            var out: [SessionTimerPhase] = []
            for step in exoSteps {
                guard case .exercise(let ex) = step.kind else { continue }
                let hold = SessionDurationParser.seconds(ex.duration) ?? defaultHoldSeconds
                out.append(SessionTimerPhase(id: next(), kind: .hold, duration: hold, stepIndex: step.index,
                                             label: .raw(ex.name)))
            }
            return out
        }

        // 1 exo, sets>=2, durée multi-bornes → circuit HIIT (work/rest) ou run/walk.
        if exoSteps.count == 1, case .exercise(let ex) = exoSteps[0].kind,
           let sets = ex.sets, sets >= 2 {
            // Circuit HIIT work/rest (« 40/20 » OU « 30 sec work + 20 sec rest ») répété.
            // Bug HIIT 2026-06-08 : le format « + work/rest » tombait dans runWalkSegments →
            // la phase REST était classée .generic → rendue comme du WORK (repos joué comme
            // effort, pas de « repos »). workRest gère les 2 formats et passe AVANT
            // runWalkSegments (réservé aux vrais segments course/marche).
            if let wr = workRest(from: ex) {
                return circuitPhases(step: exoSteps[0], work: wr.work, rest: wr.rest, rounds: sets, next: next)
            }
            let segs = SessionDurationParser.segments(ex.duration)
            if segs.count >= 2 {
                return runWalkSegments(step: exoSteps[0], sets: sets, segments: segs, next: next)
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
                                         label: .raw(ex.name), round: 1, totalRounds: 1,
                                         exerciseInRound: i + 1, totalInRound: total))
            if i < total - 1, rest > 0 {
                out.append(SessionTimerPhase(id: next(), kind: .rest, duration: rest, stepIndex: step.index,
                                             label: .recovery, round: 1, totalRounds: 1,
                                             exerciseInRound: i + 1, totalInRound: total))
            }
        }
        return out
    }

    /// Bug #9 — muscu auto-chaînée : chaque exo devient S séries [work estimé + repos],
    /// pas de repos après la toute dernière série de la séance. La durée de série est
    /// ESTIMÉE (rep-based) ; l'utilisateur peut mettre en pause si une série déborde.
    private static func strengthPhases(exoSteps: [SessionStep], next: () -> Int) -> [SessionTimerPhase] {
        var out: [SessionTimerPhase] = []
        let total = exoSteps.count
        for (i, step) in exoSteps.enumerated() {
            guard case .exercise(let ex) = step.kind else { continue }
            let sets = max(ex.sets ?? 1, 1)
            let work = estimatedSetSeconds(ex)
            let rest = ex.restSeconds ?? 0
            for set in 1...sets {
                out.append(SessionTimerPhase(id: next(), kind: .work, duration: work, stepIndex: step.index,
                                             label: .raw(ex.name),
                                             round: set, totalRounds: sets,
                                             exerciseInRound: i + 1, totalInRound: total))
                let isLastSetOfLastExo = (i == total - 1) && (set == sets)
                if rest > 0, !isLastSetOfLastExo {
                    out.append(SessionTimerPhase(id: next(), kind: .rest, duration: rest, stepIndex: step.index,
                                                 label: .recovery,
                                                 round: set, totalRounds: sets,
                                                 exerciseInRound: i + 1, totalInRound: total))
                }
            }
        }
        return out
    }

    /// Durée estimée d'une série de muscu : la durée explicite (« 30s » gainage) si
    /// présente, sinon ~4 s/rep borné [25 s, 75 s], sinon le défaut.
    static func estimatedSetSeconds(_ ex: AdaptedExercise) -> Int {
        if let d = ex.duration, let s = SessionDurationParser.seconds(d), s > 0 { return s }
        if let reps = ex.reps, let r = leadingInt(reps), r > 0 { return min(max(r * 4, 25), 75) }
        return defaultWorkSeconds
    }

    /// Premier entier d'une chaîne (« 8 », « 8-10 », « 10/côté » → 8, 8, 10). nil si aucun.
    private static func leadingInt(_ s: String) -> Int? {
        let digits = s.drop(while: { !$0.isNumber }).prefix(while: { $0.isNumber })
        return Int(digits)
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
                                         label: .raw(ex.name), round: r, totalRounds: rounds))
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

    /// (work, rest) depuis `duration`. Gère « 40/20 » / « 1 min / 30 sec » (séparateur « / »)
    /// ET « 30 sec work + 20 sec rest » (segments étiquetés work/rest, HIIT). nil sinon.
    static func workRest(from ex: AdaptedExercise) -> (work: Int, rest: Int)? {
        guard let d = ex.duration else { return nil }
        // Format « / » : 2 bornes.
        let parts = d.split(separator: "/")
        if parts.count == 2,
           let w = SessionDurationParser.seconds(String(parts[0])),
           let r = SessionDurationParser.seconds(String(parts[1])) {
            return (w, r)
        }
        // Format « N work + N rest » (HIIT) : segments étiquetés effort/repos.
        let segs = SessionDurationParser.segments(d)
        if segs.count >= 2 {
            func isWork(_ s: String?) -> Bool { let l = (s ?? "").lowercased(); return l.contains("work") || l.contains("effort") || l.contains("travail") }
            func isRest(_ s: String?) -> Bool { let l = (s ?? "").lowercased(); return l.contains("rest") || l.contains("repos") || l.contains("récup") || l.contains("recup") }
            if let w = segs.first(where: { isWork($0.label) }), let r = segs.first(where: { isRest($0.label) }) {
                return (max(w.seconds, 1), max(r.seconds, 1))
            }
        }
        return nil
    }
}

/// Chantier yoga débutant pas assez didactique (2026-08-10) — un step warmup/cooldown
/// est désormais éclaté en plusieurs `SessionTimerPhase` (une par sous-pas). La voix
/// égrenée (`SessionPhaseVoiceSchedule`, INCHANGÉE) planifie ses cues sur la durée
/// TOTALE du step dès la 1ʳᵉ sous-phase ; il faut donc cumuler le temps écoulé sur
/// TOUTES les sous-phases déjà passées du même step (pas seulement la phase courante)
/// pour que les cues se déclenchent à leur offset d'origine au fil des sous-écrans,
/// sans rejouer le script depuis le début à chaque transition.
enum SessionTimerPhaseVoiceContinuity {
    static func cumulativeElapsed(phases: [SessionTimerPhase], currentIndex: Int, currentRemaining: Int) -> Int {
        guard phases.indices.contains(currentIndex) else { return 0 }
        let phase = phases[currentIndex]
        let passed = phases.enumerated()
            .filter { $0.offset < currentIndex && $0.element.stepIndex == phase.stepIndex }
            .reduce(0) { $0 + $1.element.duration }
        return passed + max(0, phase.duration - currentRemaining)
    }
}
