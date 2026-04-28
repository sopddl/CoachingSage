// Views/Screens/Onboarding/PersonalDataView.swift
// Story 2.2 — écran 2 : sex/DOB/poids/taille + CTA HealthKit.
import SwiftUI

struct PersonalDataView: View {
    @Bindable var viewModel: OnboardingViewModel
    @State private var importing: Bool = false

    private let sexOptions: [(String, LocalizedStringKey)] = [
        ("female", "onboarding.personalData.sex.female"),
        ("male", "onboarding.personalData.sex.male"),
        ("other", "onboarding.personalData.sex.other"),
        ("prefer_not_to_say", "onboarding.personalData.sex.preferNotToSay")
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("onboarding.personalData.title")
                    .font(.coachingDisplay)
                    .foregroundStyle(Color.coachingTextPrimary)
                    .padding(.top, 16)

                if viewModel.showHealthKitCTA {
                    Button(action: importFromHealthKit) {
                        HStack(spacing: 8) {
                            if importing {
                                ProgressView().controlSize(.small)
                            } else {
                                Image(systemName: "heart.text.square.fill")
                            }
                            Text("onboarding.personalData.healthKit.cta")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    .disabled(importing)
                    .accessibilityIdentifier("onboarding.healthkit.cta")
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("onboarding.personalData.sex.label")
                        .font(.coachingCaption)
                        .foregroundStyle(Color.coachingTextSecondary)
                    Picker("onboarding.personalData.sex.label", selection: bindingForSex) {
                        Text(verbatim: " ").tag(Optional<String>(nil))
                        ForEach(sexOptions, id: \.0) { code, key in
                            Text(key).tag(Optional(code))
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(Color.coachingCard, in: RoundedRectangle(cornerRadius: CoachingRadius.md))
                    .accessibilityIdentifier("onboarding.sex.picker")
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("onboarding.personalData.dob.label")
                        .font(.coachingCaption)
                        .foregroundStyle(Color.coachingTextSecondary)
                    DatePicker(
                        "onboarding.personalData.dob.label",
                        selection: bindingForDate,
                        in: ...Date(),
                        displayedComponents: .date
                    )
                    .labelsHidden()
                    .datePickerStyle(.compact)
                    .padding(12)
                    .background(Color.coachingCard, in: RoundedRectangle(cornerRadius: CoachingRadius.md))
                    .accessibilityIdentifier("onboarding.dob.picker")
                }

                HStack(spacing: 12) {
                    NumberField(
                        labelKey: "onboarding.personalData.weight.label",
                        suffix: "kg",
                        value: $viewModel.weightKg,
                        identifier: "onboarding.weight.field"
                    )
                    NumberField(
                        labelKey: "onboarding.personalData.height.label",
                        suffix: "cm",
                        value: $viewModel.heightCm,
                        identifier: "onboarding.height.field"
                    )
                }

                Spacer(minLength: 32)
            }
            .padding(.horizontal, 24)
        }
        .safeAreaInset(edge: .bottom) {
            Button(action: { viewModel.goNext() }) {
                Text("onboarding.continue")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(!viewModel.canContinueScreen2)
            .padding(.horizontal, 24)
            .padding(.top, 8)
            .padding(.bottom, 16)
            .background(Color.coachingBackground.ignoresSafeArea(edges: .bottom))
            .accessibilityIdentifier("onboarding.continue.button")
        }
        .onAppear {
            // Pré-fill DOB pour éviter le piège UX du DatePicker .compact qui n'envoie pas
            // d'event si l'utilisateur n'interagit pas (Continuer reste disabled silencieusement).
            // L'utilisateur voit la date pré-remplie et la modifie au besoin.
            if viewModel.dateOfBirth == nil {
                viewModel.dateOfBirth = Self.defaultDOB
            }
        }
    }

    private var bindingForSex: Binding<String?> {
        Binding(
            get: { viewModel.biologicalSex },
            set: { viewModel.biologicalSex = $0 }
        )
    }

    private var bindingForDate: Binding<Date> {
        Binding(
            get: { viewModel.dateOfBirth ?? Self.defaultDOB },
            set: { viewModel.dateOfBirth = $0 }
        )
    }

    static let defaultDOB: Date = {
        Calendar.current.date(byAdding: .year, value: -30, to: Date()) ?? Date()
    }()

    private func importFromHealthKit() {
        importing = true
        Task {
            await viewModel.importFromHealthKit()
            importing = false
        }
    }
}

private struct NumberField: View {
    let labelKey: LocalizedStringKey
    let suffix: String
    @Binding var value: Double?
    let identifier: String

    @State private var text: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(labelKey)
                .font(.coachingCaption)
                .foregroundStyle(Color.coachingTextSecondary)
            HStack(spacing: 4) {
                TextField("", text: $text)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.plain)
                    .accessibilityIdentifier(identifier)
                    .onChange(of: text) { _, new in
                        value = Double(new)
                    }
                    .onChange(of: value) { _, new in
                        // Permet le pré-fill HealthKit de propager dans le TextField.
                        if let new, text != String(Int(new)) {
                            text = String(Int(new))
                        }
                    }
                Text(suffix)
                    .font(.coachingCaption)
                    .foregroundStyle(Color.coachingTextSecondary)
            }
            .padding(12)
            .background(Color.coachingCard, in: RoundedRectangle(cornerRadius: CoachingRadius.md))
        }
        .frame(maxWidth: .infinity)
        .onAppear {
            if let v = value, text.isEmpty {
                text = String(Int(v))
            }
        }
    }
}
