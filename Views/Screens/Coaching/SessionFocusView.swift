// Views/Screens/Coaching/SessionFocusView.swift
// Story 3.33 (FOCUS = EXÉCUTER) — mode plein écran d'exécution d'une séance, un
// exo à la fois. Porté du pattern HUB+FOCUS TailorSage (`ProjectStepFocusView`) :
//   - TabView(.page) : swipe ← → entre étapes ; barre top (fermer + « 3/11 » +
//     points ●◐○) ; nav bas ‹ Précédent / Suivant ›.
//   - Bouton « ✓ Fait » → coche + AUTO-AVANCE (onChange completedCount, ~350ms).
//   - Warmup & cooldown = première/dernière étape (AC5) ; exos = card riche
//     (illustration + notes + métriques + « Comment l'exécuter ? », AC6).
//   - Toutes étapes faites → récap `SessionCompleteSheet` (AC8) puis fermeture.
// Shell de base réutilisé par les modes Minuté (3.34) / Audio (3.35).
import SwiftUI
import Combine
import UIKit
import TemplateModel

struct SessionFocusView: View {
    let session: AdaptedSession
    let week: AdaptedWeek
    let program: AdaptedProgram
    var recordId: UUID? = nil

    @Environment(\.dismiss) private var dismiss
    @Environment(\.appDependencies) private var deps
    @Environment(\.languageManager) private var languageManager

    @State private var viewModel: SessionFocusViewModel
    @State private var selectedIndex: Int
    @State private var showCompletion = false
    @State private var showCompleteSheet = false
    @State private var completionVM: SessionCompletionViewModel?

    // Story 3.34 — mode Minuté (HIIT/yoga).
    @State private var timerEngine: SessionTimerEngine
    @State private var audioCues = SessionAudioCues()
    // Story 3.35 — mode Audio (voix par-dessus le déroulé chronométré).
    @State private var voiceGuide: SessionVoiceGuide?
    // Story 3.35d — toggle son (le sélecteur H/F vit désormais dans le profil).
    @AppStorage(SessionVoicePrefs.enabledKey) private var voiceEnabled = true
    // Chantier charge muscu V2 (increment 2, décision B) — poids NOTÉ par l'user, par exo
    // (clé = originalName). `notedWeights` = valeur éditable courante ; `lastWeights` =
    // ancre « dernière fois » figée au chargement (rappel). L'app ne prescrit jamais.
    @State private var notedWeights: [String: Double] = [:]
    @State private var lastWeights: [String: Double] = [:]
    private let resolvedSportCode: String
    private let executionMode: SessionExecutionMode

    /// Tick 1 s qui pilote le moteur de timer (mode Minuté).
    private let secondTick = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    init(session: AdaptedSession, week: AdaptedWeek, program: AdaptedProgram, recordId: UUID? = nil) {
        self.session = session
        self.week = week
        self.program = program
        self.recordId = recordId
        let vm = SessionFocusViewModel(session: session, recordId: recordId, week: week.weekNumber, day: session.day)
        _viewModel = State(initialValue: vm)
        _selectedIndex = State(initialValue: vm.resumeIndex)

        let effective = SessionSportInference.sportCode(
            forSessionName: session.name.canonical, programSportCode: program.sport.appSportCode
        )
        self.resolvedSportCode = effective
        self.executionMode = SessionExecutionMode.available(sportCode: effective, sessionType: session.type)
        let phases = SessionTimerPhaseBuilder.phases(for: session, sportCode: effective)
        _timerEngine = State(initialValue: SessionTimerEngine(phases: phases))
    }

    private var steps: [SessionStep] { viewModel.steps }

    /// UI compte à rebours (Minuté 3.34 ET Audio 3.35 partagent l'écran glançable) ;
    /// sinon repli gracieux sur le mode Manuel (jamais de cul-de-sac).
    private var usesTimedMode: Bool {
        (executionMode == .timed || executionMode == .audio) && !timerEngine.phases.isEmpty
    }

    /// Mode Audio (3.35) : voix par-dessus le déroulé chronométré.
    private var isAudioMode: Bool { executionMode == .audio }

    /// POC yoga (D3) : la voix lit un script de PLACEMENT à l'entrée de chaque
    /// posture (pas de pré-annonce cardio, pas de décompte vocal). Le yoga reste en
    /// mode Minuté ; on greffe juste la voix par-dessus.
    private var isYoga: Bool { resolvedSportCode == "yoga" }

    /// Langue de la voix = langue de CONTENU de l'app (tu lis FR → tu entends FR),
    /// indépendante de la locale device. (Décision 3.35e.)
    private var currentLanguage: String { languageManager.currentLanguage.rawValue }

    /// Locale in-app courante — résolution du contenu localisable (noms/warmup/notes).
    private var locale: Locale { languageManager.currentLocale }

    var body: some View {
        Group {
            if usesTimedMode {
                timedBody
            } else {
                manualBody
            }
        }
        .background(Color.coachingBackground.ignoresSafeArea())
        .task { await loadNotedWeights() }
        .onChange(of: viewModel.completedCount) { old, new in
            handleCompletionChange(old: old, new: new)
        }
        .overlay { if showCompletion { completionOverlay } }
        .sheet(isPresented: $showCompleteSheet, onDismiss: { dismiss() }) {
            if let vm = completionVM {
                SessionCompleteSheet(vm: vm, plannedDurationMinutes: session.durationMinutes)
            }
        }
    }

    // MARK: - Mode Manuel (3.33)

    private var manualBody: some View {
        VStack(spacing: 0) {
            topBar
            if steps.isEmpty {
                Spacer()
                Text("coaching.session.focus.empty")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                Spacer()
            } else {
                TabView(selection: $selectedIndex) {
                    ForEach(steps) { step in
                        ScrollView {
                            stepContent(step)
                                .padding()
                        }
                        .tag(step.index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.25), value: selectedIndex)

                bottomNav
            }
        }
    }

    // MARK: - Auto-avance + complétion

    private func handleCompletionChange(old: Int, new: Int) {
        guard new > old else { return } // ignore les dé-validations
        if viewModel.allCompleted {
            presentCompletion()
            return
        }
        // Auto-avance si l'étape COURANTE vient d'être cochée et n'est pas la dernière.
        guard let current = steps.first(where: { $0.index == selectedIndex }),
              viewModel.isCompleted(current),
              let pos = steps.firstIndex(where: { $0.index == selectedIndex }),
              pos < steps.count - 1
        else { return }
        let nextIndex = steps[pos + 1].index
        Task {
            try? await Task.sleep(nanoseconds: 350_000_000)
            withAnimation(.easeInOut(duration: 0.3)) { selectedIndex = nextIndex }
        }
    }

    /// Toutes les étapes faites → récap (`SessionCompleteSheet`) si la séance est
    /// ancrée à un programme ; sinon célébration + fermeture (hot path / preview).
    private func presentCompletion() {
        if let recordId, let deps {
            let vm = SessionCompletionViewModel(
                recordId: recordId, weekNumber: week.weekNumber, day: session.day,
                repository: deps.adaptedProgramRepository
            )
            completionVM = vm
            // Device-test 2026-06-09 : le « Bravo » était mangé par la feuille notation
            // (elle montait direct). On célèbre D'ABORD, puis on bascule sur la feuille.
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) { showCompletion = true }
            Task {
                // La célébration reste lisible ≥1.6 s, en parallèle de l'enregistrement.
                async let minDisplay: Void = Task.sleep(nanoseconds: 1_600_000_000)
                await vm.load()
                // Story 3.35h — enregistre la complétion DÈS la fin du FOCUS (et non
                // seulement si l'user valide la feuille) → le dashboard ne reproposera
                // plus cette séance comme « prochaine ». La feuille reste pour les
                // détails optionnels (durée/RPE/notes).
                if vm.completion == nil {
                    await vm.save(actualDurationMinutes: nil, rpe: nil, notes: nil)
                }
                try? await minDisplay
                withAnimation(.easeInOut(duration: 0.25)) { showCompletion = false }
                showCompleteSheet = true
            }
        } else {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) { showCompletion = true }
            Task {
                try? await Task.sleep(nanoseconds: 1_600_000_000)
                dismiss()
            }
        }
    }

    private var completionOverlay: some View {
        ZStack {
            Color.black.opacity(0.35).ignoresSafeArea()
            VStack(spacing: 16) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 64))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(Color.coachingSuccess)
                Text("coaching.session.focus.celebration")
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)
            }
            .padding(32)
            .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 18))
            .padding(40)
        }
        .transition(.opacity.combined(with: .scale))
        .accessibilityIdentifier("coaching.session.focus.celebration")
    }

    // MARK: - Top bar

    private var topBar: some View {
        VStack(spacing: 8) {
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                .accessibilityIdentifier("coaching.session.focus.close")
                Spacer()
                Text(verbatim: counterLabel)
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                Spacer()
                Image(systemName: "xmark").font(.title3).opacity(0) // miroir centrage
            }
            SessionStepDots(steps: steps, currentIndex: selectedIndex, completed: viewModel.completed)
        }
        .padding(.horizontal)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

    private var counterLabel: String {
        guard !steps.isEmpty,
              let pos = steps.firstIndex(where: { $0.index == selectedIndex }) else { return "" }
        return "\(pos + 1) · \(steps.count)"
    }

    // MARK: - Contenu d'étape

    @ViewBuilder
    private func stepContent(_ step: SessionStep) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            switch step.kind {
            case .warmup(let text):
                phaseHeader(labelKey: "coaching.adapter.session.warmup", tint: .orange, symbol: "flame.fill")
                GlossaryRichText(text: text.resolved(locale), font: .body, foreground: .primary)
            case .cooldown(let text):
                phaseHeader(labelKey: "coaching.adapter.session.cooldown", tint: .blue, symbol: "snowflake")
                GlossaryRichText(text: text.resolved(locale), font: .body, foreground: .primary)
            case .exercise(let ex):
                exerciseContent(ex, number: step.exerciseNumber ?? 0)
            }

            SessionStepCheckmark(isCompleted: viewModel.isCompleted(step)) {
                viewModel.toggle(step)
            }
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func phaseHeader(labelKey: LocalizedStringKey, tint: Color, symbol: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: symbol).foregroundStyle(tint)
            Text(labelKey).font(.title3.bold()).foregroundStyle(.primary).textCase(.uppercase)
        }
    }

    @ViewBuilder
    private func exerciseContent(_ ex: AdaptedExercise, number: Int) -> some View {
        let pattern = ExercisePatternResolver.resolve(ex, sportCode: effectiveSportCode)

        HStack(spacing: 8) {
            Text(verbatim: "\(number)")
                .font(.caption.bold())
                .foregroundStyle(Color.coachingPrimary)
                .frame(width: 26, height: 26)
                .background(Circle().fill(Color.coachingPrimary.opacity(0.15)))
            Text(verbatim: ex.displayName(locale))
                .font(.title3.bold())
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }

        if pattern != .generic {
            ExercisePatternIllustration(pattern: pattern, sportCode: effectiveSportCode, exerciseName: ex.originalName, size: 200)
                .frame(maxWidth: .infinity)
                .padding(12)
                .background(Color(uiColor: .secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }

        metricsRow(ex)
        chargeGuidance(for: ex)
        weightNote(for: ex)

        if let notes = ex.notes?.resolved(locale), !notes.isEmpty {
            BulletedNotes(text: notes, font: .callout)
        }

        let tipKey = SessionTipCatalog.tip(for: pattern, exerciseName: ex.originalName)
        ExerciseHowToDisclosure(exercise: ex, fallbackTip: tipKey, initiallyExpanded: isYoga)
    }

    @ViewBuilder
    private func metricsRow(_ ex: AdaptedExercise) -> some View {
        let hasAny = ex.sets != nil || (ex.reps?.isEmpty == false) || (ex.duration?.isEmpty == false)
            || (ex.restSeconds ?? 0) > 0 || (ex.targetZone?.isEmpty == false)
        if hasAny {
            // Revue qualité thème #1 : l'intensité passe sur SA PROPRE ligne (référentiel
            // dosage, « bandeau 1 ligne ») — un libellé sensation (« endurance — tu peux
            // parler ») ne tient pas dans la rangée de chips sets/reps/repos sans tronquer.
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    if let sets = ex.sets, let reps = ex.reps, !reps.isEmpty {
                        chip { Text(verbatim: "\(sets) × \(reps.sanitizedForDisplay)") }
                    } else if let reps = ex.reps, !reps.isEmpty {
                        chip { Text(verbatim: reps.sanitizedForDisplay) }
                    } else if let sets = ex.sets {
                        chip { Text(verbatim: "\(sets) ×") }
                    }
                    if let duration = ex.duration, !duration.isEmpty, ex.reps == nil {
                        chip { Text(verbatim: duration.sanitizedForDisplay) }
                    }
                    if let rest = ex.restSeconds, rest > 0 {
                        chip { Text("coaching.adapter.exercise.rest \(rest)") }
                    }
                    Spacer(minLength: 0)
                }
                if let zone = ex.targetZone, !zone.isEmpty {
                    IntensityLabel(zone: zone)
                }
            }
        }
    }

    /// Chantier charge muscu V2 — TRANCHE 1 (`party-charge-muscu-v2-2026-06-08.md`).
    /// Consigne de charge NON-kg, affichée en Manuel ET Minuté (D-A/D-C/D-F) : élastique,
    /// poids du corps, ou charge libre/machine → wording « reps en réserve » adapté.
    /// JAMAIS de kg. `nil` (exo non-muscu / cas vide) → rien (jamais « 0 kg », règle P0).
    @ViewBuilder
    private func chargeGuidance(for ex: AdaptedExercise) -> some View {
        // Exo en TENUE (planche, chaise au mur…) : repère de tension, pas « ajoute des reps »
        // (device-test #16). Sinon : consigne charge selon la résistance (band/poids/charge libre).
        if isStrengthSession, ChargeGuidance.isHold(ex) {
            cueLabel("coaching.dosage.charge.hold", icon: "figure.core.training")
        } else if let resistance = ChargeGuidance.resistance(for: ex, isStrength: isStrengthSession) {
            let key: LocalizedStringKey = {
                switch resistance {
                case .band: return "coaching.dosage.charge.band"
                case .bodyweight: return "coaching.dosage.charge.bodyweight"
                case .freeOrMachine: return "coaching.dosage.charge.hint"
                }
            }()
            cueLabel(key, icon: "scalemass")
        }
    }

    private func cueLabel(_ key: LocalizedStringKey, icon: String) -> some View {
        Label { Text(key) } icon: { Image(systemName: icon) }
            .font(.caption)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
    }

    /// Pas du stepper poids. 0,5 kg (décision Sophie 2026-06-09) : granularité fine qui
    /// couvre tout le matériel (barre/haltères/machines/légers) ; l'auto-repeat du stepper
    /// natif évite la pénalité de taps pour atteindre une charge élevée.
    private static let weightStep: Double = 0.5

    /// Chantier charge muscu V2 — increment 2 (décision B). Champ « poids noté » optionnel,
    /// UNIQUEMENT sur les exos chargés (`.freeOrMachine`). Stepper ± 0,5 kg sans clavier
    /// (auto-repeat natif au maintien), pré-rempli sur la dernière valeur, vide si jamais noté.
    /// L'app NE PRESCRIT JAMAIS : c'est l'user qui saisit (EU MDR). Rappel « dernière fois »
    /// ancré sur la valeur au chargement. Jamais « 0 kg » (ramené à 0 → effacé → `—`).
    @ViewBuilder
    private func weightNote(for ex: AdaptedExercise) -> some View {
        if ChargeGuidance.resistance(for: ex, isStrength: isStrengthSession) == .freeOrMachine {
            let key = ex.originalName
            let current = notedWeights[key]
            VStack(alignment: .leading, spacing: 2) {
                Stepper {
                    HStack(spacing: 6) {
                        Image(systemName: "scalemass")
                        Text("coaching.dosage.charge.log")
                        Spacer(minLength: 8)
                        // Vide = rien affiché (« sinon vide ») : un « — » ici se confond avec
                        // le « − » du stepper. Le poids n'apparaît qu'une fois saisi.
                        if let current {
                            Text(verbatim: formatKg(current))
                                .font(.callout.weight(.semibold))
                                .foregroundStyle(Color.coachingPrimary)
                                .accessibilityIdentifier("coaching.session.focus.weightNote.value")
                        }
                    }
                } onIncrement: {
                    adjustWeight(for: key, to: (current ?? lastWeights[key] ?? 0) + Self.weightStep)
                } onDecrement: {
                    guard let c = current else { return } // rien sous « — »
                    adjustWeight(for: key, to: c - Self.weightStep)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                .accessibilityIdentifier("coaching.session.focus.weightNote")
                if let last = lastWeights[key] {
                    Text("coaching.dosage.charge.lastTime \(formatKg(last))")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    /// Formate un poids pour l'affichage selon la locale in-app (« 12,5 kg » / « 12.5 kg »),
    /// sans décimale superflue (« 40 kg » et non « 40,0 kg »).
    private func formatKg(_ value: Double) -> String {
        let nf = NumberFormatter()
        nf.locale = locale
        nf.numberStyle = .decimal
        nf.minimumFractionDigits = 0
        nf.maximumFractionDigits = 1
        let num = nf.string(from: value as NSNumber) ?? "\(value)"
        return "\(num) kg"
    }

    /// Applique un nouveau poids (clampé 0…300). `≤ 0` → efface (jamais « 0 kg »).
    private func adjustWeight(for key: String, to value: Double) {
        let clamped = min(value, 300)
        if clamped <= 0 {
            notedWeights[key] = nil
            persistWeight(key: key, kg: nil)
        } else {
            notedWeights[key] = clamped
            persistWeight(key: key, kg: clamped)
        }
    }

    /// Charge les poids notés du programme (pré-remplissage stepper + ancre « dernière fois »).
    /// No-op hors muscu ou en preview/fixture (recordId/deps nil) : le stepper reste éditable
    /// en local pour le test visuel, juste sans persistance.
    private func loadNotedWeights() async {
        guard isStrengthSession, let recordId, let deps else { return }
        let svc = ExerciseWeightService(repository: deps.adaptedProgramRepository)
        if let state = try? await svc.currentWeights(recordId: recordId) {
            lastWeights = state.weights
            notedWeights = state.weights
        }
    }

    private func persistWeight(key: String, kg: Double?) {
        guard let recordId, let deps else { return }
        let svc = ExerciseWeightService(repository: deps.adaptedProgramRepository)
        Task { try? await svc.recordWeight(recordId: recordId, exerciseKey: key, kg: kg) }
    }

    private func chip<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        content()
            .font(.caption2)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 8).padding(.vertical, 4)
            .background(Color(uiColor: .tertiarySystemBackground))
            .clipShape(Capsule())
    }

    // MARK: - Nav bas

    private var bottomNav: some View {
        HStack {
            Button {
                withAnimation { goToPosition(currentPosition - 1) }
            } label: {
                Label("coaching.session.focus.previous", systemImage: "chevron.left").font(.callout)
            }
            .disabled(currentPosition == 0)
            .opacity(currentPosition == 0 ? 0.35 : 1)

            Spacer()

            Button {
                if let step = steps.first(where: { $0.index == selectedIndex }) { viewModel.skip(step) }
                withAnimation { goToPosition(currentPosition + 1) }
            } label: {
                Text("coaching.session.focus.skip").font(.callout)
            }
            .opacity(currentPosition >= steps.count - 1 ? 0.35 : 1)
            .disabled(currentPosition >= steps.count - 1)

            Spacer()

            Button {
                withAnimation { goToPosition(currentPosition + 1) }
            } label: {
                Label("coaching.session.focus.next", systemImage: "chevron.right")
                    .labelStyle(.titleAndIcon)
                    .environment(\.layoutDirection, .rightToLeft)
                    .font(.callout)
            }
            .disabled(currentPosition >= steps.count - 1)
            .opacity(currentPosition >= steps.count - 1 ? 0.35 : 1)
        }
        .tint(Color.coachingPrimary)
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(Color.coachingBackground)
    }

    private var currentPosition: Int {
        steps.firstIndex(where: { $0.index == selectedIndex }) ?? 0
    }

    private func goToPosition(_ pos: Int) {
        let clamped = min(max(pos, 0), steps.count - 1)
        guard steps.indices.contains(clamped) else { return }
        selectedIndex = steps[clamped].index
    }

    // MARK: - Mode Minuté (3.34)

    private var timedBody: some View {
        VStack(spacing: 0) {
            timedTopBar
            timedCenter
            timedControls
        }
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true // écran maintenu allumé (AC7)
            setupVoiceIfNeeded()
            // Session audio active + moteur de bips prêt. En mode Audio, le ducking
            // de la musique est géré à la demande par la voix (`duck()`/`unduck()`).
            audioCues.activate()
            timerEngine.start()
            announceCurrentPhase() // pré-annonce vocale du 1ᵉʳ bloc (anti-Decathlon)
            emitInitialCountdownIfNeeded() // bug #7 — le « 3 » d'ouverture (cf emitCountdownTick)
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
            voiceGuide?.stop()
            audioCues.deactivate()
            persistTimedProgress() // sauvegarde partielle (fermeture ✕ en cours)
        }
        .onReceive(secondTick) { _ in timerEngine.tick() }
        .onChange(of: timerEngine.currentIndex) { _, _ in handlePhaseChange() }
        .onChange(of: timerEngine.remaining) { _, new in handleTick(remaining: new) }
        .onChange(of: timerEngine.isFinished) { _, finished in
            if finished { handleTimedFinish() }
        }
    }

    private func handlePhaseChange() {
        guard let phase = timerEngine.currentPhase else { return }
        switch phase.kind {
        case .work, .hold:
            audioCues.play(.workStart)
            // POC yoga (D3) : à l'ENTRÉE de la posture, lire le script de placement
            // corporel (« allonge-toi, bras le long du corps… »), puis silence pendant
            // la tenue. Pas de pré-annonce cardio, pas de « C'est parti ! ».
            if isYoga {
                announceYogaPlacement(forStepIndex: phase.stepIndex)
            } else if precededByPrepare {
                // « C'est parti ! » au lancement d'un effort sortant de la pré-annonce.
                voiceGuide?.announce(String.localized("coaching.session.voice.go", locale: locale))
            }
        case .rest:
            audioCues.play(.restStart)
        case .warmup, .cooldown:
            voiceGuide?.announce(displayString(phase.label))
        case .prepare:
            // Bug #7 — la pré-annonce dure exactement 3 s : `onChange(remaining)` ne
            // voit jamais la valeur initiale (3 == durée), donc on n'entendait que
            // « 2, 1 ». On émet ici le « 3 » d'ouverture.
            emitCountdownTick(forSecond: phase.duration)
        }
    }

    /// À l'apparition, si la 1ʳᵉ phase est déjà la pré-annonce (séance sans
    /// échauffement), émet son « 3 » d'ouverture — `handlePhaseChange` ne se
    /// déclenche pas pour la phase de départ (pas de changement d'index).
    private func emitInitialCountdownIfNeeded() {
        guard let phase = timerEngine.currentPhase, phase.kind == .prepare else { return }
        emitCountdownTick(forSecond: phase.duration)
    }

    /// Bip (toujours) + chiffre parlé (mode Audio) du décompte 3·2·1 pour la
    /// seconde donnée. No-op hors fenêtre 1…3.
    private func emitCountdownTick(forSecond second: Int) {
        guard (1...3).contains(second) else { return }
        audioCues.play(.prepareTick)
        if isAudioMode { voiceGuide?.announce("\(second)") }
    }

    /// True si la phase précédant la phase courante était la pré-annonce.
    private var precededByPrepare: Bool {
        let i = timerEngine.currentIndex - 1
        guard timerEngine.phases.indices.contains(i) else { return false }
        return timerEngine.phases[i].kind == .prepare
    }

    /// Bips + voix pendant le décompte d'une phase. Avant chaque transition :
    /// « Prochain : <segment> » (~5 s avant la fin), puis compte à rebours vocal
    /// « 3, 2, 1 » sur les 3 dernières secondes (anti-Decathlon).
    private func handleTick(remaining new: Int) {
        guard !timerEngine.isPaused, let phase = timerEngine.currentPhase, !phase.isManual else { return }
        // Pré-annonce vocale du prochain segment, en fin de phase active (mode Audio).
        if isAudioMode, phase.kind != .prepare, new == 5, phase.duration >= 7, let next = upcomingLabel {
            voiceGuide?.announce(String.localized("coaching.session.voice.next \(next)", locale: locale))
        }
        // Décompte 3·2·1 : bip (toujours) + chiffre parlé (Audio).
        emitCountdownTick(forSecond: new)
    }

    // MARK: - Voix (3.35)

    private func setupVoiceIfNeeded() {
        // POC yoga (D3) : la voix sert aussi le yoga (mode Minuté) pour lire le
        // script de placement à l'entrée des postures, pas seulement le mode Audio.
        guard isAudioMode || isYoga, voiceGuide == nil else { return }
        voiceGuide = SessionVoiceGuide(
            enabled: SessionVoicePrefs.enabled,
            gender: SessionVoicePrefs.gender,
            language: currentLanguage,
            speaker: AVSpeechSpeaker(audioCues: audioCues),
            voiceProvider: AVSpeechSpeaker.voiceIdentifier(for:language:)
        )
    }

    /// Pré-annonce vocale du tout 1ᵉʳ segment (anti-Decathlon) : « Prochain : … »
    /// pendant la pré-annonce d'ouverture. Les transitions suivantes sont annoncées
    /// par `handleTick` en fin de segment. No-op hors mode Audio / voix OFF.
    private func announceCurrentPhase() {
        guard isAudioMode, let phase = timerEngine.currentPhase, let guide = voiceGuide else { return }
        switch phase.kind {
        case .prepare:
            guide.announce(String.localized("coaching.session.voice.next \(displayString(phase.label))", locale: locale))
        case .warmup, .cooldown:
            guide.announce(displayString(phase.label)) // « Échauffement » / « Retour au calme »
        default:
            break
        }
    }

    /// POC yoga (D3) : annonce le script de placement de la posture dont la phase
    /// vient de démarrer. Remonte de la phase (`stepIndex`) à l'exo pour récupérer
    /// son `originalName` (= nom SANSKRIT / match_key) et chercher le script. No-op
    /// si voix OFF, posture non couverte (POC) ou langue ≠ FR.
    private func announceYogaPlacement(forStepIndex stepIndex: Int) {
        guard let guide = voiceGuide,
              let step = steps.first(where: { $0.index == stepIndex }),
              case .exercise(let ex) = step.kind,
              let script = YogaVoiceScripts.script(forName: ex.originalName, language: currentLanguage)
        else { return }
        guide.announce(script)
    }

    /// Sauvegarde la progression partielle d'une séance minutée à la fermeture :
    /// une étape (échauffement / exo / récup) est marquée faite si TOUTES ses
    /// phases sont passées. Évite de tout perdre si on ferme à 7 tours sur 8
    /// (la reprise depuis le HUB repart à la 1ʳᵉ étape non faite). No-op hors minuté.
    private func persistTimedProgress() {
        guard usesTimedMode, !timerEngine.phases.isEmpty else { return }
        for step in steps {
            let positions = timerEngine.phases.enumerated()
                .filter { $0.element.stepIndex == step.index }
                .map(\.offset)
            guard !positions.isEmpty else { continue }
            let allPassed = timerEngine.isFinished || positions.allSatisfy { $0 < timerEngine.currentIndex }
            if allPassed { viewModel.markDone(step) }
        }
    }

    private func handleTimedFinish() {
        audioCues.play(.finish)
        // Toutes les phases déroulées → marque toutes les étapes faites, ce qui
        // déclenche `handleCompletionChange` (récap / célébration).
        steps.forEach { viewModel.markDone($0) }
    }

    private var timedTopBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "xmark").font(.title3).foregroundStyle(.secondary)
            }
            .accessibilityIdentifier("coaching.session.focus.close")
            Spacer()
            progressionLabel
                .font(.caption.bold())
                .foregroundStyle(.secondary)
            Spacer()
            // Story 3.35d — en mode Audio : toggle son ON/OFF en haut à droite
            // (le choix de voix Homme/Femme est dans le profil). Sinon miroir invisible.
            // POC yoga (D3) : le toggle s'affiche aussi en yoga (voix de placement débrayable).
            if isAudioMode || isYoga {
                Button {
                    voiceEnabled.toggle()
                    voiceGuide?.enabled = voiceEnabled
                    if !voiceEnabled { voiceGuide?.stop() }
                } label: {
                    Image(systemName: voiceEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                        .font(.title3)
                        .foregroundStyle(voiceEnabled ? Color.coachingPrimary : .secondary)
                }
                .accessibilityLabel(Text("coaching.session.voice.toggle"))
                .accessibilityValue(Text(voiceEnabled ? "coaching.session.voice.on" : "coaching.session.voice.off"))
                .accessibilityIdentifier("coaching.session.focus.voiceToggle")
            } else {
                Image(systemName: "xmark").font(.title3).opacity(0)
            }
        }
        .padding(.horizontal)
        .padding(.top, 12)
    }

    @ViewBuilder
    private var timedCenter: some View {
        if let phase = timerEngine.currentPhase {
            GeometryReader { geo in
            ScrollView {
                VStack(spacing: 16) {
                    if phase.kind == .warmup || phase.kind == .cooldown {
                        guidedPhaseContent(phase)
                    } else if phase.kind == .prepare {
                        Text("coaching.session.focus.timed.ready")
                            .font(.title3.bold())
                            .foregroundStyle(.orange)
                            .textCase(.uppercase)
                        Text(verbatim: displayString(phase.label))
                            .font(.title2.bold())
                            .multilineTextAlignment(.center)
                        bigTime
                    } else {
                        Text(verbatim: displayString(phase.label))
                            .font(.largeTitle.bold())
                            .foregroundStyle(phaseTint(phase))
                            .multilineTextAlignment(.center)
                        // Chantier dosage AC2 (2026-06-07) : en MUSCU les REPS sont le héros
                        // (la muscu est reps-driven), le chrono est rétrogradé en filet — il
                        // n'est qu'une ESTIMATION. Hors muscu (HIIT/yoga), le chrono reste héros.
                        let strengthRepTarget = phase.kind == .work ? strengthReps(for: phase) : nil
                        if let reps = strengthRepTarget {
                            VStack(spacing: 6) {
                                Text(verbatim: DosageFormatting.repsHero(from: reps))
                                    .font(.system(size: 80, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.coachingPrimary)
                                    .accessibilityIdentifier("coaching.session.focus.timed.strength.repsHero")
                                Text("coaching.dosage.reps.unit")
                                    .font(.headline)
                                    .foregroundStyle(.secondary)
                                // D4 côté : exo unilatéral (« 10 par côté ») → guidage explicite.
                                // Affiché seulement (la voix côté = mode Audio, hors muscu Minuté).
                                if DosageFormatting.isUnilateral(reps: reps) {
                                    Label {
                                        Text("coaching.dosage.side.right")
                                            + Text(verbatim: " · ")
                                            + Text("coaching.dosage.side.left")
                                    } icon: {
                                        Image(systemName: "arrow.left.arrow.right")
                                    }
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(Color.coachingPrimary)
                                    .padding(.top, 2)
                                    .accessibilityIdentifier("coaching.session.focus.timed.strength.side")
                                }
                                // Chantier charge V2 (T1) — consigne charge NON-kg via le
                                // helper partagé avec le mode Manuel (D-F) : élastique /
                                // poids du corps / charge libre. Jamais « 0 kg » (P0).
                                if let ex = exercise(at: phase.stepIndex) {
                                    chargeGuidance(for: ex)
                                        .multilineTextAlignment(.center)
                                        .padding(.top, 2)
                                    weightNote(for: ex)
                                        .padding(.top, 2)
                                }
                            }
                            chronoFilet
                        } else {
                            bigTime
                            // Exo muscu en TENUE (pas de reps : chaise au mur, planche) : la
                            // consigne était couplée au héros reps → invisible (#16). On la rend
                            // ici aussi, en repère de tension. Gardé à .work muscu (pas en récup).
                            if isStrengthSession, phase.kind == .work, let ex = exercise(at: phase.stepIndex) {
                                chargeGuidance(for: ex)
                                    .multilineTextAlignment(.center)
                                    .padding(.top, 2)
                                weightNote(for: ex)
                                    .padding(.top, 2)
                            }
                        }
                        timeScrubber(phase: phase)
                        if let next = upcomingLabel, next != displayString(phase.label) {
                            Text("coaching.session.focus.timed.then \(next)")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        // Story 3.35f — en minuté NON-audio (yoga/HIIT/muscu), on utilise
                        // le grand écran : illustration de l'exo + « Comment l'exécuter ».
                        // Sally P0 : seulement pendant l'EFFORT (work/hold) — pas en récup,
                        // où l'illustration laissait croire qu'il faut continuer à bouger.
                        if !isAudioMode, phase.kind == .work || phase.kind == .hold {
                            exerciseVisual(for: phase)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 8)
                // Bug device-test Sophie 2026-06-08 (DB bench) : le contenu (image +
                // « Comment l'exécuter » déplié) était coincé entre 2 Spacer() qui volaient
                // la hauteur → vide en haut, how-to coupé. minHeight = viewport → centre si
                // court, scrolle proprement si long (Spacers retirés de timedBody).
                .frame(maxWidth: .infinity, minHeight: geo.size.height)
            }
            // Revue comité 2026-06-06 (Sally P1-b) : sur la tenue `.hold`, la
            // description dépliée déborde souvent sous la ligne de flottaison →
            // dégradé de fade en bas pour signaler « il y a une suite à scroller ».
            .overlay(alignment: .bottom) {
                if phase.kind == .hold {
                    LinearGradient(colors: [Color.coachingBackground.opacity(0), Color.coachingBackground],
                                   startPoint: .top, endPoint: .bottom)
                        .frame(height: 28)
                        .allowsHitTesting(false)
                }
            }
            }
        } else if timerEngine.isFinished {
            // Bug #7 — en fin de séance minutée, `currentPhase` devient nil → l'écran
            // restait blanc le temps que la feuille de récap monte. On affiche une
            // célébration visible dès la dernière phase passée.
            // Bug device-test Sophie 2026-06-08 : la feuille récap est ASYNC (save) → si
            // elle ne monte pas (offline/échec/edge), l'user restait coincé ici sans
            // bouton (juste le petit ✕). Bouton « Terminer » explicite = sortie garantie.
            VStack(spacing: 20) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 72))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(Color.coachingSuccess)
                Text("coaching.session.focus.celebration")
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)
                Button { dismiss() } label: {
                    Text("coaching.session.focus.finish.cta")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .foregroundStyle(.white)
                        .background(Color.coachingPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 40)
                .padding(.top, 4)
                .accessibilityIdentifier("coaching.session.focus.timed.finish.cta")
            }
            .padding(.horizontal, 24)
            .accessibilityIdentifier("coaching.session.focus.timed.finished")
        }
    }

    /// Bug #6 — échauffement / récup CHRONOMÉTRÉS (auto-avance + pause, décision
    /// Sophie 2026-06-04). Compte à rebours global + sous-étapes en puces, la puce
    /// courante (estimée par tranche de temps égale) en gras. Le timer auto-avance
    /// à 0:00 ; pause/passer dans `timedControls`.
    @ViewBuilder
    private func guidedPhaseContent(_ phase: SessionTimerPhase) -> some View {
        let lines = manualPhaseLines(phase)
        let current = currentGuidedLineIndex(phase, lineCount: lines.count)
        VStack(spacing: 16) {
            Text(verbatim: displayString(phase.label))
                .font(.largeTitle.bold())
                .foregroundStyle(phaseTint(phase))
                .multilineTextAlignment(.center)
            bigTime
            timeScrubber(phase: phase)
            VStack(alignment: .leading, spacing: 10) {
                if Self.isPlaceholderGuidance(lines) {
                    // Revue ui-reviewer 2026-06-07 (P1, finding Sophie) : un warmup/récup
                    // « placeholder » (« Échauffement standard 7 min. ») ne produisait qu'une
                    // puce tautologique → écran ressenti vide. Fallback utile, jamais vide.
                    Label {
                        Text(phase.kind == .cooldown
                             ? "coaching.session.focus.guided.cooldown.fallback"
                             : "coaching.session.focus.guided.warmup.fallback")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    } icon: {
                        Image(systemName: "sparkles")
                            .font(.system(size: 9))
                            .foregroundStyle(phaseTint(phase))
                    }
                } else {
                    ForEach(Array(lines.enumerated()), id: \.offset) { idx, line in
                        Label {
                            // Revue comité 2026-06-06 (P0 challenger) : le jargon des
                            // sous-étapes d'échauffement (glutes, band, mobilité…) devient
                            // tappable via le glossaire au lieu d'être du texte opaque.
                            GlossaryRichText(text: line,
                                             font: idx == current ? .body.bold() : .body,
                                             foreground: idx == current ? .primary : .secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        } icon: {
                            Image(systemName: idx == current ? "circle.fill" : "circle")
                                .font(.system(size: 7))
                                .foregroundStyle(idx == current ? phaseTint(phase) : .secondary)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    /// Un texte de phase guidée est un « placeholder » sans valeur (« Échauffement standard
    /// 7 min. », « Étirements 5 min standards. ») s'il ne reste quasi aucune instruction une
    /// fois retirés le mot de phase, « standard » et la durée. Dans ce cas on affiche un
    /// fallback générique plutôt qu'une puce tautologique. Robuste tous sports.
    static func isPlaceholderGuidance(_ lines: [String]) -> Bool {
        guard lines.count <= 1 else { return false }
        guard let only = lines.first else { return true }
        var s = only.lowercased()
        for w in ["échauffement", "echauffement", "étirements", "etirements", "récupération",
                  "recuperation", "standard", "standards", "warm-up", "warmup", "warm up",
                  "cool-down", "cooldown", "cool down", "stretching", "stretch"] {
            s = s.replacingOccurrences(of: w, with: " ")
        }
        s = s.replacingOccurrences(of: #"[0-9]+\s*(min|sec|s)?\b"#, with: " ", options: .regularExpression)
        let letters = s.filter { $0.isLetter }
        return letters.count < 4
    }

    /// Index de la sous-étape courante d'un échauffement/récup, par tranche de temps
    /// égale (faute de durée par sous-étape). 0 si une seule ligne.
    private func currentGuidedLineIndex(_ phase: SessionTimerPhase, lineCount: Int) -> Int {
        guard lineCount > 1, phase.duration > 0 else { return 0 }
        let elapsed = max(0, phase.duration - timerEngine.remaining)
        let slice = Double(phase.duration) / Double(lineCount)
        return min(lineCount - 1, Int(Double(elapsed) / slice))
    }

    /// Illustration + tip de l'exo courant (mode minuté non-audio).
    @ViewBuilder
    private func exerciseVisual(for phase: SessionTimerPhase) -> some View {
        if let ex = exercise(at: phase.stepIndex) {
            let pattern = ExercisePatternResolver.resolve(ex, sportCode: resolvedSportCode)
            if pattern != .generic {
                ExercisePatternIllustration(pattern: pattern, sportCode: resolvedSportCode, exerciseName: ex.originalName, size: 180)
                    .frame(maxWidth: .infinity)
                    .padding(12)
                    .background(Color(uiColor: .secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            let tipKey = SessionTipCatalog.tip(for: pattern, exerciseName: ex.originalName)
            // Revue comité 2026-06-06 (reco Sally, décision Sophie) : « Comment
            // l'exécuter » déplié sur les phases STATIQUES/LONGUES (tenue `.hold` =
            // posture yoga, gainage), replié sur l'effort court chiffré (`.work` =
            // HIIT, série muscu) — règle déterministe par phase, découplée du sport.
            ExerciseHowToDisclosure(exercise: ex, fallbackTip: tipKey, initiallyExpanded: phase.kind == .hold)
        }
    }

    /// Séance de muscu (séries chronométrées auto-chaînées, bug #9).
    private var isStrengthSession: Bool {
        resolvedSportCode == "strengthTraining" || session.type == .strength
    }

    /// Reps cible d'une série muscu (« 8 », « 12/côté »). nil hors muscu ou si l'exo
    /// est tenu (pas de reps → la durée RÉELLE fait foi, pas d'estimation → pas de
    /// hint « prends le temps »).
    private func strengthReps(for phase: SessionTimerPhase) -> String? {
        guard isStrengthSession, let ex = exercise(at: phase.stepIndex),
              let reps = ex.reps, !reps.isEmpty else { return nil }
        return reps.sanitizedForDisplay
    }

    private func exercise(at stepIndex: Int) -> AdaptedExercise? {
        for step in steps where step.index == stepIndex {
            if case .exercise(let ex) = step.kind { return ex }
        }
        return nil
    }

    /// Texte d'une phase manuelle (warmup/cooldown) découpé en lignes sur les « + »,
    /// « / » assainis, et sans la mention « Total : … » (affichée à part).
    private func manualPhaseLines(_ phase: SessionTimerPhase) -> [String] {
        let text = manualPhaseText(phase)
        return SessionPhaseText.bulletLines(from: text)
    }

    private func manualPhaseText(_ phase: SessionTimerPhase) -> String {
        for step in steps where step.index == phase.stepIndex {
            switch step.kind {
            case .warmup(let t), .cooldown(let t): return t.resolved(locale)
            default: return ""
            }
        }
        return ""
    }

    private var bigTime: some View {
        Text(verbatim: timeString(timerEngine.remaining))
            .font(.system(size: 88, weight: .bold, design: .rounded))
            .monospacedDigit()
            .foregroundStyle(.primary)
            .accessibilityIdentifier("coaching.session.focus.timed.countdown")
    }

    /// Chrono « filet » discret pour la muscu : le temps n'est qu'une estimation, les reps
    /// sont le héros (chantier dosage AC2). Garde l'`accessibilityIdentifier` countdown pour
    /// rester repérable par les tests, mais en taille réduite secondaire.
    private var chronoFilet: some View {
        HStack(spacing: 6) {
            Image(systemName: "timer").font(.caption)
            Text(verbatim: timeString(timerEngine.remaining)).font(.callout.monospacedDigit())
        }
        .foregroundStyle(.secondary)
        .accessibilityIdentifier("coaching.session.focus.timed.countdown")
    }

    /// Barre de progression du segment : « écoulé · [====   ] · total » — montre où
    /// on en est sans aucun « / » (retour Sophie 2026-06-03).
    private func timeScrubber(phase: SessionTimerPhase) -> some View {
        let elapsed = max(0, phase.duration - timerEngine.remaining)
        let progress = phase.duration > 0 ? Double(elapsed) / Double(phase.duration) : 0
        return HStack(spacing: 10) {
            Text(verbatim: timeString(elapsed))
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
            ProgressView(value: min(max(progress, 0), 1))
                .tint(phaseTint(phase))
            Text(verbatim: timeString(phase.duration))
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: 280)
        .accessibilityIdentifier("coaching.session.focus.timed.scrubber")
    }

    @ViewBuilder
    private var timedControls: some View {
        if timerEngine.isFinished || timerEngine.currentPhase == nil {
            // Fin de séance : plus de contrôles (la célébration + la récap prennent le relais).
            EmptyView()
        } else {
            // Toutes les phases chronométrées (y compris échauffement/récup depuis le
            // bug #6) : précédent + pause/reprise + passer.
            HStack(spacing: 16) {
                // Revue ui-reviewer 2026-06-07 (P1) : parité avec le mode Manuel — on peut
                // revenir au set/exo précédent en minuté (compact pour ne pas serrer Pause).
                Button { withAnimation { timerEngine.back() } } label: {
                    Image(systemName: "chevron.left")
                        .font(.headline)
                        .frame(width: 52)
                        .padding(.vertical, 15)
                        .foregroundStyle(.primary)
                        .background(Color(uiColor: .secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .disabled(timerEngine.currentIndex == 0 && !timerEngine.isFinished)
                .accessibilityLabel("coaching.session.focus.previous")
                Button { timerEngine.togglePause() } label: {
                    Label(
                        timerEngine.isPaused ? "coaching.session.focus.timed.resume" : "coaching.session.focus.timed.pause",
                        systemImage: timerEngine.isPaused ? "play.fill" : "pause.fill"
                    )
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .foregroundStyle(.white)
                    .background(Color.coachingPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                Button { timerEngine.skip() } label: {
                    Label("coaching.session.focus.advance", systemImage: "forward.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .foregroundStyle(.primary)
                        .background(Color(uiColor: .secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
            .buttonStyle(.plain)
            .padding()
        }
    }

    // MARK: - Timed helpers

    /// Texte affiché/parlé d'un libellé de phase (localisé). Nom d'exo/posture en
    /// verbatim ; segments générés (Course/Marche/Effort/Récup) localisés.
    private func displayString(_ label: PhaseLabel) -> String {
        switch label {
        case .raw(let lt):               return AdaptedExercise.cleanForDisplay(lt.resolved(locale))
        case .effort:                    return String.localized("coaching.session.focus.timed.work", locale: locale)
        case .recovery:                  return String.localized("coaching.session.focus.timed.rest", locale: locale)
        case .run(let i, let t):         return String.localized("coaching.session.focus.timed.run \(i) \(t)", locale: locale)
        case .walk(let i, let t):        return String.localized("coaching.session.focus.timed.walk \(i) \(t)", locale: locale)
        case .warmup:                    return String.localized("coaching.adapter.session.warmup", locale: locale)
        case .cooldown:                  return String.localized("coaching.adapter.session.cooldown", locale: locale)
        }
    }

    private func phaseTint(_ phase: SessionTimerPhase) -> Color {
        switch phase.kind {
        case .prepare:  return .orange
        case .warmup:   return .orange
        case .cooldown: return .blue
        case .work:    return .coachingPrimary
        case .rest:    return .blue
        case .hold:    return .coachingSuccess
        }
    }

    /// Toujours mm:ss → lève l'ambiguïté « EFFORT 21 » (21 = secondes, pas un score).
    private func timeString(_ s: Int) -> String {
        String(format: "%d:%02d", s / 60, s % 60)
    }

    /// Libellé (localisé) du prochain segment actif (work/hold/rest), pour « Ensuite : … ».
    private var upcomingLabel: String? {
        guard timerEngine.currentIndex + 1 < timerEngine.phases.count else { return nil }
        for i in (timerEngine.currentIndex + 1)..<timerEngine.phases.count {
            let p = timerEngine.phases[i]
            if p.kind != .prepare { return displayString(p.label) }
        }
        return nil
    }

    @ViewBuilder
    private var progressionLabel: some View {
        if let p = timerEngine.currentPhase {
            if p.kind == .warmup || p.kind == .cooldown {
                // Échauffement / récup : pas de compteur de progression (le grand
                // titre + le décompte global suffisent).
                EmptyView()
            } else if isRunWalk(p.label) {
                // Run/walk : le grand titre « Course 1 sur 8 » porte déjà la progression.
                EmptyView()
            } else if p.kind == .hold {
                let pos = position(of: .hold)
                Text("coaching.session.focus.timed.posture \(pos.current) \(pos.total)")
            } else if let round = p.round, let tot = p.totalRounds, tot > 1 {
                // Muscu : « Série X/Y » (et non « Tour ») — bug #9/#12 clarté.
                if let k = p.exerciseInRound, let K = p.totalInRound, K > 1 {
                    Text(isStrengthSession
                         ? "coaching.session.focus.timed.setExo \(round) \(tot) \(k) \(K)"
                         : "coaching.session.focus.timed.roundExo \(round) \(tot) \(k) \(K)")
                } else {
                    Text(isStrengthSession
                         ? "coaching.session.focus.timed.set \(round) \(tot)"
                         : "coaching.session.focus.timed.round \(round) \(tot)")
                }
            } else {
                let pos = position(of: .work)
                if pos.total > 1 {
                    Text("coaching.session.focus.timed.step \(pos.current) \(pos.total)")
                }
            }
        }
    }

    private func isRunWalk(_ label: PhaseLabel) -> Bool {
        switch label { case .run, .walk: return true; default: return false }
    }

    /// Position (courant/total) parmi les phases d'un `kind` donné.
    private func position(of kind: SessionTimerPhase.Kind) -> (current: Int, total: Int) {
        let offsets = timerEngine.phases.enumerated()
            .filter { $0.element.kind == kind }
            .map(\.offset)
        let total = offsets.count
        let done = offsets.filter { $0 <= timerEngine.currentIndex }.count
        return (max(done, 1), max(total, 1))
    }

    // MARK: - Sport color

    private var effectiveSportCode: String {
        SessionSportInference.sportCode(forSessionName: session.name.canonical, programSportCode: program.sport.appSportCode)
    }
}

#if DEBUG
#Preview("FOCUS — strength") {
    SessionFocusView(
        session: AdaptedSession(
            day: 1, name: "Full body", durationMinutes: 50, type: .strength,
            warmup: "10 min mobilité articulaire + activation glutes",
            exercises: [
                AdaptedExercise(name: "Goblet squat", originalName: "Goblet squat", sets: 4, reps: "8", restSeconds: 90,
                                notes: "Descente contrôlée, genoux dans l'axe."),
                AdaptedExercise(name: "Pompes", originalName: "Pompes", sets: 3, reps: "12", restSeconds: 60),
                AdaptedExercise(name: "Gainage", originalName: "Gainage", duration: "2 min")
            ],
            cooldown: "5 min étirements doux"
        ),
        week: AdaptedProgramPreviewFixtures.sampleWeek(1, theme: "Force"),
        program: AdaptedProgramPreviewFixtures.happyPath
    )
}
#endif
