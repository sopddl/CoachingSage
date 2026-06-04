// Views/Components/ExerciseTimelineCard.swift
// Story 3.19 Jalon 4 — sous-vue d'une card exo de la timeline. Extraction de
// `SessionTimelineView.exerciseCard(_:)` pour pouvoir héberger l'état pulse
// glossaire (AC13) + fade-in tip Léon. Logique pulse activée uniquement sur la
// **1ère card exo de la timeline** (`isFirstExercise == true`), et seulement
// si la card contient au moins un terme glossaire détecté dans `notes`.
//
// Séquence (1ère card, non-VoiceOver, non-Reduce-Motion, flag firstVisit not done) :
//   t=0     : ouverture vue → pulse scale(1.05) + opacity(0.8) × 3 cycles
//   t=1.5s  : fin pulse, markPulsed UserDefaults
//   t=1.8s  : fade-in tip Léon
//
// Cas dégradés :
//   - VoiceOver ON OU Reduce Motion ON → skip pulse, tip statique immédiat
//   - flag firstVisit déjà done → skip pulse, tip statique immédiat
//   - pas de match glossaire dans notes → skip pulse, tip statique immédiat
//   - card non-première OU notes vides → comportement Jalon 3 (tip statique)
import SwiftUI
import TemplateModel

struct ExerciseTimelineCard: View {
    @Environment(\.locale) private var locale
    let exercise: AdaptedExercise
    let sportCode: String?
    /// True si cette card est la **première card exo de la timeline** (pas la
    /// première de l'écran : hero/warmup sont exclus). Seule la 1ère card peut
    /// déclencher le pulse glossaire AC13.
    let isFirstExercise: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOverEnabled

    @State private var pulseScale: CGFloat = 1.0
    @State private var pulseOpacity: Double = 1.0
    @State private var tipVisible: Bool

    init(exercise: AdaptedExercise, sportCode: String?, isFirstExercise: Bool) {
        self.exercise = exercise
        self.sportCode = sportCode
        self.isFirstExercise = isFirstExercise
        // Pre-check synchrone : si on ne va PAS pulser (pre-check best-effort
        // sans Environment), le tip est visible dès la 1ère frame. Évite le
        // flash de 1 frame avec tip puis disparition. Le `.task` corrige si
        // VoiceOver/Reduce Motion sont activés (toggle à true immédiatement).
        let mayPulse = isFirstExercise && GlossaryFirstVisitPulse.shouldPulse()
        // Pré-check pulse en `init` (pas d'accès @Environment) → glossaire sur le
        // texte canonique FR ; les termes glossaire (FTP/Z2/vinyasa) sont des codes
        // quasi-invariants entre langues, suffisant pour cette nicety.
        let hasGlossary = Self.notesHaveGlossaryMatch(exercise.notes?.canonical)
        _tipVisible = State(initialValue: !(mayPulse && hasGlossary))
    }

    private static func notesHaveGlossaryMatch(_ notes: String?) -> Bool {
        guard let notes, !notes.isEmpty else { return false }
        return !Glossary.matches(in: notes).isEmpty
    }

    private var resolvedPattern: ExercisePattern? {
        sportCode.map { ExercisePatternResolver.resolve(exercise, sportCode: $0) }
    }

    private var notesHasGlossaryMatch: Bool {
        Self.notesHaveGlossaryMatch(exercise.notes?.resolved(locale))
    }

    /// True si la 1ère card peut pulser maintenant (toutes les pré-conditions OK).
    /// - Doit être la 1ère card exo.
    /// - Flag UserDefaults pas encore done.
    /// - VoiceOver OFF.
    /// - Reduce Motion OFF.
    /// - Notes non vides et contiennent un terme glossaire.
    private var canPulseFirstTerm: Bool {
        isFirstExercise
            && GlossaryFirstVisitPulse.shouldPulse()
            && !voiceOverEnabled
            && !reduceMotion
            && notesHasGlossaryMatch
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                if exercise.wasSubstituted {
                    Image(systemName: "arrow.left.arrow.right.circle.fill")
                        .foregroundStyle(.orange)
                        .font(.caption)
                }
                // Pédagogie Phase 1 — le titre passe par le glossaire (jargon
                // tappable : FTP, Z2, vinyasa…) + sanitize "/" → " · ".
                GlossaryRichText(
                    text: exercise.displayName(locale).sanitizedForDisplay,
                    font: .callout.bold(),
                    foreground: .primary
                )
                .fixedSize(horizontal: false, vertical: true)
            }
            if let pattern = resolvedPattern, let code = sportCode, pattern != .generic {
                ExercisePatternIllustration(pattern: pattern, sportCode: code, exerciseName: exercise.name.canonical)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(8)
                    .background(Color(uiColor: .tertiarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            if let notes = exercise.notes?.resolved(locale), !notes.isEmpty {
                BulletedNotes(text: notes, font: .footnote)
                    .scaleEffect(pulseScale)
                    .opacity(pulseOpacity)
                    .accessibilityIdentifier(
                        isFirstExercise
                            ? "coaching.session.timeline.exercise.notes.first"
                            : "coaching.session.timeline.exercise.notes"
                    )
            }
            metricsChipsRow(exercise)
            // Story 3.24b — SessionTipBubble remplacé par disclosure
            // "Comment l'exécuter ?" expandable. Tip pattern reste utilisé
            // en fallback gracieux quand pas de seed/cache/IA dispo.
            if let pattern = resolvedPattern {
                let tipKey = SessionTipCatalog.tip(for: pattern, exerciseName: exercise.name.canonical)
                ExerciseHowToDisclosure(exercise: exercise, fallbackTip: tipKey)
                    .padding(.top, 2)
                    .opacity(tipVisible ? 1 : 0)
            }
            if exercise.wasSubstituted, let reason = exercise.substitutionReason {
                Text(SessionTimelineView.userFriendlyAdaptationLabel(reason: reason))
                    .font(.caption2)
                    .foregroundStyle(.orange)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .task {
            await runFirstVisitSequence()
        }
    }

    /// AC13 — séquence pulse glossaire puis fade-in tip Léon. `.task` est
    /// auto-cancelled si la vue disparaît (back rapide) — pas de Timer fuite.
    private func runFirstVisitSequence() async {
        guard isFirstExercise else {
            // Non-première card : tip statique immédiat (Jalon 3 behaviour).
            tipVisible = true
            return
        }
        guard canPulseFirstTerm else {
            // 1ère card mais conditions pulse non remplies : tip statique immédiat.
            tipVisible = true
            return
        }
        // Pulse : 3 cycles de 0.5s = 1.5s total.
        for _ in 0..<3 {
            withAnimation(.easeInOut(duration: 0.25)) {
                pulseScale = 1.05
                pulseOpacity = 0.8
            }
            try? await Task.sleep(nanoseconds: 250_000_000)
            guard !Task.isCancelled else { return }
            withAnimation(.easeInOut(duration: 0.25)) {
                pulseScale = 1.0
                pulseOpacity = 1.0
            }
            try? await Task.sleep(nanoseconds: 250_000_000)
            guard !Task.isCancelled else { return }
        }
        GlossaryFirstVisitPulse.markPulsed()
        // Délai 0.3s avant fade-in tip (1.5s pulse + 0.3s gap = 1.8s spec).
        try? await Task.sleep(nanoseconds: 300_000_000)
        guard !Task.isCancelled else { return }
        withAnimation(.easeOut(duration: 0.3)) {
            tipVisible = true
        }
    }

    // MARK: - Metrics chips (copie depuis SessionTimelineView pour autonomie)

    @ViewBuilder
    private func metricsChipsRow(_ ex: AdaptedExercise) -> some View {
        let hasAnyMetric = ex.sets != nil
            || (ex.reps?.isEmpty == false)
            || (ex.duration?.isEmpty == false)
            || (ex.restSeconds ?? 0) > 0
            || (ex.targetZone?.isEmpty == false)
        if hasAnyMetric {
            HStack(spacing: 6) {
                if let sets = ex.sets, let reps = ex.reps, !reps.isEmpty {
                    metricChip { Text(verbatim: "\(sets) × \(reps.sanitizedForDisplay)") }
                } else if let reps = ex.reps, !reps.isEmpty {
                    metricChip { Text(verbatim: reps.sanitizedForDisplay) }
                } else if let sets = ex.sets {
                    metricChip { Text(verbatim: "\(sets) ×") }
                }
                if let duration = ex.duration, !duration.isEmpty, ex.reps == nil {
                    metricChip { Text(verbatim: duration.sanitizedForDisplay) }
                }
                if let rest = ex.restSeconds, rest > 0 {
                    metricChip { Text("coaching.adapter.exercise.rest \(rest)") }
                }
                if let zone = ex.targetZone, !zone.isEmpty {
                    glossaryChip(zone)
                }
                Spacer(minLength: 0)
            }
            .padding(.top, 2)
        }
    }

    private func metricChip<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        content()
            .font(.caption2)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color(uiColor: .tertiarySystemBackground))
            .clipShape(Capsule())
    }

    private func glossaryChip(_ term: String) -> some View {
        GlossaryTermBadge(term: term)
            .font(.caption2.bold())
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.coachingPrimary.opacity(0.10))
            .clipShape(Capsule())
    }
}

#if DEBUG
#Preview("Card — 1ère exo avec pulse") {
    ExerciseTimelineCard(
        exercise: AdaptedExercise(
            name: "Bloc 30/30 (pattern run.interval)",
            originalName: "Bloc 30/30",
            sets: 8,
            reps: "30s",
            duration: "30/30",
            restSeconds: 30,
            notes: "30s à Daniels-I, 30s en récup trot relâché. RPE 8.",
            targetZone: "Daniels-I"
        ),
        sportCode: "running",
        isFirstExercise: true
    )
    .padding()
}

#Preview("Card — exo non-première") {
    ExerciseTimelineCard(
        exercise: AdaptedExercise(
            name: "Récup active",
            originalName: "Récup active",
            duration: "5 min",
            notes: "Footing très lent, respiration nasale, RPE 3.",
            targetZone: "Daniels-E"
        ),
        sportCode: "running",
        isFirstExercise: false
    )
    .padding()
}
#endif
