// Views/Components/Session/SessionMusicSuggestions.swift
// Story 3.35b — section « 🎧 Mets ta musique » du HUB : suggestions d'ambiances
// par sport, chacune ouvrant une recherche Apple Music / Spotify. L'app ne joue
// rien (T3) — elle aide juste à lancer SA musique avant de démarrer la séance.
// Repliée par défaut (discrète).
import SwiftUI

struct SessionMusicSuggestions: View {
    let sportCode: String

    @Environment(\.openURL) private var openURL
    @State private var isExpanded = false

    private var ambiances: [MusicAmbiance] { SportMusicSuggestions.ambiances(forSportCode: sportCode) }

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            VStack(spacing: 8) {
                ForEach(ambiances, id: \.kind) { ambiance in
                    ambianceRow(ambiance)
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

    private func ambianceRow(_ ambiance: MusicAmbiance) -> some View {
        HStack(spacing: 10) {
            Text(ambianceLabel(ambiance.kind))
                .font(.subheadline)
                .foregroundStyle(.primary)
            Spacer(minLength: 8)
            platformButton(.appleMusic, term: ambiance.searchTerm)
            platformButton(.spotify, term: ambiance.searchTerm)
        }
    }

    private func platformButton(_ platform: MusicPlatform, term: String) -> some View {
        Button {
            if let url = MusicLinkBuilder.url(platform: platform, searchTerm: term) {
                openURL(url)
            }
        } label: {
            Text(verbatim: platform == .appleMusic ? "Apple Music" : "Spotify")
                .font(.caption.bold())
                .padding(.horizontal, 10).padding(.vertical, 6)
                .background(Color.coachingPrimary.opacity(0.12))
                .foregroundStyle(Color.coachingPrimary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(platform == .appleMusic ? "Apple Music" : "Spotify"))
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
