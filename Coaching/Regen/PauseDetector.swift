// Coaching/Regen/PauseDetector.swift
// Story 3.4 Phase A.3 — détecte si l'user a interrompu son entraînement et à
// quel point. Sorti de l'analyzer A.2 (pour qu'A.2 reste limité à une seule
// semaine) et consommé par RegressionRule (A.3 partie 2) puis WeeklyRegenEngine
// (A.4) pour calibrer la reprise.
//
// Pur Swift, 0 dépendance HK live (déterministe, testable). Travaille à partir
// d'une liste de `WeeklyExecutionReport` récents + `daysSinceLastWorkout` (HK).
//
// Doctrine ACSM — Detraining timeline (Mujika & Padilla 2000, repris ACSM 11e) :
//   - < 2 sem off  : adaptations préservées, juste un coup de mou
//   - 2-4 sem off  : -4 à -7% VO2max (perte significative)
//   - 4-8 sem off  : -7 à -15% VO2max
//   - > 8 sem off  : -15 à -25% VO2max, refaire la base aérobie
//
// On agrège ça en 4 niveaux applicables côté coaching (mapping conservateur,
// la régen reprend toujours en sous-réalité pour ne pas blesser) :
//   - none      : pas de pause détectée, progression normale
//   - light     : ralentissement court (4-7j) OU 1 sem en deçà du seuil
//   - moderate  : pause ~1 sem (8-14j) OU 2 sem consécutives sub-seuil
//   - extended  : pause ≥ 2 sem (>14j) OU 3+ sem consécutives sub-seuil
//
// Sources :
//   - Mujika I, Padilla S. Detraining: Loss of training-induced physiological
//     and performance adaptations. Part I. Sports Med 2000;30(2):79-87.
//   - ACSM's Guidelines for Exercise Testing and Prescription (11e éd.), ch. 8.
import Foundation

// MARK: - PauseLevel

/// Niveau d'interruption détecté, mappé sur la doctrine ACSM detraining.
public enum PauseLevel: String, Equatable, Sendable, CaseIterable {
    /// Pas de pause significative — l'user suit son programme (ou en a juste
    /// raté 1-2 séances). Régen S+1 = progression normale.
    case none

    /// Ralentissement court : 4-7j sans workout OU 1 semaine sub-seuil après
    /// une semaine OK. Régen S+1 = légère réduction (10%) pour ré-engager.
    case light

    /// Pause d'environ 1 semaine : 8-14j sans workout OU 2 semaines consécutives
    /// sub-seuil. Régen S+1 = réduction marquée (25%).
    case moderate

    /// Pause longue ≥ 2 semaines : >14j sans workout OU 3+ semaines consécutives
    /// sub-seuil. Régen S+1 = restart progressif (-50%), pas une simple réduction
    /// car la doctrine ACSM dit que les adaptations sont en partie perdues.
    case extended
}

// MARK: - PauseDetectionResult

/// Résultat agrégé du détecteur. Le niveau est `max(historySignal, daysSignal)` :
/// on retient le pire des deux signaux (safety-first — un signal manquant ou
/// dégradé ne doit pas masquer une vraie pause).
public struct PauseDetectionResult: Equatable, Sendable {
    public let level: PauseLevel

    /// Nb de jours depuis le dernier workout HK enregistré. nil si on n'a aucune
    /// donnée HK ou si on n'a pas su le calculer (cas dégénéré).
    public let daysSinceLastWorkout: Int?

    /// Nb de semaines consécutives sub-seuil en partant de la plus récente.
    /// 0 si la semaine la plus récente est au-dessus du seuil de continuité.
    /// Bornée par la taille de `recentReports` fournie.
    public let consecutiveLowWeeks: Int

    public init(level: PauseLevel, daysSinceLastWorkout: Int?, consecutiveLowWeeks: Int) {
        self.level = level
        self.daysSinceLastWorkout = daysSinceLastWorkout
        self.consecutiveLowWeeks = consecutiveLowWeeks
    }
}

// MARK: - PauseDetector

public enum PauseDetector {

    /// CompletionRate sous lequel une semaine compte comme "non-suivie" pour la
    /// détection de pause. 30% = a fait moins d'1/3 de ses séances actives —
    /// signal clair de désengagement, pas une simple semaine mitigée.
    public static let continuityThreshold: Double = 0.30

    // MARK: Seuils en jours (depuis le dernier workout HK)
    //
    // Choix volontairement conservateur (côté safety) : on bascule "light" dès
    // 4 jours sans workout, ce qui pénalise un user qui a juste un planning
    // 3×/semaine mais qui suit parfaitement. C'est OK car `light` ne déclenche
    // qu'une réduction de 10% — équivalent à une semaine de décharge
    // recommandée toutes les 3-4 sem par la doctrine (Foster 1998).
    //
    // Si on observe en prod que des users 2-3×/sem se font flagger à tort, on
    // pourra (a) augmenter ces seuils, ou (b) croiser avec la fréquence
    // planifiée (nb de sessions actives par sem dans le programme) pour adapter
    // le seuil dynamiquement. À itérer Phase B+.

    /// Au-delà de ce nb de jours sans workout HK → niveau `light` minimum.
    public static let lightPauseDaysThreshold: Int = 4

    /// Au-delà → niveau `moderate` minimum.
    public static let moderatePauseDaysThreshold: Int = 8

    /// Au-delà → niveau `extended` minimum.
    public static let extendedPauseDaysThreshold: Int = 15

    /// Détecte un niveau de pause à partir de l'historique d'exécution.
    ///
    /// - Parameters:
    ///   - recentReports: rapports d'exécution récents triés du plus RÉCENT au
    ///     plus ANCIEN (index 0 = semaine la plus proche de "maintenant").
    ///     Idéalement 3 semaines max — on n'utilise pas plus de 3 pour décider.
    ///     Passer un tableau vide est valide (cas S1 : pas d'historique encore).
    ///   - daysSinceLastWorkout: nb de jours depuis le dernier workout HK
    ///     (passe nil si HK indispo ou aucun workout connu).
    public static func detect(
        recentReports: [WeeklyExecutionReport],
        daysSinceLastWorkout: Int?
    ) -> PauseDetectionResult {
        let consecutiveLow = countConsecutiveLowWeeks(reports: recentReports)
        let historyLevel = levelFromConsecutiveLowWeeks(consecutiveLow)
        let daysLevel = levelFromDaysSinceLastWorkout(daysSinceLastWorkout)
        // On prend le pire des deux signaux : si HK dit "rien depuis 20 jours"
        // mais que l'historique de rapports n'a qu'1 sem sub-seuil (cas où on
        // n'a qu'1 rapport en mémoire), on bascule quand même en `extended`.
        let combined = maxLevel(historyLevel, daysLevel)
        return PauseDetectionResult(
            level: combined,
            daysSinceLastWorkout: daysSinceLastWorkout,
            consecutiveLowWeeks: consecutiveLow
        )
    }

    // MARK: - Helpers

    /// Nb max de semaines historique inspectées pour décider du niveau de
    /// pause. Au-delà de 3 sem consécutives sub-seuil on est déjà au niveau
    /// `extended` — inutile (et trompeur côté lecteur) de continuer à scanner.
    public static let historyDepthLimit: Int = 3

    /// Compte les semaines consécutives sub-seuil en partant de la plus récente.
    /// Une semaine sans session active planifiée (programme full rest, ex.
    /// semaine de récup pure) n'est PAS comptée comme low (completionRate=0
    /// par convention de l'analyzer, mais ce n'est pas une pause subie).
    /// Inspecte au plus `historyDepthLimit` semaines — au-delà le niveau ne
    /// change plus, on évite de balayer un tableau plus long inutilement.
    static func countConsecutiveLowWeeks(reports: [WeeklyExecutionReport]) -> Int {
        var count = 0
        for report in reports.prefix(historyDepthLimit) {
            if report.plannedActiveSessionCount == 0 {
                // Semaine "off" planifiée : ne casse pas la série mais ne compte
                // pas non plus comme low. break pour éviter de continuer à
                // accumuler artificiellement après une décharge planifiée.
                break
            }
            if report.completionRate < continuityThreshold {
                count += 1
            } else {
                break
            }
        }
        return count
    }

    /// Mapping historique → niveau. 0 sem low → none ; 1 → light ; 2 → moderate ;
    /// 3+ → extended (cf. doctrine ACSM dans le header).
    static func levelFromConsecutiveLowWeeks(_ count: Int) -> PauseLevel {
        switch count {
        case ..<1:  return .none
        case 1:     return .light
        case 2:     return .moderate
        default:    return .extended
        }
    }

    /// Mapping HK days → niveau. Voir doc des constantes pour la motivation.
    static func levelFromDaysSinceLastWorkout(_ days: Int?) -> PauseLevel {
        guard let days, days >= 0 else { return .none }
        if days >= extendedPauseDaysThreshold { return .extended }
        if days >= moderatePauseDaysThreshold { return .moderate }
        if days >= lightPauseDaysThreshold    { return .light }
        return .none
    }

    /// Retourne le niveau le plus élevé des deux (rang : none < light < moderate < extended).
    static func maxLevel(_ a: PauseLevel, _ b: PauseLevel) -> PauseLevel {
        rank(a) >= rank(b) ? a : b
    }

    private static func rank(_ level: PauseLevel) -> Int {
        switch level {
        case .none:     return 0
        case .light:    return 1
        case .moderate: return 2
        case .extended: return 3
        }
    }
}
