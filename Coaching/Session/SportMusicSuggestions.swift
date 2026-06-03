// Coaching/Session/SportMusicSuggestions.swift
// Story 3.35b — suggestions de musique par sport, EN LIENS (décision : l'app ne
// joue jamais la musique, T3 ; on suggère, le user lance la sienne). 2-3 ambiances
// par sport, chacune ouvre une RECHERCHE sur Apple Music / Spotify (jamais de lien
// mort, aucun ID de playlist fabriqué). La table est remplaçable plus tard par de
// vraies playlists curées (mettre une URL directe à la place du terme de recherche).
import Foundation

/// Type d'ambiance (mappé à un libellé i18n statique côté vue).
enum MusicAmbianceKind: String, Equatable {
    case energy
    case tempo
    case chill
    case focus
}

struct MusicAmbiance: Equatable {
    let kind: MusicAmbianceKind
    /// Terme de recherche (universel, fonctionne FR/EN sur les 2 plateformes).
    let searchTerm: String
}

enum SportMusicSuggestions {

    /// 2-3 ambiances par sport. `sportCode` = code effectif (triathlon déjà résolu
    /// en discipline côté HUB).
    static func ambiances(forSportCode sportCode: String) -> [MusicAmbiance] {
        switch sportCode {
        case "running":
            return [.init(kind: .energy, searchTerm: "running workout energy"),
                    .init(kind: .tempo,  searchTerm: "tempo run beats"),
                    .init(kind: .chill,  searchTerm: "easy run chill")]
        case "cycling":
            return [.init(kind: .energy, searchTerm: "cycling workout"),
                    .init(kind: .tempo,  searchTerm: "indoor cycling beats"),
                    .init(kind: .chill,  searchTerm: "endurance ride chill")]
        case "hiking":
            return [.init(kind: .chill, searchTerm: "hiking ambient nature"),
                    .init(kind: .focus, searchTerm: "trail walking instrumental")]
        case "hiit":
            return [.init(kind: .energy, searchTerm: "hiit workout high energy"),
                    .init(kind: .tempo,  searchTerm: "workout motivation beats")]
        case "strengthTraining":
            return [.init(kind: .energy, searchTerm: "gym workout hype"),
                    .init(kind: .focus,  searchTerm: "lifting focus")]
        case "yoga":
            return [.init(kind: .chill, searchTerm: "yoga flow calm"),
                    .init(kind: .focus, searchTerm: "meditation ambient")]
        case "swimming":
            return [.init(kind: .energy, searchTerm: "swim workout"),
                    .init(kind: .focus,  searchTerm: "pool laps focus")]
        case "tennis":
            return [.init(kind: .energy, searchTerm: "tennis warmup energy"),
                    .init(kind: .focus,  searchTerm: "match focus")]
        case "football":
            return [.init(kind: .energy, searchTerm: "football training hype"),
                    .init(kind: .tempo,  searchTerm: "matchday warmup")]
        default:
            return [.init(kind: .energy, searchTerm: "workout energy"),
                    .init(kind: .chill,  searchTerm: "workout chill")]
        }
    }
}
