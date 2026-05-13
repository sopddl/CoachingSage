// Coaching/Regen/SessionVolumeScaler.swift
// Story 3.4 Phase B.2 — applique un multiplicateur de volume (produit par
// `VolumeAdjustment.multiplier`) à la durée d'une session, en clampant le
// résultat dans une plage physiologiquement raisonnable.
//
// Fonction pure, testable, 0 dépendance. Vit dans `Coaching/Regen/` pour rester
// près de l'algo dont elle dérive (RegressionRule produit le multiplier ; ce
// helper l'applique côté Phase B).
//
// Bornes de clamp :
//   - minimum 5 min : sous ce seuil la session n'a plus de valeur entraînement
//     (un échauffement seul ne compte pas). C'est aussi le plancher recommandé
//     ACSM pour qu'une séance ait un effet cardiovasculaire mesurable.
//   - maximum 240 min (4h) : protège contre un multiplier corrompu (bug amont)
//     qui projetterait une séance à 600 min. Au-delà de 4h, on est hors-doctrine
//     amateur sport (les rares sessions ultra-longues sont issues du template,
//     pas d'un +10% de regen). EU MDR : safety-first.
//
// Arrondi : `.toNearestOrEven` (banker's rounding) — évite le biais cumulatif
// des arrondis successifs (semaine après semaine) qui dériverait le volume vers
// le haut avec un simple `.round()`.
import Foundation

public enum SessionVolumeScaler {

    /// Plancher de durée d'une session active (minutes). Sous ce seuil on
    /// considère qu'on n'a plus une séance d'entraînement.
    public static let minDurationMinutes: Int = 5

    /// Plafond de durée d'une session (minutes). Filet anti-multiplier corrompu.
    public static let maxDurationMinutes: Int = 240

    /// Applique `multiplier` à `durationMinutes` et clampe à [5, 240].
    ///
    /// - Parameters:
    ///   - durationMinutes: durée planifiée originale (entier ≥ 0).
    ///   - multiplier: facteur produit par `VolumeAdjustment.multiplier`.
    ///     Typiquement 0.5 (restart), 0.75, 0.90, 1.0, 1.10. Toute valeur
    ///     hors plage [0.01, 10] est clampée défensivement.
    /// - Returns: durée ajustée, entière, clampée à [5, 240].
    public static func scale(durationMinutes: Int, multiplier: Double) -> Int {
        guard durationMinutes > 0 else { return durationMinutes }
        let clampedMultiplier = max(0.01, min(multiplier, 10.0))
        let raw = Double(durationMinutes) * clampedMultiplier
        let rounded = Int(raw.rounded(.toNearestOrEven))
        return min(maxDurationMinutes, max(minDurationMinutes, rounded))
    }
}
