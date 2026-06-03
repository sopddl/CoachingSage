// CoachingSageTests/Coaching/Session/SportMusicSuggestionsTests.swift
// Story 3.35b — suggestions musique : chaque sport renvoie 2-5 ambiances non
// vides + construction des liens Apple Music / Spotify (encodage).
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

    func test_appleMusicLink_isSearchURL() {
        let url = MusicLinkBuilder.url(platform: .appleMusic, searchTerm: "running workout energy")
        XCTAssertEqual(url?.absoluteString, "https://music.apple.com/search?term=running%20workout%20energy")
    }

    func test_spotifyLink_isSearchURL() {
        let url = MusicLinkBuilder.url(platform: .spotify, searchTerm: "yoga flow calm")
        XCTAssertEqual(url?.absoluteString, "https://open.spotify.com/search/yoga%20flow%20calm")
    }

    func test_links_neverNilForAllAmbiances() {
        for code in ["running", "yoga", "hiit", "kitesurf"] {
            for amb in SportMusicSuggestions.ambiances(forSportCode: code) {
                for platform in MusicPlatform.allCases {
                    XCTAssertNotNil(MusicLinkBuilder.url(platform: platform, searchTerm: amb.searchTerm),
                                    "lien nil pour \(code)/\(amb.kind)/\(platform)")
                }
            }
        }
    }
}
