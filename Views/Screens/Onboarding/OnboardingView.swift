// Views/Screens/Onboarding/OnboardingView.swift
// Story 2.2 — conteneur 4 écrans + indicateur de progression.
import SwiftUI

struct OnboardingView: View {
    @Bindable var viewModel: OnboardingViewModel
    let onCompleted: () -> Void

    var body: some View {
        ZStack {
            Color.coachingBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                ProgressIndicator(currentIndex: viewModel.currentScreen.rawValue, total: OnboardingScreen.allCases.count)
                    .padding(.top, 16)
                    .padding(.horizontal, 24)

                Group {
                    switch viewModel.currentScreen {
                    case .firstNameLanguage:
                        FirstNameLanguageView(viewModel: viewModel)
                    case .personalData:
                        PersonalDataView(viewModel: viewModel)
                    case .sportsSelection:
                        SportsSelectionView(viewModel: viewModel)
                    case .equipment:
                        EquipmentSelectionView(viewModel: viewModel)
                    case .disclaimerPARQ:
                        DisclaimerPARQView(viewModel: viewModel)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: viewModel.currentScreen)
        .onChange(of: viewModel.isOnboardingFinalized) { _, finalized in
            if finalized { onCompleted() }
        }
    }
}

private struct ProgressIndicator: View {
    let currentIndex: Int
    let total: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<total, id: \.self) { idx in
                Capsule()
                    .fill(idx <= currentIndex ? Color.coachingPrimary : Color.coachingDisabled.opacity(0.4))
                    .frame(height: 4)
            }
        }
        .accessibilityIdentifier("onboarding.progress")
        .accessibilityLabel(Text("onboarding.progress.label"))
        .accessibilityValue(Text(verbatim: "\(currentIndex + 1)/\(total)"))
    }
}
