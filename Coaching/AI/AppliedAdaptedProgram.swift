// Coaching/AI/AppliedAdaptedProgram.swift
// Story 3.3b — wrapper consommé par l'UI : programme adapté (mutation des
// substitutions in-place côté `program`) + notes Léon séparées (pour affichage
// en hero / footer / bullets sans polluer la struct AdaptedProgram structurelle).
//
// Pourquoi un wrapper plutôt qu'étendre AdaptedProgram :
// - AdaptedProgram reste pure (algo deterministic, decoder TemplateModel, etc.)
// - Les "notes Léon" sont marketées comme un overlay user-visible, pas comme une
//   transformation structurelle du programme
// - Permet d'afficher AVEC ou SANS notes Léon selon l'état (loading, error,
//   patchApplied) sans muter le programme
import Foundation

public struct AppliedAdaptedProgram: Equatable, Sendable {
    /// Programme post-substitutions (les `exercise_substitutions` du patch ont
    /// déjà été appliquées en mutation des `AdaptedExercise.name`).
    /// Si pas de patch ou patch sans substitutions → identique au programme algo-only.
    public let program: AdaptedProgram

    /// Notes Léon à afficher en surcouche. Nil si aucun patch reçu ou si Léon a
    /// renvoyé un patch vide.
    public let leonNotes: LeonAppliedNotes?

    public init(program: AdaptedProgram, leonNotes: LeonAppliedNotes? = nil) {
        self.program = program
        self.leonNotes = leonNotes
    }
}

public struct LeonAppliedNotes: Equatable, Sendable {
    /// Phrase courte (~200 char max) affichée en hero d'AdaptedProgramView.
    /// Inclut typiquement le prénom user + un encouragement factuel sur les progrès.
    public let personalizationNote: String?

    /// Notes de sécurité contextualisées affichées en footer du programme.
    /// JAMAIS d'avis médical (filtré côté Edge Function par les 4 garde-fous).
    public let safetyNotes: [String]

    /// Volume adjustments + progression pacing concaténés pour affichage en
    /// bullet list "Léon a aussi ajusté…". Chaque entrée = "W{n} : {adjustment} ({reason})".
    public let adjustmentNotes: [String]

    public init(personalizationNote: String?, safetyNotes: [String], adjustmentNotes: [String]) {
        self.personalizationNote = personalizationNote
        self.safetyNotes = safetyNotes
        self.adjustmentNotes = adjustmentNotes
    }

    /// `true` s'il y a au moins une note à afficher. Sinon l'UI peut masquer toute la section Léon.
    public var hasAnything: Bool {
        if let p = personalizationNote, !p.isEmpty { return true }
        return !safetyNotes.isEmpty || !adjustmentNotes.isEmpty
    }
}
