import Foundation

/// Lieu de pratique d'une séance (chantier indoor/outdoor vélo, 2026-06-10).
/// `String` brut + extensible : on peut ajouter un cas (ex. tapis) sans casser le
/// décodage des templates existants. Cf [[v2_chantier_indoor_outdoor_velo]].
public enum SessionEnvironment: String, Codable, Equatable, Sendable, CaseIterable {
    case indoor
    case outdoor
}

/// Variante de séance liée à un lieu = **prescription COMPLÈTE** pour ce lieu
/// (décision Sophie 2026-06-10 : 2 vraies séances, pas une note adaptative).
/// Le contenu NATIF de la séance vit à la racine de `TemplateSession` (= variante
/// par défaut, rétro-compatible) ; `TemplateSession.variants` porte les variantes
/// ALTERNATIVES (l'autre lieu). Tous les champs sont localisés FR/EN/ES.
public struct SessionVariant: Codable, Equatable, Sendable {
    public let environment: SessionEnvironment
    public let name: LocalizedText
    public let durationMinutes: Int
    public let warmup: LocalizedText?
    public let exercises: [TemplateExercise]
    public let cooldown: LocalizedText?

    public init(
        environment: SessionEnvironment,
        name: LocalizedText,
        durationMinutes: Int,
        warmup: LocalizedText? = nil,
        exercises: [TemplateExercise] = [],
        cooldown: LocalizedText? = nil
    ) {
        self.environment = environment
        self.name = name
        self.durationMinutes = durationMinutes
        self.warmup = warmup
        self.exercises = exercises
        self.cooldown = cooldown
    }
}
