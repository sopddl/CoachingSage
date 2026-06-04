// Coaching/Session/MusicStreamingApp.swift
// Story 3.35c — application de streaming musical préférée de l'utilisateur (choix
// UNIQUE), demandée à l'onboarding et modifiable dans le profil. Les suggestions
// musique de la séance n'ouvrent QUE cette app (pas une liste de plateformes).
//
// Préférence stockée côté device via @AppStorage (clé `storageKey`) — analogue à
// la préférence de langue UI (LanguageManager/UserDefaults), pas de champ profil
// cloud, donc zéro migration SwiftData/Supabase.
import Foundation

enum MusicStreamingApp: String, CaseIterable, Identifiable, Codable, Sendable {
    case appleMusic
    case spotify
    case deezer
    case youtubeMusic
    case none   // « Je gère moi-même » → pas de suggestions affichées

    var id: String { rawValue }

    /// Clé @AppStorage / UserDefaults partagée onboarding ↔ profil ↔ séance.
    static let storageKey = "coaching.music.app"

    /// Défaut avant tout choix : Apple Music (préinstallé sur iOS).
    static let defaultApp: MusicStreamingApp = .appleMusic

    /// Nom de marque (verbatim, non traduit). Nil pour `.none` (libellé i18n côté vue).
    var brandName: String? {
        switch self {
        case .appleMusic:   return "Apple Music"
        case .spotify:      return "Spotify"
        case .deezer:       return "Deezer"
        case .youtubeMusic: return "YouTube Music"
        case .none:         return nil
        }
    }

    var isProvider: Bool { self != .none }
}

enum MusicLinkBuilder {
    /// URL de recherche ouvrant l'app native choisie sur le terme donné. Nil pour
    /// `.none` (aucune suggestion). C'est le lien web/universal-link : sur iOS,
    /// Apple Music / Spotify / YouTube Music l'interceptent et ouvrent leur app.
    static func url(app: MusicStreamingApp, searchTerm: String) -> URL? {
        guard app.isProvider else { return nil }
        let query = searchTerm.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? searchTerm
        let path = searchTerm.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? searchTerm
        switch app {
        case .appleMusic:   return URL(string: "https://music.apple.com/search?term=\(query)")
        case .spotify:      return URL(string: "https://open.spotify.com/search/\(path)")
        case .deezer:       return URL(string: "https://www.deezer.com/search/\(path)")
        case .youtubeMusic: return URL(string: "https://music.youtube.com/search?q=\(query)")
        case .none:         return nil
        }
    }

    /// Scheme natif de l'app (`deezer://…`) à TENTER avant le lien web. Bug #10 :
    /// le universal-link `https://www.deezer.com/…` n'est pas intercepté par l'app
    /// Deezer → ça ouvrait Safari. Le scheme custom ouvre directement l'app. Si
    /// l'app n'est pas installée, `openURL` échoue → le caller retombe sur `url(…)`.
    ///
    /// Nil quand le universal-link suffit déjà (Apple Music / Spotify / YouTube
    /// Music ouvrent leur app de façon fiable) ou pour `.none`.
    static func nativeURL(app: MusicStreamingApp, searchTerm: String) -> URL? {
        let path = searchTerm.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? searchTerm
        switch app {
        case .deezer: return URL(string: "deezer://www.deezer.com/search/\(path)")
        default:      return nil
        }
    }
}
