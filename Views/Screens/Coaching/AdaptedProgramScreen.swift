// Views/Screens/Coaching/AdaptedProgramScreen.swift
// Story 3.3b — wrapper qui combine AdaptedProgramViewModel (orchestration Léon)
// et AdaptedProgramView (rendu pure-display). Push à la place de AdaptedProgramView
// directement quand on veut activer le hand-off Léon (chemins normaux app).
//
// Les `#Preview` de AdaptedProgramView restent valides (utilisent AdaptedProgramView
// directement avec des fixtures statiques sans VM).
import SwiftUI

struct AdaptedProgramScreen: View {
    @StateObject private var viewModel: AdaptedProgramViewModel
    /// Phase B.6 — coordonnées sessions S+1 mutées par la regen cette semaine
    /// (résolu côté `SessionView.pushAdaptedProgram` via
    /// `SessionDashboardViewModel.modifiedSessionCoordinates`).
    private let modifiedSessionCoordinates: Set<SessionCoordinate>

    init(
        viewModel: @autoclosure @escaping () -> AdaptedProgramViewModel,
        modifiedSessionCoordinates: Set<SessionCoordinate> = []
    ) {
        _viewModel = StateObject(wrappedValue: viewModel())
        self.modifiedSessionCoordinates = modifiedSessionCoordinates
    }

    var body: some View {
        AdaptedProgramView(
            program: viewModel.program,
            onRequestAIAssist: { Task { await viewModel.requestLeonExplicit() } },
            recordId: viewModel.recordId,
            leonNotes: viewModel.leonNotes,
            requestState: viewModel.requestState,
            modifiedSessionCoordinates: modifiedSessionCoordinates
        )
        .task {
            await viewModel.triggerLeonIfNeeded()
        }
        .sheet(isPresented: $viewModel.showQuotaSheet) {
            QuotaExceededSheet()
                .presentationDetents([.medium])
        }
    }
}

// MARK: - Quota exceeded sheet

private struct QuotaExceededSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "hourglass.bottomhalf.filled")
                .font(.system(size: 48))
                .foregroundStyle(.tint)
                .padding(.top, 24)
            Text("coaching.adapter.leon.quotaExceeded.title")
                .font(.title2.bold())
                .multilineTextAlignment(.center)
            Text("coaching.adapter.leon.quotaExceeded.subtitle")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Spacer()
            Button {
                // Léon+ paywall pas encore livré — Story 3.3.1 / Story 3.7
                dismiss()
            } label: {
                Text("coaching.adapter.leon.quotaExceeded.cta")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)
            Button {
                dismiss()
            } label: {
                Text("common.later")
                    .frame(maxWidth: .infinity)
            }
            .padding(.bottom)
        }
        .padding()
    }
}
