// CoachingSageTests/Coaching/Session/SportMusicSuggestionsTests.swift
// Story 3.35b/c — suggestions musique : 2-5 ambiances/sport + liens vers l'app
// CHOISIE (Apple Music / Spotify / Deezer / YouTube Music ; nil si « Aucune »).
import XCTest
@testable import CoachingSage

final class SportMusicSuggestionsTests: XCTestCase {

    func test_eachSport_returnsBetween2And5NonEmptyAmbiances() {
        let sports = ["running", "cycling", "hiking", "hiit", "strengthTraining",
                      "yoga", "swimming", "tennis", "football"]
        for code in sports {
            let a = SportMusicSuggestions.ambiances(forSportCode: code)
            XCTAssertTrue((2...5).contains(a.count), "\(code) doit avoir 2-5 ambiances, a \(a.count)")
            for amb in a {
                XCTAssertFalse(amb.searchTerm.trimmingCharacters(in: .whitespaces).isEmpty,
                               "terme vide pour \(code)/\(amb.kind)")
            }
        }
    }

    func test_unknownSport_fallsBackToGenericAmbiances() {
        let a = SportMusicSuggestions.ambiances(forSportCode: "kitesurf")
        XCTAssertTrue((2...5).contains(a.count))
        XCTAssertFalse(a.isEmpty)
    }

    // MARK: - Liens par application choisie

    func test_appleMusicLink_isSearchURL() {
        let url = MusicLinkBuilder.url(app: .appleMusic, searchTerm: "running workout energy")
        XCTAssertEqual(url?.absoluteString, "https://music.apple.com/search?term=running%20workout%20energy")
    }

    func test_spotifyLink_isSearchURL() {
        let url = MusicLinkBuilder.url(app: .spotify, searchTerm: "yoga flow calm")
        XCTAssertEqual(url?.absoluteString, "https://open.spotify.com/search/yoga%20flow%20calm")
    }

    func test_deezerLink_isSearchURL() {
        let url = MusicLinkBuilder.url(app: .deezer, searchTerm: "gym workout hype")
        XCTAssertEqual(url?.absoluteString, "https://www.deezer.com/search/gym%20workout%20hype")
    }

    func test_youtubeMusicLink_isSearchURL() {
        let url = MusicLinkBuilder.url(app: .youtubeMusic, searchTerm: "hiit workout high energy")
        XCTAssertEqual(url?.absoluteString, "https://music.youtube.com/search?q=hiit%20workout%20high%20energy")
    }

    func test_noneApp_returnsNilLink() {
        XCTAssertNil(MusicLinkBuilder.url(app: .none, searchTerm: "anything"))
    }

    // MARK: - Bug #10 — scheme natif (Deezer ouvrait Safari au lieu de l'app)

    func test_deezerNativeURL_usesCustomScheme() {
        let url = MusicLinkBuilder.nativeURL(app: .deezer, searchTerm: "gym workout hype")
        XCTAssertEqual(url?.absoluteString, "deezer://www.deezer.com/search/gym%20workout%20hype")
    }

    func test_nativeURL_nilForAppsWhereUniversalLinkSuffices() {
        // Apple Music / Spotify / YouTube Music ouvrent déjà leur app via le lien web.
        XCTAssertNil(MusicLinkBuilder.nativeURL(app: .appleMusic, searchTerm: "x"))
        XCTAssertNil(MusicLinkBuilder.nativeURL(app: .spotify, searchTerm: "x"))
        XCTAssertNil(MusicLinkBuilder.nativeURL(app: .youtubeMusic, searchTerm: "x"))
        XCTAssertNil(MusicLinkBuilder.nativeURL(app: .none, searchTerm: "x"))
    }

    func test_deezer_webURL_remainsFallback() {
        // Le lien web reste disponible comme repli si l'app Deezer n'est pas installée.
        XCTAssertEqual(MusicLinkBuilder.url(app: .deezer, searchTerm: "gym workout hype")?.absoluteString,
                       "https://www.deezer.com/search/gym%20workout%20hype")
    }

    func test_links_neverNilForProviderApps() {
        let providers: [MusicStreamingApp] = [.appleMusic, .spotify, .deezer, .youtubeMusic]
        for code in ["running", "yoga", "hiit", "kitesurf"] {
            for amb in SportMusicSuggestions.ambiances(forSportCode: code) {
                for app in providers {
                    XCTAssertNotNil(MusicLinkBuilder.url(app: app, searchTerm: amb.searchTerm),
                                    "lien nil pour \(code)/\(amb.kind)/\(app.rawValue)")
                }
            }
        }
    }

    // MARK: - MusicStreamingApp

    func test_musicApp_brandNames() {
        XCTAssertEqual(MusicStreamingApp.appleMusic.brandName, "Apple Music")
        XCTAssertEqual(MusicStreamingApp.spotify.brandName, "Spotify")
        XCTAssertEqual(MusicStreamingApp.deezer.brandName, "Deezer")
        XCTAssertEqual(MusicStreamingApp.youtubeMusic.brandName, "YouTube Music")
        XCTAssertNil(MusicStreamingApp.none.brandName)
    }

    func test_musicApp_isProvider() {
        XCTAssertTrue(MusicStreamingApp.deezer.isProvider)
        XCTAssertFalse(MusicStreamingApp.none.isProvider)
    }

    func test_musicApp_allCasesIncludeDeezer() {
        XCTAssertTrue(MusicStreamingApp.allCases.contains(.deezer))
        XCTAssertEqual(MusicStreamingApp.defaultApp, .appleMusic)
    }
}
