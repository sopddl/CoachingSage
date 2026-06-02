// Coaching/Session/SessionFocusViewModel.swift
// Story 3.33 (FOCUS) — état d'exécution d'une séance en mode plein écran. Porté
// de `ProjectDetailViewModel` (TailorSage) : progression par étape cochée (PAS de
// currentIndex global), reprise = 1ʳᵉ étape non faite, complétion = toutes faites.
//
// La complétion par étape est persistée en JSON plat via `SessionProgressStore`
// quand un `recordId` est fourni (hot path post-adapt / previews = nil → mémoire
// seule). La bascule « séance terminée » est gérée par la vue (réutilise
// `SessionCompletionViewModel` + `SessionCompleteSheet`).
import Foundation
import Observation
import TemplateModel

@MainActor
@Observable
final class SessionFocusViewModel {
    let steps: [SessionStep]
    private(set) var completed: Set<Int>

    private let store: SessionProgressStore?
    private let recordId: UUID?
    private let week: Int
    private let day: Int

    init(
        session: AdaptedSession,
        recordId: UUID? = nil,
        week: Int,
        day: Int,
        store: SessionProgressStore? = .documentsDefault()
    ) {
        let builtSteps = SessionStep.steps(for: session)
        self.steps = builtSteps
        self.recordId = recordId
        self.week = week
        self.day = day
        // Persistance seulement si on a un recordId (séance ancrée à un programme).
        let activeStore = recordId != nil ? store : nil
        self.store = activeStore
        if let recordId, let activeStore {
            let validIndices = Set(builtSteps.map(\.index))
            self.completed = activeStore.completedSteps(recordId: recordId, week: week, day: day)
                .intersection(validIndices) // garde-fou si la séance a changé
        } else {
            self.completed = []
        }
    }

    // MARK: - Lecture

    var completedCount: Int { completed.count }

    var allCompleted: Bool {
        !steps.isEmpty && steps.allSatisfy { completed.contains($0.index) }
    }

    var hasProgress: Bool { !completed.isEmpty }

    func isCompleted(_ step: SessionStep) -> Bool { completed.contains(step.index) }

    /// Index de l'étape de reprise = 1ʳᵉ non faite (ou 0 si tout fait / vide).
    var resumeIndex: Int {
        steps.first(where: { !completed.contains($0.index) })?.index ?? 0
    }

    /// Numéro humain (1-based) de l'étape de reprise, pour le libellé « Reprendre
    /// l'étape N » du HUB.
    var resumeStepNumber: Int {
        (steps.firstIndex(where: { !completed.contains($0.index) }) ?? 0) + 1
    }

    // MARK: - Mutations

    /// Coche l'étape (idempotent) + persiste.
    func markDone(_ step: SessionStep) {
        guard !completed.contains(step.index) else { return }
        completed.insert(step.index)
        persist(step.index, done: true)
    }

    /// Décoche l'étape + persiste.
    func markUndone(_ step: SessionStep) {
        guard completed.contains(step.index) else { return }
        completed.remove(step.index)
        persist(step.index, done: false)
    }

    /// Bascule l'état de l'étape.
    func toggle(_ step: SessionStep) {
        if completed.contains(step.index) { markUndone(step) } else { markDone(step) }
    }

    /// « Passer » : avance sans cocher (la nav est gérée par la vue). Ne modifie
    /// donc PAS l'état de complétion — l'étape reste non faite.
    func skip(_ step: SessionStep) {
        // no-op sur la complétion (intention explicite : passer ≠ faire).
    }

    private func persist(_ index: Int, done: Bool) {
        guard let store, let recordId else { return }
        store.setStep(index, done: done, recordId: recordId, week: week, day: day)
    }
}
