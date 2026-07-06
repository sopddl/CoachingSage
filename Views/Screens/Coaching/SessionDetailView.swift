// Views/Screens/Coaching/SessionDetailView.swift
// Détail riche d'une AdaptedSession (push depuis AdaptedProgramView master) :
// header (nom + position S/J + durée + thème de la semaine), warmup, exercices
// avec sets/reps/duration/rest/zone/notes/substitutions, cooldown, adaptations
// filtrées sur cette séance, footer médical EU MDR.
import SwiftUI
import TemplateModel
import TemplateLoader

struct SessionDetailView: View {
    @Environment(\.locale) private var locale
    let session: AdaptedSession
    let week: AdaptedWeek
    let program: AdaptedProgram
    /// Phase B.6 — true si cette session a été mutée par la regen S+1 cette
    /// semaine (durée modifiée par `WeeklyRegenApplicationService`). Affiche
    /// un bandeau header explicatif. Default false côté preview.
    var isModifiedByRegen: Bool = false

    /// Phase A boucle complétion — id du `AdaptedProgramRecord` persistant.
    /// Nil sur le hot path post-adapt (programme tout frais) et sur Previews.
    /// Quand non-nil, expose le bouton "Marquer comme terminée".
    var recordId: UUID? = nil

    /// **Findings UX 2026-06-29 (#1)** — `false` quand cette séance appartient à
    /// un programme **dormant** (`weekStartDate == nil`, jamais « Démarré »). On
    /// désactive alors le bouton « Démarrer la séance » : il faut d'abord lancer
    /// le programme depuis sa fiche. Default `true` = hot path / preview /
    /// dashboard (programmes déjà actifs) → aucun gating.
    var programStarted: Bool = true

    @Environment(\.appDependencies) private var deps
    /// Pop de ce détail (push depuis le programme) — sert à remonter au programme
    /// une fois la séance complétée (Sophie 2026-06-12).
    @Environment(\.dismiss) private var dismiss
    @State private var completionVM: SessionCompletionViewModel?
    @State private var showCompleteSheet: Bool = false
    /// Story 3.17 Phase 1 — tooltip 1ère ouverture découvrabilité glossaire.
    @State private var showDiscoveryTooltip: Bool = false
    /// Story 3.33 (FOCUS) — présentation du mode exécution plein écran + état de
    /// reprise (indices d'étapes déjà faites, relu depuis `SessionProgressStore`).
    @State private var showFocus: Bool = false
    @State private var focusProgress: Set<Int> = []
    /// Levé par le FOCUS quand la séance est complétée pendant cette session (1ʳᵉ fois
    /// OU refaite) → on remonte au programme à la fermeture (Sophie 2026-06-12).
    @State private var focusDidComplete: Bool = false
    /// **Finding UX 2026-07-01 (Sophie)** — levé quand on ouvre la sheet de complétion
    /// via le bouton « Marquer comme terminée » (séance PAS encore faite), pas via
    /// « Modifier » (séance déjà faite). À la fermeture, si la séance a bien été
    /// enregistrée → on remonte au programme (comme le FOCUS). La modif d'une séance
    /// déjà faite reste sur place.
    @State private var completingFresh: Bool = false

    /// Chantier indoor/outdoor vélo (2026-06-10) — séance template « à lieu » (vélo
    /// avec variantes indoor/outdoor) résolue depuis le bundle, nil si la séance est
    /// agnostique (cas général). Quand non-nil, on affiche la puce 🏠/🛣️ et on
    /// substitue la variante effective au contenu adapté.
    @State private var templateSession: TemplateSession?
    /// Lieu effectif retenu pour cette séance (override séance ?? défaut ?? natif).
    @State private var locationEnv: SessionEnvironment?
    /// L1 (2026-06-11) — profils chargés une fois pour adapter la variante ALTERNATE via
    /// les règles par-exercice (constraint/equipment/medical), comme la séance native.
    /// nil tant que non chargés (ou hors vélo) → la variante retombe en passthrough.
    @State private var adapterFacade: AdapterSportProfile?
    @State private var coachingFacade: AdapterCoachingProfile?

    /// Chantier durée réglable, pilote cycling (Increment 3) — `PersistedSession`
    /// correspondante (weekNumber, day), chargée pour savoir si l'entrée « Ajuster la
    /// durée » est réglable (`SessionDurationScaler.isAdjustable`). `nil` hors cycling,
    /// preview, ou programme sans recordId.
    @State private var persistedDurationSession: PersistedSession?
    /// Contenu réellement persisté après un ajustement réussi — prime sur `session`
    /// (le paramètre reste figé à la valeur d'avant ajustement, cf `AdaptedProgramView`
    /// qui ne recharge pas son `program` en continu). `nil` tant qu'aucun ajustement
    /// n'a été fait dans cette session de navigation.
    @State private var adjustedSession: AdaptedSession?
    @State private var showDurationAdjustSheet: Bool = false

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    SessionHeroHeader(session: displaySession, week: week, program: program)

                    // Indoor/outdoor vélo (2026-06-10) — puce lieu flippable AVANT
                    // Démarrer (D3). 1 tap = bascule la VRAIE variante affichée.
                    if isLocationSession, let env = locationEnv {
                        SessionLocationChip(environment: env, onFlip: flipLocation)
                    }

                    // Chantier durée réglable, pilote cycling (Increment 3) — entrée
                    // « Ajuster la durée ». Masquée (pas grisée) si la séance est déjà
                    // complétée (doctrine section 9.3) ou non réglable.
                    if canAdjustDuration {
                        durationAdjustButton
                    }

                    // Story 3.35d — bouton Démarrer aussi EN HAUT (visible sans
                    // scroller), en plus de celui du bas.
                    startFocusButton

                    SessionWhyPanel(session: displaySession, week: week, program: program)

                    // Story 3.32 (AC7) — aperçu scannable : tap d'une ligne ancre
                    // vers le bloc correspondant dans la timeline détaillée.
                    SessionOverviewList(session: displaySession, sportCode: effectiveSessionSportCode) { anchorIndex in
                        withAnimation(.easeInOut(duration: 0.3)) {
                            proxy.scrollTo(SessionStepAnchor.id(anchorIndex), anchor: .top)
                        }
                    }

                    if isModifiedByRegen {
                        regenAdjustedBanner
                    }

                    SessionTimelineView(session: displaySession, sportColor: sessionSportColor, sportCode: effectiveSessionSportCode)

                    // Story 3.33 — bouton « ▶ Démarrer / Reprendre » : ouvre le
                    // mode FOCUS plein écran (exécution guidée pas-à-pas).
                    startFocusButton

                    // Story 3.35d — « Marquer comme terminée » SOUS Démarrer.
                    if let vm = completionVM {
                        completionSection(vm: vm)
                    }

                    // Story 3.35b — suggestions musique (liens vers l'app choisie).
                    // L'app ne joue rien (T3) : on aide à lancer SA musique.
                    if !focusSteps.isEmpty {
                        SessionMusicSuggestions(sportCode: effectiveSessionSportCode)
                    }

                    medicalReminderFooter
                }
                .padding()
            }
        }
        .navigationTitle(Text(verbatim: displaySession.name.resolved(locale).sanitizedForDisplay))
        .navigationBarTitleDisplayMode(.inline)
        .glossaryDiscoveryTooltip(isPresented: $showDiscoveryTooltip)
        .task {
            await resolveLocationIfNeeded()
            await bootstrapCompletionVMIfNeeded()
            await presentDiscoveryTooltipIfNeeded()
            await loadPersistedDurationSessionIfNeeded()
            reloadFocusProgress()
        }
        .sheet(isPresented: $showDurationAdjustSheet) {
            SessionDurationAdjustSheet(
                currentDurationMinutes: displaySession.durationMinutes,
                adjust: { target in
                    guard let recordId, let deps else {
                        throw SessionDurationAdjustmentError.programNotFound
                    }
                    return try await deps.sessionDurationAdjustmentService.adjustDuration(
                        programId: recordId, weekNumber: week.weekNumber, day: session.day, targetMinutes: target
                    )
                },
                onAdjusted: { result in
                    persistedDurationSession = result.session
                    adjustedSession = result.session.toAdaptedSession()
                    // Doctrine (Increment 2 reprise) : log backlog RGPD-safe (enum
                    // fermé, aucun verbatim) quand la cible demandée dépassait la
                    // fourchette réglable de la séance — signal produit « périodisation
                    // temporelle non honorée », pas une erreur.
                    if result.wasBounded {
                        Task {
                            await DefaultLeonUnmetRequestLogger().log(
                                LeonUnmetRequest(
                                    category: .periodisationTemporelle,
                                    response: .notYet,
                                    locale: Locale.current.identifier,
                                    appVersion: Bundle.main.shortVersion
                                )
                            )
                        }
                    }
                }
            )
        }
        .sheet(isPresented: $showCompleteSheet, onDismiss: {
            // **Finding UX 2026-07-01 (Sophie)** — séance terminée via le bouton direct
            // (pas le FOCUS) : si c'était une 1ʳᵉ complétion (`completingFresh`) ET
            // qu'elle a bien été enregistrée → on remonte au programme, au lieu de
            // rester sur le détail (cul-de-sac). Annulation sans valider → pas de pop.
            guard completingFresh else { return }
            completingFresh = false
            Task {
                await completionVM?.load()
                if completionVM?.completion != nil { dismiss() }
            }
        }) {
            if let vm = completionVM {
                SessionCompleteSheet(vm: vm, plannedDurationMinutes: displaySession.durationMinutes)
            }
        }
        .fullScreenCover(isPresented: $showFocus, onDismiss: {
            reloadFocusProgress()
            Task { await completionVM?.load() } // rafraîchit la section complétion
            // Séance FINIE pendant ce FOCUS (1ʳᵉ fois ou refaite) → on remonte au programme
            // avec la séance faite, au lieu de retomber sur « Démarrer » (retour Sophie
            // 2026-06-12). Sortie avant la fin (Reprendre plus tard / ✕) → flag à false →
            // on reste sur le détail pour permettre la reprise.
            if focusDidComplete { focusDidComplete = false; dismiss() }
        }) {
            SessionFocusView(session: displaySession, week: week, program: program,
                             recordId: recordId, didComplete: $focusDidComplete)
        }
    }

    // MARK: - Indoor/outdoor (chantier vélo 2026-06-10)

    /// Vrai si cette séance porte des variantes de lieu (vélo) → on montre la puce.
    private var isLocationSession: Bool {
        templateSession?.environment != nil && locationEnv != nil
    }

    /// Base affichée : `session` (paramètre, figé à la valeur au push) sauf si un
    /// ajustement de durée (Increment 3) a été fait dans cette session de navigation,
    /// auquel cas le contenu réellement persisté prime — sinon l'utilisateur verrait la
    /// séance revenir à son état pré-ajustement tant qu'il ne quitte pas cet écran.
    private var durationAdjustedBase: AdaptedSession {
        adjustedSession ?? session
    }

    /// Séance effectivement affichée : variante native → contenu adapté inchangé ;
    /// variante alternate → adaptée via les règles par-exercice (L1) si profils chargés,
    /// sinon passthrough (cf `SessionEnvironmentResolver`).
    private var displaySession: AdaptedSession {
        guard let ts = templateSession, let env = locationEnv else { return durationAdjustedBase }
        let resolved = SessionEnvironmentResolver.displaySession(
            adapted: durationAdjustedBase, templateSession: ts, effective: env, adaptVariant: variantAdapter
        )
        // 2A — en sortie extérieure, le renfo hors-vélo est retiré (gardé en home-trainer).
        // Au niveau vue car le lieu natif court-circuite `displaySession` (return adapted).
        return SessionEnvironmentResolver.filteringOffBikeStrength(resolved, sport: program.sport, effective: env)
    }

    /// Hook L1 — adapte la variante alternate via `ProgramAdapter.adaptSession` (rejoue
    /// constraint/equipment/medical sur ses exercices) dès que les profils sont chargés.
    /// nil → le resolver retombe en passthrough du template brut.
    private var variantAdapter: ((SessionVariant) -> AdaptedSession)? {
        guard let facade = adapterFacade, let coaching = coachingFacade else { return nil }
        return { variant in
            ProgramAdapter().adaptSession(
                variant: variant,
                day: session.day,
                type: session.type,
                weekNumber: week.weekNumber,
                sport: program.sport,
                level: program.level,
                templateId: program.templateId,
                sportProfile: facade,
                coachingProfile: coaching
            )
        }
    }

    /// Charge la séance template correspondante (vélo only) et résout le lieu effectif
    /// (override séance ?? défaut programme ?? natif). No-op si la séance n'a pas de
    /// variantes de lieu (cas général).
    private func resolveLocationIfNeeded() async {
        guard program.sport == .cycling, templateSession == nil else { return }
        // Chantier perf 2026-06-20 : via le cache partagé (mémoïsé) plutôt qu'un
        // décodage/scan à chaque flip indoor/outdoor.
        guard let template = try? await TemplateStore.shared.template(id: program.templateId),
              week.weekNumber - 1 >= 0, week.weekNumber - 1 < template.weeks.count else { return }
        let tWeek = template.weeks[week.weekNumber - 1]
        guard let tSession = tWeek.sessions.first(where: { $0.day == session.day }),
              let native = tSession.environment else { return }
        var sessionOverride: SessionEnvironment?
        var programDefault: String?
        if let recordId, let deps {
            let svc = SessionLocationService(repository: deps.adaptedProgramRepository)
            sessionOverride = (try? await svc.currentLocation(recordId: recordId, week: week.weekNumber, day: session.day)) ?? nil
            programDefault = (try? await svc.currentDefault(recordId: recordId)) ?? nil
        }
        templateSession = tSession
        locationEnv = SessionEnvironmentResolver.effectiveEnvironment(
            native: native, sessionOverride: sessionOverride, programDefault: programDefault
        )
        // L1 — charge les profils (une fois) pour adapter la variante alternate via les
        // règles par-exercice. Échec/absent → variantAdapter reste nil → passthrough.
        if let deps,
           let sp = (try? await deps.coachingSportProfileRepository.fetchProfile(for: program.sport.rawValue)) ?? nil,
           let cp = (try? await deps.coachingProfileRepository.fetchCurrentProfile()) ?? nil {
            adapterFacade = sp.adapterFacade(merging: cp.equipment)
            coachingFacade = cp.adapterFacade
        }
    }

    /// Bascule la séance vers l'autre lieu (D3 : 1 tap). Persiste l'override par séance
    /// et repart d'une progression FOCUS propre (les 2 variantes diffèrent en nb d'étapes).
    private func flipLocation() {
        guard let ts = templateSession, let current = locationEnv,
              let target = SessionEnvironmentResolver.flipTarget(from: current, templateSession: ts) else { return }
        locationEnv = target
        if let recordId {
            SessionProgressStore.documentsDefault()
                .clear(recordId: recordId, week: week.weekNumber, day: session.day)
            focusProgress = []
        }
        guard let recordId, let deps else { return }
        Task {
            let svc = SessionLocationService(repository: deps.adaptedProgramRepository)
            try? await svc.recordLocation(recordId: recordId, week: week.weekNumber, day: session.day, environment: target)
        }
    }

    // MARK: - Chantier durée réglable, pilote cycling (Increment 3)

    /// Vrai si l'entrée « Ajuster la durée » doit être proposée : V1 cycling only (D2),
    /// séance annotée en blocs budgétés (`SessionDurationScaler.isAdjustable`), programme
    /// persisté (recordId non-nil, pas de preview), **pas déjà complétée** (doctrine
    /// section 9.3 — masquée plutôt que grisée, pas de tooltip à traduire pour un cas rare),
    /// et **variante native affichée** (review Increment 3, angle C) — seule
    /// `record.sessions` (la variante native) est réellement ajustable/persistée ;
    /// proposer le bouton sur la variante alternate afficherait une durée qui n'est
    /// PAS celle réellement scalée (mismatch silencieux entre ce que l'user voit et
    /// ce que le service mute), cf doctrine D-T4 « scaling sur la variante active ».
    private var canAdjustDuration: Bool {
        guard program.sport == .cycling, recordId != nil, isDisplayingNativeLocationVariant,
              let persistedDurationSession, SessionDurationScaler.isAdjustable(persistedDurationSession)
        else { return false }
        return completionVM?.completion == nil
    }

    /// Vrai si la séance n'a pas de variantes de lieu, OU si la variante actuellement
    /// affichée est la variante native (par opposition à l'alternate indoor/outdoor).
    private var isDisplayingNativeLocationVariant: Bool {
        !isLocationSession || locationEnv == templateSession?.environment
    }

    private var durationAdjustButton: some View {
        Button {
            showDurationAdjustSheet = true
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "slider.horizontal.3")
                Text("coaching.session.durationAdjust.entry")
            }
            .font(.footnote.weight(.semibold))
            .foregroundStyle(Color.coachingPrimary)
        }
        .accessibilityIdentifier("coaching.session.durationAdjust.entry")
    }

    /// Charge la `PersistedSession` (weekNumber, day) — gate l'entrée « Ajuster la durée »
    /// (`isAdjustable`) ; le service refait sa propre lecture au moment de l'ajustement
    /// (source de vérité au moment du submit, pas ce cache d'UI). **Review Increment 3
    /// (angle altitude)** — sert AUSSI à rafraîchir `adjustedSession` : si cette séance a
    /// déjà été ajustée lors d'une session de navigation précédente, le contenu persisté
    /// (durée + exercices) diffère du `session` figé passé en paramètre ; sans ce
    /// rafraîchissement, rouvrir une séance déjà ajustée montrait encore l'ancien contenu.
    private func loadPersistedDurationSessionIfNeeded() async {
        guard program.sport == .cycling, persistedDurationSession == nil,
              let recordId, let deps else { return }
        let record = try? await deps.adaptedProgramRepository.fetchById(recordId: recordId)
        guard let persisted = record?.sessions.first(where: {
            $0.weekNumber == week.weekNumber && $0.day == session.day
        }) else { return }
        persistedDurationSession = persisted
        if persisted.durationMinutes != session.durationMinutes {
            adjustedSession = persisted.toAdaptedSession()
        }
    }

    // MARK: - FOCUS (Story 3.33)

    /// Étapes FOCUS de la séance (warmup→exos→cooldown). Vide pour une séance de
    /// repos → le bouton Démarrer est alors masqué.
    private var focusSteps: [SessionStep] { SessionStep.steps(for: displaySession) }

    /// True si une reprise est possible : on a un programme ancré (recordId), des
    /// étapes faites mais pas toutes.
    private var canResume: Bool {
        recordId != nil && !focusProgress.isEmpty && focusProgress.count < focusSteps.count
    }

    /// Numéro humain (1-based) de l'étape de reprise = 1ʳᵉ non faite.
    private var resumeStepNumber: Int {
        (focusSteps.firstIndex(where: { !focusProgress.contains($0.index) }) ?? 0) + 1
    }

    @ViewBuilder
    private var startFocusButton: some View {
        if !focusSteps.isEmpty {
            VStack(alignment: .leading, spacing: 6) {
                Button {
                    // Story 3.35h — un « Démarrer » (pas une reprise) repart à zéro :
                    // on efface la progression d'étapes pour permettre de REFAIRE une
                    // séance déjà faite (comme Decathlon Coach) sans qu'elle s'ouvre
                    // directement sur « terminée ».
                    if !canResume, let recordId {
                        SessionProgressStore.documentsDefault()
                            .clear(recordId: recordId, week: week.weekNumber, day: session.day)
                        focusProgress = []
                    }
                    showFocus = true
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "play.fill").font(.callout)
                        if canResume {
                            Text("coaching.session.focus.resume \(resumeStepNumber)")
                                .font(.callout.bold())
                        } else {
                            Text("coaching.session.focus.start")
                                .font(.callout.bold())
                        }
                        Spacer()
                    }
                    .padding(.vertical, 15)
                    .padding(.horizontal, 16)
                    .foregroundStyle(.white)
                    // **Findings UX 2026-06-29 (#1)** — programme dormant : bouton
                    // grisé + indice. On ne lance pas une séance d'un programme
                    // pas encore démarré (il faut le « Démarrer » depuis sa fiche).
                    .background(programStarted ? Color.coachingPrimary : Color.coachingPrimary.opacity(0.4))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(!programStarted)
                .accessibilityIdentifier("coaching.session.focus.start")

                if !programStarted {
                    Label("coaching.session.focus.start.dormant", systemImage: "info.circle")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .accessibilityIdentifier("coaching.session.focus.start.dormant")
                }
            }
        }
    }

    private func reloadFocusProgress() {
        guard let recordId else { focusProgress = []; return }
        focusProgress = SessionProgressStore.documentsDefault()
            .completedSteps(recordId: recordId, week: week.weekNumber, day: session.day)
    }

    private func bootstrapCompletionVMIfNeeded() async {
        guard let recordId, let deps, completionVM == nil else { return }
        let vm = SessionCompletionViewModel(
            recordId: recordId,
            weekNumber: week.weekNumber,
            day: session.day,
            repository: deps.adaptedProgramRepository
        )
        completionVM = vm
        await vm.load()
    }

    /// Story 3.17 — présente le tooltip de découvrabilité glossaire à la 1ère
    /// ouverture. Délai 0.6s pour laisser la vue se stabiliser, puis fade-in
    /// via animation du modifier. Skip si déjà vu OU en UI testing.
    private func presentDiscoveryTooltipIfNeeded() async {
        guard GlossaryDiscoveryTooltip.shouldPresent() else { return }
        try? await Task.sleep(nanoseconds: 600_000_000)
        guard !Task.isCancelled else { return }
        showDiscoveryTooltip = true
    }

    // MARK: - Completion section (Phase A)

    @ViewBuilder
    private func completionSection(vm: SessionCompletionViewModel) -> some View {
        if let record = vm.completion {
            completedCard(record: record, vm: vm)
        } else {
            Button {
                completingFresh = true
                showCompleteSheet = true
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                    Text("coaching.session.complete.button")
                        .font(.callout.bold())
                    Spacer()
                }
                .padding(.vertical, 14)
                .padding(.horizontal, 16)
                .foregroundStyle(.white)
                .background(Color.coachingPrimary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .accessibilityIdentifier("coaching.session.complete.button")
        }
    }

    private func completedCard(record: SessionCompletionRecord, vm: SessionCompletionViewModel) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundStyle(.green)
                Text("coaching.session.complete.completedAt \(Self.completionDateFormatter.string(from: record.completedAt))")
                    .font(.subheadline.bold())
                Spacer()
            }
            if let duration = record.actualDurationMinutes {
                Text("coaching.session.complete.duration.recorded \(duration)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            if let rpe = record.perceivedEffort {
                Text("coaching.session.complete.rpe.recorded \(rpe)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            if let notes = record.notes, !notes.isEmpty {
                BulletedNotes(text: notes, font: .caption)
                    .padding(.top, 2)
            }
            HStack(spacing: 12) {
                Button("coaching.session.complete.modify") {
                    completingFresh = false
                    showCompleteSheet = true
                }
                .buttonStyle(.bordered)
                Button("coaching.session.complete.undo", role: .destructive) {
                    Task { await vm.clear() }
                }
                .buttonStyle(.bordered)
            }
            .padding(.top, 4)
        }
        .padding(12)
        .background(Color.green.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .accessibilityIdentifier("coaching.session.complete.completedCard")
    }

    private static let completionDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }()

    // MARK: - Regen adjusted banner (Phase B.6)

    /// Bandeau header affiché quand la session a été ajustée par la regen S+1
    /// de la semaine courante. Tint orange cohérent avec le marker sparkles
    /// dans `AdaptedProgramView`. i18n keys remplies en B.7.
    private var regenAdjustedBanner: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "sparkles")
                .foregroundStyle(.orange)
                .font(.callout.weight(.semibold))
            VStack(alignment: .leading, spacing: 2) {
                Text("coaching.adapter.session.regen.banner.title")
                    .font(.subheadline.bold())
                Text("coaching.adapter.session.regen.banner.body")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .background(Color.orange.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("coaching.adapter.session.regen.banner")
    }

    // MARK: - Sport color helper

    /// Couleur sport effective pour la séance (utilisée par la timeline
    /// pour tinter les pastilles exercices). Triathlon → sub-sport inféré
    /// par `SessionSportInference`.
    private var sessionSportColor: Color {
        Color.coachingSport(forCode: effectiveSessionSportCode)
    }

    /// Story 3.19 — code sport effectif de la séance (triathlon → sub-sport inféré).
    /// Utilisé par `SessionTimelineView` pour résoudre le pattern biomécanique +
    /// la palette silhouette des illustrations exo.
    private var effectiveSessionSportCode: String {
        SessionSportInference.sportCode(
            forSessionName: displaySession.name.canonical,
            programSportCode: program.sport.appSportCode
        )
    }

    // MARK: - Medical footer

    private var medicalReminderFooter: some View {
        Text("coaching.adapter.medicalReminder.footer")
            .font(.caption2)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.leading)
            .padding(.top, 4)
    }
}

// MARK: - Preview

#if DEBUG
#Preview("SessionDetail — endurance") {
    NavigationStack {
        SessionDetailView(
            session: AdaptedProgramPreviewFixtures.sampleEnduranceSession(day: 1, name: "Footing facile"),
            week: AdaptedProgramPreviewFixtures.sampleWeek(1, theme: "Découverte"),
            program: AdaptedProgramPreviewFixtures.happyPath
        )
    }
}

#Preview("SessionDetail — intervals avec substitution") {
    NavigationStack {
        SessionDetailView(
            session: AdaptedSession(
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
            week: AdaptedWeek(weekNumber: 1, theme: "Découverte", goal: "Adapter aux contraintes", sessions: []),
            program: AdaptedProgramPreviewFixtures.kneeInjury
        )
    }
}

#Preview("SessionDetail — strength") {
    NavigationStack {
        SessionDetailView(
            session: AdaptedProgramPreviewFixtures.sampleStrengthSession(day: 5),
            week: AdaptedProgramPreviewFixtures.sampleWeek(1, theme: "Découverte"),
            program: AdaptedProgramPreviewFixtures.happyPath
        )
    }
}
#endif
