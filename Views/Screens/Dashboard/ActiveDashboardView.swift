// Views/Screens/Dashboard/ActiveDashboardView.swift
// Story 3.8 sous-tâche 7 — vue mode actif (single + multi programmes).
//
// Composition (cf spec ligne 567-586) :
//   - PROCHAINE SÉANCE      : `DominantNextSessionCard` (gradient bleu coach)
//   - MES PROGRAMMES        : `ProgramCard` × N, triées par date de prochaine séance
//   - MES ROUTINES (si ≥ 1) : `RoutineCard` × M, border dashed doré
//   - Card dashed bottom    : « + Créer une routine ou un programme »
//   - Lien CTA discret      : « ↻ Réorganiser ma semaine → »
//
// Le mini-widget « Cette semaine » + la card « Et après » (cas single program)
// sont livrés à la sous-tâche 8 (rest day + WeeklyStatsService) — pas ici.
//
// Source design : `ux-design-CoachingSage-seances-dashboard-2026-05-07.html`.
import SwiftUI
import TemplateModel

struct ActiveDashboardView: View {
    let dominant: NextSessionResolver.Result?
    let programs: [ActiveProgramSummary]
    let routines: [RoutineRecord]
    let nowProvider: () -> Date
    let onTapDominantStart: (NextSessionResolver.Result) -> Void
    let onTapProgram: (ActiveProgramSummary) -> Void
    let onTapCreateProgram: () -> Void
    let onTapCreateRoutine: () -> Void
    let onTapWeeklyReorder: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            if let dominant {
                section(titleKey: "dashboard.active.next.title") {
                    DominantNextSessionCard(
                        result: dominant,
                        now: nowProvider(),
                        onTapStart: { onTapDominantStart(dominant) }
                    )
                }
            }

            section(titleKey: "dashboard.active.programs.title") {
                VStack(spacing: 10) {
                    ForEach(programs, id: \.record.id) { summary in
                        ProgramCard(
                            summary: summary,
                            onTap: { onTapProgram(summary) }
                        )
                    }
                }
            }

            if !routines.isEmpty {
                section(titleKey: "dashboard.active.routines.title") {
                    VStack(spacing: 10) {
                        ForEach(routines, id: \.id) { routine in
                            RoutineCard(routine: routine)
                        }
                    }
                }
            }

            CreateProgramOrRoutineCard(
                onTapProgram: onTapCreateProgram,
                onTapRoutine: onTapCreateRoutine
            )

            WeeklyReorderLink(onTap: onTapWeeklyReorder)
        }
    }

    @ViewBuilder
    private func section(titleKey: LocalizedStringKey, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(titleKey)
                .font(.coachingCaption.weight(.semibold))
                .foregroundStyle(Color.coachingTextSecondary)
                .textCase(.uppercase)
                .tracking(0.8)
            content()
        }
    }
}

// MARK: - Dominant next session card

private struct DominantNextSessionCard: View {
    let result: NextSessionResolver.Result
    let now: Date
    let onTapStart: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(verbatim: whenLabel)
                .font(.system(size: 11, weight: .semibold, design: .default))
                .tracking(1.2)
                .foregroundStyle(Color.coachingOnPrimary.opacity(0.85))

            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(verbatim: emoji)
                    .font(.system(size: 22))
                Text(verbatim: result.session.name)
                    .font(.system(size: 19, weight: .semibold, design: .serif))
                    .foregroundStyle(Color.coachingOnPrimary)
                    .lineLimit(2)
                Spacer(minLength: 0)
            }

            Text(verbatim: metaLine)
                .font(.system(size: 12, weight: .regular, design: .default))
                .foregroundStyle(Color.coachingOnPrimary.opacity(0.85))
                .lineLimit(2)

            Button(action: onTapStart) {
                HStack(spacing: 6) {
                    Text("dashboard.active.next.cta")
                        .font(.coachingBody.weight(.semibold))
                    Image(systemName: "arrow.right")
                        .font(.footnote.weight(.semibold))
                }
                .foregroundStyle(Color.coachingPrimary)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.coachingOnPrimary)
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("dashboard.active.next.cta")
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [Color(hex: 0x1E5090), Color(hex: 0x2B5F8A)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .accessibilityElement(children: .contain)
    }

    private var emoji: String {
        switch result.program.sportCode {
        case "running": return "🏃"
        case "cycling": return "🚴"
        case "swimming": return "🏊"
        case "triathlon": return "🥇"
        case "strengthTraining": return "🏋️"
        case "yoga": return "🧘"
        case "hiit": return "🔥"
        case "hiking": return "🥾"
        case "tennis": return "🎾"
        case "football": return "⚽"
        default: return "💪"
        }
    }

    private var whenLabel: String {
        let cal = Calendar.current
        let start = cal.startOfDay(for: now)
        let date = result.effectiveDate
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        if cal.isDate(date, inSameDayAs: start) {
            formatter.dateFormat = "HH:mm"
            let isMidnight = cal.component(.hour, from: date) == 0 && cal.component(.minute, from: date) == 0
            return isMidnight
                ? String(localized: "dashboard.active.when.today")
                : "\(String(localized: "dashboard.active.when.today")) · \(formatter.string(from: date))"
        }
        if cal.isDate(date, inSameDayAs: cal.date(byAdding: .day, value: 1, to: start) ?? start) {
            formatter.dateFormat = "HH:mm"
            let isMidnight = cal.component(.hour, from: date) == 0 && cal.component(.minute, from: date) == 0
            return isMidnight
                ? String(localized: "dashboard.active.when.tomorrow")
                : "\(String(localized: "dashboard.active.when.tomorrow")) · \(formatter.string(from: date))"
        }
        formatter.setLocalizedDateFormatFromTemplate("EEEd")
        return formatter.string(from: date).uppercased()
    }

    private var metaLine: String {
        String(
            format: NSLocalizedString("dashboard.active.next.meta", comment: "ex. Sem 3 · 45 min"),
            result.session.weekNumber,
            result.session.durationMinutes
        )
    }
}

// MARK: - Program card

private struct ProgramCard: View {
    let summary: ActiveProgramSummary
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color.coachingRecord.opacity(0.18))
                    Image(systemName: sfSymbol)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(Color.coachingRecord)
                }
                .frame(width: 36, height: 36)

                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text(verbatim: displayName)
                            .font(.coachingBody.weight(.semibold))
                            .foregroundStyle(Color.coachingTextPrimary)
                            .lineLimit(1)
                        Spacer(minLength: 8)
                        Text(verbatim: percentLabel)
                            .font(.coachingCaption.weight(.semibold))
                            .foregroundStyle(Color.coachingTextSecondary)
                    }

                    Text(verbatim: metaLine)
                        .font(.coachingCaption)
                        .foregroundStyle(Color.coachingTextSecondary)
                        .lineLimit(1)

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.coachingRecord.opacity(0.15))
                                .frame(height: 4)
                            Capsule()
                                .fill(Color.coachingRecord)
                                .frame(width: max(4, geo.size.width * summary.progress), height: 4)
                        }
                    }
                    .frame(height: 4)
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
        .accessibilityIdentifier("dashboard.active.program.\(summary.record.sportCode)")
    }

    private var displayName: String {
        if let name = summary.templateName, !name.isEmpty { return name }
        return String(format: NSLocalizedString("dashboard.active.program.fallback", comment: ""), summary.record.sportCode.capitalized)
    }

    private var percentLabel: String {
        "\(Int((summary.progress * 100).rounded()))%"
    }

    private var metaLine: String {
        let weekNumber = summary.record.sessions
            .first { !summary.record.completionState.sessionRecords.keys.contains($0.id) }?
            .weekNumber ?? 1
        let nextLabel: String
        if let date = summary.nextDate {
            let formatter = DateFormatter()
            formatter.locale = Locale.current
            formatter.setLocalizedDateFormatFromTemplate("EEEd")
            nextLabel = formatter.string(from: date)
        } else {
            nextLabel = String(localized: "dashboard.active.program.complete")
        }
        return String(
            format: NSLocalizedString("dashboard.active.program.meta", comment: "ex. Sem 3 · prochaine : lun. 12"),
            weekNumber,
            nextLabel
        )
    }

    private var sfSymbol: String {
        switch summary.record.sportCode {
        case "running": return "figure.run"
        case "cycling": return "figure.outdoor.cycle"
        case "swimming": return "figure.pool.swim"
        case "triathlon": return "figure.mixed.cardio"
        case "strengthTraining": return "dumbbell.fill"
        case "yoga": return "figure.yoga"
        case "hiit": return "bolt.heart.fill"
        case "hiking": return "figure.hiking"
        case "tennis": return "figure.tennis"
        case "football": return "soccerball"
        default: return "questionmark.circle"
        }
    }
}

// MARK: - Routine card

private struct RoutineCard: View {
    let routine: RoutineRecord

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "bolt.heart.fill")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color.coachingRecord)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(verbatim: routine.name)
                    .font(.coachingBody.weight(.semibold))
                    .foregroundStyle(Color.coachingTextPrimary)
                    .lineLimit(1)
                Text(verbatim: durationLabel)
                    .font(.coachingCaption)
                    .foregroundStyle(Color.coachingTextSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Image(systemName: "chevron.right")
                .font(.footnote)
                .foregroundStyle(Color.coachingTextSecondary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(
                    Color.coachingRecord.opacity(0.55),
                    style: StrokeStyle(lineWidth: 1, dash: [4, 3])
                )
        )
    }

    private var durationLabel: String {
        String(
            format: NSLocalizedString("dashboard.active.routine.duration", comment: "ex. 12 min"),
            routine.durationMinutes
        )
    }
}

// MARK: - Create program / routine entry

private struct CreateProgramOrRoutineCard: View {
    let onTapProgram: () -> Void
    let onTapRoutine: () -> Void

    var body: some View {
        Menu {
            Button {
                onTapProgram()
            } label: {
                Label("dashboard.active.create.program", systemImage: "plus.app")
            }
            Button {
                onTapRoutine()
            } label: {
                Label("dashboard.active.create.routine", systemImage: "bolt.heart")
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "plus")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Color.coachingPrimary)
                Text("dashboard.active.create.cta")
                    .font(.coachingBody)
                    .foregroundStyle(Color.coachingTextPrimary)
                Spacer(minLength: 0)
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
        .accessibilityIdentifier("dashboard.active.create.cta")
    }
}

// MARK: - Weekly reorder link

private struct WeeklyReorderLink: View {
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.footnote.weight(.semibold))
                Text("dashboard.active.weekly.reorder")
                    .font(.coachingCaption.weight(.semibold))
                Spacer(minLength: 0)
            }
            .foregroundStyle(Color.coachingRecord)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color.coachingRecord.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("dashboard.active.weekly.reorder")
    }
}

// MARK: - Color hex helper

private extension Color {
    init(hex: UInt32, opacity: Double = 1.0) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8) & 0xFF) / 255.0
        let b = Double(hex & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: opacity)
    }
}
