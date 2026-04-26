// Views/Screens/MainTabView.swift
// Story 1.2 — navigation principale 4 onglets (Aujourd'hui, Séance, Progrès, Profil).
// Story 1.3 — overlay banner sync.in_progress / sync.error via @Environment AppDependencies.
import SwiftUI

struct MainTabView: View {
    @Environment(\.appDependencies) private var deps

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

            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Label("tab.profile", systemImage: "person.crop.circle")
            }
            .accessibilityIdentifier("tab.profile")
        }
        .tint(Color.coachingPrimary)
        .overlay(alignment: .top) {
            // Sync feedback UI — pattern TailorSage ContentView L94-127.
            // Downcast nécessaire : `syncStatus` vit sur la classe concrète,
            // le protocole n'expose que `isConnected` pour la testabilité.
            if let syncService = deps?.syncService as? SyncService {
                if syncService.syncStatus == .syncing {
                    HStack(spacing: 6) {
                        ProgressView()
                            .controlSize(.mini)
                        Text(String(localized: "sync.in_progress"))
                            .font(.caption)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(.ultraThinMaterial, in: Capsule())
                    .accessibilityElement(children: .contain)
                    .accessibilityIdentifier("sync_in_progress_banner")
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .animation(.easeInOut, value: syncService.syncStatus)
                } else if syncService.syncStatus == .error {
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                            .font(.caption)
                        Text(String(localized: "sync.error"))
                            .font(.caption)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(.ultraThinMaterial, in: Capsule())
                    .accessibilityElement(children: .contain)
                    .accessibilityIdentifier("sync_error_banner")
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .animation(.easeInOut, value: syncService.syncStatus)
                }
            }
        }
    }
}

#Preview {
    MainTabView()
}
