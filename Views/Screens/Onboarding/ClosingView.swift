// Views/Screens/Onboarding/ClosingView.swift
// Onboarding app « fil de Léon » — écran ③ : clôture.
// Léon te remercie, prépare l'onboarding programme (« appuie sur mon icône ») SANS le commencer
// (frontière C), pendant que la finalize Supabase tourne en arrière-plan. Le CTA vert « On y va »
// entre dans l'app dès que la sauvegarde a réussi. En cas d'erreur : message + « Réessayer ».
import SwiftUI

struct ClosingView: View {
    @Bindable var viewModel: OnboardingViewModel
    let onCompleted: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Spacer()

            OnboardingLeonBubble(verbatim: closingLine)
            // Pas de direction cardinale (« en bas à droite » banni : RTL / FAB mobile) — on
            // désigne l'icône, pas sa position.
            OnboardingLeonBubble("onboarding.closing.leon.2")

            if let errorMessage = viewModel.saveErrorMessage {
                Text(verbatim: errorMessage)
                    .font(.coachingCaption)
                    .foregroundStyle(Color.coachingError)
                    .accessibilityIdentifier("onboarding.save.error")
            }

            Spacer()
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .safeAreaInset(edge: .bottom) {
            bottomButton
                .padding(.horizontal, 24)
                .padding(.top, 8)
                .padding(.bottom, 16)
                .background(Color.coachingBackground.ignoresSafeArea(edges: .bottom))
        }
        .task {
            await viewModel.finalize()
        }
    }

    @ViewBuilder
    private var bottomButton: some View {
        if viewModel.saveErrorMessage != nil {
            Button(action: { Task { await viewModel.finalize() } }) {
                Text("common.retry")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(PrimaryButtonStyle())
            .accessibilityIdentifier("onboarding.closing.retry.button")
        } else {
            Button(action: { onCompleted() }) {
                HStack(spacing: 8) {
                    if viewModel.isSaving {
                        ProgressView().tint(Color.coachingOnAccent)
                    }
                    Text("onboarding.closing.cta")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(AccentButtonStyle())
            .disabled(!viewModel.isOnboardingFinalized)
            .opacity(viewModel.isOnboardingFinalized ? 1 : 0.45)
            .accessibilityIdentifier("onboarding.closing.start.button")
        }
    }

    /// Bulle de clôture personnalisée avec le prénom, neutre sinon.
    private var closingLine: String {
        let name = viewModel.firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        if name.isEmpty {
            return String(localized: "onboarding.closing.leon.1.noname")
        }
        return String(format: String(localized: "onboarding.closing.leon.1"), name)
    }
}
