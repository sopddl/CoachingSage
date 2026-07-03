// Views/Screens/Coaching/AdaptedProgramView.swift
// Vue accordéon des semaines du programme adapté. Story 3.12 (refonte vue
// semaine vs jour) :
//   - Header progress global (X/N séances faites)
//   - Pour chaque semaine, un DisclosureGroup :
//       • Semaine courante = dépliée par défaut (sessions tap → SessionDetailView)
//       • Semaines passées = repliées, label "✓ N/N"
//       • Semaines futures = repliées, label thème (aperçu)
//   - En preview mode (`recordId == nil`) : pas de completionState, S1 dépliée.
//   - Pas de notion de jour calendaire : l'utilisateur fait ses séances dans
//     l'ordre qu'il veut au cours de la semaine.
import SwiftUI
import TemplateModel

struct AdaptedProgramView: View {
    @Environment(\.appDependencies) private var deps
    @Environment(\.languageManager) private var languageManager

    /// Locale in-app courante — résolution du contenu localisable des séances.
    private var locale: Locale { languageManager.currentLocale }

    let program: AdaptedProgram

    /// Callback déclenché par le bouton "Demander à Léon". Câblé en Story 3.3b
    /// par AdaptedProgramScreen (wrapper VM). `nil` côté Preview (rendu statique).
    var onRequestAIAssist: (() -> Void)? = nil

    /// Id de l'`AdaptedProgramRecord` persisté. Set par le push depuis le
    /// dashboard Séances mode actif. `nil` sur le hot path post-adapt (le record
    /// vient d'être créé).
    var recordId: UUID? = nil

    /// **Story 3.10** — `true` quand le programme a une `weekStartDate` posée
    /// (i.e. le user a tapé "Démarrer ma séance" au moins une fois).
    var hasStarted: Bool = false

    /// Story 3.3b — notes Léon overlay (perso + safety + adjustments). `nil` si
    /// pas de patch appliqué (état initial OU loading OU erreur).
    var leonNotes: LeonAppliedNotes? = nil

    /// Story 3.3b — état de la requête Léon en cours, exposé par le ViewModel.
    /// La View réagit avec un overlay loader / banner d'erreur correspondant.
    var requestState: AdaptedProgramViewModel.LeonRequestState = .idle

    /// Phase B.6 — coordonnées `(weekNumber, day)` des sessions mutées par la
    /// regen S+1 cette semaine. Marker `sparkles` orange sur les rows
    /// correspondantes + bandeau header dans `SessionDetailView` quand tap.
    var modifiedSessionCoordinates: Set<SessionCoordinate> = []

    /// Story sœur 3.z (2026-05-17) — callback "Démarrer ce programme" pour le
    /// mode preview. Quand non-nil, l'écran est en mode "aperçu" : aucune
    /// persistance n'a encore eu lieu, un sticky CTA s'affiche en bas. Tap
    /// déclenche la commit (persistance sportProfile + record) côté caller,
    /// puis pop de la nav vers le dashboard Séances. Sur le hot path normal
    /// (programme déjà actif), `onConfirmStart == nil` et le sticky CTA disparaît.
    var onConfirmStart: (() async -> Void)? = nil

    /// **Story 3.16 (Sophie 2026-05-21)** — callback "Retour à la home page"
    /// pour le mode preview. Sophie : « quand je termine de préparer avec Léon
    /// le programme la navigation est bizarre je devrait avoir deux bouton :
    /// Démarrer ou Lancer, et Retour à la home page ». Quand non-nil ET
    /// `onConfirmStart` non-nil, un sticky bottom 2 boutons remplace la simple
    /// toolbar trailing. Pop la nav vers le dashboard sans persistance.
    var onDismissPreview: (() -> Void)? = nil

    /// **Story 3.15 v3 (Sophie 2026-05-21)** — callback "Supprimer le
    /// programme" pour les programmes persistés (hors preview). Migré depuis
    /// le swipe-to-delete du carrousel dashboard (retiré pour ne plus masquer
    /// la border de la card sélectionnée). Quand non-nil, un bouton bas
    /// `deleteProgramFooter` apparaît avec confirmation.
    var onDeleteProgram: (() -> Void)? = nil

    /// **Story 3.15 v3** — alert confirmation suppression. Visible quand l'user
    /// tape "Supprimer le programme" en bas de la vue.
    @State private var showDeleteConfirmation: Bool = false

    /// Story sœur 3.z — true pendant l'aller-retour `commit` async. Disable le
    /// bouton "Démarrer" pour éviter le double-tap (qui créerait 2 records).
    @State private var isConfirmingStart: Bool = false

    /// **Story 3.12 hotfix** — true pendant l'aller-retour `markStarted` async.
    /// Disable le sticky CTA "Démarrer le programme" pour éviter le double-tap.
    @State private var isStartingProgram: Bool = false

    /// **Story 3.12 hotfix** — alerte cap démarré atteint lors du `markStarted`
    /// sur un programme dormant. Affichée en `.alert`. nil = pas d'alerte.
    @State private var startCapAlertLimit: Int? = nil

    /// **Story 3.12** — état de la sheet rename (tap sur le titre nav → alert
    /// TextField). nil = sheet fermée, non-nil = sheet ouverte avec ce buffer.
    @State private var renameBuffer: String? = nil

    /// **Story 3.12** — Record SwiftData fetché au montage de la vue. Source des
    /// `PersistedSession.id` (pour mapper le completionState) + `weekStartDate`
    /// (pour calculer la semaine courante). `nil` tant qu'on n'a pas reçu de
    /// `recordId` (preview mode) ou pendant le fetch initial.
    @State private var record: AdaptedProgramRecord? = nil
    /// **Story 3.12** — Set des numéros de semaines dépliées. Init à
    /// `{currentWeekNumber}` au mount (ou `{1}` en preview). L'utilisateur peut
    /// déplier/replier toutes les semaines manuellement.
    @State private var expandedWeeks: Set<Int> = []

    var body: some View {
        ScrollViewReader { proxy in
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if program.requiresAIAssist {
                    aiAssistBanner
                }

                if case let .error(error) = requestState {
                    leonErrorBanner(error)
                }

                if let notes = leonNotes, notes.hasAnything {
                    leonNotesSection(notes)
                }

                // Densité B (2026-07-02) — phrase Léon VRAIE : affichée UNIQUEMENT si
                // DensityRule a réellement agi (fork #3 Sophie). Hot path = appliedRules
                // en mémoire ; réouverture dashboard = record.densityApplied persisté.
                if densityWasApplied {
                    densityBanner
                }

                ForEach(program.weeks, id: \.weekNumber) { week in
                    weekAccordion(week)
                }

                medicalReminderFooter

                // **Story 3.15 v3 (Sophie 2026-05-21)** — bouton "Supprimer le
                // programme" en bas, uniquement pour les programmes persistés
                // (record != nil) et hors mode preview (onConfirmStart == nil).
                // Le swipe-to-delete carrousel ayant été supprimé, c'est la
                // seule porte de sortie pour archiver/supprimer.
                if record != nil, onConfirmStart == nil, onDeleteProgram != nil {
                    deleteProgramFooter
                    // Dégagement bas : le footer "Supprimer" est le dernier élément du
                    // scroll, sous la tab bar custom (overlay ZStack, MainTabView). Le
                    // `tabBarReservedHeight` (64) ne couvre pas le FAB Léon `offset -22`
                    // qui déborde → sans ce spacer la zone de tap du bouton chevauche la
                    // tab bar (visible mais intappable). Cf bug device-test Sophie.
                    Color.clear.frame(height: 44)
                }
            }
            .padding()
        }
        .alert(
            "dashboard.program.cap.started.alert.title",
            isPresented: Binding(
                get: { startCapAlertLimit != nil },
                set: { if !$0 { startCapAlertLimit = nil } }
            ),
            presenting: startCapAlertLimit
        ) { _ in
            Button("common.ok", role: .cancel) { startCapAlertLimit = nil }
        } message: { _ in
            Text("dashboard.program.cap.started.alert.message")
        }
        .alert(
            "coaching.adapter.rename.title",
            isPresented: Binding(
                get: { renameBuffer != nil },
                set: { if !$0 { renameBuffer = nil } }
            )
        ) {
            TextField(
                "coaching.adapter.rename.placeholder",
                text: Binding(
                    get: { renameBuffer ?? "" },
                    set: { renameBuffer = $0 }
                )
            )
            Button("common.ok") { Task { await saveRename() } }
            Button("common.cancel", role: .cancel) { renameBuffer = nil }
        } message: {
            Text("coaching.adapter.rename.message")
        }
        .overlay {
            if requestState == .loading {
                leonLoadingOverlay
            }
        }
        // **Findings UX 2026-06-29 (#2)** — en mode actif/dormant (record chargé)
        // le nom vit dans le bandeau sticky → on vide le titre nav pour ne pas
        // l'afficher deux fois. En preview/hot-path (pas de sticky), il reste là.
        .navigationTitle(Text(verbatim: record != nil ? "" : displayTitle))
        .navigationBarTitleDisplayMode(.inline)
        // **Findings UX 2026-06-29 (#4)** — l'avancement (X/N + barre) reste
        // visible pendant le scroll du contenu du programme : sorti du ScrollView
        // vers un inset top sticky (le titre, lui, est déjà figé dans la nav bar
        // `.inline`). Affiché uniquement en mode actif (record chargé), pas en
        // preview/hot-path où il n'y a pas de progression à montrer.
        .safeAreaInset(edge: .top, spacing: 0) {
            if record != nil {
                VStack(spacing: 8) {
                    // **Findings UX 2026-06-29 (#2)** — nom du programme TOUJOURS
                    // lisible (sticky), plus seulement la petite nav bar.
                    stickyProgramTitle
                    // **#4** — avancement (X/N + barre) qui ne défile plus.
                    // **Finding UX 2026-07-01 (Sophie)** — masqué tant que le programme
                    // est dormant (`weekStartDate == nil`) : « 0/N » sur un programme
                    // pas lancé n'a pas de sens (rien de fait) et induit en erreur.
                    if !isDormantRecord {
                        progressHeader
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 10)
                .background(.bar)
                .overlay(alignment: .bottom) { Divider() }
            }
        }
        // **Story 3.16 (Sophie 2026-05-21)** — sticky bottom 2 boutons en mode
        // preview post-questionnaire. "Retour" (sans persistance) + "Démarrer"
        // (commit). Avant : seul un bouton toolbar trailing (nav "bizarre").
        .safeAreaInset(edge: .bottom) {
            if onConfirmStart != nil, onDismissPreview != nil {
                previewBottomCTA
            }
        }
        .toolbar {
            // Bouton "Démarrer" toolbar trailing — UNIQUEMENT si pas de sticky
            // bottom 2-boutons (Story 3.16). Sinon redondant avec le CTA bottom.
            // Le mode dormant garde la toolbar (pas de sticky en dormant).
            if (onConfirmStart != nil && onDismissPreview == nil) || isDormantRecord {
                ToolbarItem(placement: .topBarTrailing) {
                    startToolbarButton
                }
            }
            // **Findings UX 2026-06-29 (#2)** — le renommage passe désormais par
            // le NOM dans le bandeau sticky (tap + crayon discret), plus par le
            // chevron ⌄ de la nav bar jugé pas parlant (retour Sophie). Le
            // `ToolbarTitleMenu` est donc retiré.
        }
        .task(id: recordId) { await loadRecord(); scrollToNextUndone(proxy) }
        }
    }

    /// Story 3.35k — positionne le scroll sur la 1ʳᵉ séance non faite à l'ouverture
    /// (toutes les semaines étant dépliées). Délai pour laisser la liste se layouter.
    private func scrollToNextUndone(_ proxy: ScrollViewProxy) {
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 350_000_000)
            guard let anchor = firstUndoneSessionAnchor else { return }
            withAnimation(.easeInOut(duration: 0.3)) { proxy.scrollTo(anchor, anchor: .top) }
        }
    }


    // MARK: - Story 3.12 — Toolbar start button + rename

    /// Titre affiché en nav bar. Priorité au `customTitle` du record, fallback
    /// vers `"{Sport} — {Goal}"` calculé à la volée (= cas record nil = preview,
    /// ou record pré-Story 3.12 sans customTitle).
    private var displayTitle: String {
        if let title = record?.customTitle, !title.isEmpty {
            return title
        }
        return AutoTitleBuilder.build(
            sportCode: program.sport.appSportCode,
            goal: nil, // pas dispo en fallback ; le sport seul suffit comme aperçu
            locale: languageManager.currentLocale
        )
    }

    /// **Story 3.15 v3 (Sophie 2026-05-21)** — footer bas "Supprimer le
    /// programme" (avec confirmation). Migration du swipe-to-delete carrousel
    /// pour libérer la border visuelle de la card sélectionnée.
    private var deleteProgramFooter: some View {
        VStack(spacing: 8) {
            Divider().padding(.vertical, 4)
            Button(role: .destructive) {
                showDeleteConfirmation = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "trash")
                    Text("coaching.adapter.delete.action")
                        .font(.subheadline.weight(.semibold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .contentShape(Rectangle()) // tout le rectangle tappable, pas que le glyphe
            }
            .buttonStyle(.plain)
            .foregroundStyle(Color.coachingError)
            .background(Color.coachingError.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .accessibilityIdentifier("coaching.adapter.delete")
        }
        .alert(
            "coaching.adapter.delete.confirm.title",
            isPresented: $showDeleteConfirmation
        ) {
            Button("coaching.adapter.delete.confirm.action", role: .destructive) {
                onDeleteProgram?()
            }
            Button("common.cancel", role: .cancel) {}
        } message: {
            Text("coaching.adapter.delete.confirm.message")
        }
    }

    /// **Story 3.16 (Sophie 2026-05-21)** — sticky bottom 2 CTAs en mode
    /// preview post-questionnaire Léon. "Retour" pop la nav sans persistance.
    /// "Démarrer ce programme" commit + active + navigue vers le dashboard.
    private var previewBottomCTA: some View {
        HStack(spacing: 12) {
            Button {
                onDismissPreview?()
            } label: {
                Text("coaching.adapter.preview.dismiss")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.plain)
            .background(Color.coachingCard)
            .foregroundStyle(Color.coachingTextPrimary)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .accessibilityIdentifier("coaching.adapter.preview.dismiss")

            Button {
                if let onConfirmStart {
                    guard !isConfirmingStart else { return }
                    isConfirmingStart = true
                    Task {
                        await onConfirmStart()
                        isConfirmingStart = false
                    }
                }
            } label: {
                HStack(spacing: 6) {
                    if isConfirmingStart {
                        ProgressView()
                            .controlSize(.mini)
                            .tint(Color.coachingOnPrimary)
                    } else {
                        Image(systemName: "play.fill")
                            .font(.footnote.weight(.semibold))
                    }
                    Text("coaching.adapter.action.start")
                        .font(.subheadline.weight(.semibold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
            }
            .buttonStyle(.plain)
            .background(Color.coachingPrimary)
            .foregroundStyle(Color.coachingOnPrimary)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .disabled(isConfirmingStart)
            .accessibilityIdentifier("coaching.adapter.preview.confirmStart")
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .padding(.bottom, 8)
        .background(.thinMaterial)
    }

    @ViewBuilder
    private var startToolbarButton: some View {
        Button {
            if let onConfirmStart {
                guard !isConfirmingStart else { return }
                isConfirmingStart = true
                Task {
                    await onConfirmStart()
                    isConfirmingStart = false
                }
            } else if isDormantRecord {
                guard !isStartingProgram else { return }
                Task { await handleStartProgram() }
            }
        } label: {
            // Story 3.15 v7.3 (Sophie 2026-05-21) — play seul (Sophie : « le
            // play est suffisant ne pas ajouter démarrer dans la fiche
            // programme »). Le label est porté par l'accessibilityLabel pour
            // VoiceOver.
            Group {
                if isConfirmingStart || isStartingProgram {
                    ProgressView()
                        .controlSize(.mini)
                } else {
                    Image(systemName: "play.fill")
                        .font(.headline.weight(.semibold))
                }
            }
        }
        .disabled(isConfirmingStart || isStartingProgram)
        .accessibilityLabel(Text("coaching.adapter.action.start"))
        .accessibilityIdentifier("coaching.adapter.toolbar.start")
    }

    /// Sauve le `customTitle` côté record SwiftData + refresh la vue. Trim +
    /// guard non-vide : un titre vide retombe sur l'autoTitle (fallback).
    ///
    /// **Story 3.28 Phase A** — set `isUserRenamed = true` quand l'user écrit
    /// un titre non-vide. Empêche le recalcul AutoTitleBuilder de l'écraser au
    /// changement de langue. Titre vide = retour au défaut (recalc dynamique
    /// gagne, `isUserRenamed = false`).
    @MainActor
    private func saveRename() async {
        guard let buffer = renameBuffer else { return }
        let trimmed = buffer.trimmingCharacters(in: .whitespacesAndNewlines)
        renameBuffer = nil
        guard let record, let deps else { return }
        if trimmed.isEmpty {
            record.customTitle = nil
            record.isUserRenamed = false
        } else {
            record.customTitle = trimmed
            record.isUserRenamed = true
        }
        record.lastUpdatedAt = Date()
        try? await deps.adaptedProgramRepository.update(record)
    }

    // MARK: - Story 3.12 — Fetch record + accordéon helpers

    private func loadRecord() async {
        // Story 3.35k — toutes les semaines OUVERTES par défaut (Sophie). Le scroll
        // se positionnera sur la prochaine séance non faite.
        expandedWeeks = Set(program.weeks.map(\.weekNumber))
        guard let recordId, let deps else { return }
        let fetched = try? await deps.adaptedProgramRepository.fetchById(recordId: recordId)
        record = fetched
    }

    /// Semaine courante du programme (1-indexed). Calculée depuis `weekStartDate`
    /// du record. Vaut 1 si le programme est dormant ou en preview.
    private var currentWeekNumber: Int {
        guard let start = record?.weekStartDate else { return 1 }
        let days = Calendar.current.dateComponents([.day], from: start, to: Date()).day ?? 0
        return max(1, (days / 7) + 1)
    }

    /// Nombre total de séances de tout le programme.
    private var totalSessionCount: Int {
        program.weeks.reduce(0) { $0 + $1.sessions.count }
    }

    /// Nombre de séances cochées sur l'ensemble du programme.
    private var globalCompletedCount: Int {
        record?.completionState.completedCount ?? 0
    }

    /// Nombre de séances cochées dans une semaine donnée.
    private func completedCount(inWeekNumber weekNumber: Int) -> Int {
        guard let record else { return 0 }
        let weekSessionIds = record.sessions
            .filter { $0.weekNumber == weekNumber }
            .map(\.id)
        return weekSessionIds.filter { record.completionState.sessionRecords[$0] != nil }.count
    }

    private enum WeekState { case past, current, future }

    private func state(of week: AdaptedWeek) -> WeekState {
        guard let record, record.weekStartDate != nil else { return .future }
        _ = record  // silence unused warning if record is dormant guard above changes
        if week.weekNumber < currentWeekNumber { return .past }
        if week.weekNumber == currentWeekNumber { return .current }
        return .future
    }

    /// **Story 3.12 hotfix** — `true` quand un record SwiftData a été fetché
    /// ET le programme est dormant (jamais démarré). Affiche le sticky CTA
    /// "Démarrer le programme" en bas de la vue.
    private var isDormantRecord: Bool {
        guard let record else { return false }
        return record.weekStartDate == nil
    }

    @MainActor
    private func handleStartProgram() async {
        guard let recordId, let deps else { return }
        isStartingProgram = true
        defer { isStartingProgram = false }
        do {
            try await deps.adaptedProgramRepository.markStarted(recordId: recordId)
            // Reload du record : `weekStartDate` est maintenant posée, la vue
            // bascule en mode actif (progressHeader visible, accordéon S1 dépliée).
            await loadRecord()
        } catch ProgramCapReached.started(let limit) {
            startCapAlertLimit = limit
        } catch {
            // Erreur générique silencieuse (cas dégénéré, ex. record disparu) ;
            // le retour dashboard via back nav reste accessible.
        }
    }

    // MARK: - AI assist banner

    private var aiAssistBanner: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "sparkles")
                    .foregroundStyle(.tint)
                VStack(alignment: .leading, spacing: 4) {
                    Text("coaching.adapter.aiAssist.banner.title")
                        .font(.headline)
                    if let reason = program.aiAssistReason {
                        Text(verbatim: reason)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("coaching.adapter.aiAssist.banner.subtitle")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            if let onRequestAIAssist, leonNotes == nil, requestState != .loading {
                Button {
                    onRequestAIAssist()
                } label: {
                    Text("coaching.adapter.aiAssist.cta")
                        .font(.callout.bold())
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .background(Color.accentColor.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Densité B — bannière phrase Léon (surface UNIQUE de la densité)

    /// True si la densification a réellement eu lieu. Hot path post-création :
    /// `program.appliedRules` en mémoire. Réouverture depuis le dashboard :
    /// `toAdaptedProgram()` reconstitue `appliedRules = []` → on lit le flag
    /// persisté `record.densityApplied`.
    private var densityWasApplied: Bool {
        record?.densityApplied == true
            || program.appliedRules.contains { $0.ruleType == .density }
    }

    /// Registre G7/G7bis : purement comportemental (« tu t'entraînes déjà
    /// régulièrement »), jamais capacité physique, jamais « pour ton objectif ».
    /// Déterministe, locale, 3 clés i18n — aucun réglage exposé (pivot 23/06).
    private var densityBanner: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "plus.circle.fill")
                .foregroundStyle(.teal)
            VStack(alignment: .leading, spacing: 4) {
                Text("coaching.adapter.density.banner.title")
                    .font(.headline)
                Text("coaching.adapter.density.banner.subtitle")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color.accentColor.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("adapter.density.banner")
    }

    // MARK: - Story 3.3b — Léon overlay UI

    private var leonLoadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.35).ignoresSafeArea()
            VStack(spacing: 16) {
                Image(systemName: "sparkles")
                    .font(.system(size: 36))
                    .foregroundStyle(.tint)
                ProgressView()
                Text("coaching.adapter.leon.loading.title")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                Text("coaching.adapter.leon.loading.subtitle")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding(24)
            .background(Color(uiColor: .systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(radius: 12)
            .padding()
        }
    }

    @ViewBuilder
    private func leonErrorBanner(_ error: LeonError) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)
            VStack(alignment: .leading, spacing: 4) {
                Text("coaching.adapter.leon.error.title")
                    .font(.subheadline.bold())
                Text(verbatim: leonErrorSubtitle(error))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func leonErrorSubtitle(_ error: LeonError) -> String {
        switch error {
        case .quotaExceeded: return String.localized("coaching.adapter.leon.error.quota", locale: locale)
        case .anthropicUnavailable: return String.localized("coaching.adapter.leon.error.unavailable", locale: locale)
        case .invalidPatch: return String.localized("coaching.adapter.leon.error.invalidPatch", locale: locale)
        case .unauthorized: return String.localized("coaching.adapter.leon.error.unauthorized", locale: locale)
        case .invalidRequest: return String.localized("coaching.adapter.leon.error.invalidRequest", locale: locale)
        case .network: return String.localized("coaching.adapter.leon.error.network", locale: locale)
        case .server: return String.localized("coaching.adapter.leon.error.server", locale: locale)
        }
    }

    @ViewBuilder
    private func leonNotesSection(_ notes: LeonAppliedNotes) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .foregroundStyle(.tint)
                Text("coaching.adapter.leon.notes.title")
                    .font(.headline)
            }
            if let perso = notes.personalizationNote, !perso.isEmpty {
                Text(verbatim: perso)
                    .font(.body)
                    .padding(.vertical, 2)
            }
            if !notes.adjustmentNotes.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(notes.adjustmentNotes, id: \.self) { line in
                        HStack(alignment: .top, spacing: 6) {
                            Text(verbatim: "•").foregroundStyle(.secondary)
                            Text(verbatim: line).font(.callout)
                        }
                    }
                }
            }
            if !notes.safetyNotes.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(notes.safetyNotes, id: \.self) { note in
                        HStack(alignment: .top, spacing: 6) {
                            Image(systemName: "shield.lefthalf.filled")
                                .font(.caption)
                                .foregroundStyle(.orange)
                            Text(verbatim: note).font(.caption).foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding()
        .background(Color.accentColor.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Sticky program title (Findings UX 2026-06-29 #2)

    /// Nom du programme dans le bandeau sticky : toujours lisible (jusqu'à 2 lignes,
    /// jamais tronqué en « … »). Tap = renommer (réutilise l'alert `renameBuffer`).
    /// Le crayon est discret (caption/secondary) : sur iPhone il n'y a pas de survol,
    /// donc l'édition se déclenche au tap du nom, le crayon ne fait que signaler.
    private var stickyProgramTitle: some View {
        Button {
            renameBuffer = displayTitle
        } label: {
            HStack(spacing: 6) {
                Text(verbatim: displayTitle)
                    .font(.headline)
                    .foregroundStyle(Color.coachingTextPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                Image(systemName: "pencil")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Spacer(minLength: 0)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("coaching.adapter.rename.action")
    }

    // MARK: - Progress header (Story 3.12)

    /// Compteur global de séances faites sur le programme + barre de progression.
    /// Affiché uniquement quand on a un record SwiftData chargé (mode actif).
    private var progressHeader: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                Text("coaching.adapter.progress.label")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.coachingTextSecondary)
                    .textCase(.uppercase)
                    .tracking(0.6)
                Spacer()
                Text("coaching.adapter.progress.count \(globalCompletedCount) \(totalSessionCount)")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.coachingTextPrimary)
                    .monospacedDigit()
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.coachingRecord.opacity(0.15))
                        .frame(height: 6)
                    Capsule()
                        .fill(Color.coachingRecord)
                        .frame(width: max(6, geo.size.width * progressFraction), height: 6)
                }
            }
            .frame(height: 6)
        }
        .accessibilityIdentifier("coaching.adapter.progress")
    }

    private var progressFraction: Double {
        guard totalSessionCount > 0 else { return 0 }
        return min(max(Double(globalCompletedCount) / Double(totalSessionCount), 0), 1)
    }

    // MARK: - Week accordion (Story 3.12)

    private func weekAccordion(_ week: AdaptedWeek) -> some View {
        let state = state(of: week)
        let isExpanded = expandedWeeks.contains(week.weekNumber)
        return VStack(alignment: .leading, spacing: 8) {
            // Header custom : le titre + le chevron togglent ; le « i » est un bouton
            // SÉPARÉ (avant, dans un DisclosureGroup, taper « i » repliait la semaine
            // et faisait « disparaître » les séances — bug Sophie 2026-06-03).
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { toggleWeek(week.weekNumber) }
                } label: {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        weekTitleAndState(week: week, state: state)
                        Spacer(minLength: 8)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                if !week.theme.canonical.isEmpty || !week.goal.canonical.isEmpty {
                    WeekInfoButton(theme: week.theme.resolved(locale), goal: week.goal.resolved(locale))
                }
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { toggleWeek(week.weekNumber) }
                } label: {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            if isExpanded {
                VStack(spacing: 6) {
                    ForEach(week.sessions, id: \.day) { session in
                        sessionRow(session, week: week)
                    }
                }
                .padding(.top, 2)
            }
        }
        .padding(.vertical, 4)
        .accessibilityIdentifier("coaching.adapter.week.\(week.weekNumber)")
    }

    private func toggleWeek(_ weekNumber: Int) {
        if expandedWeeks.contains(weekNumber) { expandedWeeks.remove(weekNumber) }
        else { expandedWeeks.insert(weekNumber) }
    }

    @ViewBuilder
    private func weekTitleAndState(week: AdaptedWeek, state: WeekState) -> some View {
        Text("coaching.adapter.week.label \(week.weekNumber)")
            .font(.headline)
            .foregroundStyle(Color.coachingTextPrimary)
        switch state {
        case .past:
            Text("coaching.adapter.week.completed \(completedCount(inWeekNumber: week.weekNumber)) \(week.sessions.count)")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Color.coachingRecord)
                .monospacedDigit()
        case .current:
            Text("coaching.adapter.week.current")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.coachingPrimary)
                .textCase(.uppercase)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.coachingPrimary.opacity(0.12))
                .clipShape(Capsule())
        case .future:
            EmptyView()
        }
    }

    private func sessionRow(_ session: AdaptedSession, week: AdaptedWeek) -> some View {
        let isModifiedByRegen = modifiedSessionCoordinates.contains(
            SessionCoordinate(weekNumber: week.weekNumber, day: session.day)
        )
        // Bug device-test Sophie 2026-06-08 : mettre la prochaine séance à lancer EN GROS
        // (comme l'accueil) au lieu d'une ligne plate indifférenciée.
        // **Findings UX 2026-06-29 (#1)** — MAIS pas sur un programme dormant : tant
        // qu'il n'est pas démarré, aucune séance ne doit paraître « lançable » (carte
        // verte + ▶). On la garde en ligne normale ; seul le ▶ « Démarrer le
        // programme » (toolbar) agit. La carte focale revient une fois le prog lancé.
        let isNext = !isDormantRecord
            && Self.sessionAnchor(week: week.weekNumber, day: session.day) == firstUndoneSessionAnchor
        return NavigationLink {
            SessionDetailView(
                session: session,
                week: week,
                program: program,
                isModifiedByRegen: isModifiedByRegen,
                recordId: recordId,
                // **Findings UX 2026-06-29 (#1)** — gate le bouton « Démarrer »
                // de la séance tant que le programme est dormant (jamais lancé).
                programStarted: !isDormantRecord
            )
        } label: {
            if isNext {
                featuredSessionLabel(session, week: week, isModifiedByRegen: isModifiedByRegen)
            } else {
                compactSessionLabel(session, week: week, isModifiedByRegen: isModifiedByRegen)
            }
        }
        .buttonStyle(.plain)
        .id(Self.sessionAnchor(week: week.weekNumber, day: session.day))
    }

    /// Ligne compacte standard (séances non-prochaines).
    private func compactSessionLabel(_ session: AdaptedSession, week: AdaptedWeek, isModifiedByRegen: Bool) -> some View {
        HStack(spacing: 12) {
            Image(systemName: sessionSymbol(for: session))
                .frame(width: 24)
                .foregroundStyle(Color.coachingSport(forCode: sessionEffectiveSportCode(for: session)))
            VStack(alignment: .leading, spacing: 2) {
                // Story 3.35k — petite ligne grise (Séance N · Sem · min) AU-DESSUS du libellé.
                Text("coaching.adapter.session.numberedLine \(globalSessionNumber(week: week.weekNumber, day: session.day)) \(week.weekNumber) \(session.durationMinutes)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(verbatim: session.name.resolved(locale).sanitizedForDisplay)
                    .font(.subheadline.bold())
                    .foregroundStyle(.primary)
            }
            Spacer()
            // Findings UX 2026-06-29 (#2) — « En cours » / « Faite » dérivés.
            sessionStatusBadge(week: week.weekNumber, day: session.day)
            if isModifiedByRegen {
                Image(systemName: "sparkles")
                    .foregroundStyle(.orange)
                    .font(.caption.weight(.semibold))
                    .accessibilityLabel(Text("coaching.adapter.session.regenAdjusted"))
                    .accessibilityIdentifier("coaching.adapter.session.regenMarker")
            }
            if hasAdaptations(week: week.weekNumber, day: session.day) {
                Image(systemName: "arrow.left.arrow.right.circle.fill")
                    .foregroundStyle(.orange)
                    .font(.caption)
            }
            Image(systemName: "chevron.right")
                .font(.caption.bold())
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    /// Carte « prochaine séance » mise en avant (bug device-test Sophie 2026-06-08) — gros
    /// titre + gradient couleur du sport + CTA, à l'image de la carte focale de l'accueil.
    private func featuredSessionLabel(_ session: AdaptedSession, week: AdaptedWeek, isModifiedByRegen: Bool) -> some View {
        let sportColor = Color.coachingSport(forCode: sessionEffectiveSportCode(for: session))
        // Findings UX 2026-06-29 (#2) — séance entamée : « REPRENDRE » plutôt que
        // « PROCHAINE » (cohérent avec le bouton « Reprendre l'étape N » du détail).
        let isInProgress = progressState(week: week.weekNumber, day: session.day) == .inProgress
        return VStack(alignment: .leading, spacing: 8) {
            Text(isInProgress ? "coaching.adapter.session.featured.resume" : "dashboard.active.next.title")
                .font(.caption.bold())
                .textCase(.uppercase)
                .foregroundStyle(Color.coachingOnPrimary.opacity(0.9))
            HStack(spacing: 12) {
                Image(systemName: sessionSymbol(for: session))
                    .font(.title2)
                    .foregroundStyle(Color.coachingOnPrimary)
                    .frame(width: 30)
                VStack(alignment: .leading, spacing: 3) {
                    Text("coaching.adapter.session.numberedLine \(globalSessionNumber(week: week.weekNumber, day: session.day)) \(week.weekNumber) \(session.durationMinutes)")
                        .font(.caption)
                        .foregroundStyle(Color.coachingOnPrimary.opacity(0.85))
                    Text(verbatim: session.name.resolved(locale).sanitizedForDisplay)
                        .font(.title3.bold())
                        .foregroundStyle(Color.coachingOnPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 8)
                Image(systemName: "play.circle.fill")
                    .font(.title)
                    .foregroundStyle(Color.coachingOnPrimary)
            }
            if isModifiedByRegen {
                Label("coaching.adapter.session.regenAdjusted", systemImage: "sparkles")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.coachingOnPrimary.opacity(0.9))
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(colors: [sportColor, sportColor.opacity(0.82)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .accessibilityIdentifier("coaching.adapter.session.next")
    }

    /// Ancre de scroll d'une séance (Story 3.35k — scroll auto vers la 1ʳᵉ non faite).
    static func sessionAnchor(week: Int, day: Int) -> String { "session-w\(week)-d\(day)" }

    /// (week, day) de la 1ʳᵉ séance non faite (hors repos). nil si tout fait / pas de record.
    private var firstUndoneSessionAnchor: String? {
        guard let record else {
            // Pas de record (preview) : 1ʳᵉ séance du programme.
            guard let w = program.weeks.first, let s = w.sessions.first else { return nil }
            return Self.sessionAnchor(week: w.weekNumber, day: s.day)
        }
        let done = record.completionState.sessionRecords
        let undone = record.sessions
            .filter { $0.type != .rest && done[$0.id] == nil }
            .sorted { ($0.weekNumber, $0.day) < ($1.weekNumber, $1.day) }
            .first
        guard let undone else { return nil }
        return Self.sessionAnchor(week: undone.weekNumber, day: undone.day)
    }

    /// Marqueur « adapté » (icône swap orange) d'une row séance. Les règles densité en
    /// sont EXCLUES : leur sémantique n'est pas une substitution, et la surface unique
    /// de la densité = la bannière Léon (pivot 23/06) — sinon un programme densifié
    /// allumerait le marqueur sur quasi toutes ses séances.
    private func hasAdaptations(week: Int, day: Int) -> Bool {
        program.appliedRules.contains {
            $0.weekNumber == week && $0.day == day && $0.ruleType != .density
        }
    }

    // MARK: - État de séance (Findings UX 2026-06-29 #2 — dérivé léger)

    /// État d'avancement d'une séance, DÉRIVÉ (zéro nouveau champ persistant) :
    /// `done` = une complétion enregistrée ; `inProgress` = de la progression
    /// d'étapes existe (séance entamée puis quittée) mais pas de complétion ;
    /// `notStarted` = rien. Une séance « lancée » n'est donc « Faite » qu'une fois
    /// terminée — entre les deux elle est « En cours / Reprendre ».
    private enum SessionProgressState { case notStarted, inProgress, done }

    private func progressState(week: Int, day: Int) -> SessionProgressState {
        guard let record,
              let sid = record.sessions.first(where: { $0.weekNumber == week && $0.day == day })?.id
        else { return .notStarted }
        if record.completionState.sessionRecords[sid] != nil { return .done }
        if let recordId,
           !SessionProgressStore.documentsDefault()
               .completedSteps(recordId: recordId, week: week, day: day).isEmpty {
            return .inProgress
        }
        return .notStarted
    }

    @ViewBuilder
    private func sessionStatusBadge(week: Int, day: Int) -> some View {
        switch progressState(week: week, day: day) {
        case .done:
            Label("coaching.adapter.session.status.done", systemImage: "checkmark.circle.fill")
                .labelStyle(.titleAndIcon)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(Color.coachingRecord)
                .accessibilityIdentifier("coaching.adapter.session.status.done")
        case .inProgress:
            Text("coaching.adapter.session.status.inProgress")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(Color.coachingPrimary)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.coachingPrimary.opacity(0.12))
                .clipShape(Capsule())
                .accessibilityIdentifier("coaching.adapter.session.status.inProgress")
        case .notStarted:
            EmptyView()
        }
    }

    /// Story 3.35j — numéro de séance INCRÉMENTAL sur tout le programme (Sophie :
    /// « presque plus important que le numéro de la semaine »). Ordre semaine puis jour.
    private func globalSessionNumber(week: Int, day: Int) -> Int {
        var n = 0
        for w in program.weeks.sorted(by: { $0.weekNumber < $1.weekNumber }) {
            for s in w.sessions.sorted(by: { $0.day < $1.day }) {
                n += 1
                if w.weekNumber == week && s.day == day { return n }
            }
        }
        return n
    }

    /// Story 3.15 v7.2 (Sophie 2026-05-21) — symbole par session, sport-aware.
    /// Pour un programme **mono-sport** (running / cycling / …) → symbole du
    /// sport parent (inchangé). Pour **triathlon**, on parse le nom de session
    /// via `SessionSportInference` pour distinguer Swim / Bike / Run ; si
    /// aucun match (séances S&C ou Mobilité), on retombe sur le `SessionType`
    /// (`AdaptedProgramFormatting.sfSymbol(for:)`) pour avoir un symbole utile
    /// (dumbbell pour strength, cooldown pour mobility) plutôt que toujours
    /// `figure.mixed.cardio`.
    private func sessionSymbol(for session: AdaptedSession) -> String {
        let parentCode = program.sport.appSportCode
        let effective = SessionSportInference.sportCode(
            forSessionName: session.name.canonical,
            programSportCode: parentCode
        )
        if effective != parentCode {
            return SportSymbol.symbol(forCode: effective)
        }
        if parentCode == "triathlon" {
            return AdaptedProgramFormatting.sfSymbol(for: session.type)
        }
        return SportSymbol.symbol(forCode: parentCode)
    }

    /// Story 3.15 v7.3 (Sophie 2026-05-21) — code sport effectif d'une session,
    /// utilisé pour coloriser le symbole (`Color.coachingSport(forCode:)`).
    /// Aligné sur `sessionSymbol(for:)` : pour triathlon multi-sport, retourne
    /// `running` / `cycling` / `swimming` selon le nom de session, sinon
    /// le sport parent.
    private func sessionEffectiveSportCode(for session: AdaptedSession) -> String {
        let parentCode = program.sport.appSportCode
        return SessionSportInference.sportCode(
            forSessionName: session.name.canonical,
            programSportCode: parentCode
        )
    }

    // MARK: - Medical reminder

    private var medicalReminderFooter: some View {
        Text("coaching.adapter.medicalReminder.footer")
            .font(.caption2)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.leading)
            .padding(.top, 8)
    }
}

// MARK: - Formatting helpers (partagés avec SessionDetailView)

enum AdaptedProgramFormatting {
    static func sfSymbol(for type: SessionType) -> String {
        switch type {
        case .endurance: return "figure.run"
        case .interval: return "bolt.fill"
        case .technique: return "scope"
        case .strength: return "dumbbell.fill"
        case .mixed: return "shuffle"
        case .mobility: return "figure.cooldown"
        case .rest: return "pause.fill"
        case .other: return "circle"
        }
    }

    static func outcomeSFSymbol(_ outcome: AppliedRule.Outcome) -> String {
        switch outcome {
        case .substituted: return "arrow.left.arrow.right.circle.fill"
        case .removed: return "minus.circle.fill"
        case .downgraded: return "arrow.down.circle.fill"
        case .requiresAI: return "sparkles"
        case .noChange: return "circle"
        case .densified: return "plus.circle.fill"
        }
    }

    static func outcomeColor(_ outcome: AppliedRule.Outcome) -> Color {
        switch outcome {
        case .substituted: return .orange
        case .removed: return .red
        case .downgraded: return .blue
        case .requiresAI: return .purple
        case .noChange: return .gray
        case .densified: return .teal
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview("AdaptedProgram — happy path") {
    NavigationStack {
        AdaptedProgramView(program: AdaptedProgramPreviewFixtures.happyPath)
    }
}

#Preview("AdaptedProgram — knee-injury substitution") {
    NavigationStack {
        AdaptedProgramView(program: AdaptedProgramPreviewFixtures.kneeInjury) { }
    }
}

#Preview("AdaptedProgram — densifié (bannière Léon)") {
    NavigationStack {
        AdaptedProgramView(program: AdaptedProgramPreviewFixtures.densified) { }
    }
}

#Preview("AdaptedProgram — requires AI assist") {
    NavigationStack {
        AdaptedProgramView(program: AdaptedProgramPreviewFixtures.requiresAI) { }
    }
}

enum AdaptedProgramPreviewFixtures {
    static var happyPath: AdaptedProgram {
        AdaptedProgram(
            templateId: "running-fixture",
            sport: .running,
            level: .beginner,
            appliedAt: Date(),
            weeks: [
                sampleWeek(1, theme: "Découverte"),
                sampleWeek(2, theme: "Consolidation")
            ],
            appliedRules: [],
            requiresAIAssist: false
        )
    }

    static var kneeInjury: AdaptedProgram {
        AdaptedProgram(
            templateId: "running-fixture",
            sport: .running,
            level: .beginner,
            appliedAt: Date(),
            weeks: [
                AdaptedWeek(
                    weekNumber: 1, theme: "Découverte", goal: "Adapter aux contraintes",
                    sessions: [
                        AdaptedSession(
                            day: 1, name: "Plyo intervals", durationMinutes: 30,
                            type: .interval,
                            warmup: "10 min footing très lent + 4 lignes droites",
                            exercises: [
                                AdaptedExercise(
                                    name: "Marche nordique 20 min",
                                    originalName: "Bondissements 6×30s",
                                    duration: "20 min",
                                    notes: "Bâtons en cadence, allure soutenue mais conversation possible.",
                                    targetZone: "Daniels-E",
                                    volumeAxis: .duration,
                                    wasSubstituted: true,
                                    substitutionReason: "constraint:knee-injury"
                                )
                            ],
                            cooldown: "5 min marche + étirements doux"
                        ),
                        sampleEnduranceSession(day: 3, name: "Tempo continu")
                    ]
                ),
                sampleWeek(2, theme: "Consolidation")
            ],
            appliedRules: [
                AppliedRule(
                    ruleType: .constraintSubstitution,
                    weekNumber: 1, day: 1,
                    originalExerciseName: "Bondissements 6×30s",
                    outcome: .substituted,
                    detail: "« Bondissements 6×30s » → « Marche nordique 20 min » (knee-injury)"
                )
            ],
            requiresAIAssist: false
        )
    }

    static var requiresAI: AdaptedProgram {
        AdaptedProgram(
            templateId: "running-fixture",
            sport: .running,
            level: .beginner,
            appliedAt: Date(),
            weeks: [sampleWeek(1, theme: "Découverte")],
            appliedRules: [
                AppliedRule(
                    ruleType: .constraintSubstitution,
                    weekNumber: 1, day: 1,
                    originalExerciseName: "Niche-exo",
                    outcome: .requiresAI,
                    detail: "« Niche-exo » incompatible (pregnancy) — pas d'alternative"
                )
            ],
            requiresAIAssist: true,
            aiAssistReason: "Aucune alternative pour la contrainte « pregnancy »"
        )
    }

    /// Densité B — programme densifié à la création (signal activité régulière) :
    /// la règle `.density` déclenche la bannière phrase Léon en tête de programme.
    static var densified: AdaptedProgram {
        AdaptedProgram(
            templateId: "running-fixture",
            sport: .running,
            level: .beginner,
            appliedAt: Date(),
            weeks: [
                sampleWeek(1, theme: "Découverte"),
                sampleWeek(2, theme: "Consolidation")
            ],
            appliedRules: [
                AppliedRule(
                    ruleType: .density,
                    weekNumber: 1, day: 5,
                    originalExerciseName: "Gainage planche",
                    outcome: .densified,
                    detail: "+1 série (3 → 4) — démarrage un cran au-dessus (activité régulière)"
                )
            ],
            requiresAIAssist: false
        )
    }

    static func sampleWeek(_ wn: Int, theme: String) -> AdaptedWeek {
        AdaptedWeek(
            weekNumber: wn, theme: LocalizedText(fr: theme),
            goal: "Construire l'endurance de base et installer une cadence régulière.",
            sessions: [
                sampleEnduranceSession(day: 1, name: "Footing facile"),
                sampleIntervalSession(day: 3),
                sampleStrengthSession(day: 5)
            ]
        )
    }

    static func sampleEnduranceSession(day: Int, name: String) -> AdaptedSession {
        AdaptedSession(
            day: day, name: LocalizedText(fr: name), durationMinutes: 40,
            type: .endurance,
            warmup: "5 min marche + 5 min footing très lent + 4 lignes droites",
            exercises: [
                AdaptedExercise(
                    name: LocalizedText(fr: "\(name) bloc principal"),
                    originalName: "\(name) bloc principal",
                    duration: "30 min",
                    notes: "Reste en respiration nasale, allure conversation possible.",
                    targetZone: "Daniels-E",
                    volumeAxis: .duration
                )
            ],
            cooldown: "5 min marche + étirements debout"
        )
    }

    static func sampleIntervalSession(day: Int) -> AdaptedSession {
        AdaptedSession(
            day: day, name: "Fractionné court", durationMinutes: 45,
            type: .interval,
            warmup: "10 min footing progressif + 4 lignes droites en accélération",
            exercises: [
                AdaptedExercise(
                    name: "6 × 400 m allure VMA",
                    originalName: "6 × 400 m allure VMA",
                    sets: 6,
                    reps: "400 m",
                    restSeconds: 90,
                    notes: "Récup en footing très lent, jamais à l'arrêt.",
                    targetZone: "Daniels-I",
                    volumeAxis: .distance
                )
            ],
            cooldown: "8 min footing facile puis marche"
        )
    }

    static func sampleStrengthSession(day: Int) -> AdaptedSession {
        AdaptedSession(
            day: day, name: "Renfo course", durationMinutes: 30,
            type: .strength,
            warmup: "5 min mobilité hanches + chevilles",
            exercises: [
                AdaptedExercise(
                    name: "Squat",
                    originalName: "Squat",
                    sets: 3,
                    reps: "12",
                    restSeconds: 60,
                    notes: "Tempo 3-1-1, descente contrôlée.",
                    volumeAxis: .reps
                ),
                AdaptedExercise(
                    name: "Fentes alternées",
                    originalName: "Fentes alternées",
                    sets: 3,
                    reps: "10/jambe",
                    restSeconds: 60,
                    volumeAxis: .reps
                ),
                AdaptedExercise(
                    name: "Gainage planche",
                    originalName: "Gainage planche",
                    sets: 3,
                    duration: "45 s",
                    restSeconds: 30,
                    notes: "Bassin neutre, pas de cambrure lombaire.",
                    volumeAxis: .duration
                )
            ],
            cooldown: "Étirements ischios + mollets"
        )
    }
}
#endif
