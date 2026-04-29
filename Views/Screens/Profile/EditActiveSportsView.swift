// Views/Screens/Profile/EditActiveSportsView.swift
// Story 2.3 — grille 2x5 sports pré-cochée.
import SwiftUI
import SageCore

struct EditActiveSportsView: View {
    @Environment(\.appDependencies) private var deps
    @Environment(\.dismiss) private var dismiss

    let coachingProfile: CoachingProfile

    @State private var viewModel: EditActiveSportsViewModel?
    @State private var showHIITTooltip: Bool = false

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        Group {
            if let vm = viewModel {
                content(vm: vm)
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.coachingBackground)
            }
        }
        .navigationTitle("profile.section.sports")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { setupViewModelIfNeeded() }
    }

    private func setupViewModelIfNeeded() {
        guard viewModel == nil, let deps else { return }
        viewModel = EditActiveSportsViewModel(
            coachingProfile: coachingProfile,
            coachingProfileRepository: deps.coachingProfileRepository
        )
    }

    @ViewBuilder
    private func content(vm: EditActiveSportsViewModel) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("profile.sports.helper")
                    .font(.coachingBody)
                    .foregroundStyle(Color.coachingTextSecondary)
                    .padding(.top, 16)

                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(SportCode.allCases, id: \.self) { sport in
                        SportCell(
                            sport: sport,
                            isSelected: vm.selectedSports.contains(sport.rawValue),
                            onToggle: { vm.toggle(sport) },
                            onShowTooltip: { showHIITTooltip = true }
                        )
                    }
                }

                if let errorMessage = vm.saveErrorMessage {
                    Text(verbatim: errorMessage)
                        .font(.coachingCaption)
                        .foregroundStyle(Color.coachingError)
                }

                Spacer(minLength: 32)
            }
            .padding(.horizontal, 24)
        }
        .background(Color.coachingBackground)
        .alert(
            "onboarding.sport.hiit.tooltip.title",
            isPresented: $showHIITTooltip
        ) {
            Button("common.ok", role: .cancel) {}
        } message: {
            Text("onboarding.sport.hiit.tooltip.body")
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task {
                        await vm.save()
                        if case .success = vm.saveState { dismiss() }
                    }
                } label: {
                    if vm.isSaving {
                        ProgressView()
                    } else {
                        Text("profile.sports.save")
                    }
                }
                .disabled(!vm.canSave)
                .accessibilityIdentifier("profile.sports.save")
            }
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
                    .accessibilityIdentifier("profile.sport.hiit.info")
                    .accessibilityLabel(Text("onboarding.sport.hiit.tooltip.title"))
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("profile.sport.\(sport.rawValue)")
        .accessibilityAddTraits(isSelected ? [.isSelected, .isButton] : .isButton)
    }
}
