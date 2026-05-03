// Views/Screens/Coaching/AdaptedProgramView.swift
// Story 3.3a — affiche un AdaptedProgram (résultat de ProgramAdapter) :
// semaines/sessions/exercices + log des adaptations + banner IA si requis +
// rappel médical EU MDR. Pas encore branché dans la nav (cf. Story 3.2 et
// Task #6 — branchement flow).
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

    // MARK: - Week / sessions

    private func weekSection(_ week: AdaptedWeek) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("coaching.adapter.week.label \(week.weekNumber)")
                    .font(.headline)
                Spacer()
                Text(verbatim: week.theme)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            ForEach(week.sessions, id: \.day) { session in
                sessionRow(session)
            }
        }
        .padding(.vertical, 4)
    }

    private func sessionRow(_ session: AdaptedSession) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: sfSymbol(for: session.type))
                    .frame(width: 24)
                    .foregroundStyle(.tint)
                Text(verbatim: session.name)
                    .font(.subheadline.bold())
                Spacer()
                Text(verbatim: "\(session.durationMinutes) min")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            ForEach(session.exercises, id: \.originalName) { ex in
                exerciseRow(ex)
            }
        }
        .padding(10)
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func exerciseRow(_ ex: AdaptedExercise) -> some View {
        HStack(alignment: .top, spacing: 8) {
            if ex.wasSubstituted {
                Image(systemName: "arrow.left.arrow.right.circle.fill")
                    .foregroundStyle(.orange)
                    .font(.caption)
            } else {
                Image(systemName: "circle.fill")
                    .foregroundStyle(.tint)
                    .font(.system(size: 6))
                    .padding(.top, 6)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(verbatim: ex.name)
                    .font(.callout)
                if let zone = ex.targetZone {
                    Text(verbatim: zone)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                if ex.wasSubstituted, let reason = ex.substitutionReason {
                    Text(verbatim: "\(String(localized: "coaching.adapter.exercise.replaces")) « \(ex.originalName) » (\(reason))")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                }
            }
            Spacer()
        }
        .padding(.leading, 32)
    }

    // MARK: - Applied rules log

    private var appliedRulesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("coaching.adapter.appliedRules.title")
                .font(.headline)
            ForEach(Array(program.appliedRules.enumerated()), id: \.offset) { _, rule in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: outcomeSFSymbol(rule.outcome))
                        .foregroundStyle(outcomeColor(rule.outcome))
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

    // MARK: - Helpers

    private func sfSymbol(for type: SessionType) -> String {
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

    private func outcomeSFSymbol(_ outcome: AppliedRule.Outcome) -> String {
        switch outcome {
        case .substituted: return "arrow.left.arrow.right.circle.fill"
        case .removed: return "minus.circle.fill"
        case .downgraded: return "arrow.down.circle.fill"
        case .requiresAI: return "sparkles"
        case .noChange: return "circle"
        }
    }

    private func outcomeColor(_ outcome: AppliedRule.Outcome) -> Color {
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

private enum AdaptedProgramPreviewFixtures {
    static var happyPath: AdaptedProgram {
        AdaptedProgram(
            templateId: "running-fixture",
            sport: .running,
            level: .beginner,
            appliedAt: Date(),
            weeks: [sampleWeek(1, theme: "Découverte")],
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
                            type: .interval, warmup: nil,
                            exercises: [
                                AdaptedExercise(
                                    name: "Marche nordique 20 min",
                                    originalName: "Bondissements 6×30s",
                                    duration: "20 min",
                                    targetZone: "Daniels-E",
                                    volumeAxis: .duration,
                                    wasSubstituted: true,
                                    substitutionReason: "constraint:knee-injury"
                                )
                            ],
                            cooldown: nil
                        ),
                        sampleSession(day: 3, name: "Tempo continu", type: .endurance)
                    ]
                )
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

    private static func sampleWeek(_ wn: Int, theme: String) -> AdaptedWeek {
        AdaptedWeek(
            weekNumber: wn, theme: theme, goal: "Build endurance",
            sessions: [
                sampleSession(day: 1, name: "Easy run", type: .endurance),
                sampleSession(day: 3, name: "Intervals", type: .interval),
                sampleSession(day: 5, name: "Long run", type: .endurance)
            ]
        )
    }

    private static func sampleSession(day: Int, name: String, type: SessionType) -> AdaptedSession {
        AdaptedSession(
            day: day, name: name, durationMinutes: 40,
            type: type, warmup: nil,
            exercises: [
                AdaptedExercise(
                    name: "\(name) bloc principal",
                    originalName: "\(name) bloc principal",
                    duration: "30 min",
                    targetZone: type == .interval ? "Daniels-I" : "Daniels-E",
                    volumeAxis: .duration
                )
            ],
            cooldown: nil
        )
    }
}
#endif
