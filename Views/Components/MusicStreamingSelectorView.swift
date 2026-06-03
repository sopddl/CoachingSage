// Views/Components/MusicStreamingSelectorView.swift
// Story 3.35c — sélecteur (Menu déroulant) de l'application musique préférée.
// Choix UNIQUE, persistant @AppStorage (clé partagée). Réutilisé à l'onboarding
// ET dans le profil. Pattern aligné sur LanguageSelectorView.
import SwiftUI

struct MusicStreamingSelectorView: View {
    @AppStorage(MusicStreamingApp.storageKey) private var appRaw = MusicStreamingApp.defaultApp.rawValue

    private var selected: MusicStreamingApp {
        MusicStreamingApp(rawValue: appRaw) ?? .defaultApp
    }

    var body: some View {
        Menu {
            ForEach(MusicStreamingApp.allCases) { app in
                Button {
                    appRaw = app.rawValue
                } label: {
                    HStack {
                        label(for: app)
                        if selected == app {
                            Image(systemName: "checkmark")
                        }
                    }
                }
                .accessibilityIdentifier("musicSelector.\(app.rawValue)")
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "music.note")
                label(for: selected).font(.coachingBody.bold())
            }
            .foregroundColor(.coachingTextPrimary)
            .frame(minHeight: 44)
            .padding(.horizontal, 8)
        }
        .menuStyle(.borderlessButton)
        .accessibilityLabel("coaching.music.app.label")
        .accessibilityIdentifier("onboarding.musicSelector")
    }

    @ViewBuilder
    private func label(for app: MusicStreamingApp) -> some View {
        if let brand = app.brandName {
            Text(verbatim: brand)
        } else {
            Text("coaching.music.app.none")
        }
    }
}

#if DEBUG
#Preview("Music selector") {
    MusicStreamingSelectorView()
        .padding()
        .background(Color.coachingBackground)
}
#endif
