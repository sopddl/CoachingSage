// Views/Screens/Onboarding/WelcomeFilView.swift
// Onboarding app « fil de Léon » — écran ① : un seul fil qui défile.
// Léon t'accueille → prénom · Léon demande tes sports → grille multi-sélection · bloc accord.
// Un seul CTA vert « C'est parti » (actif dès prénom + ≥ 1 sport). Pas de barre d'étapes.
import SwiftUI
import SageCore

struct WelcomeFilView: View {
    @Bindable var viewModel: OnboardingViewModel
    @Environment(\.languageManager) private var languageManager
    @FocusState private var nameFocused: Bool
    @State private var showHIITTooltip: Bool = false

    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {

                // Header : titre « Bienvenue » + pastille langue (pas de barre d'étapes).
                HStack(alignment: .firstTextBaseline) {
                    Text("onboarding.welcome.title")
                        .font(.coachingDisplay)
                        .foregroundStyle(Color.coachingTextPrimary)
                    Spacer()
                    LanguageSelectorView(languageManager: languageManager)
                }
                .padding(.top, 8)

                // ① Léon + prénom
                OnboardingLeonBubble("onboarding.fil.greeting")
                TextField("onboarding.firstName.placeholder", text: $viewModel.firstName)
                    .textContentType(.givenName)
                    .textInputAutocapitalization(.words)
                    .submitLabel(.done)
                    .focused($nameFocused)
                    .padding(12)
                    .background(Color.coachingCard, in: RoundedRectangle(cornerRadius: CoachingRadius.md))
                    .accessibilityIdentifier("onboarding.firstName.field")

                // ② Léon demande les sports (+ bille « tu pourras changer ») + grille
                OnboardingLeonBubble(verbatim: sportsPrompt)
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(SportCode.allCases, id: \.self) { sport in
                        SportTileView(
                            sport: sport,
                            isSelected: viewModel.activeSports.contains(sport.rawValue),
                            onTap: { toggle(sport) },
                            onShowTooltip: { showHIITTooltip = true },
                            identifierPrefix: "onboarding.sport"
                        )
                    }
                }

                // ③ Accord données (bloc compact inline)
                consentBlock

                Spacer(minLength: 16)
            }
            .padding(.horizontal, 24)
        }
        .alert(
            "onboarding.sport.hiit.tooltip.title",
            isPresented: $showHIITTooltip
        ) {
            Button("common.ok", role: .cancel) {}
        } message: {
            Text("onboarding.sport.hiit.tooltip.body")
        }
        .safeAreaInset(edge: .bottom) {
            Button(action: { viewModel.goNext() }) {
                Text("onboarding.fil.cta")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(AccentButtonStyle())
            .disabled(!viewModel.canStart)
            .opacity(viewModel.canStart ? 1 : 0.45)
            .padding(.horizontal, 24)
            .padding(.top, 8)
            .padding(.bottom, 16)
            .background(Color.coachingBackground.ignoresSafeArea(edges: .bottom))
            .accessibilityIdentifier("onboarding.start.button")
        }
        .onAppear {
            // Sync langue active du LanguageManager → ViewModel pour persistence dans core_profiles.
            viewModel.language = languageManager.currentLanguage.rawValue
        }
        .task {
            await viewModel.prefillFromExistingProfile()
            if viewModel.firstName.isEmpty {
                nameFocused = true
            }
        }
        .onChange(of: languageManager.currentLanguage) { _, newLang in
            viewModel.language = newLang.rawValue
        }
    }

    // MARK: - Bloc accord

    @ViewBuilder
    private var consentBlock: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "lock.fill")
                    .foregroundStyle(Color.coachingPrimary)
                Text("onboarding.fil.consent.text")
                    .font(.coachingCaption)
                    .foregroundStyle(Color.coachingTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 0)
            }

            if viewModel.showHealthAuthorizeButton {
                Button(action: { Task { await viewModel.authorizeHealthData() } }) {
                    Text("onboarding.fil.consent.authorize")
                        .font(.coachingBody)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.coachingOnPrimary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 9)
                        .background(Color.coachingPrimary, in: RoundedRectangle(cornerRadius: CoachingRadius.md))
                }
                .accessibilityIdentifier("onboarding.consent.authorize")
            } else if viewModel.isHealthDataAvailable {
                Label("onboarding.fil.consent.authorized", systemImage: "checkmark.circle.fill")
                    .font(.coachingBody)
                    .foregroundStyle(Color.coachingSuccess)
                    .accessibilityIdentifier("onboarding.consent.authorized")
            }

            Divider()

            // Consentement analytics — finalité RGPD distincte, non pré-coché.
            Toggle(isOn: $viewModel.analyticsConsent) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("onboarding.analytics.toggle.label")
                        .font(.coachingBody)
                        .foregroundStyle(Color.coachingTextPrimary)
                    Text("onboarding.analytics.toggle.helper")
                        .font(.coachingCaption)
                        .foregroundStyle(Color.coachingTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .tint(Color.coachingPrimary)
            .accessibilityIdentifier("onboarding.analytics.toggle")
        }
        .padding(14)
        .background(Color.coachingCard, in: RoundedRectangle(cornerRadius: CoachingRadius.md))
    }

    // MARK: - Helpers

    /// Bulle ② : personnalisée avec le prénom dès qu'il est saisi, neutre sinon.
    private var sportsPrompt: String {
        let name = viewModel.firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        if name.isEmpty {
            return String(localized: "onboarding.fil.sports.prompt.noname")
        }
        return String(format: String(localized: "onboarding.fil.sports.prompt"), name)
    }

    private func toggle(_ sport: SportCode) {
        if viewModel.activeSports.contains(sport.rawValue) {
            viewModel.activeSports.remove(sport.rawValue)
        } else {
            viewModel.activeSports.insert(sport.rawValue)
        }
    }
}
