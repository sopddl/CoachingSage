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
    /// `.none` (aucune suggestion).
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
}
