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

                if record != nil {
                    progressHeader
                }

                ForEach(program.weeks, id: \.weekNumber) { week in
                    weekAccordion(week)
                }

                medicalReminderFooter
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
        .navigationTitle(Text(verbatim: displayTitle))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // Bouton "Démarrer" toolbar trailing (preview ou dormant). Le tap
            // déclenche soit la commit + activation (preview), soit `markStarted`
            // (dormant existant). Sur un programme déjà actif, pas de bouton.
            if onConfirmStart != nil || isDormantRecord {
                ToolbarItem(placement: .topBarTrailing) {
                    startToolbarButton
                }
            }
            // Menu titre (rename) — disponible dans tous les modes où on a un
            // record SwiftData persisté.
            if record != nil {
                ToolbarTitleMenu {
                    Button {
                        renameBuffer = displayTitle
                    } label: {
                        Label("coaching.adapter.rename.action", systemImage: "pencil")
                    }
                }
            }
        }
        .task(id: recordId) { await loadRecord() }
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
            HStack(spacing: 4) {
                if isConfirmingStart || isStartingProgram {
                    ProgressView()
                        .controlSize(.mini)
                } else {
                    Image(systemName: "play.fill")
                        .font(.footnote.weight(.semibold))
                }
                Text("coaching.adapter.action.start")
                    .font(.subheadline.weight(.semibold))
            }
        }
        .disabled(isConfirmingStart || isStartingProgram)
        .accessibilityIdentifier("coaching.adapter.toolbar.start")
    }

    /// Sauve le `customTitle` côté record SwiftData + refresh la vue. Trim +
    /// guard non-vide : un titre vide retombe sur l'autoTitle (fallback).
    @MainActor
    private func saveRename() async {
        guard let buffer = renameBuffer else { return }
        let trimmed = buffer.trimmingCharacters(in: .whitespacesAndNewlines)
        renameBuffer = nil
        guard let record, let deps else { return }
        record.customTitle = trimmed.isEmpty ? nil : trimmed
        record.lastUpdatedAt = Date()
        try? await deps.adaptedProgramRepository.update(record)
    }

    // MARK: - Story 3.12 — Fetch record + accordéon helpers

    private func loadRecord() async {
        guard let recordId, let deps else {
            // Preview mode (pas de record) → S1 dépliée par défaut.
            if let firstWeek = program.weeks.first {
                expandedWeeks = [firstWeek.weekNumber]
            }
            return
        }
        let fetched = try? await deps.adaptedProgramRepository.fetchById(recordId: recordId)
        record = fetched
        expandedWeeks = [currentWeekNumber]
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

    private func expansionBinding(for weekNumber: Int) -> Binding<Bool> {
        Binding(
            get: { expandedWeeks.contains(weekNumber) },
            set: { expanded in
                if expanded {
                    expandedWeeks.insert(weekNumber)
                } else {
                    expandedWeeks.remove(weekNumber)
                }
            }
        )
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
        case .quotaExceeded: return String(localized: "coaching.adapter.leon.error.quota")
        case .anthropicUnavailable: return String(localized: "coaching.adapter.leon.error.unavailable")
        case .invalidPatch: return String(localized: "coaching.adapter.leon.error.invalidPatch")
        case .unauthorized: return String(localized: "coaching.adapter.leon.error.unauthorized")
        case .invalidRequest: return String(localized: "coaching.adapter.leon.error.invalidRequest")
        case .network: return String(localized: "coaching.adapter.leon.error.network")
        case .server: return String(localized: "coaching.adapter.leon.error.server")
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
        return DisclosureGroup(isExpanded: expansionBinding(for: week.weekNumber)) {
            VStack(alignment: .leading, spacing: 8) {
                if !week.goal.isEmpty {
                    Text(verbatim: week.goal)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                VStack(spacing: 6) {
                    ForEach(week.sessions, id: \.day) { session in
                        sessionRow(session, week: week)
                    }
                }
            }
            .padding(.top, 6)
        } label: {
            weekAccordionLabel(week: week, state: state)
        }
        .padding(.vertical, 4)
        .accessibilityIdentifier("coaching.adapter.week.\(week.weekNumber)")
    }

    @ViewBuilder
    private func weekAccordionLabel(week: AdaptedWeek, state: WeekState) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
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
            Spacer(minLength: 8)
            Text(verbatim: week.theme)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
    }

    private func sessionRow(_ session: AdaptedSession, week: AdaptedWeek) -> some View {
        let isModifiedByRegen = modifiedSessionCoordinates.contains(
            SessionCoordinate(weekNumber: week.weekNumber, day: session.day)
        )
        return NavigationLink {
            SessionDetailView(
                session: session,
                week: week,
                program: program,
                isModifiedByRegen: isModifiedByRegen,
                recordId: recordId
            )
        } label: {
            HStack(spacing: 12) {
                Image(systemName: program.sport.sfSymbol)
                    .frame(width: 24)
                    .foregroundStyle(.tint)
                VStack(alignment: .leading, spacing: 2) {
                    Text(verbatim: session.name)
                        .font(.subheadline.bold())
                        .foregroundStyle(.primary)
                    Text("coaching.adapter.session.shortLine \(week.weekNumber) \(session.day) \(session.durationMinutes)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
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
        .buttonStyle(.plain)
    }

    private func hasAdaptations(week: Int, day: Int) -> Bool {
        program.appliedRules.contains { $0.weekNumber == week && $0.day == day }
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
        }
    }

    static func outcomeColor(_ outcome: AppliedRule.Outcome) -> Color {
        switch outcome {
        case .substituted: return .orange
        case .removed: return .red
        case .downgraded: return .blue
        case .requiresAI: return .purple
        case .noChange: return .gray
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

    static func sampleWeek(_ wn: Int, theme: String) -> AdaptedWeek {
        AdaptedWeek(
            weekNumber: wn, theme: theme,
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
            day: day, name: name, durationMinutes: 40,
            type: .endurance,
            warmup: "5 min marche + 5 min footing très lent + 4 lignes droites",
            exercises: [
                AdaptedExercise(
                    name: "\(name) bloc principal",
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
