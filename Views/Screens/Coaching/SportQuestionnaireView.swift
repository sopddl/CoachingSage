// Views/Screens/Coaching/SportQuestionnaireView.swift
// Story 3.1 — écran principal du flow questionnaire chat.
// Présenté en sheet plein écran depuis SessionView (review AC1).
// VStack (PAS LazyVStack — review P1-4) + scrollDismissesKeyboard pour Q6 (review P1-12).
import SwiftUI

struct SportQuestionnaireView: View {
    @State var viewModel: SportQuestionnaireViewModel
    let requiresMedicalClearance: Bool
    let healthKitService: any HealthKitServiceProtocol
    let onCompleted: (CoachingSportProfile) -> Void

    private let inference: AutoProfileInference = AutoProfileInference()

    @Environment(\.dismiss) private var dismiss
    @State private var showExitConfirm: Bool = false
    @State private var autoProfileLoadState: AutoProfileLoadState = .loading
    @State private var hasStartedFlow: Bool = false

    private enum AutoProfileLoadState: Equatable {
        case loading
        case suggested(AutoProfileSuggestion)
        case unavailable // pas de signal HK exploitable → fallback standard
    }

    var body: some View {
        NavigationStack {
            content
            .background(Color.coachingBackground.ignoresSafeArea())
            .navigationTitle(Text("questionnaire.title"))
            .tint(Color.coachingPrimary)  // Sophie 2026-05-11 : sans tint, les boutons confirmationDialog/alert prennent le bleu système iOS hors palette CoachingSage
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showExitConfirm = true
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(Color.coachingTextPrimary)
                    }
                }
                // **Story 3.16 (Sophie 2026-05-21)** — retour à la question
                // précédente. Visible uniquement quand `canGoBack` (≥ 1 réponse
                // déjà donnée + pas en cours d'avancement).
                if viewModel.canGoBack {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            viewModel.goBack()
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "arrow.uturn.backward")
                                Text("questionnaire.back")
                            }
                            .foregroundStyle(Color.coachingPrimary)
                        }
                        .accessibilityIdentifier("questionnaire.back")
                    }
                }
            }
            .confirmationDialog(
                Text("questionnaire.exit.confirm.title"),
                isPresented: $showExitConfirm,
                titleVisibility: .visible
            ) {
                Button(role: .destructive) {
                    dismiss()
                } label: {
                    Text("questionnaire.exit.confirm.action")
                }
                Button(role: .cancel) {} label: {
                    Text("questionnaire.exit.cancel")
                }
            } message: {
                Text("questionnaire.exit.confirm.message")
            }
            .alert(
                Text("questionnaire.recovery.prompt"),
                isPresented: $viewModel.showRecoveryPrompt
            ) {
                Button {
                    viewModel.resumeFromDraft()
                } label: {
                    Text("questionnaire.recovery.resume")
                }
                Button(role: .destructive) {
                    viewModel.discardDraftAndStart()
                } label: {
                    Text("questionnaire.recovery.restart")
                }
            }
            .task {
                guard autoProfileLoadState == .loading else { return }
                let summary = await healthKitService.fetchWorkoutSummary()
                let vo2 = await healthKitService.fetchVO2MaxRecent()
                if let suggestion = inference.suggest(
                    vo2Max: vo2?.value,
                    workoutSummary: summary,
                    sportCode: viewModel.questionnaire.sportCode
                ) {
                    autoProfileLoadState = .suggested(suggestion)
                } else {
                    autoProfileLoadState = .unavailable
                    if !hasStartedFlow, viewModel.messages.isEmpty {
                        hasStartedFlow = true
                        viewModel.start(requiresMedicalClearance: requiresMedicalClearance)
                    }
                }
            }
            .onChange(of: isCompleted) { _, newValue in
                if newValue, case .success(let profile) = viewModel.state {
                    onCompleted(profile)
                    dismiss()
                }
            }
        }
    }

    // MARK: - Sub-views (split pour aider le type-checker SwiftUI)

    @ViewBuilder
    private var content: some View {
        switch autoProfileLoadState {
        case .loading:
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .suggested(let suggestion) where !hasStartedFlow:
            AutoProfileReviewView(
                suggestion: suggestion,
                onContinue: { level, frequency in
                    hasStartedFlow = true
                    viewModel.startWithAutoProfile(
                        level: level,
                        frequency: frequency,
                        requiresMedicalClearance: requiresMedicalClearance
                    )
                },
                onSkip: {
                    hasStartedFlow = true
                    viewModel.start(requiresMedicalClearance: requiresMedicalClearance)
                }
            )
        case .suggested, .unavailable:
            mainContent
        }
    }

    @ViewBuilder
    private var mainContent: some View {
        VStack(spacing: 0) {
            chatScroll
            errorSection
            // Sépare visuellement la zone chat (historique + question) de la zone options.
            // Sans ce divider, la dernière bulle de question se confond avec les bulles précédentes
            // et l'user perd le contexte de la question courante (Sophie 2026-05-03).
            if viewModel.currentQuestion != nil {
                Divider()
            }
            optionsSection
        }
    }

    @ViewBuilder
    private var chatScroll: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(viewModel.messages) { message in
                        bubble(for: message)
                            .id(message.id)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 24)
            }
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: viewModel.messages.count) { _, _ in
                withAnimation(.easeOut(duration: 0.2)) {
                    proxy.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                }
            }
        }
    }

    @ViewBuilder
    private var errorSection: some View {
        if case .error(let err) = viewModel.state {
            errorBanner(message: err.localizedDescription)
        }
    }

    @ViewBuilder
    private var optionsSection: some View {
        if let q = viewModel.currentQuestion {
            QuestionAnswerOptionsView(
                question: q,
                onAnswer: { value in
                    Task { await viewModel.answer(value) }
                },
                freeTextDraft: $viewModel.freeTextDraft,
                isLocked: viewModel.isAdvancing || isLoadingState,
                sportCode: viewModel.questionnaire.sportCode
            )
        } else if isLoadingState {
            ProgressView()
                .padding(.vertical, 24)
        }
    }

    private var isLoadingState: Bool {
        if case .loading = viewModel.state { return true }
        return false
    }

    /// Bool Equatable pour `.onChange` (ViewState SageCore 1.3 n'est pas Equatable).
    private var isCompleted: Bool {
        if case .success = viewModel.state { return true }
        return false
    }

    @ViewBuilder
    private func bubble(for message: ChatMessage) -> some View {
        let sportCode = viewModel.questionnaire.sportCode
        switch message {
        case .leonText(_, let key):
            ChatBubbleView(sender: .leon, textRaw: key, avatarStyle: .sport(code: sportCode))
        case .userText(_, let questionId, let text):
            // Story 3.30 — "remonter le fil" : tap sur une réponse passée → rouvre la question.
            // Désactivé pendant un avancement (typing) pour éviter une édition concurrente.
            ChatBubbleView(
                sender: .user,
                textRaw: text,
                onEdit: viewModel.isAdvancing ? nil : { viewModel.beginEditing(questionId: questionId) }
            )
        case .typingIndicator:
            HStack(alignment: .top, spacing: 8) {
                SportAvatarView(sportCode: sportCode, size: 32)
                TypingIndicatorView()
                Spacer(minLength: 40)
            }
        }
    }

    @ViewBuilder
    private func errorBanner(message: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.white)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            Button {
                Task { await viewModel.retrySubmit() }
            } label: {
                Text("questionnaire.error.save.retry")
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color.coachingError)
    }
}
