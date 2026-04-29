// ViewModels/EditPersonalDataViewModel.swift
// Story 2.3 — édition sex/DOB/poids/taille avec import HealthKit toujours visible.
import Foundation
import HealthKit
import SwiftUI
import SageCore

@MainActor
@Observable
final class EditPersonalDataViewModel {
    var biologicalSex: String?
    var dateOfBirth: Date?
    var weightKg: Double?
    var heightCm: Double?

    var saveState: ViewState<Void> = .idle
    var isImportingHealthKit: Bool = false

    /// Si on a déjà demandé l'autorisation HK ET aucune donnée n'a été retournée → l'utilisateur a probablement
    /// refusé via Réglages. CTA bascule sur "Activer dans Réglages > Santé" (review P2-1).
    var healthKitProbablyDenied: Bool = false

    private let coachingProfile: CoachingProfile
    private let coachingProfileRepository: any CoachingProfileRepository
    private let healthKitService: any HealthKitServiceProtocol

    init(
        coachingProfile: CoachingProfile,
        coachingProfileRepository: any CoachingProfileRepository,
        healthKitService: any HealthKitServiceProtocol
    ) {
        self.coachingProfile = coachingProfile
        self.coachingProfileRepository = coachingProfileRepository
        self.healthKitService = healthKitService
        self.biologicalSex = coachingProfile.biologicalSex
        self.dateOfBirth = coachingProfile.dateOfBirth
        self.weightKg = coachingProfile.weightKg
        self.heightCm = coachingProfile.heightCm
    }

    var canSave: Bool {
        guard let sex = biologicalSex, !sex.isEmpty,
              dateOfBirth != nil,
              let w = weightKg, (30.0...250.0).contains(w),
              let h = heightCm, (100.0...230.0).contains(h)
        else { return false }
        if case .loading = saveState { return false }
        return true
    }

    var isSaving: Bool {
        if case .loading = saveState { return true }
        return false
    }

    var saveErrorMessage: String? {
        if case .error(let err) = saveState { return err.localizedDescription }
        return nil
    }

    var isHealthKitAvailable: Bool {
        healthKitService.isHealthDataAvailable
    }

    /// Différent de Story 2.2 : pas de `hasUserEdited` flag — l'import écrase toujours.
    /// L'user a explicitement tap la CTA, il sait qu'il va overwrite (AC4).
    func importFromHealthKit() async {
        isImportingHealthKit = true
        defer { isImportingHealthKit = false }

        let alreadyRequested = healthKitService.hasRequestedAuthorization

        do {
            try await healthKitService.requestProfileAuthorization()
        } catch {
            #if DEBUG
            print("HealthKit auth failed (acceptable): \(error.localizedDescription)")
            #endif
        }

        let data = await healthKitService.fetchProfileData()

        if let sex = data.biologicalSex {
            biologicalSex = Self.mapBiologicalSex(sex) ?? biologicalSex
        }
        if let dob = data.dateOfBirth {
            dateOfBirth = dob
        }
        if let w = data.bodyMassKg, (30.0...250.0).contains(w) {
            weightKg = w
        }
        if let h = data.heightCm, (100.0...230.0).contains(h) {
            heightCm = h
        }

        // Heuristique refus : déjà demandé + tous les champs HK retournent nil → bascule label CTA.
        let allNil = data.biologicalSex == nil && data.dateOfBirth == nil
            && data.bodyMassKg == nil && data.heightCm == nil
        healthKitProbablyDenied = alreadyRequested && allNil
    }

    func save() async {
        guard canSave else { return }
        saveState = .loading

        coachingProfile.biologicalSex = biologicalSex
        coachingProfile.dateOfBirth = dateOfBirth
        coachingProfile.weightKg = weightKg
        coachingProfile.heightCm = heightCm
        coachingProfile.updatedAt = Date()

        do {
            try await coachingProfileRepository.save(coachingProfile)
            saveState = .success(())
        } catch {
            saveState = .error(error as? AppError ?? .sync(error.localizedDescription))
        }
    }

    static func mapBiologicalSex(_ value: HKBiologicalSex) -> String? {
        switch value {
        case .female: return "female"
        case .male: return "male"
        case .other: return "other"
        case .notSet: return nil
        @unknown default: return nil
        }
    }
}
