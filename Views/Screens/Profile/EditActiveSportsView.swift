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

    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

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

                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(SportCode.allCases, id: \.self) { sport in
                        SportTileView(
                            sport: sport,
                            isSelected: vm.selectedSports.contains(sport.rawValue),
                            onTap: { vm.toggle(sport) },
                            onShowTooltip: { showHIITTooltip = true },
                            identifierPrefix: "profile.sport"
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

// SportCell privée supprimée — refactor en `SportTileView` partagé
// (Views/Components/SportTileView.swift), aligne le rendu modif profil sur l'onboarding.
