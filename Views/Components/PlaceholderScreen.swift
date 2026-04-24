// Views/Components/PlaceholderScreen.swift
// Story 1.2 — écran "contenu à venir" partagé par les placeholders d'onglets.
// Remplacé par le vrai contenu au fil des epics (TodayView → Epic 3, ProgressionView → Epic 4, etc.).
import SwiftUI

struct PlaceholderScreen: View {
    let systemImage: String
    let titleKey: LocalizedStringKey
    let subtitleKey: LocalizedStringKey

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: systemImage)
                .font(.system(size: 64))
                .foregroundStyle(Color.coachingPrimary)

            Text(titleKey)
                .font(.coachingDisplay)
                .foregroundStyle(Color.coachingTextPrimary)

            Text(subtitleKey)
                .font(.coachingBody)
                .foregroundStyle(Color.coachingTextSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.coachingBackground)
    }
}
