// Coaching/Session/SessionEnvironmentResolver.swift
// Chantier indoor/outdoor vélo (2026-06-10) — résout, À L'AFFICHAGE, quelle variante
// de lieu présenter et construit la séance effective. Logique PURE (testable hors UI).
//
// Archi PILOTE LÉGÈRE (cf mémoire v2_chantier_indoor_outdoor_velo) : l'adaptateur
// n'est PAS dupliqué par variante. La variante NATIVE (= contenu racine du template,
// déjà adapté → substitutions constraint/equipment/medical) est servie telle quelle
// (zéro régression). La variante ALTERNATE est servie en passthrough du template brut
// — LIMITE V1 ASSUMÉE : elle n'hérite pas des substitutions (OK vélo ride-centric, à
// fermer en prod/extension).
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
    static func displaySession(
        adapted: AdaptedSession,
        templateSession: TemplateSession,
        effective: SessionEnvironment
    ) -> AdaptedSession {
        guard let native = templateSession.environment,
              effective != native,
              let variant = templateSession.variant(for: effective) else {
            return adapted
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
