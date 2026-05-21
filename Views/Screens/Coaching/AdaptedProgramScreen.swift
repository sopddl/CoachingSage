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
    /// Story sœur 3.z (2026-05-17) — closure "Démarrer ce programme" forwardée
    /// à `AdaptedProgramView`. Non-nil = preview mode (sticky CTA bottom).
    private let onConfirmStart: (() async -> Void)?
    /// **Story 3.16 (Sophie 2026-05-21)** — closure "Retour à la home page"
    /// forwardée. Non-nil = sticky bottom devient 2 boutons (cf
    /// `AdaptedProgramView.previewBottomCTA`).
    private let onDismissPreview: (() -> Void)?
    /// **Story 3.10** — programme démarré (weekStartDate != nil) ; forwardé à
    /// `AdaptedProgramView.hasStarted`.
    private let hasStarted: Bool

    init(
        viewModel: @autoclosure @escaping () -> AdaptedProgramViewModel,
        modifiedSessionCoordinates: Set<SessionCoordinate> = [],
        onConfirmStart: (() async -> Void)? = nil,
        onDismissPreview: (() -> Void)? = nil,
        hasStarted: Bool = false
    ) {
        _viewModel = StateObject(wrappedValue: viewModel())
        self.modifiedSessionCoordinates = modifiedSessionCoordinates
        self.onConfirmStart = onConfirmStart
        self.onDismissPreview = onDismissPreview
        self.hasStarted = hasStarted
    }

    var body: some View {
        AdaptedProgramView(
            program: viewModel.program,
            onRequestAIAssist: { Task { await viewModel.requestLeonExplicit() } },
            recordId: viewModel.recordId,
            hasStarted: hasStarted,
            leonNotes: viewModel.leonNotes,
            requestState: viewModel.requestState,
            modifiedSessionCoordinates: modifiedSessionCoordinates,
            onConfirmStart: onConfirmStart,
            onDismissPreview: onDismissPreview
        )
        .task {
            // En preview mode, on évite de déclencher Léon (pas de record persisté,
            // pas de raison de consommer une requête IA pour un programme qui peut
            // ne jamais être démarré).
            guard onConfirmStart == nil else { return }
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
