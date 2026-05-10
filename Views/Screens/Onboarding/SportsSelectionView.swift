// Views/Screens/Onboarding/SportsSelectionView.swift
// Story 2.2 — écran 3 : grille 10 sports + tooltip HIIT.
import SwiftUI

struct SportsSelectionView: View {
    @Bindable var viewModel: OnboardingViewModel
    @State private var showHIITTooltip: Bool = false

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("onboarding.sports.title")
                    .font(.coachingDisplay)
                    .foregroundStyle(Color.coachingTextPrimary)
                    .padding(.top, 16)

                Text("onboarding.sports.helper")
                    .font(.coachingBody)
                    .foregroundStyle(Color.coachingTextSecondary)

                LazyVGrid(columns: columns, spacing: 12) {
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
                .padding(.top, 8)

                Spacer(minLength: 32)
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
                Text("onboarding.continue")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(!viewModel.canContinueScreen3)
            .padding(.horizontal, 24)
            .padding(.top, 8)
            .padding(.bottom, 16)
            .background(Color.coachingBackground.ignoresSafeArea(edges: .bottom))
            .accessibilityIdentifier("onboarding.continue.button")
        }
    }

    private func toggle(_ sport: SportCode) {
        if viewModel.activeSports.contains(sport.rawValue) {
            viewModel.activeSports.remove(sport.rawValue)
        } else {
            viewModel.activeSports.insert(sport.rawValue)
        }
    }
}

// SportCell privée supprimée — refactor en `SportTileView` partagé
// (Views/Components/SportTileView.swift), réutilisé par onboarding,
// modif profil et sport picker création programme.
