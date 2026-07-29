// ViewModels/AdaptedProgramViewModel.swift
// Story 3.3b — orchestre le hand-off Léon depuis AdaptedProgramView :
// 1. Construit le payload (template stub + profile + health summary + program JSON).
// 2. Appelle SageCoachingAIService.requestAdaptRare.
// 3. Applique le patch via PatchApplier (mute le programme + extrait notes Léon).
// 4. Persiste le patch dans le record SwiftData (idempotence au reload).
// 5. Expose `requestState` (.idle/.loading/.success/.error) à l'UI pour loader/erreurs.
import Foundation
import SwiftUI

@MainActor
final class AdaptedProgramViewModel: ObservableObject {

    enum LeonRequestState: Equatable {
        case idle
        case loading
        case success
        case error(LeonError)
    }

    @Published private(set) var program: AdaptedProgram
    @Published private(set) var leonNotes: LeonAppliedNotes?
    @Published private(set) var requestState: LeonRequestState = .idle
    @Published var showQuotaSheet: Bool = false

    let recordId: UUID?

    private let aiService: any SageCoachingAIServiceProtocol
    private let healthSummaryBuilder: any HealthSummaryBuilding
    private let coreRepo: any CoreProfileRepository
    private let coachingRepo: any CoachingProfileRepository
    private let adaptedRepo: any AdaptedProgramRepository
    private let storeKitService: any StoreKitServiceProtocol

    /// Empêche le déclenchement automatique multiple si la View se réabonne
    /// (.task peut être appelé plusieurs fois sur re-render).
    private var hasAutoTriggered = false

    init(
        program: AdaptedProgram,
        initialLeonNotes: LeonAppliedNotes? = nil,
        recordId: UUID? = nil,
        aiService: any SageCoachingAIServiceProtocol,
        healthSummaryBuilder: any HealthSummaryBuilding,
        coreRepo: any CoreProfileRepository,
        coachingRepo: any CoachingProfileRepository,
        adaptedRepo: any AdaptedProgramRepository,
        storeKitService: any StoreKitServiceProtocol
    ) {
        self.program = program
        self.leonNotes = initialLeonNotes
        self.recordId = recordId
        self.aiService = aiService
        self.healthSummaryBuilder = healthSummaryBuilder
        self.coreRepo = coreRepo
        self.coachingRepo = coachingRepo
        self.adaptedRepo = adaptedRepo
        self.storeKitService = storeKitService
    }

    /// Appelé par AdaptedProgramView.task. Trigger le call Léon UNIQUEMENT si :
    /// - le programme est marqué requiresAIAssist (algo 3.3a a remonté un cas atypique)
    /// - aucune note Léon n'a déjà été affichée (premier passage OU reload sans patch persisté)
    /// - on n'a pas déjà tenté dans cette session
    func triggerLeonIfNeeded() async {
        guard program.requiresAIAssist, leonNotes == nil, !hasAutoTriggered else { return }
        hasAutoTriggered = true
        await requestLeon(reason: .atypicalConstraints)
    }

    /// Appelé par le bouton "Léon, retravaille ce programme" (toujours visible).
    /// Re-trigger même si déjà appliqué — le user demande explicitement.
    func requestLeonExplicit() async {
        await requestLeon(reason: .userExplicit)
    }

    private func requestLeon(reason: AdaptRareReason) async {
        requestState = .loading

        do {
            let payload = try await buildPayload()
            let summary = await healthSummaryBuilder.buildSummary()

            let response = try await aiService.requestAdaptRare(
                triggeredReason: reason,
                templateJSON: payload.templateJSON,
                profileJSON: payload.profileJSON,
                healthSummary: summary,
                adaptedProgramJSON: payload.programJSON
            )

            let applied = PatchApplier.apply(response.patch, to: program)
            program = applied.program
            leonNotes = applied.leonNotes

            if let recordId, response.patch.hasContent {
                try? await adaptedRepo.applyLeonPatch(recordId: recordId, patch: response.patch)
            }

            // Source de vérité serveur pour le tier : à synchroniser après CHAQUE
            // réponse Léon réussie (pas seulement après achat), sinon une
            // expiration/remboursement ne se refléterait qu'au prochain boot.
            storeKitService.applyQuotaTier(response.quota.tier)

            requestState = .success
        } catch let leonError as LeonError {
            if case .quotaExceeded = leonError { showQuotaSheet = true }
            requestState = .error(leonError)
        } catch {
            requestState = .error(.network(error.localizedDescription))
        }
    }

    // MARK: - Payload building

    private func buildPayload() async throws -> Payload {
        let core = try? await coreRepo.fetchCurrentProfile()
        let coaching = try? await coachingRepo.fetchCurrentProfile()

        let profileDict: [String: Any] = [
            "first_name": (core?.firstName ?? "") as Any,
            "language": (core?.language ?? "fr") as Any,
            "level": program.level.rawValue,
            "sport": program.sport.rawValue,
            "requires_medical_clearance": coaching?.requiresMedicalClearance ?? false
        ]
        let profileJSON = try JSONSerialization.data(withJSONObject: profileDict)
        let programJSON = try JSONEncoder().encode(program)

        // V1 : on n'envoie pas le template-source (Léon a tout dans
        // adapted_program_json). À enrichir V2 si Léon a besoin du contexte
        // doctrinal pour proposer des substitutions cohérentes avec le template.
        let templateJSON = Data("{\"id\":\"\(program.templateId)\"}".utf8)

        return Payload(templateJSON: templateJSON, profileJSON: profileJSON, programJSON: programJSON)
    }

    private struct Payload {
        let templateJSON: Data
        let profileJSON: Data
        let programJSON: Data
    }
}
