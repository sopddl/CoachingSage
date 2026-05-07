// Views/Screens/MainTabView.swift
// Story 1.2 — navigation principale.
// Story 1.3 — overlay banner sync.in_progress / sync.error via @Environment AppDependencies.
// Story 3.8 (Commit 2) — tab bar 3 onglets (Séances · Progrès · Profil) + FAB Léon
//   en overlay à cheval sur la tab bar (transposition `FloreFloatingButton` GardenSage,
//   adaptée Color.coachingPrimary #1E5090 / 54×54 / offset y -32).
import SwiftUI

struct MainTabView: View {
    @Environment(\.appDependencies) private var deps
    @State private var isLeonChatPresented = false

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView {
                SessionView()
                    .tabItem {
                        Label("tab.session", systemImage: "figure.run")
                    }
                    .accessibilityIdentifier("tab.session")

                ProgressionView()
                    .tabItem {
                        Label("tab.progress", systemImage: "chart.bar.fill")
                    }
                    .accessibilityIdentifier("tab.progress")

                NavigationStack {
                    ProfileView()
                }
                .tabItem {
                    Label("tab.profile", systemImage: "person.fill")
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

            // FAB Léon — à cheval sur la tab bar système (offset négatif).
            // Visible sur les 3 onglets, ouvre une bottom sheet placeholder
            // tant que Story 3.6 (chat IA) n'est pas livrée.
            LeonFloatingButton(isPresented: $isLeonChatPresented)
                .offset(y: -32)
        }
        .sheet(isPresented: $isLeonChatPresented) {
            LeonChatPlaceholderSheet()
        }
    }
}

#Preview {
    MainTabView()
}
