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
            exercises: variant.exercises.map { AdaptedExercise.passthrough($0) },
            cooldown: variant.cooldown
        )
    }

    /// Décision Sophie 2026-06-12 (2A) : le renfo hors-vélo (gainage, pont fessier, mollets)
    /// reste sur les séances INDOOR (home-trainer : on descend du vélo, on enchaîne au sol),
    /// mais en sortie EXTÉRIEURE on le retire (sur la route on ne fait que pédaler — ces exos
    /// au sol ne parlaient pas, retour device-test). S'applique au résultat FINAL de
    /// `displaySession` (natif comme variante) car le lieu natif court-circuite la résolution.
    /// Robuste : on RETIRE par DENYLIST (patterns de la famille renfo) plutôt que par allowlist
    /// → un exo de pédalage non reconnu retombe sur `.cycleEndurance` (sport-fallback) et reste.
    /// Défensif : on ne vide jamais une séance (si tout est filtré, on rend l'original).
    static func filteringOffBikeStrength(
        _ session: AdaptedSession,
        sport: Sport,
        effective: SessionEnvironment
    ) -> AdaptedSession {
        guard sport == .cycling, effective == .outdoor else { return session }
        let kept = session.exercises.filter {
            !ExercisePatternResolver.resolve($0, sportCode: "cycling").isStrengthFamily
        }
        guard !kept.isEmpty else { return session } // ne vide jamais une séance
        // En sortie extérieure, une séance vélo « mixte » n'est qu'une sortie de pédalage →
        // on la requalifie en `.endurance` pour que « Pourquoi cette séance ? » ne dise plus
        // « on combine plusieurs qualités » (le `type` template est partagé avec la variante
        // indoor qui garde son renfo → reste « mixte »). À faire MÊME si aucun exo n'est
        // retiré : le fix template a déjà nettoyé le natif, mais son `type` reste « mixed ».
        let resolvedType: SessionType = session.type == .mixed ? .endurance : session.type
        // Rien à changer (pas de renfo à retirer ET type déjà correct) → on rend l'original.
        guard kept.count != session.exercises.count || resolvedType != session.type else { return session }
        return AdaptedSession(
            day: session.day,
            name: session.name,
            durationMinutes: session.durationMinutes,
            type: resolvedType,
            warmup: session.warmup,
            exercises: kept,
            cooldown: session.cooldown
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
