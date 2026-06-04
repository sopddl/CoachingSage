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
            forSessionName: session.name, programSportCode: program.sport.appSportCode
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

    /// Langue de la voix = langue de CONTENU de l'app (tu lis FR → tu entends FR),
    /// indépendante de la locale device. (Décision 3.35e.)
    private var currentLanguage: String { languageManager.currentLanguage.rawValue }

    var body: some View {
        Group {
            if usesTimedMode {
                timedBody
            } else {
                manualBody
            }
        }
        .background(Color.coachingBackground.ignoresSafeArea())
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
            Task {
                await vm.load()
                // Story 3.35h — enregistre la complétion DÈS la fin du FOCUS (et non
                // seulement si l'user valide la feuille) → le dashboard ne reproposera
                // plus cette séance comme « prochaine ». La feuille reste pour les
                // détails optionnels (durée/RPE/notes).
                if vm.completion == nil {
                    await vm.save(actualDurationMinutes: nil, rpe: nil, notes: nil)
                }
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
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 64))
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
                GlossaryRichText(text: text, font: .body, foreground: .primary)
            case .cooldown(let text):
                phaseHeader(labelKey: "coaching.adapter.session.cooldown", tint: .blue, symbol: "snowflake")
                GlossaryRichText(text: text, font: .body, foreground: .primary)
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
            Text(verbatim: ex.displayName)
                .font(.title3.bold())
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }

        if pattern != .generic {
            ExercisePatternIllustration(pattern: pattern, sportCode: effectiveSportCode, exerciseName: ex.name, size: 200)
                .frame(maxWidth: .infinity)
                .padding(12)
                .background(Color(uiColor: .secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }

        metricsRow(ex)

        if let notes = ex.notes, !notes.isEmpty {
            BulletedNotes(text: notes, font: .callout)
        }

        let tipKey = SessionTipCatalog.tip(for: pattern, exerciseName: ex.name)
        ExerciseHowToDisclosure(exercise: ex, fallbackTip: tipKey)
    }

    @ViewBuilder
    private func metricsRow(_ ex: AdaptedExercise) -> some View {
        let hasAny = ex.sets != nil || (ex.reps?.isEmpty == false) || (ex.duration?.isEmpty == false)
            || (ex.restSeconds ?? 0) > 0 || (ex.targetZone?.isEmpty == false)
        if hasAny {
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
                if let zone = ex.targetZone, !zone.isEmpty {
                    GlossaryTermBadge(term: zone)
                        .font(.caption2.bold())
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .background(Color.coachingPrimary.opacity(0.10))
                        .clipShape(Capsule())
                }
                Spacer(minLength: 0)
            }
        }
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
            Spacer()
            timedCenter
            Spacer()
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
            // « C'est parti ! » au lancement d'un effort sortant de la pré-annonce.
            if precededByPrepare { voiceGuide?.announce(String(localized: "coaching.session.voice.go")) }
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
            voiceGuide?.announce(String(localized: "coaching.session.voice.next \(next)"))
        }
        // Décompte 3·2·1 : bip (toujours) + chiffre parlé (Audio).
        emitCountdownTick(forSecond: new)
    }

    // MARK: - Voix (3.35)

    private func setupVoiceIfNeeded() {
        guard isAudioMode, voiceGuide == nil else { return }
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
            guide.announce(String(localized: "coaching.session.voice.next \(displayString(phase.label))"))
        case .warmup, .cooldown:
            guide.announce(displayString(phase.label)) // « Échauffement » / « Retour au calme »
        default:
            break
        }
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
            if isAudioMode {
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
                        bigTime
                        timeScrubber(phase: phase)
                        if let next = upcomingLabel, next != displayString(phase.label) {
                            Text("coaching.session.focus.timed.then \(next)")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        // Story 3.35f — en minuté NON-audio (yoga/HIIT), on utilise
                        // le grand écran : illustration de l'exo + « Comment l'exécuter ».
                        if !isAudioMode { exerciseVisual(for: phase) }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 8)
            }
        } else if timerEngine.isFinished {
            // Bug #7 — en fin de séance minutée, `currentPhase` devient nil → l'écran
            // restait blanc le temps que la feuille de récap monte. On affiche une
            // célébration visible dès la dernière phase passée.
            VStack(spacing: 16) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(Color.coachingSuccess)
                Text("coaching.session.focus.celebration")
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)
            }
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
                ForEach(Array(lines.enumerated()), id: \.offset) { idx, line in
                    Label {
                        Text(verbatim: line)
                            .font(idx == current ? .body.bold() : .body)
                            .foregroundStyle(idx == current ? .primary : .secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    } icon: {
                        Image(systemName: idx == current ? "circle.fill" : "circle")
                            .font(.system(size: 7))
                            .foregroundStyle(idx == current ? phaseTint(phase) : .secondary)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
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
                ExercisePatternIllustration(pattern: pattern, sportCode: resolvedSportCode, exerciseName: ex.name, size: 180)
                    .frame(maxWidth: .infinity)
                    .padding(12)
                    .background(Color(uiColor: .secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            let tipKey = SessionTipCatalog.tip(for: pattern, exerciseName: ex.name)
            ExerciseHowToDisclosure(exercise: ex, fallbackTip: tipKey)
        }
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
            case .warmup(let t), .cooldown(let t): return t
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
            // bug #6) : pause/reprise + passer.
            HStack(spacing: 16) {
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
        case .raw(let s):                return s.sanitizedForDisplay
        case .effort:                    return String(localized: "coaching.session.focus.timed.work")
        case .recovery:                  return String(localized: "coaching.session.focus.timed.rest")
        case .run(let i, let t):         return String(localized: "coaching.session.focus.timed.run \(i) \(t)")
        case .walk(let i, let t):        return String(localized: "coaching.session.focus.timed.walk \(i) \(t)")
        case .warmup:                    return String(localized: "coaching.adapter.session.warmup")
        case .cooldown:                  return String(localized: "coaching.adapter.session.cooldown")
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
                if let k = p.exerciseInRound, let K = p.totalInRound, K > 1 {
                    Text("coaching.session.focus.timed.roundExo \(round) \(tot) \(k) \(K)")
                } else {
                    Text("coaching.session.focus.timed.round \(round) \(tot)")
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
        SessionSportInference.sportCode(forSessionName: session.name, programSportCode: program.sport.appSportCode)
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
