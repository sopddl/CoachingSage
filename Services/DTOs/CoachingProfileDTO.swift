// Services/DTOs/CoachingProfileDTO.swift
// Story 2.2 — mapping JSON Supabase ↔ CoachingProfile SwiftData.
// snake_case côté Postgres, camelCase côté Swift.
import Foundation

struct CoachingProfileDTO: Decodable {
    let id: UUID
    let biologicalSex: String?
    let dateOfBirth: Date?
    let weightKg: Double?
    let heightCm: Double?
    let activeSports: [String]
    let parqResponses: [String: Bool]
    let requiresMedicalClearance: Bool
    let disclaimerVersionAccepted: String?
    let disclaimerAcceptedAt: Date?
    let onboardingCompletedAt: Date?
    let createdAt: Date
    let updatedAt: Date
    let isSoftDeleted: Bool
    let deletedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case biologicalSex = "biological_sex"
        case dateOfBirth = "date_of_birth"
        case weightKg = "weight_kg"
        case heightCm = "height_cm"
        case activeSports = "active_sports"
        case parqResponses = "parq_responses"
        case requiresMedicalClearance = "requires_medical_clearance"
        case disclaimerVersionAccepted = "disclaimer_version_accepted"
        case disclaimerAcceptedAt = "disclaimer_accepted_at"
        case onboardingCompletedAt = "onboarding_completed_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case isSoftDeleted = "is_soft_deleted"
        case deletedAt = "deleted_at"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        biologicalSex = try container.decodeIfPresent(String.self, forKey: .biologicalSex)
        // date_of_birth Postgres = DATE (YYYY-MM-DD), pas TIMESTAMPTZ → décodage manuel.
        if let dobString = try container.decodeIfPresent(String.self, forKey: .dateOfBirth) {
            dateOfBirth = Self.dateFormatter.date(from: dobString)
        } else {
            dateOfBirth = nil
        }
        weightKg = try container.decodeIfPresent(Double.self, forKey: .weightKg)
        heightCm = try container.decodeIfPresent(Double.self, forKey: .heightCm)
        activeSports = try container.decodeIfPresent([String].self, forKey: .activeSports) ?? []
        parqResponses = try container.decodeIfPresent([String: Bool].self, forKey: .parqResponses) ?? [:]
        requiresMedicalClearance = try container.decode(Bool.self, forKey: .requiresMedicalClearance)
        disclaimerVersionAccepted = try container.decodeIfPresent(String.self, forKey: .disclaimerVersionAccepted)
        disclaimerAcceptedAt = try container.decodeIfPresent(Date.self, forKey: .disclaimerAcceptedAt)
        onboardingCompletedAt = try container.decodeIfPresent(Date.self, forKey: .onboardingCompletedAt)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        isSoftDeleted = try container.decode(Bool.self, forKey: .isSoftDeleted)
        deletedAt = try container.decodeIfPresent(Date.self, forKey: .deletedAt)
    }

    func toModel() -> CoachingProfile {
        let profile = CoachingProfile(id: id)
        profile.biologicalSex = biologicalSex
        profile.dateOfBirth = dateOfBirth
        profile.weightKg = weightKg
        profile.heightCm = heightCm
        profile.activeSports = activeSports
        profile.parqResponses = parqResponses
        profile.requiresMedicalClearance = requiresMedicalClearance
        profile.disclaimerVersionAccepted = disclaimerVersionAccepted
        profile.disclaimerAcceptedAt = disclaimerAcceptedAt
        profile.onboardingCompletedAt = onboardingCompletedAt
        profile.createdAt = createdAt
        profile.updatedAt = updatedAt
        profile.isSoftDeleted = isSoftDeleted
        profile.deletedAt = deletedAt
        return profile
    }

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.timeZone = TimeZone(secondsFromGMT: 0)
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()
}

/// DTO pour l'UPSERT Supabase. Codable car SyncService décode au drain offline.
struct CoachingProfileUpsertDTO: Codable {
    let id: UUID
    let biologicalSex: String?
    let dateOfBirth: String?              // YYYY-MM-DD pour Postgres DATE
    let weightKg: Double?
    let heightCm: Double?
    let activeSports: [String]
    let parqResponses: [String: Bool]
    let requiresMedicalClearance: Bool
    let disclaimerVersionAccepted: String?
    let disclaimerAcceptedAt: Date?
    let onboardingCompletedAt: Date?
    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case biologicalSex = "biological_sex"
        case dateOfBirth = "date_of_birth"
        case weightKg = "weight_kg"
        case heightCm = "height_cm"
        case activeSports = "active_sports"
        case parqResponses = "parq_responses"
        case requiresMedicalClearance = "requires_medical_clearance"
        case disclaimerVersionAccepted = "disclaimer_version_accepted"
        case disclaimerAcceptedAt = "disclaimer_accepted_at"
        case onboardingCompletedAt = "onboarding_completed_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    init(from profile: CoachingProfile) {
        self.id = profile.id
        self.biologicalSex = profile.biologicalSex
        self.dateOfBirth = profile.dateOfBirth.map { CoachingProfileUpsertDTO.dateFormatter.string(from: $0) }
        self.weightKg = profile.weightKg
        self.heightCm = profile.heightCm
        self.activeSports = profile.activeSports
        self.parqResponses = profile.parqResponses
        self.requiresMedicalClearance = profile.requiresMedicalClearance
        self.disclaimerVersionAccepted = profile.disclaimerVersionAccepted
        self.disclaimerAcceptedAt = profile.disclaimerAcceptedAt
        self.onboardingCompletedAt = profile.onboardingCompletedAt
        self.createdAt = profile.createdAt
        self.updatedAt = profile.updatedAt
    }

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.timeZone = TimeZone(secondsFromGMT: 0)
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()
}
