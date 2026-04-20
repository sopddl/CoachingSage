// Models/NotificationPreferences.swift
// Structure JSON pour SageCoreProfile.notificationPreferences.
// Version minimale bootstrap — catégories domaine (séances, rappels, etc.)
// seront ajoutées en Epic 5 (Notifications & Engagement).
import Foundation

struct NotificationPreferences: Codable, Equatable {
    var enabled: Bool = false
    var preferredHour: Int = 9
    var preferredMinute: Int = 0

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        enabled = try container.decodeIfPresent(Bool.self, forKey: .enabled) ?? false
        preferredHour = try container.decodeIfPresent(Int.self, forKey: .preferredHour) ?? 9
        preferredMinute = try container.decodeIfPresent(Int.self, forKey: .preferredMinute) ?? 0
    }

    init() { }

    enum CodingKeys: String, CodingKey {
        case enabled
        case preferredHour = "preferred_hour"
        case preferredMinute = "preferred_minute"
    }
}

extension SageCoreProfile {
    /// Décode les préférences de notification depuis le champ Data? JSON.
    var decodedNotificationPreferences: NotificationPreferences {
        get {
            guard let data = notificationPreferences else {
                return NotificationPreferences()
            }
            return (try? JSONDecoder().decode(NotificationPreferences.self, from: data)) ?? NotificationPreferences()
        }
        set {
            notificationPreferences = try? JSONEncoder().encode(newValue)
        }
    }

    func setNotificationPreferences(_ prefs: NotificationPreferences) {
        notificationPreferences = try? JSONEncoder().encode(prefs)
    }
}
