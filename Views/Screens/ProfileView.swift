// Views/Screens/ProfileView.swift
// Story 2.3 — hub de modification profil. Form sectionné, sous-écrans via NavigationLink.
// Conserve signOut (Story 1.2) + DeleteAccount (Story 1.4).
import SwiftUI
import SageCore

struct ProfileView: View {
    @Environment(\.appDependencies) private var deps
    @Environment(\.languageManager) private var languageManager
    @State private var viewModel: ProfileViewModel?

    var body: some View {
        Group {
            if let vm = viewModel {
                content(vm: vm)
            } else if deps == nil {
                ContentUnavailableView(
                    "profile.error.unavailable.title",
                    systemImage: "exclamationmark.circle",
                    description: Text("profile.error.unavailable.description")
                )
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.coachingBackground)
            }
        }
        .navigationTitle("tab.profile")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            setupViewModelIfNeeded()
            Task { await viewModel?.refresh() }
        }
    }

    private func setupViewModelIfNeeded() {
        guard viewModel == nil, let deps else { return }
        viewModel = ProfileViewModel(
            coreProfileRepository: deps.coreProfileRepository,
            coachingProfileRepository: deps.coachingProfileRepository,
            authService: deps.authService
        )
    }

    @ViewBuilder
    private func content(vm: ProfileViewModel) -> some View {
        Form {
            switch vm.state {
            case .idle, .loading:
                skeletonSections
            case .error(.notFound):
                // Cas le plus fréquent : profil pas (encore) chargé localement (post-reset
                // SwiftData ou première synchro après login). Pas d'erreur fatale — wording
                // humain + bouton de re-fetch explicite.
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("profile.error.notLoaded.title")
                            .font(.coachingH2)
                            .foregroundStyle(Color.coachingTextPrimary)
                        Text("profile.error.notLoaded.description")
                            .font(.coachingBody)
                            .foregroundStyle(Color.coachingTextSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.vertical, 4)

                    Button("profile.error.refresh") {
                        Task { await vm.refresh() }
                    }
                }
            case .error(let err):
                Section {
                    Text(err.localizedDescription)
                        .foregroundStyle(Color.coachingError)
                    Button("profile.error.refresh") {
                        Task { await vm.refresh() }
                    }
                }
            case .success(let profiles):
                identitySection(core: profiles.core)
                personalDataSection(coaching: profiles.coaching)
                sportsSection(coaching: profiles.coaching)
                equipmentSection(coaching: profiles.coaching)
                healthSection(coaching: profiles.coaching)
                privacySection(vm: vm)
                aboutSection(coaching: profiles.coaching)
                accountSection
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.coachingBackground)
    }

    // MARK: - Skeleton placeholders

    @ViewBuilder
    private var skeletonSections: some View {
        Section("profile.section.identity") {
            HStack {
                Text("profile.identity.firstName")
                Spacer()
                Text(verbatim: "—").foregroundStyle(Color.coachingTextSecondary)
            }
        }
        Section("profile.section.personalData") {
            Text(verbatim: "—").foregroundStyle(Color.coachingTextSecondary)
        }
    }

    // MARK: - Sections

    @ViewBuilder
    private func identitySection(core: SageCoreProfile) -> some View {
        Section("profile.section.identity") {
            NavigationLink {
                EditIdentityView(coreProfile: core)
            } label: {
                LabeledContent("profile.identity.firstName") {
                    Text(verbatim: core.firstName ?? "—")
                        .foregroundStyle(Color.coachingTextSecondary)
                }
            }
            .accessibilityIdentifier("profile.identity.link")

            HStack {
                Text("profile.identity.language")
                    .foregroundStyle(Color.coachingTextPrimary)
                Spacer()
                LanguageSelectorView(languageManager: languageManager)
            }
        }
    }

    @ViewBuilder
    private func personalDataSection(coaching: CoachingProfile) -> some View {
        Section("profile.section.personalData") {
            NavigationLink {
                EditPersonalDataView(coachingProfile: coaching)
            } label: {
                Text(verbatim: personalDataSummary(coaching))
                    .foregroundStyle(Color.coachingTextSecondary)
            }
            .accessibilityIdentifier("profile.personalData.link")
        }
    }

    private func personalDataSummary(_ coaching: CoachingProfile) -> String {
        let locale = languageManager.currentLocale
        let sex = coaching.biologicalSex.map { localizedSex($0, locale: locale) } ?? "—"
        let age = coaching.dateOfBirth.map { String(yearsFromNow($0)) } ?? "—"
        let weight = coaching.weightKg.map { String(format: "%.0f", $0) } ?? "—"
        let height = coaching.heightCm.map { String(format: "%.0f", $0) } ?? "—"
        let years = String.localized("profile.personalData.years", locale: locale)
        return "\(sex), \(age) \(years), \(weight) kg, \(height) cm"
    }

    private func localizedSex(_ code: String, locale: Locale) -> String {
        switch code {
        case "female": return String.localized("onboarding.personalData.sex.female", locale: locale)
        case "male": return String.localized("onboarding.personalData.sex.male", locale: locale)
        case "other": return String.localized("onboarding.personalData.sex.other", locale: locale)
        case "prefer_not_to_say": return String.localized("onboarding.personalData.sex.preferNotToSay", locale: locale)
        default: return code
        }
    }

    private func yearsFromNow(_ date: Date) -> Int {
        Calendar.current.dateComponents([.year], from: date, to: Date()).year ?? 0
    }

    @ViewBuilder
    private func sportsSection(coaching: CoachingProfile) -> some View {
        Section("profile.section.sports") {
            NavigationLink {
                EditActiveSportsView(coachingProfile: coaching)
            } label: {
                LabeledContent("profile.sports.edit") {
                    Text("profile.sports.count \(coaching.activeSports.count)")
                        .foregroundStyle(Color.coachingTextSecondary)
                }
            }
            .accessibilityIdentifier("profile.sports.link")
        }
    }

    @ViewBuilder
    private func equipmentSection(coaching: CoachingProfile) -> some View {
        Section("profile.section.equipment") {
            NavigationLink {
                EditEquipmentView(coachingProfile: coaching)
            } label: {
                LabeledContent("profile.equipment.edit") {
                    Text("profile.equipment.count \(coaching.equipment.count)")
                        .foregroundStyle(Color.coachingTextSecondary)
                }
            }
            .accessibilityIdentifier("profile.equipment.link")
        }
    }

    @ViewBuilder
    private func healthSection(coaching: CoachingProfile) -> some View {
        Section("profile.section.health") {
            if coaching.requiresMedicalClearance {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(Color.coachingWarning)
                    Text("profile.health.warning.banner")
                        .font(.coachingCaption)
                        .foregroundStyle(Color.coachingTextPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .listRowBackground(Color.coachingWarning.opacity(0.15))
                .accessibilityIdentifier("profile.health.warning.banner")
            }

            NavigationLink {
                EditHealthQuestionsView(coachingProfile: coaching)
            } label: {
                Text("profile.health.edit")
            }
            .accessibilityIdentifier("profile.health.link")
        }
    }

    @ViewBuilder
    private func privacySection(vm: ProfileViewModel) -> some View {
        Section("profile.section.privacy") {
            HStack {
                Toggle(isOn: Binding(
                    get: { vm.analyticsConsent },
                    set: { newValue in
                        vm.analyticsConsent = newValue
                        vm.scheduleAnalyticsSave(value: newValue)
                    }
                )) {
                    Text("profile.privacy.analyticsConsent")
                }
                .tint(Color.coachingPrimary)
                .accessibilityIdentifier("profile.privacy.analyticsConsent.toggle")
                if vm.isAnalyticsSaving {
                    ProgressView().controlSize(.mini)
                }
            }
            if vm.privacyErrorVisible {
                Text("profile.privacy.error.save")
                    .font(.coachingCaption)
                    .foregroundStyle(Color.coachingError)
            }
        }
    }

    @ViewBuilder
    private func aboutSection(coaching: CoachingProfile) -> some View {
        Section("profile.section.about") {
            NavigationLink {
                MedicalDisclaimerView(
                    versionAccepted: coaching.disclaimerVersionAccepted,
                    acceptedAt: coaching.disclaimerAcceptedAt
                )
            } label: {
                Text("profile.disclaimer.title")
            }
            .accessibilityIdentifier("profile.about.disclaimer.link")
        }
    }

    @ViewBuilder
    private var accountSection: some View {
        Section("profile.section.account") {
            Button {
                Task { try? await deps?.authService.signOut() }
            } label: {
                Text("auth.signOut")
                    .foregroundStyle(Color.coachingPrimary)
            }
            .accessibilityIdentifier("profile.account.signOut")
        }

        Section("profile.section.dangerZone") {
            NavigationLink {
                DeleteAccountView()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(Color.coachingError)
                    Text("account.delete.button")
                        .foregroundStyle(Color.coachingError)
                }
            }
            .accessibilityIdentifier("delete_account_link")
        }
    }
}

#Preview {
    NavigationStack { ProfileView() }
}
