// Views/Components/SessionHeroHeader.swift
// Story 3.32 (HUB) — bandeau hero slimmé d'une séance : icône sport + S/J + nom,
// grille 3 stats AGNOSTIQUES (Durée · Intensité 1-5 · Format caméléon), zéro
// case vide / jamais "—" quel que soit le sport. La "Zone" n'est plus un slot
// fixe (elle reste dans l'exo via la timeline). Fix bug troncature "50…/55…".
// Remplace la grille 4 stats (Story 3.18) Durée·Zone·RPE·Blocs.
import SwiftUI
import TemplateModel

struct SessionHeroHeader: View {
    @Environment(\.locale) private var locale
    let session: AdaptedSession
    let week: AdaptedWeek
    let program: AdaptedProgram

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
            forSessionName: session.name.canonical,
            programSportCode: program.sport.appSportCode
        )
    }

    private var estimatedRPE: Int {
        SessionStatsCalculator.estimatedRPE(for: session)
    }

    private var sessionFormat: SessionFormatDescriptor.Format {
        SessionFormatDescriptor.format(for: session, sportCode: effectiveSportCode)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center, spacing: 12) {
                Image(systemName: sportSymbol)
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(sportColor)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle().fill(sportColor.opacity(0.18))
                    )
                VStack(alignment: .leading, spacing: 2) {
                    Text("coaching.adapter.session.fullLabel \(week.weekNumber) \(session.day)")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                    Text(verbatim: session.name.resolved(locale).sanitizedForDisplay)
                        .font(.title3.bold())
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.leading)
                }
                Spacer(minLength: 0)
            }

            statsGrid
                .accessibilityIdentifier("coaching.session.hero.statsGrid")
        }
        .padding(14)
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

    // MARK: - Stats grid (3 cellules agnostiques)

    @ViewBuilder
    private var statsGrid: some View {
        HStack(alignment: .top, spacing: 10) {
            statCell(
                systemImage: "clock.fill",
                value: "\(session.durationMinutes) min",
                labelKey: "coaching.session.stats.duration",
                tint: .coachingPrimary
            )
            intensityCell(rpe: estimatedRPE)
            formatCell(format: sessionFormat)
        }
    }

    /// Cellule "Intensité" : jauge 5 niveaux + libellé figé 1-5 commun à tous les
    /// sports (AC5). Pas de "RPE N" brut côté user.
    private func intensityCell(rpe: Int) -> some View {
        let level = SessionStatsCalculator.effortLevel(rpe: rpe)
        let labelKey = SessionStatsCalculator.intensityLabel(level: level)
        return VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Image(systemName: "flame.fill")
                    .font(.caption2.bold())
                    .foregroundStyle(SessionStatsCalculator.rpeColor(rpe))
                EffortGauge(level: level)
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
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("coaching.session.stats.intensity"))
        .accessibilityValue(Text(labelKey))
    }

    /// Cellule "Format" caméléon (AC4) : libellé piloté par `SessionFormatDescriptor`.
    /// Rendu i18n par interpolation de placeholders (jamais de clé construite).
    private func formatCell(format: SessionFormatDescriptor.Format) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: "rectangle.stack.fill")
                    .font(.caption2.bold())
                    .foregroundStyle(sportColor)
                formatValueText(format)
                    .font(.callout.bold())
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
            Text("coaching.session.stats.format")
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

    @ViewBuilder
    private func formatValueText(_ format: SessionFormatDescriptor.Format) -> some View {
        switch format {
        case .blocks(let n):
            Text("coaching.session.format.blocks \(n)")
        case .rounds(let count, let work, let rest):
            Text("coaching.session.format.rounds \(count) \(work) \(rest)")
        case .intervals(let n):
            Text("coaching.session.format.intervals \(n)")
        case .postures(let n):
            Text("coaching.session.format.postures \(n)")
        case .series(let n):
            Text("coaching.session.format.series \(n)")
        case .keySession(let s):
            Text(verbatim: s)
        case .exercises(let n):
            Text("coaching.session.format.exercises \(n)")
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
                    .lineLimit(2)
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
                    name: LocalizedText(fr: "Bloc \(i)"),
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
