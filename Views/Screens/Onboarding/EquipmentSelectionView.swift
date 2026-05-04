// Views/Screens/Onboarding/EquipmentSelectionView.swift
// Equipment global onboarding — 4 capsules génériques multi-sport.
// L'équipement spécifique sport (treadmill, home-trainer, accès piscine…)
// reste dans le questionnaire sport et override/complète celui-ci.
import SwiftUI

struct EquipmentSelectionView: View {
    @Bindable var viewModel: OnboardingViewModel

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("onboarding.equipment.title")
                    .font(.coachingDisplay)
                    .foregroundStyle(Color.coachingTextPrimary)
                    .padding(.top, 16)

                Text("onboarding.equipment.helper")
                    .font(.coachingBody)
                    .foregroundStyle(Color.coachingTextSecondary)

                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(EquipmentCode.allCases, id: \.self) { item in
                        EquipmentCell(
                            item: item,
                            isSelected: viewModel.equipment.contains(item.rawValue),
                            onToggle: { toggle(item) }
                        )
                    }
                }
                .padding(.top, 8)

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
            .disabled(!viewModel.canContinueScreen4)
            .padding(.horizontal, 24)
            .padding(.top, 8)
            .padding(.bottom, 16)
            .background(Color.coachingBackground.ignoresSafeArea(edges: .bottom))
            .accessibilityIdentifier("onboarding.continue.button")
        }
    }

    private func toggle(_ item: EquipmentCode) {
        if viewModel.equipment.contains(item.rawValue) {
            viewModel.equipment.remove(item.rawValue)
        } else {
            viewModel.equipment.insert(item.rawValue)
        }
    }
}

private struct EquipmentCell: View {
    let item: EquipmentCode
    let isSelected: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            VStack(spacing: 8) {
                Image(systemName: item.sfSymbol)
                    .font(.system(size: 32))
                    .foregroundStyle(isSelected ? Color.coachingOnPrimary : Color.coachingPrimary)
                Text(LocalizedStringKey(item.localizationKey))
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
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("onboarding.equipment.\(item.rawValue)")
        .accessibilityAddTraits(isSelected ? [.isSelected, .isButton] : .isButton)
    }
}
