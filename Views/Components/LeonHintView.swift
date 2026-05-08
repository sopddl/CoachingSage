// Views/Components/LeonHintView.swift
// Story 3.8 — hint italique Léon, fond bleu coach atténué + border-left 3px.
// Réutilisable pour mode vide (3.8 sous-tâche 6) + mode rest day (3.8 sous-tâche 8)
// + tout futur message contextuel sans bulle de chat (anti-pattern UI bloated).
//
// Source design : maquette `ux-design-CoachingSage-seances-dashboard-2026-05-07.html`,
// rgba(30,80,144,0.08) + border-left 3px #1E5090.
import SwiftUI

struct LeonHintView: View {
    let text: LocalizedStringKey

    init(_ text: LocalizedStringKey) {
        self.text = text
    }

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            Rectangle()
                .fill(Color.coachingPrimary)
                .frame(width: 3)

            Text(text)
                .font(.coachingLeon)
                .foregroundStyle(Color.coachingTextPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
        }
        .background(Color.coachingPrimary.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    VStack(spacing: 16) {
        LeonHintView("dashboard.empty.hint.default")
        LeonHintView("dashboard.empty.hint.health")
    }
    .padding()
    .background(Color.coachingBackground)
}
