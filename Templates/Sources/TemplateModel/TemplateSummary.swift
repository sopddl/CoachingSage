import Foundation

/// Métadonnées légères d'un `ProgramTemplate` — projection sans le contenu profond
/// (`weeks` = ~70 % du poids JSON). Chantier perf 2026-06-20 : les chemins qui ne
/// font PAS exécuter une séance (sélection, suggestions mode vide, résolution du
/// nom d'un programme au dashboard) n'ont besoin que de ces champs. Le template
/// complet n'est décodé paresseusement (`TemplateLoader.load(id:)`) qu'au moment
/// d'adapter/exécuter une séance.
///
/// Sérialisé dans le manifest bundlé `template-summaries.json` (~10 KB) → le
/// dashboard ne décode plus les 18 MB des 40 templates au launch.
public struct TemplateSummary: Codable, Equatable, Sendable, Identifiable {
    public let id: String
    public let sport: Sport
    public let level: Level
    public let name: LocalizedText
    public let durationWeeks: Int
    public let sessionsPerWeek: Int

    public init(
        id: String,
        sport: Sport,
        level: Level,
        name: LocalizedText,
        durationWeeks: Int,
        sessionsPerWeek: Int
    ) {
        self.id = id
        self.sport = sport
        self.level = level
        self.name = name
        self.durationWeeks = durationWeeks
        self.sessionsPerWeek = sessionsPerWeek
    }
}

public extension ProgramTemplate {
    /// Projection métadonnées (pour le manifest summaries + les chemins non-exécution).
    /// NB : `summary` (LocalizedText) est déjà un champ du modèle → projection = `asSummary`.
    var asSummary: TemplateSummary {
        TemplateSummary(
            id: id,
            sport: sport,
            level: level,
            name: name,
            durationWeeks: durationWeeks,
            sessionsPerWeek: sessionsPerWeek
        )
    }
}

public enum TemplateSummaryCoding {
    /// Encodeur canonique du manifest — clés snake_case triées, diffs stables.
    public static func makeEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        return encoder
    }

    public static func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }

    /// Encode la liste triée par `id` (ordre déterministe du manifest).
    public static func encode(_ summaries: [TemplateSummary]) throws -> Data {
        try makeEncoder().encode(summaries.sorted { $0.id < $1.id })
    }

    public static func decode(_ data: Data) throws -> [TemplateSummary] {
        try makeDecoder().decode([TemplateSummary].self, from: data)
    }
}
