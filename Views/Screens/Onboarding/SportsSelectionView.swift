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
                        SportCell(
                            sport: sport,
                            isSelected: viewModel.activeSports.contains(sport.rawValue),
                            onToggle: { toggle(sport) },
                            onShowTooltip: { showHIITTooltip = true }
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

private struct SportCell: View {
    let sport: SportCode
    let isSelected: Bool
    let onToggle: () -> Void
    let onShowTooltip: () -> Void

    var body: some View {
        Button(action: onToggle) {
            ZStack(alignment: .topTrailing) {
                VStack(spacing: 8) {
                    Image(systemName: sport.sfSymbol)
                        .font(.system(size: 32))
                        .foregroundStyle(isSelected ? Color.coachingOnPrimary : Color.coachingPrimary)
                    Text(LocalizedStringKey(sport.localizationKey))
                        .font(.coachingCaption)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(isSelected ? Color.coachingOnPrimary : Color.coachingTextPrimary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 96)
                .background(
                    RoundedRectangle(cornerRadius: CoachingRadius.md)
                        .fill(isSelected ? Color.coachingPrimary : Color.coachingCard)
                )

                if sport == .hiit {
                    Button(action: onShowTooltip) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(isSelected ? Color.coachingOnPrimary : Color.coachingPrimary)
                            .padding(8)
                    }
                    .accessibilityIdentifier("onboarding.sport.hiit.info")
                    .accessibilityLabel(Text("onboarding.sport.hiit.tooltip.title"))
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("onboarding.sport.\(sport.rawValue)")
        .accessibilityAddTraits(isSelected ? [.isSelected, .isButton] : .isButton)
    }
}
