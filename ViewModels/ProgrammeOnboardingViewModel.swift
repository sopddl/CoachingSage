// ViewModels/ProgrammeOnboardingViewModel.swift
// Onboarding PROGRAMME « fil de Léon » (inc1 — coquille fil + génération).
//
// Deux zones franches (party onboarding 2026-06-23) :
//   ① TA DEMANDE   : carrousel de TES sports + champ libre (multi-ligne).
//   ② CE QUE LÉON PROPOSE : restitution + récap éditable (rythme/durée),
//     « aperçu vivant » → éditer le rythme recompose la proposition.
//   ③ conversation : champ persistant + bulle d'invite (relances LOGGÉES, pas
//     encore interprétées — l'interprétation ✓/⏳/🚫 arrive à l'inc NL).
//
// **Inc1 = PREVIEW SEULEMENT** : aucune écriture. Le vert « Créer mon programme »
// rend le `CoachingSportProfile` finalisé via `onCompleted` → `SessionView`
// réutilise `presentAdaptedProgram(for:)` (commit + push) = zéro logique dupliquée.
//
// La demande libre est CAPTURÉE dans `freeTextNotes` (donnée de l'user) mais
// NON interprétée en inc1 (pas de routage ✓/⏳/🚫, pas de classification MDR).
import Foundation
import SwiftUI

@MainActor
@Observable
final class ProgrammeOnboardingViewModel {

    // MARK: - Dépendances injectées

    private let userId: UUID
    private let requiresMedicalClearance: Bool
    /// Niveau inféré (autoprofil HK) si dispo, sinon nil → `recreational` par défaut.
    private let autoprofileLevel: String?
    /// Seam de génération : rend l'aperçu (nombre de semaines du programme adapté)
    /// pour un profil donné, sans persister. Injecté = testable (stub) ; en prod
    /// = wrapper sur `AutoProgramFactory.previewGenerate(sportProfile:userId:)`.
    private let generatePreview: (CoachingSportProfile) async throws -> Int
    /// Interprétation NL (inc2). Phase 1 = `StubLeonIntentService` (⏳ honnête, pas de
    /// classification locale) ; phase 2 = service edge function `sage-coaching-ai`.
    private let intentService: LeonIntentService
    private let unmetLogger: LeonUnmetRequestLogger
    private let appVersion: String
    private let localeIdentifier: String

    // MARK: - Zone ① — Ta demande

    /// Sports de l'user (carrousel). `nil` selectedSport = état A (Léon attend).
    let activeSports: [SportCode]
    private(set) var selectedSport: SportCode?
    /// Champ libre. Capturé dans `freeTextNotes`, non interprété en inc1.
    var demandeText: String = ""

    // MARK: - Zone ② — Récap éditable (leviers réellement supportés par le moteur)

    /// Rythme = séances/semaine (Q3). Éditable 2/3/4 → recompose la proposition.
    private(set) var frequencyPerWeek: Int = 3

    // MARK: - Zone ② — Proposition (dérivée de l'aperçu généré)

    struct Proposal: Equatable {
        let sport: SportCode
        let weekCount: Int
        let frequencyPerWeek: Int
    }
    private(set) var proposal: Proposal?
    private(set) var isGenerating: Bool = false
    private(set) var generationFailed: Bool = false

    // MARK: - Zone ③ — Fil de conversation (relances)

    struct FilMessage: Identifiable, Equatable {
        enum Sender: Equatable { case user, leon }
        let id = UUID()
        let sender: Sender
        let text: String
    }
    private(set) var conversation: [FilMessage] = []

    // MARK: - Init

    init(
        userId: UUID,
        activeSports: [SportCode],
        requiresMedicalClearance: Bool,
        autoprofileLevel: String?,
        generatePreview: @escaping (CoachingSportProfile) async throws -> Int,
        intentService: LeonIntentService = StubLeonIntentService(),
        unmetLogger: LeonUnmetRequestLogger = NoopLeonUnmetRequestLogger(),
        appVersion: String = Bundle.main.shortVersion,
        localeIdentifier: String = Locale.current.identifier
    ) {
        self.userId = userId
        self.activeSports = activeSports
        self.requiresMedicalClearance = requiresMedicalClearance
        self.autoprofileLevel = autoprofileLevel
        self.generatePreview = generatePreview
        self.intentService = intentService
        self.unmetLogger = unmetLogger
        self.appVersion = appVersion
        self.localeIdentifier = localeIdentifier
    }

    // MARK: - Dérivés UI

    var canCreate: Bool { proposal != nil }

    /// Choix de rythme proposés dans le récap éditable.
    static let frequencyChoices: [Int] = [2, 3, 4]

    private var frequencyLabel: String {
        switch frequencyPerWeek {
        case 4...: return "4_or_more"
        default:   return String(frequencyPerWeek)
        }
    }

    /// Demande déjà soumise au fil (le champ est vidé à la soumission). Sert de note
    /// persistée (`freeTextNotes`) même après vidage du champ.
    private var capturedNote: String?

    private var trimmedNotes: String? {
        let raw = capturedNote ?? demandeText
        let t = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { return nil }
        // CHECK SQL freeTextNotes ≤ 200 chars (cf. CoachingSportProfile).
        return String(t.prefix(200))
    }

    // MARK: - Actions zone ①

    /// Tap d'un sport dans le carrousel → amorce la proposition (garde-fou page
    /// blanche : taper un sport suffit, le texte libre reste optionnel).
    func selectSport(_ sport: SportCode) {
        selectedSport = sport
        frequencyPerWeek = 3 // défaut sain à chaque (re)sélection
        Task { await regenerate() }
    }

    // MARK: - Actions zone ② (aperçu vivant)

    func setFrequency(_ value: Int) {
        guard value != frequencyPerWeek else { return }
        frequencyPerWeek = value
        Task { await regenerate() }
    }

    // MARK: - Actions zone ③ (conversation — inc1 : capté + réponse d'attente)

    /// Soumission de la demande libre (zone ①) → interprétation NL. Vide le champ et
    /// garde le texte comme note. MDR : c'est l'endroit le plus naturel pour exprimer
    /// une blessure → il DOIT passer par le routage ✓/⏳/🚫 (jamais juste « noté »).
    func submitDemande() {
        let text = demandeText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        capturedNote = text
        demandeText = ""
        enqueueUserMessage(text)
    }

    /// Envoi d'une relance dans le fil → passe par le service d'intention (inc2).
    func sendFollowUp(_ raw: String) {
        let text = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        enqueueUserMessage(text)
    }

    /// Ajoute la bulle user (sync) puis lance l'interprétation (async) : restitution
    /// de Léon + recomposition si supporté + log backlog si hors périmètre.
    private func enqueueUserMessage(_ text: String) {
        conversation.append(FilMessage(sender: .user, text: text))
        Task { await processIntent(text: text) }
    }

    /// Clé i18n de la réponse d'attente de Léon (repli si le service échoue ;
    /// = restitution du `StubLeonIntentService` en phase 1).
    static let holdingReplyKey = "programme.fil.leon.holding"

    /// Interprète une demande/relance et applique le résultat au fil (restitution,
    /// recomposition si supporté, log backlog si hors périmètre). Une demande peut
    /// produire plusieurs intentions (ex. « vélo + course + perdre 5 kg »).
    private func processIntent(text: String) async {
        let request = LeonIntentRequest(
            text: text,
            activeSports: activeSports.map(\.rawValue),
            selectedSport: selectedSport?.rawValue,
            locale: localeIdentifier
        )
        let response: LeonIntentResponse
        do {
            response = try await intentService.interpret(request)
        } catch {
            // Dégradation propre : Léon reste poli, le fil reste utilisable au carrousel.
            conversation.append(FilMessage(sender: .leon, text: Self.holdingReplyKey))
            return
        }
        for intent in response.intents {
            conversation.append(FilMessage(sender: .leon, text: intent.restitution))
            switch intent.route {
            case .supported:
                await applySlots(intent.slots)
            case .notYet, .refusedSafety:
                await unmetLogger.log(
                    LeonUnmetRequest(
                        category: intent.category ?? .unknown,
                        response: intent.route == .refusedSafety ? .refusedSafety : .notYet,
                        locale: localeIdentifier,
                        appVersion: appVersion
                    )
                )
            }
        }
    }

    /// Applique les slots compris (sport / rythme) → recompose la proposition (aperçu vivant).
    private func applySlots(_ slots: LeonIntentSlots?) async {
        guard let slots else { return }
        if let first = slots.sportCodes?.first, let sport = SportCode(rawValue: first) {
            selectedSport = sport
        }
        if let freq = slots.frequencyPerWeek {
            frequencyPerWeek = freq
        }
        await regenerate()
    }

    // MARK: - Génération de l'aperçu (preview, sans persistance)

    func regenerate() async {
        guard let sport = selectedSport else { return }
        isGenerating = true
        generationFailed = false
        defer { isGenerating = false }
        do {
            let profile = makeSportProfile(sport: sport)
            let weekCount = try await generatePreview(profile)
            proposal = Proposal(
                sport: sport,
                weekCount: weekCount,
                frequencyPerWeek: frequencyPerWeek
            )
        } catch {
            proposal = nil
            generationFailed = true
        }
    }

    // MARK: - Finalisation (rendue à SessionView.onCompleted)

    /// `CoachingSportProfile` finalisé à committer par `SessionView` (réutilise
    /// `presentAdaptedProgram(for:)`). `nil` si aucun sport choisi.
    func finalizedSportProfile() -> CoachingSportProfile? {
        guard let sport = selectedSport else { return nil }
        return makeSportProfile(sport: sport)
    }

    // MARK: - Construction du profil

    private func makeSportProfile(sport: SportCode) -> CoachingSportProfile {
        CoachingSportProfile(
            userId: userId,
            sportCode: sport.rawValue,
            level: autoprofileLevel ?? "recreational",
            goals: GoalsPayload(primary: UniversalQuestionnaire.defaultGoal(for: sport.rawValue)),
            equipment: [],
            constraints: [],
            frequencyPerWeek: frequencyPerWeek,
            frequencyLabel: frequencyLabel,
            sessionDurationMinutes: nil,
            freeTextNotes: trimmedNotes,
            conversationHistory: [],
            medicalClearanceAcknowledged: requiresMedicalClearance,
            questionnaireVersion: "fil_v1",
            durationMode: .routineCyclic,
            targetDate: nil
        )
    }
}

private extension Bundle {
    var shortVersion: String {
        (infoDictionary?["CFBundleShortVersionString"] as? String) ?? "0"
    }
}
