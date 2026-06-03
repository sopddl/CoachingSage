// Coaching/Session/SessionVoiceGuide.swift
// Story 3.35 (FOCUS Audio) — couche voix : lit les phrases d'étape via
// `AVSpeechSynthesizer`, en faisant du ducking de l'audio tiers (la musique du
// user baisse pendant la prise de parole puis remonte). On ne joue JAMAIS la
// musique (principe T3) — on glisse voix + bips par-dessus.
//
// Testable : la synthèse et le ducking sont derrière le protocole `SpeechSpeaking`
// (mocké dans les tests). La sélection de voix (langue + homme/femme) passe par
// un `voiceProvider` injectable. La logique d'annonce (toggle, overrides) est pure.
import Foundation
import AVFoundation

enum SessionVoiceGender: String, CaseIterable, Equatable {
    case female
    case male
}

/// Abstraction de la synthèse vocale (mockée en test).
@MainActor
protocol SpeechSpeaking: AnyObject {
    func speak(_ text: String, voiceIdentifier: String?)
    func stopSpeaking()
}

@MainActor
final class SessionVoiceGuide {
    var enabled: Bool
    var gender: SessionVoiceGender
    /// Code langue courant ("fr"/"en"…) pour overrides + sélection de voix.
    var language: String

    private let speaker: SpeechSpeaking
    /// Renvoie l'identifiant de voix `AVSpeechSynthesisVoice` pour (genre, langue),
    /// ou nil (la synthèse choisira la voix par défaut de la langue courante).
    private let voiceProvider: (SessionVoiceGender, String) -> String?

    init(
        enabled: Bool,
        gender: SessionVoiceGender,
        language: String,
        speaker: SpeechSpeaking,
        voiceProvider: @escaping (SessionVoiceGender, String) -> String?
    ) {
        self.enabled = enabled
        self.gender = gender
        self.language = language
        self.speaker = speaker
        self.voiceProvider = voiceProvider
    }

    /// Annonce une phrase : applique les overrides de prononciation puis parle —
    /// seulement si la voix est activée. No-op si OFF ou phrase vide (mode 3.34
    /// bips seuls).
    func announce(_ phrase: String) {
        let trimmed = phrase.trimmingCharacters(in: .whitespacesAndNewlines)
        guard enabled, !trimmed.isEmpty else { return }
        let spoken = VoicePronunciationOverrides.apply(to: trimmed, language: language)
        speaker.speak(spoken, voiceIdentifier: voiceProvider(gender, language))
    }

    func stop() {
        speaker.stopSpeaking()
    }
}

// MARK: - Implémentation réelle (AVSpeechSynthesizer + ducking)

/// Speaker de production. Duck l'audio tiers le temps de la phrase puis le
/// restaure (`AVAudioSession.setActive(false, .notifyOthersOnDeactivation)`).
/// Réutilise la session audio partagée configurée par `SessionAudioCues`.
@MainActor
final class AVSpeechSpeaker: NSObject, SpeechSpeaking, AVSpeechSynthesizerDelegate {
    private let synthesizer = AVSpeechSynthesizer()
    private let audioCues: SessionAudioCues

    init(audioCues: SessionAudioCues) {
        self.audioCues = audioCues
        super.init()
        synthesizer.delegate = self
    }

    func speak(_ text: String, voiceIdentifier: String?) {
        // Duck l'audio tiers avant de parler.
        audioCues.activate(duckOthers: true)
        let utterance = AVSpeechUtterance(string: text)
        if let voiceIdentifier, let voice = AVSpeechSynthesisVoice(identifier: voiceIdentifier) {
            utterance.voice = voice
        }
        synthesizer.speak(utterance)
    }

    func stopSpeaking() {
        synthesizer.stopSpeaking(at: .immediate)
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        // Restaure le son tiers une fois la phrase finie.
        Task { @MainActor in audioCues.deactivate() }
    }

    /// Choisit l'identifiant de voix pour (genre, langue). Préfère une voix
    /// Enhanced/Premium si dispo, filtre par genre quand l'info existe.
    static func voiceIdentifier(for gender: SessionVoiceGender, language: String) -> String? {
        let langPrefix = String(language.prefix(2)).lowercased()
        let candidates = AVSpeechSynthesisVoice.speechVoices().filter {
            $0.language.lowercased().hasPrefix(langPrefix)
        }
        let targetGender: AVSpeechSynthesisVoiceGender = gender == .male ? .male : .female
        let byGender = candidates.filter { $0.gender == targetGender }
        let pool = byGender.isEmpty ? candidates : byGender
        // Préférer une qualité supérieure si disponible.
        let best = pool.max { lhs, rhs in lhs.quality.rawValue < rhs.quality.rawValue }
        return best?.identifier
    }
}
