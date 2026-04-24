// Views/Screens/MainTabView.swift
// Story 1.2 — navigation principale 4 onglets (Aujourd'hui, Séance, Progrès, Profil).
// Icônes tabbar : SF Symbols, cohérent avec direction-finale des mockups UX.
import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            TodayView()
                .tabItem {
                    Label("tab.today", systemImage: "sun.max")
                }
                .accessibilityIdentifier("tab.today")

            SessionView()
                .tabItem {
                    Label("tab.session", systemImage: "figure.gymnastics")
                }
                .accessibilityIdentifier("tab.session")

            ProgressionView()
                .tabItem {
                    Label("tab.progress", systemImage: "chart.line.uptrend.xyaxis")
                }
                .accessibilityIdentifier("tab.progress")

            ProfileView()
                .tabItem {
                    Label("tab.profile", systemImage: "person.crop.circle")
                }
                .accessibilityIdentifier("tab.profile")
        }
        .tint(Color.coachingPrimary)
    }
}

#Preview {
    MainTabView()
}
