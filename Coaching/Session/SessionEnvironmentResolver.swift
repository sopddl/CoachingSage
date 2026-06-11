// Coaching/Session/SessionEnvironmentResolver.swift
// Chantier indoor/outdoor vélo (2026-06-10) — résout, À L'AFFICHAGE, quelle variante
// de lieu présenter et construit la séance effective. Logique PURE (testable hors UI).
//
// La variante NATIVE (= contenu racine du template, déjà adapté → substitutions
// constraint/equipment/medical) est servie telle quelle (zéro régression). La variante
// ALTERNATE est adaptée À LA VOLÉE via le hook `adaptVariant` (L1, 2026-06-11 — rejoue
// les règles par-exercice, cf `ProgramAdapter.adaptSession`). Sans hook fourni (Previews,
// tests purs), fallback passthrough du template brut.
import Foundation
import TemplateModel

enum SessionEnvironmentResolver {

    /// Lieu effectif d'une séance : override séance ?? défaut programme (si décidé) ?? natif.
    /// `programDefault` = "indoor" / "outdoor" / "both" / nil. "both" et nil → on retombe
    /// sur le lieu natif (D4 : « les deux » montre la variante d'origine, flip libre).
    static func effectiveEnvironment(
        native: SessionEnvironment,
        sessionOverride: SessionEnvironment?,
        programDefault: String?
    ) -> SessionEnvironment {
        if let sessionOverride { return sessionOverride }
        if let programDefault, let env = SessionEnvironment(rawValue: programDefault) { return env }
        return native
    }

    /// Séance effective à afficher pour le lieu choisi. Lieu natif → on renvoie la séance
    /// ADAPTÉE inchangée. Lieu alternate → on construit une `AdaptedSession` passthrough
    /// depuis la variante du template. `day` et `type` (absents de `SessionVariant`) sont
    /// conservés depuis la séance adaptée.
    /// `adaptVariant` (L1) : adapte la variante alternate via les règles par-exercice
    /// (fourni par la vue quand les profils sont chargés). nil → fallback passthrough.
    static func displaySession(
        adapted: AdaptedSession,
        templateSession: TemplateSession,
        effective: SessionEnvironment,
        adaptVariant: ((SessionVariant) -> AdaptedSession)? = nil
    ) -> AdaptedSession {
        guard let native = templateSession.environment,
              effective != native,
              let variant = templateSession.variant(for: effective) else {
            return adapted
        }
        if let adaptVariant {
            return adaptVariant(variant)
        }
        return AdaptedSession(
            day: adapted.day,
            name: variant.name,
            durationMinutes: variant.durationMinutes,
            type: adapted.type,
            warmup: variant.warmup,
            exercises: variant.exercises.map(AdaptedExercise.passthrough),
            cooldown: variant.cooldown
        )
    }

    /// Lieu vers lequel basculer au tap de la puce : l'autre variante disponible.
    /// V1 = 2 variantes (indoor/outdoor) → on renvoie simplement l'opposé présent dans
    /// `environmentVariants`. nil si la séance n'a pas de seconde variante.
    static func flipTarget(
        from current: SessionEnvironment,
        templateSession: TemplateSession
    ) -> SessionEnvironment? {
        let envs = templateSession.environmentVariants.map(\.environment)
        return envs.first(where: { $0 != current })
    }
}
