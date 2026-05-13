// Views/Screens/Coaching/SessionDetailView.swift
// Détail riche d'une AdaptedSession (push depuis AdaptedProgramView master) :
// header (nom + position S/J + durée + thème de la semaine), warmup, exercices
// avec sets/reps/duration/rest/zone/notes/substitutions, cooldown, adaptations
// filtrées sur cette séance, footer médical EU MDR.
import SwiftUI
import TemplateModel

struct SessionDetailView: View {
    let session: AdaptedSession
    let week: AdaptedWeek
    let program: AdaptedProgram
    /// Phase B.6 — true si cette session a été mutée par la regen S+1 cette
    /// semaine (durée modifiée par `WeeklyRegenApplicationService`). Affiche
    /// un bandeau header explicatif. Default false côté preview.
    var isModifiedByRegen: Bool = false

    private var rulesForSession: [AppliedRule] {
        program.appliedRules.filter { $0.weekNumber == week.weekNumber && $0.day == session.day }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header

                if isModifiedByRegen {
                    regenAdjustedBanner
                }

                if let warmup = session.warmup, !warmup.isEmpty {
                    phaseBlock(systemImage: "flame.fill",
                               labelKey: "coaching.adapter.session.warmup",
                               text: warmup,
                               tint: .orange)
                }

                exercisesSection

                if let cooldown = session.cooldown, !cooldown.isEmpty {
                    phaseBlock(systemImage: "snowflake",
                               labelKey: "coaching.adapter.session.cooldown",
                               text: cooldown,
                               tint: .blue)
                }

                if !rulesForSession.isEmpty {
                    sessionAdaptationsSection
                }

                medicalReminderFooter
            }
            .padding()
        }
        .navigationTitle(Text(verbatim: session.name))
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("coaching.adapter.session.fullLabel \(week.weekNumber) \(session.day)")
                .font(.caption.bold())
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
            HStack(spacing: 10) {
                Image(systemName: AdaptedProgramFormatting.sfSymbol(for: session.type))
                    .font(.title3)
                    .foregroundStyle(.tint)
                Text(verbatim: session.name)
                    .font(.title2.bold())
            }
            Text(verbatim: "\(session.durationMinutes) min")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            if !week.theme.isEmpty {
                Text(verbatim: week.theme)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.top, 2)
            }
        }
    }

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

    // MARK: - Phase block (warmup / cooldown)

    private func phaseBlock(systemImage: String, labelKey: LocalizedStringKey, text: String, tint: Color) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: systemImage)
                .foregroundStyle(tint)
                .font(.callout)
                .frame(width: 20)
                .padding(.top, 2)
            VStack(alignment: .leading, spacing: 4) {
                Text(labelKey)
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                Text(verbatim: text)
                    .font(.callout)
            }
            Spacer()
        }
        .padding(12)
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    // MARK: - Exercises

    private var exercisesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("coaching.adapter.session.exercises.title")
                .font(.caption.bold())
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
            VStack(spacing: 8) {
                ForEach(session.exercises, id: \.originalName) { ex in
                    exerciseRow(ex)
                }
            }
        }
    }

    private func exerciseRow(_ ex: AdaptedExercise) -> some View {
        HStack(alignment: .top, spacing: 10) {
            if ex.wasSubstituted {
                Image(systemName: "arrow.left.arrow.right.circle.fill")
                    .foregroundStyle(.orange)
                    .font(.callout)
                    .padding(.top, 2)
            } else {
                Image(systemName: "circle.fill")
                    .foregroundStyle(.tint)
                    .font(.system(size: 7))
                    .padding(.top, 7)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(verbatim: ex.name)
                    .font(.callout.bold())
                if let metrics = exerciseMetrics(ex), !metrics.isEmpty {
                    Text(verbatim: metrics)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if let notes = ex.notes, !notes.isEmpty {
                    HStack(alignment: .top, spacing: 4) {
                        Text("coaching.adapter.exercise.notes")
                            .font(.caption2.bold())
                            .foregroundStyle(.secondary)
                        Text(verbatim: notes)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                if ex.wasSubstituted, let reason = ex.substitutionReason {
                    // Sophie 2026-05-11 : texte audit "remplace X par Y (equipment:dumbbells)"
                    // remplacé par un libellé user-friendly basé sur le préfixe de reason.
                    Text(Self.userFriendlyAdaptationLabel(reason: reason))
                        .font(.caption2)
                        .foregroundStyle(.orange)
                }
            }
            Spacer()
        }
        .padding(12)
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    /// Sophie 2026-05-11 : libellé user-friendly d'un exercice substitué.
    /// Le `substitutionReason` brut (ex: "equipment:dumbbells", "constraint:knee-injury")
    /// est un audit dev — on le mappe à un message court compréhensible par le user.
    static func userFriendlyAdaptationLabel(reason: String) -> LocalizedStringKey {
        if reason.hasPrefix("equipment:") {
            return "coaching.adapter.exercise.adapted.equipment"
        }
        if reason.hasPrefix("constraint:") {
            return "coaching.adapter.exercise.adapted.constraint"
        }
        return "coaching.adapter.exercise.adapted.generic"
    }

    /// Concatène sets/reps/duration/rest/zone en une ligne compacte, séparés par " · ".
    /// Renvoie nil si rien d'affichable.
    private func exerciseMetrics(_ ex: AdaptedExercise) -> String? {
        var parts: [String] = []
        if let sets = ex.sets, let reps = ex.reps, !reps.isEmpty {
            parts.append("\(sets) × \(reps)")
        } else if let sets = ex.sets {
            parts.append("\(sets) ×")
        } else if let reps = ex.reps, !reps.isEmpty {
            parts.append(reps)
        }
        if let duration = ex.duration, !duration.isEmpty {
            parts.append(duration)
        }
        if let rest = ex.restSeconds, rest > 0 {
            parts.append(String(localized: "coaching.adapter.exercise.rest \(rest)"))
        }
        if let zone = ex.targetZone, !zone.isEmpty {
            parts.append(zone)
        }
        return parts.isEmpty ? nil : parts.joined(separator: " · ")
    }

    // MARK: - Adaptations propres à cette séance

    private var sessionAdaptationsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("coaching.adapter.appliedRules.title")
                .font(.caption.bold())
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
            ForEach(Array(rulesForSession.enumerated()), id: \.offset) { _, rule in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: AdaptedProgramFormatting.outcomeSFSymbol(rule.outcome))
                        .foregroundStyle(AdaptedProgramFormatting.outcomeColor(rule.outcome))
                        .font(.caption)
                        .padding(.top, 2)
                    Text(verbatim: rule.detail)
                        .font(.caption)
                }
            }
        }
        .padding(12)
        .background(Color(uiColor: .tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
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
