// Views/Screens/Dashboard/EmptyDashboardView.swift
// Story 3.8 sous-tâche 6 — vue mode vide « Séances » (Nathalie, 0 programme).
//
// Composition (cf spec ligne 554-565) :
//   - LeonHintView en haut (texte calibré sur autoprofil HK, fallback générique)
//   - Hero card gradient doré (#D4A85A → #C09548) — accroche émotionnelle
//   - Section SUGGESTIONS POUR TOI — exactement 3 templates `selectTopN`
//   - Lien dashed « Crée un programme sur mesure → » → questionnaire universel
// Pas de section « Mes routines » en mode vide (décision party #4).
//
// Source design : `ux-design-CoachingSage-seances-dashboard-2026-05-07.html`.
import SwiftUI
import TemplateModel

struct EmptyDashboardView: View {
    let suggestions: [ProgramTemplate]
    let hintKey: LocalizedStringKey
    let onTapSuggestion: (ProgramTemplate) -> Void
    let onTapCustom: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            LeonHintView(hintKey)

            HeroCard()

            VStack(alignment: .leading, spacing: 12) {
                Text("dashboard.empty.suggestions.title")
                    .font(.coachingCaption.weight(.semibold))
                    .foregroundStyle(Color.coachingTextSecondary)
                    .textCase(.uppercase)
                    .tracking(0.8)

                if suggestions.isEmpty {
                    SuggestionsFallbackCard()
                } else {
                    VStack(spacing: 10) {
                        ForEach(suggestions, id: \.id) { template in
                            SuggestedTemplateCard(
                                template: template,
                                onTap: { onTapSuggestion(template) }
                            )
                        }
                    }
                }
            }

            CustomProgramLink(onTap: onTapCustom)
        }
    }
}

// MARK: - Hero card

private struct HeroCard: View {
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: "figure.run")
                .font(.system(size: 32, weight: .semibold))
                .foregroundStyle(Color.coachingOnPrimary)
                .frame(width: 38, height: 38)

            VStack(alignment: .leading, spacing: 4) {
                Text("dashboard.empty.hero.title")
                    .font(.system(size: 20, weight: .semibold, design: .serif))
                    .foregroundStyle(Color.coachingOnPrimary)

                Text("dashboard.empty.hero.subtitle")
                    .font(.coachingBody)
                    .foregroundStyle(Color.coachingOnPrimary.opacity(0.92))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 18)
        .background(
            LinearGradient(
                colors: [Color(hex: 0xD4A85A), Color(hex: 0xC09548)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Suggested template card

private struct SuggestedTemplateCard: View {
    let template: ProgramTemplate
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                ZStack {
                    // Sophie 2026-05-10 (raffinement) : pattern carré arrondi
                    // + bordure couleur sport + icone couleur sport (mockup
                    // photo 2 sport picker). Cohérent avec ProgramCard.
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.coachingCard)
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .strokeBorder(Color.coachingSport(forCode: template.sport.appSportCode), lineWidth: 2)
                    Image(systemName: sfSymbol)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(Color.coachingSport(forCode: template.sport.appSportCode))
                }
                .frame(width: 40, height: 40)

                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text(template.name)
                            .font(.coachingBody.weight(.semibold))
                            .foregroundStyle(Color.coachingTextPrimary)
                            .lineLimit(1)

                        Spacer(minLength: 8)

                        Text(durationTag)
                            .font(.coachingCaption.weight(.medium))
                            .foregroundStyle(Color.coachingTextSecondary)
                    }

                    Text(template.summary)
                        .font(.coachingCaption)
                        .foregroundStyle(Color.coachingTextSecondary)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "chevron.right")
                    .font(.footnote)
                    .foregroundStyle(Color.coachingTextSecondary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color.coachingCard)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("dashboard.empty.suggestion.\(template.sport.appSportCode)")
    }

    private var sfSymbol: String {
        switch template.sport {
        case .running: return "figure.run"
        case .cycling: return "figure.outdoor.cycle"
        case .swimming: return "figure.pool.swim"
        case .triathlon: return "figure.mixed.cardio"
        case .strengthTraining: return "dumbbell.fill"
        case .yoga: return "figure.yoga"
        case .hiit: return "bolt.heart.fill"
        case .hiking: return "figure.hiking"
        case .tennis: return "figure.tennis"
        case .football: return "soccerball"
        }
    }

    private var durationTag: String {
        let weeks = template.durationWeeks
        return String(
            format: NSLocalizedString("dashboard.empty.suggestion.weeks", comment: "ex. 8 sem"),
            weeks
        )
    }
}

// MARK: - Suggestions fallback (library KO)

private struct SuggestionsFallbackCard: View {
    var body: some View {
        Text("dashboard.empty.suggestions.unavailable")
            .font(.coachingCaption)
            .foregroundStyle(Color.coachingTextSecondary)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.coachingCard)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

// MARK: - Lien programme sur mesure

private struct CustomProgramLink: View {
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Text("dashboard.empty.custom.cta")
                    .font(.coachingBody)
                    .foregroundStyle(Color.coachingTextPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "arrow.right")
                    .font(.footnote)
                    .foregroundStyle(Color.coachingPrimary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(
                        Color.coachingTextSecondary.opacity(0.45),
                        style: StrokeStyle(lineWidth: 1, dash: [4, 3])
                    )
            )
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("dashboard.empty.custom.cta")
    }
}

// MARK: - Color hex helper (privé fichier — ne PAS dupliquer si déjà exposé)

private extension Color {
    init(hex: UInt32, opacity: Double = 1.0) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8) & 0xFF) / 255.0
        let b = Double(hex & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: opacity)
    }
}

#Preview {
    let template = ProgramTemplate(
        id: "running-beginner-5k-8sem",
        schemaVersion: 1,
        sport: .running,
        level: .beginner,
        name: "Mon premier 5K",
        durationWeeks: 8,
        sessionsPerWeek: 3,
        defaultObjective: "objective",
        assumedProfile: "profile",
        summary: "Reprends en douceur avec 3 séances par semaine.",
        weeks: [],
        safetyNotes: "n/a",
        progressionLogic: "n/a"
    )
    return ScrollView {
        EmptyDashboardView(
            suggestions: [template, template, template],
            hintKey: "dashboard.empty.hint.default",
            onTapSuggestion: { _ in },
            onTapCustom: {}
        )
        .padding(.horizontal, 16)
    }
    .background(Color.coachingBackground)
}
