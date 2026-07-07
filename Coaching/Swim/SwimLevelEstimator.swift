// Coaching/Swim/SwimLevelEstimator.swift
// Story 3.16 Phase 2.B — estime le niveau natation ("beginner" / "recreational"
// / "regular" / "competitive") depuis l'historique HK, pour pré-remplir
// l'autoprofil à la création d'un programme natation.
//
// Choix de design : on classe sur la DISTANCE PAR SÉANCE + la meilleure allure,
// PAS sur le volume hebdomadaire. Le volume/sem confond fréquence et niveau —
// un bon nageur occasionnel (1 séance de 1500 m / 2 sem) serait classé débutant
// à tort. La capacité se lit dans ce qu'il fait QUAND il nage.
//
// Biais volontaire vers le BAS : en cas de doute, sous-estimer le niveau plutôt
// que proposer un programme trop dur. L'autoprofil n'est qu'une suggestion
// initiale, l'utilisateur peut ajuster. Ce n'est PAS une calibration d'adapter
// (cf caveat CSS : on ne redéfinit pas la vitesse de référence ici).
import Foundation

enum SwimLevelEstimator {

    /// Seuils (tunables). Distance moyenne par séance (m) et meilleure allure (s/100m).
    enum Thresholds {
        static let competitiveSessionMeters = 2500.0
        static let competitivePaceSecondsPer100m = 95.0
        static let regularSessionMeters = 1500.0
        static let regularPaceSecondsPer100m = 110.0
        static let recreationalSessionMeters = 600.0
    }

    /// Retourne le niveau estimé, ou `nil` si pas assez de signal (0 séance) —
    /// le caller applique alors son défaut.
    static func estimate(from summary: SwimSummary) -> String? {
        guard summary.sessionCount > 0, summary.totalDistanceMeters > 0 else { return nil }

        let avgSessionMeters = summary.totalDistanceMeters / Double(summary.sessionCount)
        let bestPace = summary.bestPaceSecondsPer100m // plus PETIT = plus rapide

        func paceAtMost(_ threshold: Double) -> Bool {
            guard let bestPace else { return false }
            return bestPace <= threshold
        }

        // competitive : gros volume par séance ET allure rapide (les deux requis).
        if avgSessionMeters >= Thresholds.competitiveSessionMeters,
           paceAtMost(Thresholds.competitivePaceSecondsPer100m) {
            return "competitive"
        }
        // regular : bon volume par séance OU allure solide.
        if avgSessionMeters >= Thresholds.regularSessionMeters
            || paceAtMost(Thresholds.regularPaceSecondsPer100m) {
            return "regular"
        }
        // recreational : volume modéré.
        if avgSessionMeters >= Thresholds.recreationalSessionMeters {
            return "recreational"
        }
        return "beginner"
    }
}
