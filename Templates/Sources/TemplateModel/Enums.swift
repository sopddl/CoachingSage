import Foundation

public enum Sport: String, Codable, CaseIterable, Sendable {
    case running
    case musculation
    case natation
    case velo
    case triathlon
    case tennis
    case yoga
    case hiit
    case remiseEnForme = "remise_en_forme"
    case sportsCollectifs = "sports_collectifs"
}

public enum Level: String, Codable, CaseIterable, Sendable {
    case debutant
    case intermediaire
    case avance
    case expert
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
