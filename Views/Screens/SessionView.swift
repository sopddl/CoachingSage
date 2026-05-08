// Views/Screens/SessionView.swift
// Story 3.8 — onglet « Séances » dashboard. Bascule mode vide ↔ mode actif via
// `SessionDashboardViewModel`. Le hot path questionnaire → adapter → push
// `AdaptedProgramView` reste branché (entrée depuis card suggestion mode vide
// ou « Crée sur mesure »).
//
// Sous-tâche 6 livrée : mode vide complet (hint Léon + hero + 3 suggestions
// `selectTopN` + lien sur mesure). Modes actifs (singleProgram / multiProgram)
// restent en placeholder léger jusqu'à la sous-tâche 7.
//
// 100% local sur le hot path : 0 réseau, 0 token côté adaptation.
import SwiftUI
import os
import TemplateModel

struct SessionView: View {
    @Environment(\.appDependencies) private var deps

    @State private var dashboardViewModel: SessionDashboardViewModel?
    @State private var coachingProfile: CoachingProfile?
    @State private var loadingProfile: Bool = true
    @State private var library: ProgramTemplateLibrary?
    @State private var libraryLoadFailed: Bool = false
    @State private var sheetSelection: SheetSelection?
    @State private var adaptedRoute: AdaptedProgramRoute?
    @State private var presentationError: String?
    @State private var weeklyCalendarPresented: Bool = false
    @State private var nowTick: Date = Date()

    private let adapterService = ProgramAdapterService()
    private static let persistLogger = Logger(subsystem: "com.sopddl.coachingsage", category: "session-view")

    enum SheetSelection: Identifiable {
        case questionnaire(sportCode: String)
        case sportPicker

        var id: String {
            switch self {
            case .questionnaire(let s): return "questionnaire_\(s)"
            case .sportPicker:          return "sport_picker"
            }
        }
    }

    var body: some View {
        NavigationStack {
            content
                .background(Color.coachingBackground.ignoresSafeArea())
                .navigationTitle(Text("tab.session"))
                .navigationBarTitleDisplayMode(.large)
                .toolbar { calendarToolbar }
                .navigationDestination(isPresented: $weeklyCalendarPresented) {
                    WeeklyCalendarPlaceholderView()
                }
                .navigationDestination(item: $adaptedRoute) { route in
                    AdaptedProgramView(program: route.program)
                }
                .task {
                    await bootstrapVMIfNeeded()
                    await reloadProfile()
                    await loadLibraryIfNeeded()
                    await refreshDashboard()
                }
                .onAppear {
                    Task {
                        await reloadProfile(silent: true)
                        await refreshDashboard()
                    }
                }
        }
        .sheet(item: $sheetSelection) { selection in
            sheet(for: selection)
        }
    }

    @ToolbarContentBuilder
    private var calendarToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                weeklyCalendarPresented = true
            } label: {
                Image(systemName: "calendar")
                    .accessibilityLabel(Text("dashboard.toolbar.calendar"))
            }
            .accessibilityIdentifier("dashboard.toolbar.calendar")
        }
    }

    @ViewBuilder
    private var content: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let dashboardViewModel, !dashboardViewModel.loading || coachingProfile != nil {
                    modeContent(vm: dashboardViewModel)
                } else if loadingProfile || dashboardViewModel?.loading == true {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                } else {
                    Text("session.requestProgram.noProfile")
                        .font(.body)
                        .foregroundStyle(Color.coachingTextSecondary)
                        .padding(.vertical, 16)
                }

                if let presentationError {
                    Text(verbatim: presentationError)
                        .font(.footnote)
                        .foregroundStyle(Color.coachingError)
                        .padding(.vertical, 8)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
    }

    @ViewBuilder
    private func modeContent(vm: SessionDashboardViewModel) -> some View {
        switch vm.mode {
        case .empty:
            EmptyDashboardView(
                suggestions: vm.emptyModeSuggestions,
                hintKey: hintKey(for: vm),
                onTapSuggestion: { template in
                    Task { await handleTap(sportCode: template.sport.rawValue) }
                },
                onTapCustom: {
                    sheetSelection = .sportPicker
                }
            )
        case .singleProgram, .multiProgram:
            ActiveDashboardView(
                dominant: dominantNextSession(vm: vm),
                programs: vm.activeProgramSummaries,
                routines: vm.routines,
                nowProvider: { nowTick },
                onTapDominantStart: { result in
                    pushAdaptedProgram(record: result.program)
                },
                onTapProgram: { summary in
                    pushAdaptedProgram(record: summary.record)
                },
                onTapCreateProgram: {
                    sheetSelection = .sportPicker
                },
                onTapCreateRoutine: {
                    presentationError = String(localized: "dashboard.active.create.routine.placeholder")
                },
                onTapWeeklyReorder: {
                    weeklyCalendarPresented = true
                }
            )
        }
    }

    /// Récupère le `NextSessionResolver.Result` selon le mode courant — la
    /// View le passe à la card dominante quand pertinent.
    private func dominantNextSession(vm: SessionDashboardViewModel) -> NextSessionResolver.Result? {
        switch vm.mode {
        case .empty: return nil
        case .singleProgram(_, let next): return next
        case .multiProgram(_, let dominant): return dominant
        }
    }

    /// Reconstruit l'`AdaptedProgram` mémoire depuis le record persisté et push
    /// la vue maître. Si la conversion échoue (sport/level non mappable, hors
    /// V1), on flag l'erreur visible plutôt que de silencer la nav.
    private func pushAdaptedProgram(record: AdaptedProgramRecord) {
        guard let program = record.toAdaptedProgram() else {
            presentationError = String(localized: "session.adapter.profileMissing")
            return
        }
        adaptedRoute = AdaptedProgramRoute(program: program)
    }

    /// Texte hint Léon — calibré sur autoprofil HK quand `CoachingProfile.healthAutofill`
    /// existera (sous-tâche 8 + flux A/B). Pour V1, on choisit le texte selon la
    /// présence de sports déclarés à l'onboarding.
    private func hintKey(for vm: SessionDashboardViewModel) -> LocalizedStringKey {
        vm.declaredSportCodes.isEmpty
            ? "dashboard.empty.hint.default"
            : "dashboard.empty.hint.declared"
    }

    // MARK: - Bootstrap VM

    private func bootstrapVMIfNeeded() async {
        guard dashboardViewModel == nil, let deps else { return }
        dashboardViewModel = SessionDashboardViewModel(
            programRepository: deps.adaptedProgramRepository,
            routineRepository: deps.routineRepository,
            coachingProfileRepository: deps.coachingProfileRepository
        )
    }

    private func refreshDashboard() async {
        guard let vm = dashboardViewModel,
              let userId = SupabaseService.shared.client.auth.currentSession?.user.id
        else { return }
        await vm.refresh(userId: userId)
    }

    // MARK: - Tap handler

    private func handleTap(sportCode: String) async {
        guard let deps else { return }
        let existing = try? await deps.coachingSportProfileRepository.fetchProfile(for: sportCode)
        if let existing {
            await presentAdaptedProgram(for: existing)
        } else {
            sheetSelection = .questionnaire(sportCode: sportCode)
        }
    }

    // MARK: - Sheet routing

    @ViewBuilder
    private func sheet(for selection: SheetSelection) -> some View {
        switch selection {
        case .questionnaire(let code):
            questionnaireSheet(sportCode: code)
        case .sportPicker:
            SportPickerSheet { code in
                sheetSelection = .questionnaire(sportCode: code)
            }
        }
    }

    @ViewBuilder
    private func questionnaireSheet(sportCode: String) -> some View {
        if let deps {
            let questionnaire = questionnaireFor(sportCode: sportCode)
            let vm = SportQuestionnaireViewModel(
                questionnaire: questionnaire,
                repository: deps.coachingSportProfileRepository,
                authService: deps.authService
            )
            SportQuestionnaireView(
                viewModel: vm,
                requiresMedicalClearance: coachingProfile?.requiresMedicalClearance ?? false,
                healthKitService: deps.healthKitService,
                onCompleted: { sportProfile in
                    sheetSelection = nil
                    Task {
                        await reloadProfile(silent: true)
                        await presentAdaptedProgram(for: sportProfile)
                    }
                }
            )
        } else {
            Text("session.requestProgram.unsupportedSport")
        }
    }

    // MARK: - Hot path : selector → adapter → push

    private func presentAdaptedProgram(for sportProfile: CoachingSportProfile) async {
        await loadLibraryIfNeeded()
        guard let library else {
            presentationError = String(localized: "session.adapter.libraryUnavailable")
            return
        }
        guard let coachingProfile else {
            presentationError = String(localized: "session.adapter.profileMissing")
            return
        }
        presentationError = nil

        let selector = ProgramTemplateSelector(library: library)
        let template = selector.select(profile: sportProfile)
        let adapted = adapterService.adapt(
            template: template,
            sportProfile: sportProfile,
            coachingProfile: coachingProfile
        )
        await persistAdaptedProgram(adapted)
        adaptedRoute = AdaptedProgramRoute(program: adapted)
        await refreshDashboard()
    }

    /// Story 3.8 — persiste l'AdaptedProgram en `AdaptedProgramRecord` SwiftData
    /// pour alimenter le dashboard Séances. Best-effort : un échec n'empêche pas
    /// la navigation vers `AdaptedProgramView`.
    private func persistAdaptedProgram(_ adapted: AdaptedProgram) async {
        guard let deps else { return }
        guard let userId = SupabaseService.shared.client.auth.currentSession?.user.id else {
            #if DEBUG
            Self.persistLogger.debug("persistAdaptedProgram skipped: no auth session")
            #endif
            return
        }
        do {
            let record = AdaptedProgramRecord(from: adapted, userId: userId)
            try await deps.adaptedProgramRepository.save(record)
        } catch {
            Self.persistLogger.error("persistAdaptedProgram FAILED: \(error.localizedDescription)")
        }
    }

    // MARK: - Library loading

    private func loadLibraryIfNeeded() async {
        guard library == nil, !libraryLoadFailed else { return }
        do {
            library = try await ProgramTemplateLibrary.bundled()
        } catch {
            libraryLoadFailed = true
            presentationError = String(localized: "session.adapter.libraryUnavailable")
        }
    }

    // MARK: - Dispatch sport → questionnaire

    /// Phase 2 #5 — UniversalQuestionnaire pour les 10 sports (décision Sophie 2026-05-04).
    private func questionnaireFor(sportCode: String) -> SportQuestionnaire {
        UniversalQuestionnaire(sportCode: sportCode)
    }

    // MARK: - Profile loading

    private func reloadProfile(silent: Bool = false) async {
        guard let deps else {
            if !silent { loadingProfile = false }
            return
        }
        if !silent { loadingProfile = true }
        coachingProfile = try? await deps.coachingProfileRepository.fetchCurrentProfile()
        loadingProfile = false
    }
}

// MARK: - AdaptedProgramRoute (wrapper Hashable pour navigationDestination)

private struct AdaptedProgramRoute: Hashable {
    let id: UUID = UUID()
    let program: AdaptedProgram

    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: AdaptedProgramRoute, rhs: AdaptedProgramRoute) -> Bool { lhs.id == rhs.id }
}

#Preview {
    SessionView()
        .environment(\.appDependencies, nil)
}
