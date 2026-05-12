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
    /// V2 #6 — loader overlay pendant la génération auto déclenchée par tap
    /// suggestion mode vide (skip questionnaire). True pendant l'aller-retour
    /// `AutoProgramFactory.generate` (~quelques 100ms en moyenne).
    @State private var isGeneratingAutoProgram: Bool = false

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
                .overlay {
                    if isGeneratingAutoProgram { autoGeneratingOverlay }
                }
                .navigationTitle(Text("tab.session"))
                .navigationBarTitleDisplayMode(.large)
                .toolbar { calendarToolbar }
                .navigationDestination(isPresented: $weeklyCalendarPresented) {
                    WeeklyCalendarView(mode: .allActivePrograms)
                }
                .navigationDestination(item: $adaptedRoute) { route in
                    if let deps {
                        AdaptedProgramScreen(viewModel: AdaptedProgramViewModel(
                            program: route.program,
                            initialLeonNotes: route.initialLeonNotes,
                            recordId: route.recordId,
                            aiService: deps.sageCoachingAIService,
                            healthSummaryBuilder: DefaultHealthSummaryBuilder(healthKit: deps.healthKitService),
                            coreRepo: deps.coreProfileRepository,
                            coachingRepo: deps.coachingProfileRepository,
                            adaptedRepo: deps.adaptedProgramRepository
                        ))
                    } else {
                        // Fallback : pas de deps (preview sans dependencies) → rendu statique sans Léon.
                        AdaptedProgramView(program: route.program, recordId: route.recordId)
                    }
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
        // Sophie 2026-05-10 : force le tint app sur tous les éléments
        // navigation (back button "‹ Séances", chevrons, etc.) sinon iOS
        // applique le bleu système qui jure avec le bleu Léon coachingPrimary.
        .tint(Color.coachingPrimary)
    }

    /// V2 #6 — overlay « génération en cours » sur tap suggestion mode vide.
    /// Le hot path est rapide (<1s) mais l'overlay évite un freeze visuel
    /// pendant les awaits (fetch coachingProfile + save Supabase).
    private var autoGeneratingOverlay: some View {
        ZStack {
            Color.black.opacity(0.15).ignoresSafeArea()
            VStack(spacing: 12) {
                ProgressView()
                    .tint(Color.coachingPrimary)
                Text("session.auto.generating")
                    .font(.footnote)
                    .foregroundStyle(Color.coachingTextSecondary)
            }
            .padding(24)
            .background(Color.coachingBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(radius: 8)
        }
    }

    @ToolbarContentBuilder
    private var calendarToolbar: some ToolbarContent {
        // Bouton "+" : créer un nouveau programme. Affiché UNIQUEMENT en mode
        // dashboard actif (déjà ≥ 1 programme) — en mode vide le CTA principal
        // EmptyDashboardView suffit. Sophie 2026-05-10 : remplace le `CreateProgramOrRoutineCard`
        // du bas (peu visible). Action directe = SportPickerSheet (la distinction
        // routine vs programme est cachée au user, pivot via Q3 fréquence).
        // Tint forcé `coachingPrimary` (#1E5090) sinon iOS applique un bleu
        // système qui jure avec le bleu Léon (Sophie feedback 2026-05-10).
        if let mode = dashboardViewModel?.mode, mode != .empty {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    sheetSelection = .sportPicker
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(Color.coachingPrimary)
                        .accessibilityLabel(Text("dashboard.toolbar.create.label"))
                }
                .accessibilityHint(Text("dashboard.toolbar.create.hint"))
                .accessibilityIdentifier("dashboard.toolbar.create")
            }
        }

        ToolbarItem(placement: .topBarTrailing) {
            Button {
                weeklyCalendarPresented = true
            } label: {
                Image(systemName: "calendar")
                    .foregroundStyle(Color.coachingPrimary)
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
                    Task { await handleTap(sportCode: template.sport.appSportCode) }
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
                weeklyStats: vm.weeklyStats,
                nextAfterDominant: vm.nextAfterDominant,
                restDayHintKey: vm.restDayHintKey,
                nowProvider: { nowTick },
                onTapDominantStart: { result in
                    pushAdaptedProgram(record: result.program)
                },
                onTapProgram: { summary in
                    pushAdaptedProgram(record: summary.record)
                },
                onDeleteProgram: { summary in
                    Task { await deleteProgram(summary) }
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
        guard let applied = record.toAppliedAdaptedProgram() else {
            presentationError = String(localized: "session.adapter.profileMissing")
            return
        }
        adaptedRoute = AdaptedProgramRoute(
            program: applied.program,
            recordId: record.id,
            initialLeonNotes: applied.leonNotes
        )
    }

    /// Story 3.3b cleanup 2026-05-10 — swipe-to-delete depuis le dashboard.
    /// Archive le programme côté SwiftData (`isActive = false`) puis refresh le
    /// dashboard pour le retirer de la liste. Pas de hard-delete : l'historique
    /// reste pour audit / re-activation future éventuelle.
    @MainActor
    private func deleteProgram(_ summary: ActiveProgramSummary) async {
        guard let deps else { return }
        do {
            try await deps.adaptedProgramRepository.archive(summary.record)
            await refreshDashboard()
        } catch {
            presentationError = error.localizedDescription
        }
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
            coachingProfileRepository: deps.coachingProfileRepository,
            weeklyRegenApplicationService: deps.weeklyRegenApplicationService
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
            return
        }
        // V2 #6 — skip questionnaire pour les suggestions empty mode.
        // Defaults sensibles (level recreational si pas d'autoprofil, premier
        // goal du sport, fréquence 3, durée routineCyclic). Sur échec on
        // tombe sur le questionnaire pour ne pas bloquer l'user.
        do {
            try await generateAutoProgram(sportCode: sportCode)
        } catch {
            #if DEBUG
            Self.persistLogger.debug("AutoProgramFactory failed (\(error.localizedDescription)) — fallback questionnaire")
            #endif
            sheetSelection = .questionnaire(sportCode: sportCode)
        }
    }

    /// Génère un programme pré-rempli pour `sportCode` sans questionnaire et
    /// push directement `AdaptedProgramView`. Throws si pré-requis manquant
    /// (coachingProfile absent, library KO, Supabase save fail).
    private func generateAutoProgram(sportCode: String) async throws {
        guard let deps else {
            throw AutoProgramFactoryError.coachingProfileMissing
        }
        guard let userId = SupabaseService.shared.client.auth.currentSession?.user.id else {
            throw AutoProgramFactoryError.coachingProfileMissing
        }
        isGeneratingAutoProgram = true
        defer { isGeneratingAutoProgram = false }

        let factory = AutoProgramFactory(
            sportProfileRepository: deps.coachingSportProfileRepository,
            adaptedProgramRepository: deps.adaptedProgramRepository,
            coachingProfileRepository: deps.coachingProfileRepository
        )
        // TODO: brancher `autoprofileLevel` quand `CoachingProfile.healthAutofill`
        // sera dispo (cf SessionDashboardViewModel.suggestionLevelProvider).
        let result = try await factory.generate(
            sportCode: sportCode,
            userId: userId,
            autoprofileLevel: nil
        )
        await refreshDashboard()
        adaptedRoute = AdaptedProgramRoute(program: result.program, recordId: result.recordId)
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
        adaptedRoute = AdaptedProgramRoute(program: adapted, recordId: nil)
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
    /// Story 3.8 — id du `AdaptedProgramRecord` persisté ; alimente le toolbar 📅
    /// (entry point #2 `WeeklyCalendarView`). `nil` sur le hot path post-adapt.
    let recordId: UUID?
    /// Story 3.3b — notes Léon pré-existantes si push depuis dashboard d'un programme
    /// déjà raffiné par Léon (record.aiPatchApplied=true). `nil` sur hot path.
    let initialLeonNotes: LeonAppliedNotes?

    init(program: AdaptedProgram, recordId: UUID?, initialLeonNotes: LeonAppliedNotes? = nil) {
        self.program = program
        self.recordId = recordId
        self.initialLeonNotes = initialLeonNotes
    }

    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: AdaptedProgramRoute, rhs: AdaptedProgramRoute) -> Bool { lhs.id == rhs.id }
}

#Preview {
    SessionView()
        .environment(\.appDependencies, nil)
}
