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
