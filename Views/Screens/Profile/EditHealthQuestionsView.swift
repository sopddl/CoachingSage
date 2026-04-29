// Views/Screens/Profile/EditHealthQuestionsView.swift
// Story 2.3 — édition PARQ-light + bandeau live + recalcul requires_medical_clearance.
import SwiftUI
import SageCore

struct EditHealthQuestionsView: View {
    @Environment(\.appDependencies) private var deps
    @Environment(\.dismiss) private var dismiss

    let coachingProfile: CoachingProfile

    @State private var viewModel: EditHealthQuestionsViewModel?

    private let questions: [(PARQQuestion, LocalizedStringKey)] = [
        (.q1ChestPain, "onboarding.parq.q1"),
        (.q2Dizziness, "onboarding.parq.q2"),
        (.q3JointAggravated, "onboarding.parq.q3"),
        (.q4HeartMedication, "onboarding.parq.q4"),
        (.q5OtherReason, "onboarding.parq.q5")
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
        .navigationTitle("profile.section.health")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { setupViewModelIfNeeded() }
        .onChange(of: viewModel?.saveState.isSuccess) { _, success in
            if success == true { dismiss() }
        }
    }

    private func setupViewModelIfNeeded() {
        guard viewModel == nil, let deps else { return }
        viewModel = EditHealthQuestionsViewModel(
            coachingProfile: coachingProfile,
            coachingProfileRepository: deps.coachingProfileRepository
        )
    }

    @ViewBuilder
    private func content(vm: EditHealthQuestionsViewModel) -> some View {
        Form {
            Section {
                Text("onboarding.parq.title")
                    .font(.coachingH1)
                    .foregroundStyle(Color.coachingTextPrimary)
                    .listRowBackground(Color.clear)
            }

            Section {
                ForEach(questions, id: \.0) { question, labelKey in
                    Toggle(isOn: Binding(
                        get: { vm.parqResponses[question.rawValue] ?? false },
                        set: { vm.toggleResponse(for: question, value: $0) }
                    )) {
                        Text(labelKey)
                            .font(.coachingBody)
                            .foregroundStyle(Color.coachingTextPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .tint(Color.coachingPrimary)
                    .accessibilityIdentifier("profile.parq.\(question.rawValue).toggle")
                }
            }

            if vm.requiresMedicalClearance {
                Section {
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(Color.coachingWarning)
                        Text("onboarding.parq.warning")
                            .font(.coachingCaption)
                            .foregroundStyle(Color.coachingTextPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .listRowBackground(Color.coachingWarning.opacity(0.15))
                    .accessibilityIdentifier("profile.parq.warning.banner")
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
                    vm.save()
                } label: {
                    if vm.isSaving {
                        ProgressView()
                    } else {
                        Text("profile.health.save")
                    }
                }
                .disabled(!vm.canSave)
                .accessibilityIdentifier("profile.health.save")
            }
        }
    }
}

private extension ViewState {
    var isSuccess: Bool {
        if case .success = self { return true }
        return false
    }
}
