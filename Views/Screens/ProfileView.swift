// Views/Screens/ProfileView.swift
// Story 2.3 — hub de modification profil. Form sectionné, sous-écrans via NavigationLink.
// Conserve signOut (Story 1.2) + DeleteAccount (Story 1.4).
import SwiftUI
import SageCore

struct ProfileView: View {
    @Environment(\.appDependencies) private var deps
    @Environment(\.languageManager) private var languageManager
    @State private var viewModel: ProfileViewModel?
    // Léon+ — le singleton @Observable doit être stocké en @State pour que la
    // View se re-render sur changement de tier (sinon lecture directe du
    // singleton dans le body ne déclenche pas d'update SwiftUI).
    @State private var storeKit = StoreKitService.shared
    @State private var showLeonUpsell = false

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
            authService: deps.authService,
            notificationService: deps.notificationService
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

                    // Voie de sortie si le re-fetch ne ramène toujours rien (cas où
                    // la row Supabase manque vraiment) : sign out → re-login → re-onboarding.
                    Button(role: .destructive) {
                        Task { try? await deps?.authService.signOut() }
                    } label: {
                        Text("profile.error.signOut")
                    }
                    .accessibilityIdentifier("profile.error.signOut")
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
                notificationsSection(vm: vm)
                privacySection(vm: vm)
                aboutSection(coaching: profiles.coaching)
                subscriptionSection
                accountSection
                #if DEBUG
                debugSection
                #endif
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.coachingBackground)
        .contentMargins(.bottom, 60, for: .scrollContent)
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

            // Story 3.35c — appli musique préférée (suggestions musique séance).
            HStack {
                Text("coaching.music.app.label")
                    .foregroundStyle(Color.coachingTextPrimary)
                Spacer()
                MusicStreamingSelectorView()
            }

            // Story 3.35d — voix du guidage audio (Homme/Femme). Le ON/OFF se règle
            // pendant la séance (mode Audio, haut droite).
            HStack {
                Text("coaching.session.voice.gender")
                    .foregroundStyle(Color.coachingTextPrimary)
                Spacer()
                VoiceGenderSelectorView()
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
    private func notificationsSection(vm: ProfileViewModel) -> some View {
        Section {
            HStack {
                Toggle(isOn: Binding(
                    get: { vm.notificationPrefs.enabled },
                    set: { newValue in Task { await vm.setNotificationsEnabled(newValue) } }
                )) {
                    Text("profile.notifications.enabled")
                }
                .tint(Color.coachingPrimary)
                .accessibilityIdentifier("profile.notifications.enabled.toggle")
                if vm.isNotificationsSaving {
                    ProgressView().controlSize(.mini)
                }
            }

            if vm.notificationSystemDenied {
                Text("profile.notifications.deniedHint")
                    .font(.coachingCaption)
                    .foregroundStyle(Color.coachingTextSecondary)
                Button("profile.notifications.openSettings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
            } else if vm.notificationPrefs.enabled {
                Toggle(isOn: typeBinding(vm: vm, \.sessionReminderEnabled)) {
                    Text("profile.notifications.sessionReminder")
                }
                .tint(Color.coachingPrimary)
                Toggle(isOn: typeBinding(vm: vm, \.nudgeEnabled)) {
                    Text("profile.notifications.nudge")
                }
                .tint(Color.coachingPrimary)
                Toggle(isOn: typeBinding(vm: vm, \.weeklyCelebrationEnabled)) {
                    Text("profile.notifications.celebration")
                }
                .tint(Color.coachingPrimary)
                Toggle(isOn: typeBinding(vm: vm, \.routineRenewalEnabled)) {
                    Text("profile.notifications.routineRenewal")
                }
                .tint(Color.coachingPrimary)

                DatePicker(
                    "profile.notifications.preferredTime",
                    selection: Binding(
                        get: {
                            Calendar.current.date(
                                bySettingHour: vm.notificationPrefs.preferredHour,
                                minute: vm.notificationPrefs.preferredMinute,
                                second: 0,
                                of: Date()
                            ) ?? Date()
                        },
                        set: { date in
                            let c = Calendar.current.dateComponents([.hour, .minute], from: date)
                            vm.notificationPrefs.preferredHour = c.hour ?? 9
                            vm.notificationPrefs.preferredMinute = c.minute ?? 0
                            vm.scheduleNotificationPrefsSave()
                        }
                    ),
                    displayedComponents: .hourAndMinute
                )
            }
        } header: {
            Text("profile.section.notifications")
        } footer: {
            Text("profile.notifications.footer")
        }
    }

    /// Binding pour un toggle de type : mute la pref + save debouncé.
    private func typeBinding(
        vm: ProfileViewModel,
        _ keyPath: WritableKeyPath<NotificationPreferences, Bool>
    ) -> Binding<Bool> {
        Binding(
            get: { vm.notificationPrefs[keyPath: keyPath] },
            set: { newValue in
                vm.notificationPrefs[keyPath: keyPath] = newValue
                vm.scheduleNotificationPrefsSave()
            }
        )
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
            // Story 3.4 prélude (2026-05-11) — réutilise l'écran HowItWorks de
            // l'onboarding en mode "consultation seule" (pas de bouton du bas,
            // navigation push retour via back system).
            NavigationLink {
                HowItWorksView()
                    .navigationTitle("profile.howItWorks.title")
                    .navigationBarTitleDisplayMode(.inline)
            } label: {
                Text("profile.howItWorks.title")
            }
            .accessibilityIdentifier("profile.about.howItWorks.link")

            NavigationLink {
                MedicalDisclaimerView(
                    versionAccepted: coaching.disclaimerVersionAccepted,
                    acceptedAt: coaching.disclaimerAcceptedAt
                )
            } label: {
                Text("profile.disclaimer.title")
            }
            .accessibilityIdentifier("profile.about.disclaimer.link")

            // Story 3.26 Phase B — page glossaire dédiée searchable + filtre sport.
            NavigationLink {
                GlossaryIndexView()
            } label: {
                Text("profile.glossary.title")
            }
            .accessibilityIdentifier("profile.about.glossary.link")
        }
    }

    // MARK: - Léon+

    @ViewBuilder
    private var subscriptionSection: some View {
        Section("profile.section.subscription") {
            if storeKit.currentTier == "free" {
                Button {
                    showLeonUpsell = true
                } label: {
                    HStack {
                        Text("profile.subscription.discover")
                        Spacer()
                        Text("profile.subscription.free")
                            .foregroundStyle(Color.coachingTextSecondary)
                    }
                }
                .accessibilityIdentifier("profile.subscription.discover")
            } else {
                HStack {
                    Text("profile.subscription.leonPlus")
                    Spacer()
                    Text("profile.subscription.active")
                        .foregroundStyle(Color.coachingPrimary)
                }
                .accessibilityIdentifier("profile.subscription.status")
            }
        }
        .sheet(isPresented: $showLeonUpsell) {
            LeonUpsellView(storeKitService: storeKit)
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

    #if DEBUG
    @ViewBuilder
    private var debugSection: some View {
        Section("DEBUG") {
            NavigationLink {
                SwimHealthKitInspectorView()
            } label: {
                Text(verbatim: "🐞 Inspecter HK natation (DEBUG)")
            }
            .accessibilityIdentifier("profile.debug.swimHKInspector.link")
        }
    }
    #endif
}

#Preview {
    NavigationStack { ProfileView() }
}
