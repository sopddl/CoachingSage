// Views/Screens/Onboarding/OnboardingView.swift
// Onboarding app « fil de Léon » — conteneur 3 étapes (fil · PARQ · clôture).
// Header = ‹ retour seul (titre porté par chaque écran), PAS de barre d'étapes (template figé).
import SwiftUI

struct OnboardingView: View {
    @Bindable var viewModel: OnboardingViewModel
    let onCompleted: () -> Void

    var body: some View {
        ZStack {
            Color.coachingBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    if viewModel.canGoPrevious {
                        Button {
                            viewModel.goPrevious()
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                Text("common.back")
                            }
                            .font(.subheadline)
                            .foregroundStyle(Color.coachingPrimary)
                        }
                        .accessibilityIdentifier("onboarding.back")
                    }
                    Spacer()
                }
                .frame(height: 24)
                .padding(.top, 8)
                .padding(.horizontal, 24)

                Group {
                    switch viewModel.currentScreen {
                    case .welcome:
                        WelcomeFilView(viewModel: viewModel)
                    case .parq:
                        DisclaimerPARQView(viewModel: viewModel)
                    case .closing:
                        ClosingView(viewModel: viewModel, onCompleted: onCompleted)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: viewModel.currentScreen)
    }
}
