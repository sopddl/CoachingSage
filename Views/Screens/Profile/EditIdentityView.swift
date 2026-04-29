// Views/Screens/Profile/EditIdentityView.swift
// Story 2.3 — sous-écran édition prénom. Langue gérée par LanguageSelectorView (live, extensible).
import SwiftUI
import SageCore

struct EditIdentityView: View {
    @Environment(\.appDependencies) private var deps
    @Environment(\.languageManager) private var languageManager
    @Environment(\.dismiss) private var dismiss

    let coreProfile: SageCoreProfile

    @State private var viewModel: EditIdentityViewModel?
    @FocusState private var nameFocused: Bool

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
        .navigationTitle("profile.section.identity")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { setupViewModelIfNeeded() }
    }

    private func setupViewModelIfNeeded() {
        guard viewModel == nil, let deps else { return }
        viewModel = EditIdentityViewModel(
            coreProfile: coreProfile,
            coreProfileRepository: deps.coreProfileRepository,
            languageManager: languageManager
        )
    }

    @ViewBuilder
    private func content(vm: EditIdentityViewModel) -> some View {
        @Bindable var vm = vm
        Form {
            Section("profile.identity.firstName") {
                TextField("onboarding.firstName.placeholder", text: $vm.firstName)
                    .textContentType(.givenName)
                    .textInputAutocapitalization(.words)
                    .submitLabel(.done)
                    .focused($nameFocused)
                    .accessibilityIdentifier("profile.identity.firstName.field")
            }

            Section("profile.identity.language") {
                HStack {
                    Text("profile.identity.language")
                        .foregroundStyle(Color.coachingTextPrimary)
                    Spacer()
                    LanguageSelectorView(languageManager: languageManager)
                }
            }

            if let errorMessage = vm.saveErrorMessage {
                Section {
                    Text(verbatim: errorMessage)
                        .foregroundStyle(Color.coachingError)
                }
            }
        }
        .scrollContentBackground(.hidden)
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
                        Text("profile.identity.save")
                    }
                }
                .disabled(!vm.canSave)
                .accessibilityIdentifier("profile.identity.save")
            }
        }
    }
}
