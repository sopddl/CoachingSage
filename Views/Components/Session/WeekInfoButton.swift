// Views/Components/Session/WeekInfoButton.swift
// Story 3.35j — bouton « i » qui ouvre (popover) le thème + l'objectif d'une
// semaine, en PUCES (retour Sophie : le petit texte gris sous chaque semaine doit
// passer dans un encart « i », sans bloc de texte).
import SwiftUI

struct WeekInfoButton: View {
    let theme: String
    let goal: String

    @State private var isShown = false

    var body: some View {
        Button {
            isShown = true
        } label: {
            Image(systemName: "info.circle")
                .font(.subheadline)
                .foregroundStyle(Color.coachingPrimary)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text("coaching.adapter.week.info"))
        .accessibilityIdentifier("coaching.adapter.week.info")
        .popover(isPresented: $isShown) {
            // Contenu SCROLLABLE + hauteur bornée : le texte d'objectif peut être
            // long et débordait du popover (texte coupé — bug Sophie 2026-06-03).
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("coaching.adapter.week.info")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                    if !theme.isEmpty { BulletedNotes(text: theme, font: .callout) }
                    if !goal.isEmpty { BulletedNotes(text: goal, font: .callout) }
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(width: 300, height: 360)
            .presentationCompactAdaptation(.popover)
        }
    }
}
