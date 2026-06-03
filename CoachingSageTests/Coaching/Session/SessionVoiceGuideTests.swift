// CoachingSageTests/Coaching/Session/SessionVoiceGuideTests.swift
// Story 3.35 (AC9) — couche voix : séquence d'annonces, toggle OFF = aucune voix,
// sélection H/F, mapping langue→voix, override de prononciation appliqué.
// (Synthèse mockée via `SpeechSpeaking`.)
import XCTest
@testable import CoachingSage

@MainActor
final class SessionVoiceGuideTests: XCTestCase {

    // MARK: - Mock

    final class FakeSpeaker: SpeechSpeaking {
        var utterances: [(text: String, voiceId: String?)] = []
        var stopped = false
        func speak(_ text: String, voiceIdentifier: String?) {
            utterances.append((text, voiceIdentifier))
        }
        func stopSpeaking() { stopped = true }
    }

    private func makeGuide(enabled: Bool = true,
                           gender: SessionVoiceGender = .female,
                           language: String = "fr",
                           speaker: FakeSpeaker) -> SessionVoiceGuide {
        SessionVoiceGuide(
            enabled: enabled, gender: gender, language: language, speaker: speaker,
            voiceProvider: { g, l in "\(l)-\(g.rawValue)" }
        )
    }

    // MARK: - Annonce / toggle

    func test_announce_whenEnabled_speaks() {
        let s = FakeSpeaker()
        makeGuide(speaker: s).announce("Prochain : Burpees")
        XCTAssertEqual(s.utterances.count, 1)
        XCTAssertEqual(s.utterances.first?.text, "Prochain : Burpees")
    }

    func test_announce_whenDisabled_silent() {
        let s = FakeSpeaker()
        makeGuide(enabled: false, speaker: s).announce("Prochain : Burpees")
        XCTAssertTrue(s.utterances.isEmpty)
    }

    func test_announce_emptyPhrase_silent() {
        let s = FakeSpeaker()
        makeGuide(speaker: s).announce("   ")
        XCTAssertTrue(s.utterances.isEmpty)
    }

    func test_sequence_multipleAnnounces() {
        let s = FakeSpeaker()
        let g = makeGuide(speaker: s)
        g.announce("Prochain : A")
        g.announce("C'est parti")
        XCTAssertEqual(s.utterances.map(\.text), ["Prochain : A", "C'est parti"])
    }

    // MARK: - Sélection de voix (H/F + langue)

    func test_gender_female_selectsFemaleVoice() {
        let s = FakeSpeaker()
        makeGuide(gender: .female, language: "fr", speaker: s).announce("test")
        XCTAssertEqual(s.utterances.first?.voiceId, "fr-female")
    }

    func test_gender_male_selectsMaleVoice() {
        let s = FakeSpeaker()
        makeGuide(gender: .male, language: "fr", speaker: s).announce("test")
        XCTAssertEqual(s.utterances.first?.voiceId, "fr-male")
    }

    func test_language_mapsToVoice() {
        let s = FakeSpeaker()
        makeGuide(gender: .female, language: "en", speaker: s).announce("test")
        XCTAssertEqual(s.utterances.first?.voiceId, "en-female")
    }

    func test_genderChange_appliesToNextAnnounce() {
        let s = FakeSpeaker()
        let g = makeGuide(gender: .female, language: "fr", speaker: s)
        g.announce("un")
        g.gender = .male
        g.announce("deux")
        XCTAssertEqual(s.utterances.map(\.voiceId), ["fr-female", "fr-male"])
    }

    // MARK: - Override de prononciation

    func test_announce_appliesPronunciationOverride() {
        let s = FakeSpeaker()
        makeGuide(language: "fr", speaker: s).announce("Bloc VO2max")
        XCTAssertEqual(s.utterances.first?.text, "Bloc V O 2 max")
    }

    func test_announce_overrideZoneAndEndurance() {
        let s = FakeSpeaker()
        makeGuide(language: "fr", speaker: s).announce("Cours en Z2 puis EN2")
        XCTAssertEqual(s.utterances.first?.text, "Cours en zone 2 puis endurance 2")
    }

    // MARK: - Stop

    func test_stop_callsSpeaker() {
        let s = FakeSpeaker()
        let g = makeGuide(speaker: s)
        g.stop()
        XCTAssertTrue(s.stopped)
    }

    // MARK: - Overrides purs

    func test_overrides_caseInsensitiveAndEN() {
        XCTAssertEqual(VoicePronunciationOverrides.apply(to: "ftp test", language: "en"), "F T P test")
        XCTAssertEqual(VoicePronunciationOverrides.apply(to: "RPE 8", language: "en"), "perceived effort 8")
    }
}
