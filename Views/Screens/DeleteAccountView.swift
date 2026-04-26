// Views/Screens/DeleteAccountView.swift
// Story 1.4 — écran "Zone dangereuse" → suppression compte RGPD Art. 17.
// Encapsulé dans le NavigationStack de ProfileView (cf. MainTabView).
import SwiftUI
import SageCore

struct DeleteAccountView: View {
    @Environment(\.appDependencies) private var deps
    @State private var viewModel: AccountViewModel?
    @State private var showConfirmation = false

    var body: some View {
        Group {
            if let vm = viewModel {
                content(vm: vm)
            } else if deps == nil {
                ContentUnavailableView(
                    "account.delete.error.unavailable.title",
                    systemImage: "exclamationmark.circle",
                    description: Text("account.delete.error.unavailable.description")
                )
            } else {
                ProgressView()
            }
        }
        .navigationTitle("account.delete.title")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.coachingBackground)
        .onAppear { setupViewModel() }
    }

    @ViewBuilder
    private func content(vm: AccountViewModel) -> some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(.coachingError)

            Text("account.delete.heading")
                .font(.coachingH1)
                .foregroundStyle(Color.coachingTextPrimary)

            Text("account.delete.description")
                .font(.coachingBody)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.coachingTextSecondary)
                .padding(.horizontal)

            switch vm.deleteAccountState {
            case .loading:
                ProgressView {
                    Text("account.delete.inProgress")
                        .font(.coachingCaption)
                }

            case .error(let err):
                Text(err.localizedDescription)
                    .foregroundStyle(Color.coachingError)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                deleteButton(vm: vm)

            default:
                deleteButton(vm: vm)
            }
        }
        .frame(maxHeight: .infinity)
        .padding(.horizontal)
        .confirmationDialog(
            "account.delete.confirm.title",
            isPresented: $showConfirmation,
            titleVisibility: .visible
        ) {
            Button("account.delete.confirm.action", role: .destructive) {
                Task { await vm.deleteAccount() }
            }
            Button("account.delete.confirm.cancel", role: .cancel) {}
        } message: {
            Text("account.delete.confirm.message")
        }
    }

    private func deleteButton(vm: AccountViewModel) -> some View {
        let isLoading: Bool = {
            if case .loading = vm.deleteAccountState { return true }
            return false
        }()
        return Button {
            showConfirmation = true
        } label: {
            Text("account.delete.button")
        }
        .buttonStyle(DangerButtonStyle())
        .padding(.horizontal)
        .disabled(isLoading)
        .accessibilityIdentifier("delete_account_button")
    }

    private func setupViewModel() {
        guard let deps else { return }
        viewModel = AccountViewModel(
            accountService: deps.accountService,
            authService: deps.authService
        )
    }
}
