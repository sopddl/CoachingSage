import Foundation
import TemplateModel

/// Chantier indoor/outdoor vélo (2026-06-10) — lieu choisi par l'user pour chaque séance,
/// sérialisé dans `AdaptedProgramRecord` (mirroir léger, même pattern que `ExerciseWeightState`).
/// Clé = `"week-day"` (stable à travers ré-adaptation et renouvellement) ; valeur =
/// `SessionEnvironment.rawValue`. Override du défaut programme (`environmentDefaultRaw`).
public struct SessionLocationState: Codable, Equatable, Sendable {
    public var locations: [String: String]

    public init(locations: [String: String] = [:]) {
        self.locations = locations
    }

    public static let empty = SessionLocationState()

    public static func key(week: Int, day: Int) -> String { "\(week)-\(day)" }

    /// Lieu choisi pour une séance (nil = pas d'override → on retombe sur le défaut programme/natif).
    public func environment(week: Int, day: Int) -> SessionEnvironment? {
        locations[Self.key(week: week, day: day)].flatMap(SessionEnvironment.init(rawValue:))
    }

    public mutating func set(_ environment: SessionEnvironment?, week: Int, day: Int) {
        let k = Self.key(week: week, day: day)
        if let environment { locations[k] = environment.rawValue }
        else { locations.removeValue(forKey: k) }
    }
}
