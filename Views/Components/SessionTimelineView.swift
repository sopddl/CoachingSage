// Views/Components/SessionTimelineView.swift
// Story 3.18 Phase 2 — timeline visuelle stepper vertical d'une séance :
// rail à gauche avec pastilles (warmup ⓪ flamme · exos numérotés · cooldown
// ⓝ flocon), cards content alignées à droite. Migration des rendus inline
// `phaseBlock`+`exerciseRow` de SessionDetailView pour pose pédagogique
// "étape par étape".
import SwiftUI
import TemplateModel

struct SessionTimelineView: View {
    let session: AdaptedSession
    let sportColor: Color
    /// Code sport (camelCase) utilisé pour résoudre les illustrations exo
    /// (`ExercisePatternResolver`) et leur palette silhouette. Optionnel :
    /// si nil, les illus tombent en `.generic` SF Symbol fallback générique.
    let sportCode: String?

    init(session: AdaptedSession, sportColor: Color, sportCode: String? = nil) {
        self.session = session
        self.sportColor = sportColor
        self.sportCode = sportCode
    }

    /// Items dérivés (ordre stable : warmup si présent, exos, cooldown si présent).
    private var items: [TimelineItem] {
        var result: [TimelineItem] = []
        if let w = session.warmup, !w.isEmpty {
            result.append(.warmup(w))
        }
        for ex in session.exercises {
            result.append(.exercise(ex))
        }
        if let c = session.cooldown, !c.isEmpty {
            result.append(.cooldown(c))
        }
        return result
    }

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.offset) { idx, item in
                row(item: item, exerciseIndex: exerciseIndex(in: items, at: idx), isLast: idx == items.count - 1)
            }
        }
        .accessibilityIdentifier("coaching.session.timeline")
    }

    private func exerciseIndex(in items: [TimelineItem], at idx: Int) -> Int {
        var count = 0
        for i in 0..<idx {
            if case .exercise = items[i] { count += 1 }
        }
        return count + 1
    }

    @ViewBuilder
    private func row(item: TimelineItem, exerciseIndex: Int, isLast: Bool) -> some View {
        HStack(alignment: .top, spacing: 12) {
            // Colonne rail + pastille
            VStack(spacing: 0) {
                pastille(for: item, exerciseIndex: exerciseIndex)
                    .accessibilityHidden(true)
                if !isLast {
                    Rectangle()
                        .fill(Color.coachingPrimary.opacity(0.25))
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                }
            }
            .frame(width: 32)

            // Colonne content
            content(for: item)
                .padding(.bottom, isLast ? 0 : 12)
        }
    }

    // MARK: - Pastille

    @ViewBuilder
    private func pastille(for item: TimelineItem, exerciseIndex: Int) -> some View {
        ZStack {
            Circle()
                .fill(pastilleTint(for: item).opacity(0.18))
                .frame(width: 28, height: 28)
            Circle()
                .strokeBorder(pastilleTint(for: item), lineWidth: 1.5)
                .frame(width: 28, height: 28)
            pastilleGlyph(for: item, exerciseIndex: exerciseIndex)
                .font(.caption.bold())
                .foregroundStyle(pastilleTint(for: item))
        }
    }

    @ViewBuilder
    private func pastilleGlyph(for item: TimelineItem, exerciseIndex: Int) -> some View {
        switch item {
        case .warmup:
            Image(systemName: "flame.fill")
                .font(.caption2.bold())
        case .cooldown:
            Image(systemName: "snowflake")
                .font(.caption2.bold())
        case .exercise:
            Text(verbatim: "\(exerciseIndex)")
        }
    }

    private func pastilleTint(for item: TimelineItem) -> Color {
        switch item {
        case .warmup:   return .orange
        case .cooldown: return .blue
        case .exercise: return sportColor
        }
    }

    // MARK: - Card content

    @ViewBuilder
    private func content(for item: TimelineItem) -> some View {
        switch item {
        case .warmup(let text):
            phaseCard(
                labelKey: "coaching.adapter.session.warmup",
                text: text,
                tint: .orange
            )
        case .cooldown(let text):
            phaseCard(
                labelKey: "coaching.adapter.session.cooldown",
                text: text,
                tint: .blue
            )
        case .exercise(let ex):
            exerciseCard(ex)
        }
    }

    private func phaseCard(labelKey: LocalizedStringKey, text: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(labelKey)
                .font(.caption.bold())
                .foregroundStyle(tint)
                .textCase(.uppercase)
            GlossaryRichText(text: text, font: .callout, foreground: .primary)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func exerciseCard(_ ex: AdaptedExercise) -> some View {
        let resolvedPattern: ExercisePattern? = sportCode.map { code in
            ExercisePatternResolver.resolve(ex, sportCode: code)
        }
        return VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                if ex.wasSubstituted {
                    Image(systemName: "arrow.left.arrow.right.circle.fill")
                        .foregroundStyle(.orange)
                        .font(.caption)
                }
                Text(verbatim: ex.name)
                    .font(.callout.bold())
                    .foregroundStyle(.primary)
            }
            if let pattern = resolvedPattern, let code = sportCode, pattern != .generic {
                ExercisePatternIllustration(pattern: pattern, sportCode: code, exerciseName: ex.name)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(8)
                    .background(Color(uiColor: .tertiarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            if let notes = ex.notes, !notes.isEmpty {
                GlossaryRichText(text: notes, font: .footnote, foreground: .primary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            metricsChipsRow(ex)
            if ex.wasSubstituted, let reason = ex.substitutionReason {
                Text(Self.userFriendlyAdaptationLabel(reason: reason))
                    .font(.caption2)
                    .foregroundStyle(.orange)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    static func userFriendlyAdaptationLabel(reason: String) -> LocalizedStringKey {
        if reason.hasPrefix("equipment:") {
            return "coaching.adapter.exercise.adapted.equipment"
        }
        if reason.hasPrefix("constraint:") {
            return "coaching.adapter.exercise.adapted.constraint"
        }
        return "coaching.adapter.exercise.adapted.generic"
    }

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
                    metricChip { Text(verbatim: "\(sets) × \(reps)") }
                } else if let reps = ex.reps, !reps.isEmpty {
                    metricChip { Text(verbatim: reps) }
                } else if let sets = ex.sets {
                    metricChip { Text(verbatim: "\(sets) ×") }
                }
                if let duration = ex.duration, !duration.isEmpty, ex.reps == nil {
                    metricChip { Text(verbatim: duration) }
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

    // MARK: - Item type

    enum TimelineItem {
        case warmup(String)
        case exercise(AdaptedExercise)
        case cooldown(String)
    }
}

#if DEBUG
#Preview("Timeline — interval rich") {
    ScrollView {
        SessionTimelineView(
            session: AdaptedSession(
                day: 3, name: "Fractionné court 30/30",
                durationMinutes: 45,
                type: .interval,
                warmup: "10 min footing progressif + 4 strides",
                exercises: [
                    AdaptedExercise(
                        name: "Bloc 30/30",
                        originalName: "Bloc 30/30",
                        sets: 8,
                        reps: "30s",
                        duration: "30/30",
                        restSeconds: 30,
                        notes: "30s à Daniels-I, 30s en récup trot relâché.",
                        targetZone: "Daniels-I"
                    ),
                    AdaptedExercise(
                        name: "Récup active",
                        originalName: "Récup active",
                        duration: "5 min",
                        notes: "Footing très lent, respiration nasale, RPE 3.",
                        targetZone: "Daniels-E"
                    )
                ],
                cooldown: "5 min marche + étirements doux"
            ),
            sportColor: .coachingPrimary
        )
        .padding()
    }
}
#endif
