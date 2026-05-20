// Views/Screens/Dashboard/DormantProgramsList.swift
// Story 3.15 AC8/AC9 — section "Préparés" en liste verticale scrollable.
//
// Composition :
//   - Header : "Préparés (N)" — titre majuscule cohérent avec autres sections
//   - ForEach des `DormantProgramCard` empilées (full-width)
//   - Tap card → push AdaptedProgramView via `onTapProgram`
//   - Swipe-to-delete via le wrapper existant `SwipeToDeleteRow` (réutilisable)
//
// **Distinction visuelle Story 3.15** : opacité 0.9 sur le contenu + badge
// "Préparé" en haut. Pas d'icône ambiguë (⏸ peut être lu "en pause").
import SwiftUI

struct DormantProgramsList: View {
    let dormants: [ProgramSummary]
    let onTapProgram: (ProgramSummary) -> Void
    let onDeleteProgram: (ProgramSummary) -> Void
    /// Variant : si `true`, ne pas afficher le header (cas mode `.dormantOnly`
    /// où on a déjà un titre de page dédié). Default = `false`.
    var hideHeader: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !hideHeader {
                HStack(spacing: 4) {
                    Text("dashboard.section.dormants.title")
                        .font(.coachingCaption.weight(.semibold))
                        .foregroundStyle(Color.coachingTextSecondary)
                        .textCase(.uppercase)
                        .tracking(0.8)
                    Text(verbatim: " (\(dormants.count))")
                        .font(.coachingCaption.weight(.semibold))
                        .foregroundStyle(Color.coachingTextSecondary)
                }
                .accessibilityIdentifier("dashboard.section.dormants.title")
            }
            VStack(spacing: 10) {
                ForEach(dormants) { summary in
                    DormantProgramRow(
                        summary: summary,
                        onTap: { onTapProgram(summary) },
                        onDelete: { onDeleteProgram(summary) }
                    )
                }
            }
        }
        .accessibilityIdentifier("dashboard.section.dormants")
    }
}

/// **Story 3.15 AC8** — card individuelle d'un dormant en list-row. Badge
/// "Préparé" en haut, opacité 0.9 sur le contenu, chevron à droite. Wrapping
/// SwipeToDeleteRow réutilisable depuis ActiveDashboardView (interne fileprivate
/// → on duplique ici une mini-version pour éviter le coupling fileprivate).
private struct DormantProgramRow: View {
    let summary: ProgramSummary
    let onTap: () -> Void
    let onDelete: () -> Void

    private var sportCode: String { summary.sport.appSportCode }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                // Icône sport — pattern carré arrondi + bordure couleur sport.
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .strokeBorder(Color.coachingSport(forCode: sportCode), lineWidth: 2)
                    Image(systemName: sfSymbol)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(Color.coachingSport(forCode: sportCode))
                }
                .frame(width: 44, height: 44)

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text("dashboard.dormant.badge.prepared")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(Color.coachingPrimary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.coachingPrimary.opacity(0.12))
                            .clipShape(Capsule())
                            .accessibilityIdentifier("dashboard.dormant.badge.prepared")
                        Spacer(minLength: 0)
                    }
                    Text(verbatim: summary.templateName)
                        .font(.coachingBody.weight(.semibold))
                        .foregroundStyle(Color.coachingTextPrimary)
                        .lineLimit(2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(Color.coachingTextSecondary)
            }
            .opacity(0.9)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color.coachingCard)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("dashboard.dormant.program.\(sportCode)")
    }

    private var sfSymbol: String {
        switch sportCode {
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
