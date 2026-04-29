// Views/Screens/Profile/EditPersonalDataView.swift
// Story 2.3 — édition données perso, CTA HealthKit toujours visible.
import SwiftUI
import UIKit
import SageCore

struct EditPersonalDataView: View {
    @Environment(\.appDependencies) private var deps
    @Environment(\.dismiss) private var dismiss

    let coachingProfile: CoachingProfile

    @State private var viewModel: EditPersonalDataViewModel?

    private let sexOptions: [(String, LocalizedStringKey)] = [
        ("female", "onboarding.personalData.sex.female"),
        ("male", "onboarding.personalData.sex.male"),
        ("other", "onboarding.personalData.sex.other"),
        ("prefer_not_to_say", "onboarding.personalData.sex.preferNotToSay")
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
        .navigationTitle("profile.section.personalData")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { setupViewModelIfNeeded() }
    }

    private func setupViewModelIfNeeded() {
        guard viewModel == nil, let deps else { return }
        viewModel = EditPersonalDataViewModel(
            coachingProfile: coachingProfile,
            coachingProfileRepository: deps.coachingProfileRepository,
            healthKitService: deps.healthKitService
        )
    }

    @ViewBuilder
    private func content(vm: EditPersonalDataViewModel) -> some View {
        @Bindable var vm = vm
        Form {
            if vm.isHealthKitAvailable {
                Section {
                    Button(action: { handleHealthKitTap(vm: vm) }) {
                        HStack(spacing: 8) {
                            if vm.isImportingHealthKit {
                                ProgressView().controlSize(.small)
                            } else {
                                Image(systemName: "heart.text.square.fill")
                            }
                            Text(vm.healthKitProbablyDenied
                                 ? "profile.personalData.healthKit.openSettings"
                                 : "profile.personalData.healthKit.cta")
                        }
                    }
                    .disabled(vm.isImportingHealthKit)
                    .accessibilityIdentifier("profile.personalData.healthKit.cta")
                }
            }

            Section("profile.personalData.sex.label") {
                Picker("profile.personalData.sex.label", selection: Binding(
                    get: { vm.biologicalSex },
                    set: { vm.biologicalSex = $0 }
                )) {
                    Text(verbatim: " ").tag(Optional<String>(nil))
                    ForEach(sexOptions, id: \.0) { code, key in
                        Text(key).tag(Optional(code))
                    }
                }
                .pickerStyle(.menu)
                .accessibilityIdentifier("profile.personalData.sex.picker")
            }

            Section("profile.personalData.dob.label") {
                DatePicker(
                    "profile.personalData.dob.label",
                    selection: Binding(
                        get: { vm.dateOfBirth ?? Self.defaultDOB },
                        set: { vm.dateOfBirth = $0 }
                    ),
                    in: ...Date(),
                    displayedComponents: .date
                )
                .labelsHidden()
                .datePickerStyle(.compact)
                .accessibilityIdentifier("profile.personalData.dob.picker")
            }

            Section("profile.personalData.weight.label") {
                NumberRow(suffix: "kg", value: $vm.weightKg, identifier: "profile.personalData.weight.field")
            }

            Section("profile.personalData.height.label") {
                NumberRow(suffix: "cm", value: $vm.heightCm, identifier: "profile.personalData.height.field")
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
                        Text("profile.personalData.save")
                    }
                }
                .disabled(!vm.canSave)
                .accessibilityIdentifier("profile.personalData.save")
            }
        }
        .onAppear {
            if vm.dateOfBirth == nil {
                vm.dateOfBirth = Self.defaultDOB
            }
        }
    }

    private func handleHealthKitTap(vm: EditPersonalDataViewModel) {
        if vm.healthKitProbablyDenied {
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        } else {
            Task { await vm.importFromHealthKit() }
        }
    }

    static let defaultDOB: Date = {
        Calendar.current.date(byAdding: .year, value: -30, to: Date()) ?? Date()
    }()
}

private struct NumberRow: View {
    let suffix: String
    @Binding var value: Double?
    let identifier: String

    @State private var text: String = ""

    var body: some View {
        HStack {
            TextField("", text: $text)
                .keyboardType(.numberPad)
                .accessibilityIdentifier(identifier)
                .onChange(of: text) { _, new in
                    value = Double(new)
                }
                .onChange(of: value) { _, new in
                    if let new, text != String(Int(new)) {
                        text = String(Int(new))
                    }
                }
            Text(verbatim: suffix)
                .foregroundStyle(Color.coachingTextSecondary)
        }
        .onAppear {
            if let v = value, text.isEmpty {
                text = String(Int(v))
            }
        }
    }
}
