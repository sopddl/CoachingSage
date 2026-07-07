// Coaching/Session/SessionTimerEngine.swift
// Story 3.34 (FOCUS Minuté) — moteur de timer PUR qui déroule une suite de
// `SessionTimerPhase` (prepare/work/rest/hold). Logique 100% testable : le temps
// avance via `tick()` (1 s), appelé par un `Timer` côté vue ; aucune dépendance
// horloge interne → les tests appellent `tick()` directement.
//
// Gère : compte à rebours par phase, transition auto à la phase suivante,
// pause/reprise (gèle le temps), « passer » (saute la phase), fin de séquence.
import Foundation
import Observation

@MainActor
@Observable
final class SessionTimerEngine {
    let phases: [SessionTimerPhase]

    private(set) var currentIndex: Int = 0
    /// Secondes restantes sur la phase courante.
    private(set) var remaining: Int = 0
    private(set) var isPaused: Bool = false
    private(set) var isRunning: Bool = false
    private(set) var isFinished: Bool = false

    init(phases: [SessionTimerPhase]) {
        self.phases = phases
        if let first = phases.first {
            self.remaining = first.duration
        } else {
            self.isFinished = true
        }
    }

    // MARK: - Lecture

    var currentPhase: SessionTimerPhase? {
        phases.indices.contains(currentIndex) ? phases[currentIndex] : nil
    }

    var nextPhase: SessionTimerPhase? {
        phases.indices.contains(currentIndex + 1) ? phases[currentIndex + 1] : nil
    }

    /// Index du `SessionStep` (exo/posture) courant.
    var currentStepIndex: Int? { currentPhase?.stepIndex }

    // MARK: - Contrôles

    func start() {
        guard !isFinished else { return }
        isRunning = true
        isPaused = false
    }

    func pause() {
        guard isRunning, !isFinished else { return }
        isPaused = true
    }

    func resume() {
        guard isRunning, !isFinished else { return }
        isPaused = false
    }

    func togglePause() {
        if isPaused { resume() } else { pause() }
    }

    /// Saute immédiatement à la phase suivante (ou termine si c'était la dernière).
    func skip() {
        guard !isFinished else { return }
        advance()
    }

    /// Revient à la phase précédente et réinitialise son temps (symétrique de `skip()`).
    /// Cas limites : si la séquence est terminée → reprend la dernière phase ; si déjà sur
    /// la première → redémarre son chrono. Préserve l'état run/pause courant.
    func back() {
        if isFinished {
            isFinished = false
            remaining = currentPhase?.duration ?? 0
            return
        }
        let prev = currentIndex - 1
        guard phases.indices.contains(prev) else {
            remaining = currentPhase?.duration ?? remaining
            return
        }
        currentIndex = prev
        remaining = phases[prev].duration
    }

    /// Avance d'une seconde. No-op si pas démarré, en pause, terminé, ou sur une
    /// phase MANUELLE (échauffement/récup : on attend le tap « Avancer »).
    func tick() {
        guard isRunning, !isPaused, !isFinished else { return }
        if currentPhase?.isManual == true { return }
        if remaining > 1 {
            remaining -= 1
        } else {
            advance()
        }
    }

    // MARK: - Interne

    private func advance() {
        let next = currentIndex + 1
        if phases.indices.contains(next) {
            currentIndex = next
            remaining = phases[next].duration
        } else {
            isFinished = true
            isRunning = false
            remaining = 0
        }
    }
}
