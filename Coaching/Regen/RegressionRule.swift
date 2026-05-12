// Coaching/Regen/RegressionRule.swift
// Story 3.4 Phase A.3 — décide de l'ajustement de volume pour la semaine S+1
// à partir du rapport d'exécution S (A.2) + niveau de pause détecté (A.3
// PauseDetector). Sortie consommée par WeeklyRegenEngine (A.4) qui applique
// l'ajustement aux templates de S+1.
//
// Pur Swift, fonction `decide` totale (aucun input n'a de cas non-géré). 0
// dépendance HK live.
//
// Doctrine ACSM — principes appliqués :
//   1. "10% rule" : ne jamais augmenter le volume hebdo de plus de 10% par
//      semaine (prévention shin splints / fractures de stress).
//      → progress = +10% max.
//      Source : ACSM Guidelines 11e éd. ch. 7 + Yamato et al. 2015 (meta-revue,
//      la 10% rule est une heuristique pédagogique pas strictement prouvée mais
//      reste la convention pédagogique de référence).
//   2. Detraining-then-resume : après pause, ne JAMAIS reprendre au volume
//      pré-pause. -10% à -50% selon la durée.
//      Source : Mujika & Padilla 2000 ; ACSM 11e ch. 8.
//   3. Frein over-training : si l'user a sur-réalisé (volume > 110%), réduire
//      pour éviter blessure de surcharge — même si la qualité est bonne.
//      Source : Foster Carl 1998 (Acute:Chronic Workload Ratio > 1.5 = risque
//      blessure x4) ; Gabbett 2016.
//   4. Maintien sur qualité faible : si l'user a fait ses séances mais avec
//      qualité < 60% (sous-pacing intensité ou volume), on maintient plutôt
//      que de progresser — sinon on enchaîne sur une semaine encore plus
//      ratée. Pas de réduction non plus (la session reste à portée).
//
// Ordre de priorité (haute → basse, EU MDR safety-first : on préfère sous-
// charger un user qui pourrait suivre plus, que sur-charger un user fragile) :
//   1. Pause extended      → restart progressif (-50%)
//   2. Pause moderate      → reduce 25%
//   3. Pause light         → reduce 10%
//   4. Sur-réalisation     → reduce 10% (frein safety)
//   5. Sessions manquées   → reduce 25% (programme manifestement trop chargé)
//   6. Qualité faible      → maintain (pas de progression sans validation
//                            qualitative)
//   7. Default             → progress +10% (ACSM 10% rule)
//
// Sources reprises dans la doctrine projet : `_bmad-output/planning-artifacts/
// leon-algo-doctrine-by-sport.md` (réf ACSM ligne 28).
import Foundation

// MARK: - VolumeAdjustment

/// Ajustement applicable au volume hebdo de la semaine S+1.
/// Chaque cas porte sa magnitude pour le hook UI (badge, explication) et pour
/// le moteur Phase B qui applique le facteur à `session.durationMinutes` (ou
/// `targetDistanceMeters`, selon le sport).
public enum VolumeAdjustment: Equatable, Sendable {
    /// Augmentation, percent ∈ ]0, 0.10] (cap ACSM 10%). Le getter `multiplier`
    /// clampe à [0, 0.10] pour blinder un appelant qui construirait une valeur
    /// hors-contrat.
    case progress(percent: Double)

    /// Pas de changement (multiplicateur 1.0).
    case maintain

    /// Réduction, percent ∈ ]0, 0.50]. Le getter `multiplier` clampe à
    /// [0, 0.99] pour éviter `multiplier = 0` (sessions à 0 min → corruption
    /// silencieuse Phase B).
    case reduce(percent: Double)

    /// Restart progressif post-pause longue : -50% du volume planifié.
    /// Sémantiquement distinct de `reduce(percent: 0.5)` : signale à l'UI que
    /// l'user reprend après une coupure (texte d'explication différent) et au
    /// moteur Phase B que la semaine S+1 doit être « rebuilt from base »
    /// (cf. `requiresRebuild`) plutôt que d'appliquer un facteur sur le
    /// template courant.
    case restart

    /// Multiplicateur à appliquer au volume planifié de la semaine S+1.
    /// Maintain = 1.0, restart = 0.5. Clamping défensif des `percent` reçus
    /// (cap ACSM 10% pour progress, ]0, 0.99] pour reduce).
    public var multiplier: Double {
        switch self {
        case .progress(let percent):
            return 1.0 + max(0, min(percent, RegressionRule.maxProgressPercent))
        case .maintain:
            return 1.0
        case .reduce(let percent):
            return 1.0 - max(0, min(percent, 0.99))
        case .restart:
            return 0.5
        }
    }

    /// `true` si l'ajustement doit pousser Phase B à reconstruire la semaine
    /// S+1 « from base » (template d'origine + niveau réduit) plutôt qu'à
    /// multiplier le template courant. Distingue `.restart` de
    /// `.reduce(percent: 0.5)`. Évite à Phase B de réimplémenter la
    /// connaissance du cas spécial.
    public var requiresRebuild: Bool {
        if case .restart = self { return true }
        return false
    }
}

// MARK: - RegressionDecision

public struct RegressionDecision: Equatable, Sendable {
    public let adjustment: VolumeAdjustment

    /// Cause machine-readable, pour debug (logs) et pour la couche UI/i18n
    /// (mapping vers une phrase localisée du type "Tu as ralenti cette semaine,
    /// on garde le cap"). Pas de string libre côté algo.
    public let reason: Reason

    public enum Reason: String, Equatable, Sendable, CaseIterable {
        /// Programme suivi normalement, on progresse (10% ACSM).
        case onTrack

        /// Séances faites mais qualité < seuil → on maintient, pas de progression
        /// sans validation qualitative.
        case lowQuality

        /// Sur-réalisation persistante (frein safety, prévention surcharge).
        case overExecuting

        /// > 50% des séances actives manquées → programme manifestement trop
        /// chargé, on régresse pour ré-engager.
        case missedSessions

        /// Pause détectée légère (4-7j ou 1 sem sub-seuil).
        case pauseLight

        /// Pause détectée modérée (~1 sem).
        case pauseModerate

        /// Pause détectée longue (≥ 2 sem), restart progressif.
        case pauseExtended
    }

    public init(adjustment: VolumeAdjustment, reason: Reason) {
        self.adjustment = adjustment
        self.reason = reason
    }
}

// MARK: - RegressionRule

public enum RegressionRule {

    // MARK: Seuils doctrinaires (exposés pour tuning post-prod)

    /// Qualité moyenne sous laquelle on bloque la progression. 60/100 = environ
    /// la moyenne d'un user qui sous-pace de 10-15 BPM et fait 80% du volume.
    /// Au-dessus → on progresse ; en-dessous → on maintient.
    public static let lowQualityThreshold: Double = 60.0

    /// Sous ce completionRate, on régresse de 25%. 50% = a manqué la majorité
    /// de ses séances actives — programme manifestement trop chargé pour son
    /// rythme actuel.
    public static let highMissCompletionThreshold: Double = 0.50

    /// Cap ACSM "10% rule" : ne jamais augmenter de plus de 10%/semaine.
    public static let maxProgressPercent: Double = 0.10

    /// Réduction post-pause light (-10%).
    public static let pauseLightReducePercent: Double = 0.10

    /// Réduction post-pause moderate ET sessions manquées (-25%).
    public static let pauseModerateReducePercent: Double = 0.25

    /// Frein sur over-execution (-10%).
    public static let overExecutionReducePercent: Double = 0.10

    /// Nb minimum de séances complétées pour que `globalQuality` soit fiable.
    /// Avec 1 séance seule, la qualité est trop noisy pour décider — on traite
    /// alors comme "onTrack" (par défaut) si la pause n'est pas déclenchée et
    /// que les autres signaux ne pèsent pas.
    public static let minCompletedForQualityCheck: Int = 2

    /// Décide de l'ajustement à appliquer à la semaine S+1.
    ///
    /// Ordre de priorité strictement décroissant (premier match l'emporte) :
    ///   1. Pause extended → restart
    ///   2. Pause moderate → reduce 25%
    ///   3. Pause light → reduce 10%
    ///   4. Sur-réalisation globale → reduce 10%
    ///   5. completionRate < 0.50 (avec ≥1 active planifiée) → reduce 25%
    ///   6. Qualité < 60 (avec ≥2 complétées) → maintain
    ///   7. Default → progress +10%
    ///
    /// - Parameters:
    ///   - currentWeek: rapport de la semaine S qu'on vient de finir.
    ///   - pauseLevel: niveau détecté par `PauseDetector`. `.none` = pas de pause.
    public static func decide(
        currentWeek: WeeklyExecutionReport,
        pauseLevel: PauseLevel
    ) -> RegressionDecision {
        // 1. Pause extended : restart progressif. Priorité max — la doctrine
        // ACSM detraining dit qu'à ce niveau les adaptations sont en partie
        // perdues, ne pas reprendre comme avant.
        if pauseLevel == .extended {
            return RegressionDecision(adjustment: .restart, reason: .pauseExtended)
        }

        // 2. Pause moderate : reduce 25%.
        if pauseLevel == .moderate {
            return RegressionDecision(
                adjustment: .reduce(percent: pauseModerateReducePercent),
                reason: .pauseModerate
            )
        }

        // 3. Pause light : reduce 10%.
        if pauseLevel == .light {
            return RegressionDecision(
                adjustment: .reduce(percent: pauseLightReducePercent),
                reason: .pauseLight
            )
        }

        // 4. Sur-réalisation : frein safety. Prime sur missedSessions car le
        // risque physique (surcharge) > le risque adhérence (abandon).
        if currentWeek.isOverallOverExecuted {
            return RegressionDecision(
                adjustment: .reduce(percent: overExecutionReducePercent),
                reason: .overExecuting
            )
        }

        // 5. Sessions manquées en masse : > 50% des actives non faites.
        // On ne déclenche QUE s'il y avait des sessions actives à faire (sinon
        // completionRate = 0 par convention de l'analyzer mais ce n'est pas
        // un user qui rate, c'est un programme de décharge).
        if currentWeek.plannedActiveSessionCount > 0,
           currentWeek.completionRate < highMissCompletionThreshold {
            return RegressionDecision(
                adjustment: .reduce(percent: pauseModerateReducePercent),
                reason: .missedSessions
            )
        }

        // 6. Qualité faible (et au moins 2 séances faites pour être fiable).
        // On maintient — pas une régression mais on bloque la progression.
        if currentWeek.completedSessionCount >= minCompletedForQualityCheck,
           currentWeek.globalQuality < lowQualityThreshold {
            return RegressionDecision(adjustment: .maintain, reason: .lowQuality)
        }

        // 7. Default : on progresse de 10% (ACSM rule).
        return RegressionDecision(
            adjustment: .progress(percent: maxProgressPercent),
            reason: .onTrack
        )
    }
}
