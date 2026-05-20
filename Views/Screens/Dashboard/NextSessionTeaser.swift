// Views/Screens/Dashboard/NextSessionTeaser.swift
// Story 3.15 AC7 — teaser séance N+1 affiché toujours visible sous la séance
// focale (NextSessionCard). Hauteur réduite ~70pt, contenu : préfixe "Puis :"
// + nom séance + chevron.
//
// Cas de rendu :
//   - `teaserSession` non nil → ligne pleine cliquable
//   - `teaserSession` nil ET `hasFocal == true` → label discret "Dernière
//     séance de la semaine" (variante deadline qui bloque sur la semaine
//     courante, ou pénultième session globale)
//   - `hasFocal == false` → rien affiché (mais le caller n'a pas affiché la
//     focale non plus dans ce cas)
//
// Style : fond pâle (coachingCard) + bordure subtle + chevron, distingué
// visuellement de la card focale (qui est plus contrastée coach blue).
import SwiftUI

struct NextSessionTeaser: View {
    /// Session N+1 résolue par `NextSessionResolver.nextTwoSessions(for:now:).teaser?.session`.
    /// `nil` = pas de N+1 disponible.
    let teaserSession: PersistedSession?
    /// `true` quand la séance focale est affichée — sert à savoir si on doit
    /// montrer le label "Dernière séance de la semaine" en fallback.
    let hasFocal: Bool
    /// Tap sur le teaser → push `AdaptedProgramView` ciblé sur cette session
    /// (à raffiner Phase 4 si besoin de scrolling automatique).
    let onTapTeaser: (PersistedSession) -> Void

    var body: some View {
        if let teaserSession {
            teaserRow(session: teaserSession)
        } else if hasFocal {
            lastOfWeekRow
        }
    }

    private func teaserRow(session: PersistedSession) -> some View {
        Button {
            onTapTeaser(session)
        } label: {
            HStack(spacing: 10) {
                Text("dashboard.next_session.teaser.prefix")
                    .font(.coachingCaption.weight(.semibold))
                    .foregroundStyle(Color.coachingTextSecondary)
                    .textCase(.uppercase)
                    .tracking(0.8)
                Text(verbatim: session.name)
                    .font(.coachingBody)
                    .foregroundStyle(Color.coachingTextPrimary)
                    .lineLimit(1)
                Spacer(minLength: 6)
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(Color.coachingTextSecondary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color.coachingCard)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("dashboard.next_session.teaser")
    }

    private var lastOfWeekRow: some View {
        HStack(spacing: 8) {
            Image(systemName: "flag.checkered")
                .font(.footnote.weight(.medium))
                .foregroundStyle(Color.coachingTextSecondary)
            Text("dashboard.next_session.teaser.last_of_week")
                .font(.coachingCaption)
                .foregroundStyle(Color.coachingTextSecondary)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color.coachingCard.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .accessibilityIdentifier("dashboard.next_session.teaser.lastOfWeek")
    }
}
