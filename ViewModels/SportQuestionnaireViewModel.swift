// ViewModels/SportQuestionnaireViewModel.swift
// Story 3.1 — orchestre le flow conversationnel chat (intro Léon → questions → save).
// 100% local jusqu'au save final (UPSERT Supabase via repo).
//
// Garde-fous critiques (review pré-implem 2026-04-29) :
//   - Cross-user race au submit (P0-4) : capture currentUserId au start, re-vérifie après chaque await.
//   - Idempotence double-tap option (P1-8) : isAdvancing guard.
//   - Recovery si dismiss accidentel (P1-6) : snapshot des réponses + freeTextDraft dans UserDefaults
//     à chaque progression. Purge au save success.
//   - Mots bannis EU MDR (P0-5) : la formulation des questions est dans Localizable.xcstrings, validée Task 9.
//   - Honorer requires_medical_clearance (P0-6) : bulle conditionnelle injectée au start si flag true.
//
import Foundation
import os
import SageCore

@MainActor
@Observable
final class SportQuestionnaireViewModel {

    // MARK: - Dependencies

    private static let logger = Logger(subsystem: "com.sopddl.coachingsage", category: "questionnaire")

    private(set) var questionnaire: SportQuestionnaire
    private let repository: any CoachingSportProfileRepository
    private let authService: any AuthServiceProtocol
    private let typingDelay: TypingDelayProvider

    // MARK: - State observable

    /// Bulles affichées dans le ScrollView (review P1-7 : enum typé, typing inline).
    var messages: [ChatMessage] = []

    /// Question actuellement présentée (nil = pas démarré OU finalisé).
    var currentQuestion: QuestionnaireQuestion?

    /// Réponses validées des questions précédentes.
    var accumulatedAnswers: [QuestionId: AnswerValue] = [:]

    /// Historique conversationnel pour `conversation_history_json` (audit + Léon Story 3.3).
    var conversationHistory: [ConversationEntry] = []

    /// Brouillon Q6 (texte libre). Sauvegardé dans UserDefaults pour recovery (review P1-6).
    var freeTextDraft: String = ""

    /// État global du flow.
    var state: ViewState<CoachingSportProfile> = .idle

    /// Recovery prompt à afficher au start si pendingDraft trouvé (review P1-6).
    var showRecoveryPrompt: Bool = false

    // MARK: - State internal

    /// Idempotence : empêche le double-tap option de sauter une question (review P1-8).
    private(set) var isAdvancing: Bool = false

    /// **Story 3.30** — true entre `beginEditing()` et le tap de re-réponse. Aiguille
    /// `answer()` vers le commit d'édition (rejoue le fil en aval) au lieu du forward incrémental.
    private(set) var isEditingInPlace: Bool = false

    /// **Story 3.30** — true si le flow a démarré en autoprofil HK (reconstruit la bulle résumé
    /// au `rebuildFromAnswers`). Set par `startPreFilledFlow` / dérivé au resume.
    private var isAutoProfileFlow: Bool = false

    /// **Story 3.30** — ids des questions pré-remplies autoprofil (flag `autoFilled` au rebuild).
    private var autoFilledIds: Set<QuestionId> = []

    /// **Story 3.16 (Sophie 2026-05-21)** — stack des questions déjà répondues
    /// (FIFO, dernière pushée = question pop par `goBack()`). Maintenu en
    /// parallèle de `conversationHistory` pour pouvoir restaurer le
    /// `currentQuestion` lors d'un retour arrière sans avoir à dépendre de la
    /// logique de navigation forward (`nextQuestion(after:)`).
    private(set) var questionHistory: [QuestionnaireQuestion] = []

    /// Capture du userId au start pour détecter cross-user race (review P0-4).
    private var capturedUserId: UUID?

    /// Indique si la bulle medical clearance a été affichée (pour AC8 / review P0-6).
    private var medicalClearanceAcknowledgedSnapshot: Bool = false

    /// Mesure perf flow complet (review P2-5).
    private var flowStartedAt: Date?

    /// Pending draft à proposer au start s'il existe.
    private var pendingDraftToOffer: PendingDraft?

    // MARK: - Init

    init(
        questionnaire: SportQuestionnaire,
        repository: any CoachingSportProfileRepository,
        authService: any AuthServiceProtocol,
        typingDelay: TypingDelayProvider = RandomTypingDelay()
    ) {
        self.questionnaire = questionnaire
        self.repository = repository
        self.authService = authService
        self.typingDelay = typingDelay
    }

    // MARK: - Public API

    /// Densité B (2026-07-02) — active la question de calibrage activité (QActivity,
    /// posée après Q1 si niveau beginner/recreational). À appeler AVANT `start()` /
    /// `startWithAutoProfile()`, dès que la View sait si le signal HK est disponible
    /// (`fetchWorkoutSummary` du `.task` autoprofil). No-op si le flow n'utilise pas
    /// `UniversalQuestionnaire` ou si le flag ne change pas.
    func setAskActivityCalibration(_ ask: Bool) {
        guard let universal = questionnaire as? UniversalQuestionnaire,
              universal.askActivityCalibration != ask else { return }
        questionnaire = UniversalQuestionnaire(
            sportCode: universal.sportCode,
            askActivityCalibration: ask
        )
    }

    /// Lance le flow ou propose recovery si un brouillon existe.
    /// `requiresMedicalClearance` = snapshot du flag coachingProfile au moment de l'ouverture (review P0-6).
    func start(requiresMedicalClearance: Bool) {
        flowStartedAt = Date()
        capturedUserId = currentAuthUserId()
        medicalClearanceAcknowledgedSnapshot = requiresMedicalClearance

        // Vérifier brouillon en attente pour ce (user × sport).
        if let draft = loadPendingDraft() {
            pendingDraftToOffer = draft
            showRecoveryPrompt = true
            // L'écran présentera le prompt Reprendre/Recommencer ; les méthodes resumeFromDraft / discardDraftAndStart
            // poursuivront en conséquence.
            return
        }

        startFreshFlow()
    }

    /// Variante autoprofil HealthKit : démarre en pré-remplissant Q1 (level) et Q3 (frequency)
    /// depuis les valeurs validées par l'utilisateur dans `AutoProfileReviewView`.
    /// Toujours soumis à la même recovery logic — un brouillon en attente prime.
    func startWithAutoProfile(
        level: LevelEstimate,
        frequency: FrequencyEstimate,
        requiresMedicalClearance: Bool
    ) {
        flowStartedAt = Date()
        capturedUserId = currentAuthUserId()
        medicalClearanceAcknowledgedSnapshot = requiresMedicalClearance

        if let draft = loadPendingDraft() {
            pendingDraftToOffer = draft
            showRecoveryPrompt = true
            return
        }

        startPreFilledFlow(level: level, frequency: frequency)
    }

    /// Choisi par l'user au prompt recovery → restaure les réponses + currentQuestion.
    func resumeFromDraft() {
        guard let draft = pendingDraftToOffer else {
            startFreshFlow()
            return
        }
        accumulatedAnswers = draft.answers
        conversationHistory = draft.history
        freeTextDraft = draft.freeText ?? ""
        // **Story 3.30** — restaurer le contexte autoprofil pour que l'édition post-resume reste cohérente.
        autoFilledIds = Set(draft.history.filter { $0.autoFilled == true }.map { $0.questionId })
        isAutoProfileFlow = !autoFilledIds.isEmpty
        isEditingInPlace = false

        // Re-construire les bulles affichées à partir de l'historique pour donner du contexte visuel.
        messages = []
        appendIntroBubbles()
        for entry in conversationHistory where !entry.skipped {
            if let key = entry.questionTextKey {
                messages.append(.leonText(id: UUID(), key: key))
            }
            if let answer = entry.answer {
                let q = questionnaire.findQuestion(byId: entry.questionId)
                messages.append(.userText(id: UUID(), questionId: entry.questionId, text: userBubbleText(for: AnswerValue(dto: answer), in: q)))
            }
        }

        // Reprendre à la prochaine question non répondue.
        if let currentId = draft.currentQuestionId,
           let q = questionnaire.findQuestion(byId: currentId) {
            currentQuestion = q
        } else {
            currentQuestion = questionnaire.firstQuestion
        }

        showRecoveryPrompt = false
        pendingDraftToOffer = nil
    }

    /// Choisi par l'user au prompt recovery → purge le brouillon + start fresh.
    func discardDraftAndStart() {
        purgePendingDraft()
        pendingDraftToOffer = nil
        showRecoveryPrompt = false
        startFreshFlow()
    }

    /// Tap sur une option (single ou multi confirmé) ou validation Q6 freeText.
    func answer(_ value: AnswerValue) async {
        // Idempotence : ignore si déjà en cours d'avancement (review P1-8).
        guard !isAdvancing, let asked = currentQuestion else { return }
        isAdvancing = true
        defer { isAdvancing = false }

        // **Story 3.30** — commit d'une édition "remonter le fil" : pose la nouvelle réponse puis
        // rejoue le fil en aval (réutilise les réponses dormantes encore valides). Chemin séparé
        // du forward incrémental pour ne pas toucher l'autoprofil ni l'animation typing.
        if isEditingInPlace {
            isEditingInPlace = false
            accumulatedAnswers[asked.id] = value
            rebuildFromAnswers(editing: nil)
            savePendingDraft(currentQuestionId: currentQuestion?.id)
            if currentQuestion == nil {
                await submit()
            }
            return
        }

        // Bulle user
        messages.append(.userText(id: UUID(), questionId: asked.id, text: userBubbleText(for: value, in: asked)))

        // Stocker la réponse + push dans le stack history pour goBack() (Story 3.16)
        accumulatedAnswers[asked.id] = value
        questionHistory.append(asked)
        conversationHistory.append(
            ConversationEntry(
                questionId: asked.id,
                questionTextKey: asked.textKey,
                answer: value.asDTO,
                askedAt: Date()
            )
        )

        // Persister le brouillon à chaque progression (review P1-6).
        savePendingDraft(currentQuestionId: nil)

        // Question suivante. Avance par-dessus les questions déjà pré-remplies par l'autoprofil
        // (Story Autoprofil HealthKit) — leurs bulles user sont déjà dans `messages` depuis startPreFilledFlow.
        var next = questionnaire.nextQuestion(after: asked.id, answer: value, accumulated: accumulatedAnswers)
        while let candidate = next, let cachedValue = accumulatedAnswers[candidate.id] {
            next = questionnaire.nextQuestion(after: candidate.id, answer: cachedValue, accumulated: accumulatedAnswers)
        }

        currentQuestion = nil

        guard let nextQuestion = next else {
            // Fin du flow → submit
            await submit()
            return
        }

        // Typing indicator + bulle Léon + nouvelle question
        let typingId = UUID()
        messages.append(.typingIndicator(id: typingId))
        await typingDelay.wait()
        // Retirer le typing
        messages.removeAll { if case .typingIndicator(let id) = $0 { return id == typingId } else { return false } }
        messages.append(.leonText(id: UUID(), key: nextQuestion.textKey))
        currentQuestion = nextQuestion

        // Sauvegarder l'avancée (currentQuestionId pour reprise)
        savePendingDraft(currentQuestionId: nextQuestion.id)
    }

    /// **Story 3.16 (Sophie 2026-05-21)** — retour arrière depuis la question
    /// courante vers la précédente. Pop la dernière réponse (`accumulatedAnswers`
    /// + `conversationHistory` + `questionHistory`), pop les 2 derniers messages
    /// (la bubble Léon de la question actuelle + la bubble user de la dernière
    /// réponse), et restaure `currentQuestion` à celle d'avant.
    ///
    /// No-op si :
    ///   - `isAdvancing` (idempotence : pas de retour pendant typing indicator)
    ///   - `questionHistory.isEmpty` (1ère question, rien avant)
    ///
    /// La 1ère question reste atteignable mais le bouton retour est masqué côté
    /// View via `canGoBack`.
    func goBack() {
        guard !isAdvancing else { return }
        guard let previousQuestion = questionHistory.popLast() else { return }

        // Pop accumulatedAnswers + conversationHistory en parallèle
        accumulatedAnswers.removeValue(forKey: previousQuestion.id)
        if !conversationHistory.isEmpty {
            conversationHistory.removeLast()
        }

        // Pop les 2 derniers messages (bubble Léon question actuelle + bubble
        // user réponse de la question précédente). Garde-fou : on ne pop pas
        // un typing indicator si présent (rare, mais robust).
        var popped = 0
        while popped < 2, let last = messages.last {
            messages.removeLast()
            // Le typing indicator est déjà retiré par answer() avant le push
            // de la bulle Léon, donc on devrait toujours pop 2 messages
            // (user answer + Léon next). Mais filtre par sécurité.
            if case .typingIndicator = last { continue }
            popped += 1
        }

        currentQuestion = previousQuestion
        savePendingDraft(currentQuestionId: previousQuestion.id)
    }

    /// `true` quand `goBack()` peut être appelé (au moins 1 question répondue).
    var canGoBack: Bool {
        !questionHistory.isEmpty && !isAdvancing
    }

    // MARK: - Story 3.30 — Remonter le fil (édition directe)

    /// Tap sur une réponse passée dans le chat → rouvre cette question pour la modifier.
    /// S'appuie sur `accumulatedAnswers` + le parcours (PAS `questionHistory`, vide après
    /// autoprofil) → permet d'éditer aussi les réponses pré-remplies HK.
    /// No-op si avancement en cours, question inconnue, ou réponse absente.
    func beginEditing(questionId: QuestionId) {
        guard !isAdvancing else { return }
        guard accumulatedAnswers[questionId] != nil else { return }
        guard questionnaire.findQuestion(byId: questionId) != nil else { return }
        isEditingInPlace = true
        rebuildFromAnswers(editing: questionId)
        savePendingDraft(currentQuestionId: currentQuestion?.id)
    }

    /// Reconstruit le fil (messages + questionHistory + conversationHistory + currentQuestion) en
    /// marchant le parcours déterministe depuis `accumulatedAnswers` (source de vérité).
    /// - `editing` : si fourni, le walk s'arrête à cette question pour la ré-poser.
    /// - Aucune purge : les réponses hors-parcours restent dormantes dans `accumulatedAnswers`
    ///   (décision Sophie « garder ce qui reste valide » + réutilisation si la question revient).
    ///   `buildProfile` reste défensif (durationMode résolu via Q3 prioritaire) → dormantes inoffensives.
    private func rebuildFromAnswers(editing editingId: QuestionId?) {
        messages = []
        appendIntroBubbles()
        if isAutoProfileFlow {
            messages.append(.leonText(id: UUID(), key: "questionnaire.autoprofile.summary"))
        }

        var newHistory: [QuestionnaireQuestion] = []
        var newConvo: [ConversationEntry] = []
        var current: QuestionnaireQuestion? = questionnaire.firstQuestion
        let now = Date()
        while let q = current {
            if q.id == editingId { break }                       // stop pour ré-poser
            guard let value = accumulatedAnswers[q.id] else { break }  // 1re non répondue → on la pose
            messages.append(.leonText(id: UUID(), key: q.textKey))
            messages.append(.userText(id: UUID(), questionId: q.id, text: userBubbleText(for: value, in: q)))
            newHistory.append(q)
            newConvo.append(
                ConversationEntry(
                    questionId: q.id,
                    questionTextKey: q.textKey,
                    answer: value.asDTO,
                    askedAt: now,
                    autoFilled: autoFilledIds.contains(q.id) ? true : nil
                )
            )
            current = questionnaire.nextQuestion(after: q.id, answer: value, accumulated: accumulatedAnswers)
        }
        questionHistory = newHistory
        conversationHistory = newConvo

        if let q = current {
            messages.append(.leonText(id: UUID(), key: q.textKey))
            currentQuestion = q
        } else {
            currentQuestion = nil   // parcours complet → le commit déclenchera submit()
        }
    }

    // MARK: - Submit

    private func submit() async {
        // Cross-user race check (review P0-4)
        guard let captured = capturedUserId, captured == currentAuthUserId() else {
            state = .error(.sync(String(localized: "questionnaire.error.userChanged")))
            return
        }

        state = .loading

        let draft = questionnaire.buildProfile(
            userId: captured,
            answers: accumulatedAnswers,
            freeTextNotes: freeTextDraft.isEmpty ? nil : freeTextDraft,
            history: conversationHistory,
            medicalClearanceAcknowledged: medicalClearanceAcknowledgedSnapshot
        )

        do {
            try await repository.save(draft)

            // Re-vérifier après l'await (review P0-4)
            guard captured == currentAuthUserId() else {
                state = .error(.sync(String(localized: "questionnaire.error.userChanged")))
                return
            }

            purgePendingDraft()
            state = .success(draft)

            if let started = flowStartedAt {
                let duration = Date().timeIntervalSince(started)
                Self.logger.info("questionnaire_duration sport=\(self.questionnaire.sportCode) seconds=\(duration)")
            }
        } catch {
            Self.logger.error("Save CoachingSportProfile failed: \(error.localizedDescription)")
            state = .error(error as? AppError ?? .sync(error.localizedDescription))
        }
    }

    /// Réessayer le save après un échec (UI bouton "Réessayer").
    func retrySubmit() async {
        guard case .error = state else { return }
        await submit()
    }

    // MARK: - Helpers

    private func startFreshFlow() {
        accumulatedAnswers = [:]
        conversationHistory = []
        freeTextDraft = ""
        messages = []
        isAutoProfileFlow = false
        autoFilledIds = []
        isEditingInPlace = false
        purgePendingDraft()

        appendIntroBubbles()
        let first = questionnaire.firstQuestion
        messages.append(.leonText(id: UUID(), key: first.textKey))
        currentQuestion = first
        savePendingDraft(currentQuestionId: first.id)
    }

    /// Démarre le flow en pré-remplissant Q1 (level) et Q3 (frequency) depuis l'autoprofil HK.
    /// Q2 reste à demander à l'utilisateur (objectif sport — non inférable depuis HK).
    /// Q4+ continuent normalement à partir de Q2 répondu.
    private func startPreFilledFlow(level: LevelEstimate, frequency: FrequencyEstimate) {
        accumulatedAnswers = [:]
        conversationHistory = []
        freeTextDraft = ""
        messages = []
        isEditingInPlace = false
        isAutoProfileFlow = true
        autoFilledIds = [UniversalQuestionnaire.q1LevelId, UniversalQuestionnaire.q3FrequencyId]
        purgePendingDraft()

        appendIntroBubbles()
        // Bulle de transparence sur l'autoprofil.
        messages.append(.leonText(id: UUID(), key: "questionnaire.autoprofile.summary"))

        // Pré-remplir Q1 + Q3 — clés textKey/labelKey lookupées via le protocol pour rester
        // sport-agnostique (UniversalQuestionnaire pour les 10 sports).
        let q1Id = UniversalQuestionnaire.q1LevelId
        let q3Id = UniversalQuestionnaire.q3FrequencyId
        let q1Value = AnswerValue.single(level.rawValue)
        let q3Value = AnswerValue.single(frequency.rawValue)

        accumulatedAnswers[q1Id] = q1Value
        accumulatedAnswers[q3Id] = q3Value
        let now = Date()
        let q1Question = questionnaire.findQuestion(byId: q1Id)
        let q3Question = questionnaire.findQuestion(byId: q3Id)
        conversationHistory.append(ConversationEntry(
            questionId: q1Id,
            questionTextKey: q1Question?.textKey,
            answer: q1Value.asDTO,
            askedAt: now,
            autoFilled: true
        ))
        conversationHistory.append(ConversationEntry(
            questionId: q3Id,
            questionTextKey: q3Question?.textKey,
            answer: q3Value.asDTO,
            askedAt: now,
            autoFilled: true
        ))

        // Bulles user de confirmation — labelKey de l'option correspondante (résolue View).
        let q1Label = q1Question?.options.first(where: { $0.code == level.rawValue })?.labelKey ?? level.rawValue
        let q3Label = q3Question?.options.first(where: { $0.code == frequency.rawValue })?.labelKey ?? frequency.rawValue
        messages.append(.userText(id: UUID(), questionId: q1Id, text: q1Label))
        messages.append(.userText(id: UUID(), questionId: q3Id, text: q3Label))

        // Première question non-répondue = Q2 (goal).
        let next = firstUnansweredQuestion()
        if let q = next {
            messages.append(.leonText(id: UUID(), key: q.textKey))
            currentQuestion = q
            savePendingDraft(currentQuestionId: q.id)
        } else {
            // Cas extrême : tout est déjà rempli. submit() direct.
            currentQuestion = nil
            Task { await submit() }
        }
    }

    /// Walk le flow depuis la première question, en suivant `nextQuestion`, et retourne la 1re non-répondue.
    private func firstUnansweredQuestion() -> QuestionnaireQuestion? {
        var current: QuestionnaireQuestion? = questionnaire.firstQuestion
        while let q = current {
            if let value = accumulatedAnswers[q.id] {
                current = questionnaire.nextQuestion(after: q.id, answer: value, accumulated: accumulatedAnswers)
            } else {
                return q
            }
        }
        return nil
    }

    private func appendIntroBubbles() {
        // Intro universelle (10 sports utilisent UniversalQuestionnaire)
        messages.append(.leonText(id: UUID(), key: "questionnaire.universal.intro"))
        // Bulle medical clearance (review P0-6)
        if medicalClearanceAcknowledgedSnapshot {
            messages.append(.leonText(id: UUID(), key: "questionnaire.intro.medicalClearance"))
        }
    }

    private func currentAuthUserId() -> UUID? {
        authService.currentUserId
    }

    /// Texte de la bulle user à afficher (label localisé pour les options, texte brut pour freeText).
    /// La résolution `Text(LocalizedStringKey(...))` côté View transforme la clé en label si présent.
    /// **Story 3.30** — `question` explicite (au lieu de `currentQuestion`) pour résoudre les labels
    /// au rebuild / resume où la question répondue n'est pas la question courante.
    private func userBubbleText(for value: AnswerValue, in question: QuestionnaireQuestion?) -> String {
        switch value {
        case .single(let code):
            // Chercher l'option correspondante dans la question répondue
            if let q = question, let opt = q.options.first(where: { $0.code == code }) {
                return opt.labelKey
            }
            return code
        case .multi(let codes):
            // Concaténer les labelKey des options sélectionnées (séparées par "|").
            // La View résoudra chaque clé individuellement via une concaténation post-localisation.
            if let q = question {
                let labels = codes.compactMap { code in q.options.first(where: { $0.code == code })?.labelKey }
                return labels.joined(separator: "|")  // séparateur conventionnel à parser côté View
            }
            return codes.joined(separator: ", ")
        case .text(let s):
            return s ?? ""
        }
    }

    // MARK: - UserDefaults pending draft

    private var pendingKey: String {
        let userIdString = capturedUserId?.uuidString.lowercased() ?? "anon"
        return "pending_questionnaire_\(userIdString)_\(questionnaire.sportCode)"
    }

    private struct PendingDraft: Codable {
        let answers: [QuestionId: AnswerValue]
        let history: [ConversationEntry]
        let freeText: String?
        let currentQuestionId: QuestionId?
    }

    private func savePendingDraft(currentQuestionId: QuestionId?) {
        guard capturedUserId != nil else { return }
        let draft = PendingDraft(
            answers: accumulatedAnswers,
            history: conversationHistory,
            freeText: freeTextDraft.isEmpty ? nil : freeTextDraft,
            currentQuestionId: currentQuestionId
        )
        if let data = try? JSONEncoder().encode(draft) {
            UserDefaults.standard.set(data, forKey: pendingKey)
        }
    }

    private func loadPendingDraft() -> PendingDraft? {
        guard capturedUserId != nil,
              let data = UserDefaults.standard.data(forKey: pendingKey),
              let draft = try? JSONDecoder().decode(PendingDraft.self, from: data) else {
            return nil
        }
        return draft
    }

    private func purgePendingDraft() {
        UserDefaults.standard.removeObject(forKey: pendingKey)
    }
}

// MARK: - AnswerValue Codable (pour PendingDraft UserDefaults)

extension AnswerValue: Codable {
    private enum CodingKeys: String, CodingKey { case type, value }
    private enum Kind: String, Codable { case single, multi, text }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .single(let s):
            try c.encode(Kind.single, forKey: .type)
            try c.encode(s, forKey: .value)
        case .multi(let arr):
            try c.encode(Kind.multi, forKey: .type)
            try c.encode(arr, forKey: .value)
        case .text(let s):
            try c.encode(Kind.text, forKey: .type)
            try c.encodeIfPresent(s, forKey: .value)
        }
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try c.decode(Kind.self, forKey: .type)
        switch kind {
        case .single: self = .single(try c.decode(String.self, forKey: .value))
        case .multi: self = .multi(try c.decode([String].self, forKey: .value))
        case .text: self = .text(try c.decodeIfPresent(String.self, forKey: .value))
        }
    }
}

// MARK: - ChatMessage (review P1-7 : enum typé)

enum ChatMessage: Identifiable, Equatable {
    case leonText(id: UUID, key: String)                        // clé xcstrings (résolue View)
    case userText(id: UUID, questionId: QuestionId, text: String) // questionId = question répondue (Story 3.30 tap-to-edit) ; text = labelKey OU labelKey1|... pour multi
    case typingIndicator(id: UUID)

    var id: UUID {
        switch self {
        case .leonText(let id, _), .userText(let id, _, _), .typingIndicator(let id): return id
        }
    }
}

// MARK: - SportQuestionnaireError
// Note : utilisé seulement par les tests (qui veulent un type discriminé typé).
// Côté VM, on assigne directement state = .error(.sync(...)) car ViewState attend AppError.

enum SportQuestionnaireError: LocalizedError, Equatable {
    case userChanged
    case saveFailed

    var errorDescription: String? {
        switch self {
        case .userChanged: return String(localized: "questionnaire.error.userChanged")
        case .saveFailed: return String(localized: "questionnaire.error.save.title")
        }
    }
}
