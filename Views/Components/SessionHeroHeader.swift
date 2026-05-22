// Views/Components/SessionHeroHeader.swift
// Story 3.18 Phase 2 — bandeau hero d'une séance : background tinté couleur
// sport, icône SF Symbol grande, sous-titre W/J, nom séance, thème inline
// glossaire, grille 4 stats (durée · zone dominante · RPE estimé · nb blocs).
import SwiftUI
import TemplateModel

struct SessionHeroHeader: View {
    let session: AdaptedSession
    let week: AdaptedWeek
    let program: AdaptedProgram

    /// Couleur signature du sport effectif (peut différer du sport du programme
    /// pour triathlon : on regarde le nom de la séance via `SessionSportInference`).
    private var sportColor: Color {
        Color.coachingSport(forCode: effectiveSportCode)
    }

    private var sportSymbol: String {
        let parentCode = program.sport.appSportCode
        if effectiveSportCode != parentCode {
            return SportSymbol.symbol(forCode: effectiveSportCode)
        }
        if parentCode == "triathlon" {
            return AdaptedProgramFormatting.sfSymbol(for: session.type)
        }
        return SportSymbol.symbol(forCode: parentCode)
    }

    private var effectiveSportCode: String {
        SessionSportInference.sportCode(
            forSessionName: session.name,
            programSportCode: program.sport.appSportCode
        )
    }

    private var dominantZone: String? {
        SessionStatsCalculator.dominantZone(for: session)
    }

    private var estimatedRPE: Int {
        SessionStatsCalculator.estimatedRPE(for: session)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 14) {
                Image(systemName: sportSymbol)
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(sportColor)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle().fill(sportColor.opacity(0.18))
                    )
                VStack(alignment: .leading, spacing: 2) {
                    Text("coaching.adapter.session.fullLabel \(week.weekNumber) \(session.day)")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                    Text(verbatim: session.name)
                        .font(.title2.bold())
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.leading)
                }
                Spacer(minLength: 0)
            }

            if !week.theme.isEmpty {
                GlossaryRichText(text: week.theme, font: .footnote, foreground: .secondary)
            }

            statsGrid
                .accessibilityIdentifier("coaching.session.hero.statsGrid")
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(sportColor.opacity(0.10))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(sportColor.opacity(0.35), lineWidth: 1)
        )
        .accessibilityElement(children: .contain)
    }

    // MARK: - Stats grid

    @ViewBuilder
    private var statsGrid: some View {
        HStack(alignment: .top, spacing: 10) {
            statCell(
                systemImage: "clock.fill",
                value: "\(session.durationMinutes) min",
                labelKey: "coaching.session.stats.duration",
                tint: .coachingPrimary
            )
            statCell(
                systemImage: "chart.bar.fill",
                value: dominantZone ?? "—",
                labelKey: "coaching.session.stats.zone",
                tint: sportColor
            )
            statCell(
                systemImage: "flame.fill",
                value: "\(estimatedRPE)/10",
                labelKey: "coaching.session.stats.rpe",
                tint: SessionStatsCalculator.rpeColor(estimatedRPE)
            )
            statCell(
                systemImage: "square.stack.3d.up.fill",
                value: "\(session.exercises.count)",
                labelKey: "coaching.session.stats.blocks",
                tint: .coachingTextSecondary
            )
        }
    }

    private func statCell(systemImage: String, value: String, labelKey: LocalizedStringKey, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: systemImage)
                    .font(.caption2.bold())
                    .foregroundStyle(tint)
                Text(verbatim: value)
                    .font(.callout.bold())
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            Text(labelKey)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#if DEBUG
#Preview("Hero — endurance") {
    SessionHeroHeader(
        session: AdaptedProgramPreviewFixtures.sampleEnduranceSession(day: 1, name: "Footing facile"),
        week: AdaptedProgramPreviewFixtures.sampleWeek(1, theme: "Découverte"),
        program: AdaptedProgramPreviewFixtures.happyPath
    )
    .padding()
}

#Preview("Hero — interval") {
    SessionHeroHeader(
        session: AdaptedSession(
            day: 3, name: "Fractionné court 30/30", durationMinutes: 45,
            type: .interval,
            warmup: "10 min footing + 4 strides",
            exercises: (1...8).map { i in
                AdaptedExercise(
                    name: "Bloc \(i)",
                    originalName: "Bloc \(i)",
                    duration: "30s/30s",
                    notes: "30s à Daniels-I, 30s récup trot.",
                    targetZone: "Daniels-I"
                )
            },
            cooldown: "5 min footing très lent"
        ),
        week: AdaptedWeek(weekNumber: 3, theme: "Consolidation VO2max", goal: "Densifier la VO2", sessions: []),
        program: AdaptedProgramPreviewFixtures.happyPath
    )
    .padding()
}
#endif
