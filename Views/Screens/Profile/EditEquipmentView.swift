// Views/Screens/Profile/EditEquipmentView.swift
// Édition de l'équipement générique multi-sport — pattern EditActiveSportsView.
import SwiftUI
import SageCore

struct EditEquipmentView: View {
    @Environment(\.appDependencies) private var deps
    @Environment(\.dismiss) private var dismiss

    let coachingProfile: CoachingProfile

    @State private var viewModel: EditEquipmentViewModel?

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
        .navigationTitle("profile.section.equipment")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { setupViewModelIfNeeded() }
    }

    private func setupViewModelIfNeeded() {
        guard viewModel == nil, let deps else { return }
        viewModel = EditEquipmentViewModel(
            coachingProfile: coachingProfile,
            coachingProfileRepository: deps.coachingProfileRepository
        )
    }

    @ViewBuilder
    private func content(vm: EditEquipmentViewModel) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("profile.equipment.helper")
                    .font(.coachingBody)
                    .foregroundStyle(Color.coachingTextSecondary)
                    .padding(.top, 16)

                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(EquipmentCode.allCases, id: \.self) { item in
                        EquipmentCell(
                            item: item,
                            isSelected: vm.selectedEquipment.contains(item.rawValue),
                            onToggle: { vm.toggle(item) }
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
                        Text("profile.equipment.save")
                    }
                }
                .disabled(!vm.canSave)
                .accessibilityIdentifier("profile.equipment.save")
            }
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
        .accessibilityIdentifier("profile.equipment.\(item.rawValue)")
        .accessibilityAddTraits(isSelected ? [.isSelected, .isButton] : .isButton)
    }
}
