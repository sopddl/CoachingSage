// Views/Screens/Coaching/SessionDurationAdjustSheet.swift
// Chantier durée réglable, pilote cycling (Increment 3) — sheet « Ajuster la durée »
// présentée depuis SessionDetailView. Flux 2 étapes (pattern ReplanifySheet) :
//   `.pick`   : TextField+Stepper (pattern SessionCompleteSheet) pour la cible minutes.
//   `.result` : chiffre RÉEL affiché + message doux si `wasBounded` (doctrine D7/D-T5).
// Le caller (SessionDetailView) fournit `adjust` (appel service + persistance) et
// récupère le résultat via `onAdjusted` pour rafraîchir l'affichage local.
import SwiftUI

struct SessionDurationAdjustSheet: View {
    let currentDurationMinutes: Int
    let adjust: (Int) async throws -> SessionDurationAdjustmentResult
    let onAdjusted: (SessionDurationAdjustmentResult) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var targetMinutes: Int
    @State private var step: Step
    @State private var isSaving = false

    /// Pattern `ReplanifySheet.Step` — interne (pas `private`) pour permettre aux
    /// scénarios `ui_review_*` (`UIReviewScenarioContainer`) de screenshot chaque état
    /// terminal (résultat OK, résultat borné, erreur) sans dépendre d'un tap simu
    /// (bloqués/flaky, cf `feedback_tests_swift_screenshots_no_mcp`).
    enum Step: Equatable {
        case pick
        case result(newDuration: Int, wasBounded: Bool)
        case error(SessionDurationAdjustmentError)
    }

    init(
        currentDurationMinutes: Int,
        adjust: @escaping (Int) async throws -> SessionDurationAdjustmentResult,
        onAdjusted: @escaping (SessionDurationAdjustmentResult) -> Void,
        initialStep: Step = .pick
    ) {
        self.currentDurationMinutes = currentDurationMinutes
        self.adjust = adjust
        self.onAdjusted = onAdjusted
        _targetMinutes = State(initialValue: currentDurationMinutes)
        _step = State(initialValue: initialStep)
    }

    var body: some View {
        NavigationStack {
            Group {
                switch step {
                case .pick:
                    pickView
                case .result(let newDuration, let wasBounded):
                    resultView(newDuration: newDuration, wasBounded: wasBounded)
                case .error(let error):
                    errorView(error)
                }
            }
            .navigationTitle(Text("coaching.session.durationAdjust.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if case .pick = step {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("coaching.session.complete.cancel") { dismiss() }
                    }
                }
            }
        }
    }

    // MARK: - Step 1 : cible minutes

    private var pickView: some View {
        Form {
            Section {
                HStack(spacing: 12) {
                    Text("coaching.session.durationAdjust.target.label")
                    Spacer()
                    // Pattern SessionCompleteSheet (Sophie 2026-05-15 bug B2) : TextField
                    // numérique pour la saisie directe + Stepper pour l'ajustement fin.
                    TextField("", value: $targetMinutes, format: .number)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.numberPad)
                        .monospacedDigit()
                        .frame(minWidth: 50)
                        .accessibilityIdentifier("coaching.session.durationAdjust.target.field")
                    Text("coaching.session.complete.duration.unit")
                        .foregroundStyle(.secondary)
                    Stepper("", value: $targetMinutes, in: 5...600, step: 5)
                        .labelsHidden()
                }
            } footer: {
                Text("coaching.session.durationAdjust.target.footer")
            }

            Section {
                Button {
                    Task { await submit() }
                } label: {
                    HStack {
                        Spacer()
                        if isSaving {
                            ProgressView()
                        } else {
                            Text("coaching.session.durationAdjust.confirm")
                        }
                        Spacer()
                    }
                }
                .disabled(isSaving)
                .accessibilityIdentifier("coaching.session.durationAdjust.confirm")
            }
        }
    }

    private func submit() async {
        isSaving = true
        do {
            let result = try await adjust(targetMinutes)
            isSaving = false
            onAdjusted(result)
            step = .result(newDuration: result.session.durationMinutes, wasBounded: result.wasBounded)
        } catch let error as SessionDurationAdjustmentError {
            isSaving = false
            step = .error(error)
        } catch {
            isSaving = false
            step = .error(.notAdjustable)
        }
    }

    // MARK: - Step 2 : résultat

    private func resultView(newDuration: Int, wasBounded: Bool) -> some View {
        VStack(spacing: 16) {
            Spacer(minLength: 8)
            Image(systemName: wasBounded ? "info.circle.fill" : "checkmark.circle.fill")
                .font(.system(size: 44))
                .foregroundStyle(wasBounded ? Color.orange : Color.green)
            Text("coaching.session.durationAdjust.result.newDuration \(newDuration)")
                .font(.title3.bold())
                .multilineTextAlignment(.center)
            if wasBounded {
                // Doctrine D7 « Léon borne honnête » + D-T5 : message système doux,
                // jamais cible vs obtenu — juste le fait que ça a été limité.
                Text("coaching.session.durationAdjust.result.bounded")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            Spacer(minLength: 8)
            Button("coaching.session.durationAdjust.result.done") { dismiss() }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("coaching.session.durationAdjust.result.done")
        }
        .padding()
        .accessibilityIdentifier("coaching.session.durationAdjust.result")
    }

    // MARK: - Erreur

    private func errorView(_ error: SessionDurationAdjustmentError) -> some View {
        VStack(spacing: 12) {
            Spacer(minLength: 8)
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 36))
                .foregroundStyle(.secondary)
            Text(errorMessageKey(error))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Spacer(minLength: 8)
            Button("coaching.session.durationAdjust.result.done") { dismiss() }
                .buttonStyle(.bordered)
        }
        .padding()
    }

    private func errorMessageKey(_ error: SessionDurationAdjustmentError) -> LocalizedStringKey {
        switch error {
        case .sessionAlreadyCompleted:
            return "coaching.session.durationAdjust.error.alreadyCompleted"
        case .programNotFound, .sessionNotFound, .notAdjustable:
            return "coaching.session.durationAdjust.error.generic"
        }
    }
}

#if DEBUG
private func previewNoopAdjust(_ target: Int) async throws -> SessionDurationAdjustmentResult {
    SessionDurationAdjustmentResult(
        session: PersistedSession(
            weekNumber: 1, weekTheme: "Test", weekGoal: "Test", day: 1,
            name: "Séance test", durationMinutes: target, type: .endurance,
            warmup: nil, exercises: [], cooldown: nil
        ),
        wasBounded: false
    )
}

#Preview("DurationAdjust — pick") {
    SessionDurationAdjustSheet(
        currentDurationMinutes: 60, adjust: previewNoopAdjust, onAdjusted: { _ in }
    )
}

#Preview("DurationAdjust — result OK") {
    SessionDurationAdjustSheet(
        currentDurationMinutes: 60, adjust: previewNoopAdjust, onAdjusted: { _ in },
        initialStep: .result(newDuration: 50, wasBounded: false)
    )
}

#Preview("DurationAdjust — result borné") {
    SessionDurationAdjustSheet(
        currentDurationMinutes: 60, adjust: previewNoopAdjust, onAdjusted: { _ in },
        initialStep: .result(newDuration: 90, wasBounded: true)
    )
}

#Preview("DurationAdjust — erreur déjà complétée") {
    SessionDurationAdjustSheet(
        currentDurationMinutes: 60, adjust: previewNoopAdjust, onAdjusted: { _ in },
        initialStep: .error(.sessionAlreadyCompleted)
    )
}
#endif
