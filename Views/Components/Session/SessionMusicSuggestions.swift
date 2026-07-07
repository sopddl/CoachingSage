// Views/Components/Session/SessionMusicSuggestions.swift
// Story 3.35b/c — section « 🎧 Mets ta musique » du HUB : suggestions d'ambiances
// par sport, ouvrant une recherche dans l'application musique CHOISIE par
// l'utilisateur (onboarding/profil). L'app ne joue rien (T3) — elle aide juste à
// lancer SA musique. Masquée si l'utilisateur a choisi « Aucune ».
import SwiftUI

struct SessionMusicSuggestions: View {
    let sportCode: String

    @AppStorage(MusicStreamingApp.storageKey) private var appRaw = MusicStreamingApp.defaultApp.rawValue
    @Environment(\.openURL) private var openURL
    @State private var isExpanded = false

    private var app: MusicStreamingApp { MusicStreamingApp(rawValue: appRaw) ?? .defaultApp }
    private var ambiances: [MusicAmbiance] { SportMusicSuggestions.ambiances(forSportCode: sportCode) }

    var body: some View {
        if app.isProvider, let brand = app.brandName {
            DisclosureGroup(isExpanded: $isExpanded) {
                VStack(spacing: 8) {
                    ForEach(ambiances, id: \.kind) { ambiance in
                        ambianceRow(ambiance, brand: brand)
                    }
                }
                .padding(.top, 8)
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "headphones").foregroundStyle(Color.coachingPrimary)
                    Text("coaching.session.music.title")
                        .font(.callout.bold())
                        .foregroundStyle(.primary)
                }
                .accessibilityElement(children: .combine)
            }
            .padding(12)
            .background(Color(uiColor: .secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .accessibilityIdentifier("coaching.session.music")
        }
    }

    private func ambianceRow(_ ambiance: MusicAmbiance, brand: String) -> some View {
        Button {
            openAmbiance(ambiance.searchTerm)
        } label: {
            HStack(spacing: 10) {
                Text(ambianceLabel(ambiance.kind))
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                Spacer(minLength: 8)
                HStack(spacing: 4) {
                    Image(systemName: "play.circle.fill")
                    Text(verbatim: brand)
                }
                .font(.caption.bold())
                .padding(.horizontal, 10).padding(.vertical, 6)
                .background(Color.coachingPrimary.opacity(0.12))
                .foregroundStyle(Color.coachingPrimary)
                .clipShape(Capsule())
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("coaching.session.music.row.\(ambiance.kind.rawValue)")
    }

    /// Bug #10 — tente d'abord le scheme natif (Deezer), retombe sur le lien web
    /// si l'app n'est pas installée (`accepted == false`).
    private func openAmbiance(_ searchTerm: String) {
        let webURL = MusicLinkBuilder.url(app: app, searchTerm: searchTerm)
        if let native = MusicLinkBuilder.nativeURL(app: app, searchTerm: searchTerm) {
            openURL(native) { accepted in
                if !accepted, let webURL { openURL(webURL) }
            }
        } else if let webURL {
            openURL(webURL)
        }
    }

    private func ambianceLabel(_ kind: MusicAmbianceKind) -> LocalizedStringKey {
        switch kind {
        case .energy: return "coaching.session.music.energy"
        case .tempo:  return "coaching.session.music.tempo"
        case .chill:  return "coaching.session.music.chill"
        case .focus:  return "coaching.session.music.focus"
        }
    }
}

#if DEBUG
#Preview("Music — running") {
    SessionMusicSuggestions(sportCode: "running").padding()
}
#endif
