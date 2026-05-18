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
    /// **Story 3.10** — Set non-nil → présente une `.alert` informant que le
    /// cap de programmes dormants (10) ou démarrés (5) est atteint. Tap "OK"
    /// dismiss, tap "Voir mes programmes" scrolle vers le carrousel haut.
    @State private var capAlertContext: ProgramCapAlertContext?
    /// **Story 3.11** — Programme courant pour la sheet Replanifier. Non-nil
    /// = sheet présentée. Le caller câble `onSelect` côté `replanifyService`.
    @State private var replanifyTarget: ProgramSummary?

    /// **Story 3.10** — Contexte de l'alerte cap pour résoudre titre/message
    /// i18n côté View. `Identifiable` pour `.alert(item:)` SwiftUI.
    enum ProgramCapAlertContext: Identifiable {
        case dormant(limit: Int)
        case started(limit: Int)

        var id: String {
            switch self {
            case .dormant: return "dormant"
            case .started: return "started"
            }
        }
    }

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
                        AdaptedProgramScreen(
                            viewModel: AdaptedProgramViewModel(
                                program: route.program,
                                initialLeonNotes: route.initialLeonNotes,
                                recordId: route.recordId,
                                aiService: deps.sageCoachingAIService,
                                healthSummaryBuilder: DefaultHealthSummaryBuilder(healthKit: deps.healthKitService),
                                coreRepo: deps.coreProfileRepository,
                                coachingRepo: deps.coachingProfileRepository,
                                adaptedRepo: deps.adaptedProgramRepository
                            ),
                            modifiedSessionCoordinates: route.modifiedSessionCoordinates,
                            onConfirmStart: confirmStartClosure(for: route, deps: deps),
                            hasStarted: route.hasStarted
                        )
                    } else {
                        // Fallback : pas de deps (preview sans dependencies) → rendu statique sans Léon.
                        AdaptedProgramView(
                            program: route.program,
                            recordId: route.recordId,
                            hasStarted: route.hasStarted,
                            modifiedSessionCoordinates: route.modifiedSessionCoordinates
                        )
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
        // **Story 3.11** — sheet Replanifier (medium/large detents).
        .sheet(item: $replanifyTarget) { summary in
            ReplanifySheet(
                onSelect: { action in
                    Task { await handleReplanifyAction(action, summary: summary) }
                },
                onCancel: {
                    replanifyTarget = nil
                }
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        // **Story 3.10 AC12/AC13** — alerte cap dormant ou démarré atteint.
        // CTA primary "OK" dismiss. Pas de "Voir mes programmes" en V1
        // (l'écran courant est déjà le dashboard où l'user voit ses programmes).
        .alert(
            item: $capAlertContext,
            content: { ctx in
                switch ctx {
                case .dormant:
                    Alert(
                        title: Text("dashboard.program.cap.dormant.alert.title"),
                        message: Text("dashboard.program.cap.dormant.alert.message"),
                        dismissButton: .default(Text("common.ok"))
                    )
                case .started:
                    Alert(
                        title: Text("dashboard.program.cap.started.alert.title"),
                        message: Text("dashboard.program.cap.started.alert.message"),
                        dismissButton: .default(Text("common.ok"))
                    )
                }
            }
        )
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
        case let .active(programs, selectedId):
            // **Story 3.10** — refonte façon Decathlon Coach :
            //   - carrousel horizontal de ProgramCard
            //   - NextSessionCard du programme sélectionné en dessous
            //   - lien "Réorganiser ma semaine →" inchangé
            ActiveDashboardView(
                programs: programs,
                selectedId: selectedId,
                regenBadges: vm.regenBadgesByRecord,
                onSelectProgram: { id in
                    vm.selectProgram(id: id)
                },
                onTapStartSession: { summary in
                    Task { await handleStartSession(summary: summary) }
                },
                onTapProgram: { summary in
                    pushAdaptedProgramSummary(summary)
                },
                onDeleteProgram: { summary in
                    Task { await deleteProgramSummary(summary) }
                },
                onTapWeeklyReorder: {
                    weeklyCalendarPresented = true
                },
                onTapReplanify: { summary in
                    replanifyTarget = summary
                }
            )
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
        let modified = dashboardViewModel?.modifiedSessionCoordinates(forRecordId: record.id) ?? []
        adaptedRoute = AdaptedProgramRoute(
            program: applied.program,
            recordId: record.id,
            initialLeonNotes: applied.leonNotes,
            modifiedSessionCoordinates: modified,
            hasStarted: record.weekStartDate != nil
        )
    }

    /// Story 3.3b cleanup 2026-05-10 — swipe-to-delete depuis le dashboard.
    /// Archive le programme côté SwiftData (`isActive = false`) puis refresh le
    /// dashboard pour le retirer de la liste. Pas de hard-delete : l'historique
    /// reste pour audit / re-activation future éventuelle.
    @MainActor
    private func deleteProgramSummary(_ summary: ProgramSummary) async {
        guard let deps, let vm = dashboardViewModel else { return }
        guard let record = vm.recordsByID[summary.id] else { return }
        do {
            try await deps.adaptedProgramRepository.archive(record)
            await refreshDashboard()
        } catch {
            presentationError = error.localizedDescription
        }
    }

    /// **Story 3.10** — push AdaptedProgramView pour le programme représenté
    /// par le ProgramSummary. Résout le record via la map interne du VM, puis
    /// délègue à `pushAdaptedProgram(record:)`. No-op si record introuvable.
    @MainActor
    private func pushAdaptedProgramSummary(_ summary: ProgramSummary) {
        guard let vm = dashboardViewModel,
              let record = vm.recordsByID[summary.id]
        else { return }
        pushAdaptedProgram(record: record)
    }

    /// **Story 3.11** — handle action choisie dans `ReplanifySheet`.
    /// `reportSession` ou `shiftWeek` selon l'action, puis ferme la sheet,
    /// refresh le dashboard et affiche l'erreur en cas d'échec.
    @MainActor
    private func handleReplanifyAction(_ action: ReplanifyAction, summary: ProgramSummary) async {
        guard let deps else { return }
        do {
            switch action {
            case .reportSession:
                guard let sessionId = summary.nextSession?.id else {
                    replanifyTarget = nil
                    return
                }
                try await deps.replanifyService.reportSession(
                    programId: summary.id,
                    sessionId: sessionId
                )
            case .shiftWeek(let date):
                try await deps.replanifyService.shiftWeek(programId: summary.id, to: date)
            }
            replanifyTarget = nil
            await refreshDashboard()
        } catch {
            presentationError = error.localizedDescription
            replanifyTarget = nil
        }
    }

    /// **Story 3.10** — tap "Démarrer" sur NextSessionCard.
    ///
    /// Si le programme est dormant (`weekStartDate == nil`), on appelle d'abord
    /// `markStarted(recordId:)` côté repo (qui check le cap démarrés AC13 et
    /// pose `weekStartDate`). Si le cap est atteint, on affiche l'alerte
    /// `dashboard.program.cap.started`. Puis on push AdaptedProgramView.
    @MainActor
    private func handleStartSession(summary: ProgramSummary) async {
        guard let deps, let vm = dashboardViewModel else { return }
        guard let record = vm.recordsByID[summary.id] else { return }
        if record.weekStartDate == nil {
            do {
                try await deps.adaptedProgramRepository.markStarted(recordId: record.id)
            } catch ProgramCapReached.started(let limit) {
                capAlertContext = .started(limit: limit)
                return
            } catch {
                presentationError = error.localizedDescription
                return
            }
            await refreshDashboard()
        }
        // Re-fetch après markStarted (record peut être stale).
        if let refreshed = vm.recordsByID[summary.id] {
            pushAdaptedProgram(record: refreshed)
        } else {
            pushAdaptedProgram(record: record)
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
            coachingProfileRepository: deps.coachingProfileRepository,
            weeklyRegenApplicationService: deps.weeklyRegenApplicationService,
            weeklyRegenRepository: deps.weeklyRegenRepository
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
        // Story sœur 3.z (2026-05-17) — tap suggestion empty mode = preview, pas
        // commit. L'utilisateur visualise le programme adapté ; les 2 autres
        // suggestions restent dispo via le back. Tap "Démarrer ce programme" sur
        // l'écran preview déclenche la commit (`confirmStartClosure`). Sur échec
        // on tombe sur le questionnaire pour ne pas bloquer l'user.
        do {
            try await previewAutoProgram(sportCode: sportCode)
        } catch {
            #if DEBUG
            Self.persistLogger.debug("AutoProgramFactory preview failed (\(error.localizedDescription)) — fallback questionnaire")
            #endif
            sheetSelection = .questionnaire(sportCode: sportCode)
        }
    }

    /// Story sœur 3.z (2026-05-17) — génère un programme pré-rempli en mémoire
    /// (pas de persistance) et push `AdaptedProgramView` en mode preview.
    /// L'utilisateur peut revenir à la liste de suggestions sans avoir commit.
    /// La commit se fait via `confirmStartClosure(for:deps:)` quand l'utilisateur
    /// tape "Démarrer ce programme".
    private func previewAutoProgram(sportCode: String) async throws {
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
        let preview = try await factory.previewGenerate(
            sportCode: sportCode,
            userId: userId,
            autoprofileLevel: nil
        )
        adaptedRoute = AdaptedProgramRoute(
            program: preview.program,
            recordId: nil,
            previewSportProfile: preview.sportProfile
        )
    }

    /// Story sœur 3.z (2026-05-17) — closure passée à `AdaptedProgramScreen` pour
    /// le sticky CTA "Démarrer ce programme". `nil` si la route n'est pas en
    /// mode preview (programme déjà actif ouvert depuis dashboard). Sur tap :
    /// persiste sportProfile + record, refresh dashboard, pop la nav.
    private func confirmStartClosure(
        for route: AdaptedProgramRoute,
        deps: AppDependencies
    ) -> (() async -> Void)? {
        guard let previewProfile = route.previewSportProfile else { return nil }
        return {
            guard let userId = SupabaseService.shared.client.auth.currentSession?.user.id else { return }
            do {
                let factory = AutoProgramFactory(
                    sportProfileRepository: deps.coachingSportProfileRepository,
                    adaptedProgramRepository: deps.adaptedProgramRepository,
                    coachingProfileRepository: deps.coachingProfileRepository
                )
                let preview = AutoProgramPreview(program: route.program, sportProfile: previewProfile)
                _ = try await factory.commit(preview: preview, userId: userId)
                await refreshDashboard()
                // Pop vers Séances : dashboard refresh montre maintenant le programme
                // démarré en mode active.
                adaptedRoute = nil
            } catch ProgramCapReached.dormant(let limit) {
                // **Story 3.10 AC12** — cap dormant atteint : on garde l'écran
                // preview ouvert, on affiche l'alerte. L'user peut choisir
                // d'archiver un dormant existant puis retenter.
                capAlertContext = .dormant(limit: limit)
            } catch {
                presentationError = error.localizedDescription
            }
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
    /// Phase B.6 — coordonnées `(weekNumber, day)` des sessions S+1 mutées par
    /// la regen cette semaine. Highlight visuel côté `AdaptedProgramView` +
    /// `SessionDetailView`. Vide sur hot path post-adapt (record vient d'être
    /// créé) ou si pas de regen appliquée.
    let modifiedSessionCoordinates: Set<SessionCoordinate>
    /// Story sœur 3.z (2026-05-17) — sportProfile généré pour la preview mode
    /// (tap suggestion empty dashboard). Non-nil = pas encore persisté ; le tap
    /// "Démarrer ce programme" déclenche `commit(preview:)` via
    /// `SessionView.confirmStartClosure`. nil = ouverture d'un programme déjà
    /// actif depuis le dashboard active mode.
    let previewSportProfile: CoachingSportProfile?
    /// **Story 3.10** — `true` quand le programme correspondant à `recordId` a
    /// `weekStartDate != nil` (a été démarré au moins une fois). Forwardé à
    /// `AdaptedProgramView.hasStarted` pour cacher l'icône calendar des dormants.
    let hasStarted: Bool

    init(
        program: AdaptedProgram,
        recordId: UUID?,
        initialLeonNotes: LeonAppliedNotes? = nil,
        modifiedSessionCoordinates: Set<SessionCoordinate> = [],
        previewSportProfile: CoachingSportProfile? = nil,
        hasStarted: Bool = false
    ) {
        self.program = program
        self.recordId = recordId
        self.initialLeonNotes = initialLeonNotes
        self.modifiedSessionCoordinates = modifiedSessionCoordinates
        self.hasStarted = hasStarted
        self.previewSportProfile = previewSportProfile
    }

    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: AdaptedProgramRoute, rhs: AdaptedProgramRoute) -> Bool { lhs.id == rhs.id }
}

#Preview {
    SessionView()
        .environment(\.appDependencies, nil)
}
