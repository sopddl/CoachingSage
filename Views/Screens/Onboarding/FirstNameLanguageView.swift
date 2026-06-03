// Views/Screens/Onboarding/FirstNameLanguageView.swift
// Story 2.2 — écran 1 : prénom + langue.
// Sélecteur langue = Menu déroulant extensible (cohérent GardenSage/TailorSage).
import SwiftUI
import SageCore

struct FirstNameLanguageView: View {
    @Bindable var viewModel: OnboardingViewModel
    @Environment(\.languageManager) private var languageManager
    @FocusState private var nameFocused: Bool

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                HStack {
                    Text("onboarding.welcome.title")
                        .font(.coachingDisplay)
                        .foregroundStyle(Color.coachingTextPrimary)
                    Spacer()
                    LanguageSelectorView(languageManager: languageManager)
                }
                .padding(.top, 32)

                VStack(alignment: .leading, spacing: 8) {
                    Text("onboarding.firstName.label")
                        .font(.coachingCaption)
                        .foregroundStyle(Color.coachingTextSecondary)
                    TextField("onboarding.firstName.placeholder", text: $viewModel.firstName)
                        .textContentType(.givenName)
                        .textInputAutocapitalization(.words)
                        .submitLabel(.done)
                        .focused($nameFocused)
                        .padding(12)
                        .background(Color.coachingCard, in: RoundedRectangle(cornerRadius: CoachingRadius.md))
                        .accessibilityIdentifier("onboarding.firstName.field")
                }

                // Story 3.35c — appli musique préférée (ouverte depuis les
                // suggestions musique de la séance). Modifiable plus tard dans le profil.
                VStack(alignment: .leading, spacing: 8) {
                    Text("coaching.music.app.label")
                        .font(.coachingCaption)
                        .foregroundStyle(Color.coachingTextSecondary)
                    HStack {
                        MusicStreamingSelectorView()
                        Spacer()
                    }
                    .padding(.horizontal, 4)
                    .background(Color.coachingCard, in: RoundedRectangle(cornerRadius: CoachingRadius.md))
                }

                Spacer(minLength: 32)
            }
            .padding(.horizontal, 24)
        }
        .safeAreaInset(edge: .bottom) {
            Button(action: { viewModel.goNext() }) {
                Text("onboarding.continue")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(!viewModel.canContinueScreen1)
            .padding(.horizontal, 24)
            .padding(.top, 8)
            .padding(.bottom, 16)
            .background(Color.coachingBackground.ignoresSafeArea(edges: .bottom))
            .accessibilityIdentifier("onboarding.continue.button")
        }
        .onAppear {
            // Sync langue active du LanguageManager → ViewModel pour persistence dans core_profiles.
            viewModel.language = languageManager.currentLanguage.rawValue
        }
        .task {
            await viewModel.prefillFromExistingProfile()
            // Focus sur le field uniquement si rien n'est pré-rempli (sinon on évite le clavier intrusif).
            if viewModel.firstName.isEmpty {
                nameFocused = true
            }
        }
        .onChange(of: languageManager.currentLanguage) { _, newLang in
            viewModel.language = newLang.rawValue
        }
    }
}
