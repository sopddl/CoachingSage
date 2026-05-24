// Views/Components/NextSessionInlineCard.swift
// **Story 3.22-G (Sophie 2026-05-24)** — Card "Prochaine séance" affichée en
// haut de `AdaptedProgramView` quand le programme est actif et qu'il reste
// au moins une séance pending. Évite l'effet "le bouton Démarrer disparaît,
// je ne sais pas où aller" remonté par Sophie au test simu : guide l'user
// d'un tap vers `SessionDetailView` de la 1ère séance pending.
//
// Sourcing de la 1ère pending : `NextSessionResolver.nextSession(for:now:)`
// (déjà testé Stories 3.11 / 3.15). Le caller passe la `PersistedSession`
// + l'`AdaptedProgramRecord` retournés ; cette vue résout `AdaptedSession` +
// `AdaptedWeek` via le `program: AdaptedProgram` pour push `SessionDetailView`
// avec la même signature que `sessionRow`.
import SwiftUI

struct NextSessionInlineCard: View {
    let session: PersistedSession
    let program: AdaptedProgram
    let record: AdaptedProgramRecord
    let modifiedSessionCoordinates: Set<SessionCoordinate>

    var body: some View {
        if let resolved = resolveAdaptedSession() {
            NavigationLink {
                SessionDetailView(
                    session: resolved.session,
                    week: resolved.week,
                    program: program,
                    isModifiedByRegen: isModifiedByRegen,
                    recordId: record.id
                )
            } label: {
                content(resolved: resolved)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("coaching.adapter.nextSession.card")
            .accessibilityHint(Text("coaching.adapter.nextSession.a11yHint"))
        }
    }

    private struct ResolvedSession {
        let week: AdaptedWeek
        let session: AdaptedSession
    }

    private func resolveAdaptedSession() -> ResolvedSession? {
        guard let week = program.weeks.first(where: { $0.weekNumber == session.weekNumber }),
              let adapted = week.sessions.first(where: { $0.day == session.day }) else {
            return nil
        }
        return ResolvedSession(week: week, session: adapted)
    }

    private var isModifiedByRegen: Bool {
        modifiedSessionCoordinates.contains(
            SessionCoordinate(weekNumber: session.weekNumber, day: session.day)
        )
    }

    private func content(resolved: ResolvedSession) -> some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: "play.circle.fill")
                .font(.title2)
                .foregroundStyle(Color.coachingPrimary)
            VStack(alignment: .leading, spacing: 2) {
                Text("coaching.adapter.nextSession.title")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.coachingTextSecondary)
                    .textCase(.uppercase)
                    .tracking(0.6)
                Text(verbatim: resolved.session.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.coachingTextPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                Text(
                    "coaching.adapter.session.shortLine \(resolved.week.weekNumber) \(resolved.session.day) \(resolved.session.durationMinutes)"
                )
                .font(.caption)
                .foregroundStyle(Color.coachingTextSecondary)
            }
            Spacer(minLength: 8)
            Image(systemName: "chevron.right")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.coachingTextSecondary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color.coachingPrimary.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.coachingPrimary.opacity(0.25), lineWidth: 1)
        )
    }
}
