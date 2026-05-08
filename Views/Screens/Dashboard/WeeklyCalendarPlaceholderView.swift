// Views/Screens/Dashboard/WeeklyCalendarPlaceholderView.swift
// Story 3.8 sous-tâche 6 — placeholder léger pour l'icône 📅 nav bar Séances.
// Le drag&drop hebdo réel arrive en sous-tâche 9 (`WeeklyCalendarView`).
import SwiftUI

struct WeeklyCalendarPlaceholderView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar")
                .font(.system(size: 48, weight: .light))
                .foregroundStyle(Color.coachingPrimary.opacity(0.6))

            Text("dashboard.weekly.placeholder.title")
                .font(.coachingH2)
                .foregroundStyle(Color.coachingTextPrimary)
                .multilineTextAlignment(.center)

            Text("dashboard.weekly.placeholder.subtitle")
                .font(.coachingBody)
                .foregroundStyle(Color.coachingTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.coachingBackground.ignoresSafeArea())
        .navigationTitle(Text("dashboard.weekly.placeholder.navtitle"))
        .navigationBarTitleDisplayMode(.inline)
    }
}
