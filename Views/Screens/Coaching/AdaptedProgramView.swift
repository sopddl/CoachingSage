// Views/Screens/Coaching/AdaptedProgramView.swift
// Master view : liste compacte de toutes les séances du programme adapté
// (header + AI banner si requis + sessions tap → push SessionDetailView +
// résumé adaptations + footer médical EU MDR).
// Détail riche d'une séance = SessionDetailView.
import SwiftUI
import TemplateModel

struct AdaptedProgramView: View {
    let program: AdaptedProgram

    /// Callback déclenché par le bouton "Demander à Léon". Stub Story 3.3a
    /// — l'implémentation réelle (appel Edge Function `sage-coaching-ai?mode=adapt-rare`)
    /// sera livrée en Story 3.3b.
    var onRequestAIAssist: (() -> Void)? = nil

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header

                if program.requiresAIAssist {
                    aiAssistBanner
                }

                ForEach(program.weeks, id: \.weekNumber) { week in
                    weekSection(week)
                }

                if !program.appliedRules.isEmpty {
                    appliedRulesSection
                }

                medicalReminderFooter
            }
            .padding()
        }
        .navigationTitle(Text("coaching.adapter.title"))
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(program.sport.rawValue.capitalized)
                .font(.title2.bold())
            Text(verbatim: "\(program.level.rawValue.capitalized) · \(program.weeks.count) sem")
                .font(.subheadline)
                .foregroundStyle(.secondary)
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
            if let onRequestAIAssist {
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

    // MARK: - Week section

    private func weekSection(_ week: AdaptedWeek) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text("coaching.adapter.week.label \(week.weekNumber)")
                    .font(.headline)
                Spacer()
                Text(verbatim: week.theme)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
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
            .padding(.top, 2)
        }
        .padding(.vertical, 4)
    }

    private func sessionRow(_ session: AdaptedSession, week: AdaptedWeek) -> some View {
        NavigationLink {
            SessionDetailView(session: session, week: week, program: program)
        } label: {
            HStack(spacing: 12) {
                Image(systemName: AdaptedProgramFormatting.sfSymbol(for: session.type))
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

    // MARK: - Applied rules log (résumé global)

    private var appliedRulesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("coaching.adapter.appliedRules.title")
                .font(.headline)
            ForEach(Array(program.appliedRules.enumerated()), id: \.offset) { _, rule in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: AdaptedProgramFormatting.outcomeSFSymbol(rule.outcome))
                        .foregroundStyle(AdaptedProgramFormatting.outcomeColor(rule.outcome))
                        .font(.caption)
                    Text(verbatim: "S\(rule.weekNumber) J\(rule.day) — \(rule.detail)")
                        .font(.caption)
                }
            }
        }
        .padding()
        .background(Color(uiColor: .tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
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
