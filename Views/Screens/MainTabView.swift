// Views/Screens/MainTabView.swift
// Story 1.2 — navigation principale.
// Story 1.3 — overlay banner sync.in_progress / sync.error via @Environment AppDependencies.
// Story 3.8 (Commit 2) — tab bar 3 onglets (Séances · Progrès · Profil) + FAB Léon.
// Story 3.8 (UI fix 2026-05-09) — passage de TabView système à custom HStack tab bar
//   (pattern GardenSage `ContentView.swift:79-100`) :
//     · 3 onglets décalés à gauche (~75%)
//     · FAB Léon à droite (~25%) à cheval (offset y -22)
//     · shadow `coachingEarth.opacity(0.08)` haut, fond `systemBackground`
//   Permet d'aligner la tab bar visuellement avec GS / TS et de placer le FAB
//   à droite plutôt que centré (retour Sophie 2026-05-09).
import SwiftUI

struct MainTabView: View {
    @Environment(\.appDependencies) private var deps
    @State private var isLeonChatPresented = false
    @State private var selectedTab: AppTab = .session
    /// **Hotfix Story 3.27 2026-05-31** — signal broadcast vers `SessionView`
    /// quand l'user tape sur l'onglet « Séances » alors qu'il est déjà sur
    /// cette tab (= il est probablement push sur `AdaptedProgramView`). La
    /// custom tab bar n'a pas le comportement natif iOS « tap on current tab
    /// = pop to root ». Le signal incrémente un compteur, `SessionView`
    /// observe et reset `adaptedRoute = nil`. Bug Sophie 2026-05-31 :
    /// « je ne peux plus retourner à l'accueil via le menu, juste la flèche ».
    @State private var sessionPopSignal: Int = 0

    enum AppTab: Int, Hashable {
        case session = 0
        case progress = 1
        case profile = 2
    }

    /// Hauteur réservée pour la custom tab bar dans le safe area inset.
    /// Garantit que le bas du content scrollable (ex: ProfileView Section "Supprimer
    /// mon compte") est atteignable, masqué sinon par la tab bar overlay. Sophie
    /// bug 2026-05-10 : bouton supprimer compte invisible.
    private static let tabBarReservedHeight: CGFloat = 64

    var body: some View {
        ZStack(alignment: .bottom) {
            tabContent
                .background(Color.coachingBackground.ignoresSafeArea())
                .overlay(alignment: .top) { syncBanner }
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    Color.clear.frame(height: Self.tabBarReservedHeight)
                }
            customTabBar
        }
        .sheet(isPresented: $isLeonChatPresented) {
            LeonChatPlaceholderSheet()
        }
    }

    // MARK: - Content (manuel, plus de TabView système)

    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .session:
            SessionView()
                .environment(\.sessionPopSignal, sessionPopSignal)
        case .progress:
            ProgressionView()
        case .profile:
            NavigationStack { ProfileView() }
        }
    }

    // MARK: - Custom tab bar (3 onglets gauche + FAB droite)

    private var customTabBar: some View {
        HStack(spacing: 0) {
            tabBarButton(
                titleKey: "tab.session",
                identifier: "tab.session",
                icon: "figure.run",
                tab: .session
            )
            tabBarButton(
                titleKey: "tab.progress",
                identifier: "tab.progress",
                icon: "chart.bar.fill",
                tab: .progress
            )
            tabBarButton(
                titleKey: "tab.profile",
                identifier: "tab.profile",
                icon: "person.fill",
                tab: .profile
            )

            // FAB Léon — cellule ~25% à droite, à cheval sur la tab bar.
            LeonFloatingButton(isPresented: $isLeonChatPresented)
                .offset(y: -22)
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 8)
        .padding(.top, 8)
        .padding(.bottom, 2)
        .background(
            Color(.systemBackground)
                .shadow(color: Color.coachingEarth.opacity(0.08), radius: 8, x: 0, y: -2)
                .ignoresSafeArea(edges: .bottom)
        )
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("main.tabbar")
    }

    private func tabBarButton(
        titleKey: LocalizedStringKey,
        identifier: String,
        icon: String,
        tab: AppTab
    ) -> some View {
        Button {
            // **Hotfix Story 3.27 2026-05-31** — pattern « tap on current tab
            // = pop to root » manquant sur la custom tab bar. Broadcast un
            // signal vers `SessionView` qui reset son `adaptedRoute = nil`.
            if selectedTab == tab && tab == .session {
                sessionPopSignal &+= 1
            } else {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                Text(titleKey)
                    .font(.caption2)
            }
            .frame(maxWidth: .infinity)
            .foregroundStyle(
                selectedTab == tab
                    ? Color.coachingPrimary
                    : Color.coachingTextSecondary
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(identifier)
    }

    // MARK: - Sync banner (overlay top)

    @ViewBuilder
    private var syncBanner: some View {
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

#Preview {
    MainTabView()
}

// MARK: - Pop session nav signal (Hotfix Story 3.27 2026-05-31)

private struct SessionPopSignalKey: EnvironmentKey {
    static let defaultValue: Int = 0
}

extension EnvironmentValues {
    /// Compteur incrémenté quand l'user tape sur l'onglet « Séances » alors
    /// qu'il est déjà sur cette tab. `SessionView` observe et pop sa nav stack
    /// (reset `adaptedRoute = nil`). Pattern « tap on current tab = pop to
    /// root » que la `TabView` native iOS implémente, mais que notre custom
    /// tab bar (Story 3.8 UI fix 2026-05-09) ne fait pas par défaut.
    var sessionPopSignal: Int {
        get { self[SessionPopSignalKey.self] }
        set { self[SessionPopSignalKey.self] = newValue }
    }
}
