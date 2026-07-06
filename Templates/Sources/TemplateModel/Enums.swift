import Foundation

public enum Sport: String, Codable, CaseIterable, Sendable {
    case running
    case cycling
    case swimming
    case triathlon
    case strengthTraining = "strength_training"
    case yoga
    case hiit
    case hiking
    case tennis
    case football
}

public enum Level: String, Codable, CaseIterable, Sendable {
    case beginner
    case recreational
    case regular
    case competitive
}

public enum SessionType: String, Codable, CaseIterable, Sendable {
    case endurance
    case interval
    case technique
    case strength
    case mixed
    case mobility
    case rest
    case other
}

public enum VolumeAxis: String, Codable, CaseIterable, Sendable {
    case duration
    case distance
    case reps
    case sets
    case elevation
}

/// Rôle d'un bloc dans une séance (chantier durée réglable, pilote cycling, 2026-07-04).
/// `core` = le pourquoi de la séance, jamais retiré (seulement scalé dans sa fourchette
/// doctrine). `accessory` = renforcement/drill secondaire, sacrifié en premier (D5).
/// `nil` sur `TemplateExercise.role` = sport pas encore annoté (hors V1 cycling).
public enum BlockRole: String, Codable, CaseIterable, Sendable {
    case core
    case accessory
}

/// Unité de scaling d'un bloc (chantier durée réglable). `continuous` = minutes continues
/// (sortie Z1-Z3 en un seul tenant). `roundsReps` = nombre de répétitions (`sets`), la durée
/// par rep ne bouge pas. `fixed` = intouchable même en `accessory` (aucun cas cycling V1,
/// gardé pour extension future type test FTP).
public enum ScalingUnit: String, Codable, CaseIterable, Sendable {
    case continuous
    case roundsReps
    case fixed
}
