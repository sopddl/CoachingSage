// CoachingSage/Services/DTOs/CoreProfileDTO.swift
// [COPIE IDENTIQUE] — synchroniser avec GardenSage et TailorSage.
import Foundation

struct CoreProfileDTO: Decodable {
    let id: UUID
    let firstName: String?
    let language: String
    let region: String
    let latitude: Double?
    let longitude: Double?
    let altitude: Double?
    let analyticsConsent: Bool
    let notificationPreferences: Data?
    let vacationEndDate: Date?
    let subscriptionTier: String
    let subscriptionExpiresAt: Date?
    let createdAt: Date
    let updatedAt: Date
    let isSoftDeleted: Bool
    let deletedAt: Date?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        firstName = try container.decodeIfPresent(String.self, forKey: .firstName)
        language = try container.decode(String.self, forKey: .language)
        region = try container.decode(String.self, forKey: .region)
        latitude = try container.decodeIfPresent(Double.self, forKey: .latitude)
        longitude = try container.decodeIfPresent(Double.self, forKey: .longitude)
        altitude = try container.decodeIfPresent(Double.self, forKey: .altitude)
        analyticsConsent = try container.decode(Bool.self, forKey: .analyticsConsent)
        vacationEndDate = try container.decodeIfPresent(Date.self, forKey: .vacationEndDate)
        subscriptionTier = try container.decode(String.self, forKey: .subscriptionTier)
        subscriptionExpiresAt = try container.decodeIfPresent(Date.self, forKey: .subscriptionExpiresAt)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        isSoftDeleted = try container.decode(Bool.self, forKey: .isSoftDeleted)
        deletedAt = try container.decodeIfPresent(Date.self, forKey: .deletedAt)

        // notification_preferences : JSONB de Supabase → Data brut
        if let prefs = try? container.decodeIfPresent(NotificationPreferences.self, forKey: .notificationPreferences) {
            notificationPreferences = try? JSONEncoder().encode(prefs)
        } else {
            notificationPreferences = nil
        }
    }

    enum CodingKeys: String, CodingKey {
        case id
        case firstName             = "first_name"
        case language
        case region
        case latitude
        case longitude
        case altitude
        case analyticsConsent      = "analytics_consent"
        case notificationPreferences = "notification_preferences"
        case vacationEndDate       = "vacation_end_date"
        case subscriptionTier      = "subscription_tier"
        case subscriptionExpiresAt = "subscription_expires_at"
        case createdAt             = "created_at"
        case updatedAt             = "updated_at"
        case isSoftDeleted         = "is_soft_deleted"
        case deletedAt             = "deleted_at"
    }
}

/// DTO pour l'upsert vers Supabase — tous les champs sauf soft delete.
/// Codable (pas seulement Encodable) : SyncService.execute() décode le payload
/// stocké dans PendingOperation pour le ré-envoyer à Supabase au drain.
struct CoreProfileUpsertDTO: Codable {
    let id: UUID
    let firstName: String?
    let language: String
    let region: String
    let latitude: Double?
    let longitude: Double?
    let altitude: Double?
    let analyticsConsent: Bool
    let notificationPreferences: Data?
    let vacationEndDate: Date?
    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case firstName             = "first_name"
        case language
        case region
        case latitude
        case longitude
        case altitude
        case analyticsConsent      = "analytics_consent"
        case notificationPreferences = "notification_preferences"
        case vacationEndDate       = "vacation_end_date"
        case createdAt             = "created_at"
        case updatedAt             = "updated_at"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(firstName, forKey: .firstName)
        try container.encode(language, forKey: .language)
        try container.encode(region, forKey: .region)
        try container.encodeIfPresent(latitude, forKey: .latitude)
        try container.encodeIfPresent(longitude, forKey: .longitude)
        try container.encodeIfPresent(altitude, forKey: .altitude)
        try container.encode(analyticsConsent, forKey: .analyticsConsent)
        try container.encodeIfPresent(vacationEndDate, forKey: .vacationEndDate)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)

        if let notifData = notificationPreferences {
            let jsonObject = try JSONSerialization.jsonObject(with: notifData)
            try container.encode(AnyEncodable(jsonObject), forKey: .notificationPreferences)
        }
    }
}

private struct AnyEncodable: Encodable {
    let value: Any

    init(_ value: Any) {
        self.value = value
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let dict = value as? [String: Any] {
            let data = try JSONSerialization.data(withJSONObject: dict)
            let decoded = try JSONDecoder().decode([String: AnyCodable].self, from: data)
            try container.encode(decoded)
        } else if let array = value as? [Any] {
            let data = try JSONSerialization.data(withJSONObject: array)
            let decoded = try JSONDecoder().decode([AnyCodable].self, from: data)
            try container.encode(decoded)
        } else if let string = value as? String {
            try container.encode(string)
        } else if let bool = value as? Bool {
            try container.encode(bool)
        } else if let int = value as? Int {
            try container.encode(int)
        } else if let double = value as? Double {
            try container.encode(double)
        } else {
            try container.encodeNil()
        }
    }
}

private enum AnyCodable: Codable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case null

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let v = try? container.decode(Bool.self) { self = .bool(v) }
        else if let v = try? container.decode(Int.self) { self = .int(v) }
        else if let v = try? container.decode(Double.self) { self = .double(v) }
        else if let v = try? container.decode(String.self) { self = .string(v) }
        else { self = .null }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let v): try container.encode(v)
        case .int(let v): try container.encode(v)
        case .double(let v): try container.encode(v)
        case .bool(let v): try container.encode(v)
        case .null: try container.encodeNil()
        }
    }
}
