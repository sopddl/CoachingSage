// Views/Screens/Coaching/SessionCompleteSheet.swift
// Phase A boucle complétion — sheet modal présentée depuis SessionDetailView
// quand le user tape "Marquer comme terminée". Form simple : RPE 1-10 (Slider
// avec label dynamique), durée réelle (Stepper Int), notes (TextEditor). Tous
// les champs facultatifs — le seul fait de submit marque la session terminée
// et alimente l'onglet Progrès.
import SwiftUI

struct SessionCompleteSheet: View {
    @Environment(\.dismiss) private var dismiss

    @Bindable var vm: SessionCompletionViewModel

    /// Préfill suggéré : durée planifiée de la session (affichée header). Le user
    /// peut ajuster si la séance a duré plus/moins.
    let plannedDurationMinutes: Int

    @State private var rpeEnabled: Bool = false
    @State private var rpe: Double = 5
    @State private var actualDuration: Int
    @State private var notes: String = ""

    init(vm: SessionCompletionViewModel, plannedDurationMinutes: Int) {
        self.vm = vm
        self.plannedDurationMinutes = plannedDurationMinutes
        _actualDuration = State(initialValue: plannedDurationMinutes)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack(spacing: 12) {
                        Text("coaching.session.complete.duration.label")
                        Spacer()
                        // Sophie 2026-05-15 bug B2 : Stepper seul empêchait la saisie
                        // directe au clavier. TextField numérique + Stepper combo →
                        // tap TextField pour taper 75, Stepper pour ajuster ±5.
                        TextField("", value: $actualDuration, format: .number)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.numberPad)
                            .monospacedDigit()
                            .frame(minWidth: 50)
                        Text("coaching.session.complete.duration.unit")
                            .foregroundStyle(.secondary)
                        Stepper("", value: $actualDuration, in: 1...300, step: 5)
                            .labelsHidden()
                    }
                } header: {
                    Text("coaching.session.complete.duration.section")
                }

                Section {
                    Toggle(isOn: $rpeEnabled.animation()) {
                        Text("coaching.session.complete.rpe.toggle")
                    }
                    if rpeEnabled {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(verbatim: "\(Int(rpe))/10")
                                    .font(.title3.bold())
                                    .foregroundStyle(Color.coachingPrimary)
                                Spacer()
                                Text(rpeLabel(for: Int(rpe)))
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            Slider(value: $rpe, in: 1...10, step: 1)
                                .tint(Color.coachingPrimary)
                            Text("coaching.session.complete.rpe.hint")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                } header: {
                    Text("coaching.session.complete.rpe.section")
                }

                Section {
                    TextField(
                        "coaching.session.complete.notes.placeholder",
                        text: $notes,
                        axis: .vertical
                    )
                    .lineLimit(3...6)
                } header: {
                    Text("coaching.session.complete.notes.section")
                }

                if case let .failed(message) = vm.saveState {
                    Section {
                        Text(verbatim: message)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle(Text("coaching.session.complete.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("coaching.session.complete.cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("coaching.session.complete.submit") {
                        Task {
                            await vm.save(
                                actualDurationMinutes: actualDuration,
                                rpe: rpeEnabled ? Int(rpe) : nil,
                                notes: notes
                            )
                            if case .saved = vm.saveState {
                                dismiss()
                            }
                        }
                    }
                    .disabled(vm.saveState == .saving)
                }
            }
        }
        .onAppear {
            if let existing = vm.completion {
                actualDuration = existing.actualDurationMinutes ?? plannedDurationMinutes
                if let existingRPE = existing.perceivedEffort {
                    rpe = Double(existingRPE)
                    rpeEnabled = true
                }
                notes = existing.notes ?? ""
            }
        }
    }

    private func rpeLabel(for value: Int) -> LocalizedStringKey {
        switch value {
        case 1, 2:  return "coaching.session.complete.rpe.veryEasy"
        case 3, 4:  return "coaching.session.complete.rpe.easy"
        case 5, 6:  return "coaching.session.complete.rpe.moderate"
        case 7, 8:  return "coaching.session.complete.rpe.hard"
        default:    return "coaching.session.complete.rpe.maximal"
        }
    }
}

#if DEBUG
#Preview("SessionCompleteSheet — fresh") {
    SessionCompleteSheet(
        vm: SessionCompletionViewModel(
            recordId: UUID(),
            weekNumber: 1,
            day: 1,
            repository: PreviewAdaptedProgramRepository()
        ),
        plannedDurationMinutes: 45
    )
}

private final class PreviewAdaptedProgramRepository: AdaptedProgramRepository {
    func fetchActive(for userId: UUID) async throws -> [AdaptedProgramRecord] { [] }
    func fetchStartedCount(for userId: UUID) async throws -> Int { 0 }
    func fetchDormantCount(for userId: UUID) async throws -> Int { 0 }
    func save(_ record: AdaptedProgramRecord) async throws {}
    func update(_ record: AdaptedProgramRecord) async throws {}
    func markStarted(recordId: UUID) async throws {}
    func archive(_ record: AdaptedProgramRecord) async throws {}
    func applyLeonPatch(recordId: UUID, patch: AdaptationPatch) async throws {}
    func loadSessionCompletion(recordId: UUID, weekNumber: Int, day: Int) async throws -> SessionCompletionRecord? { nil }
    func recordSessionCompletion(recordId: UUID, weekNumber: Int, day: Int, record: SessionCompletionRecord?) async throws {}
}
#endif
